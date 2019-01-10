from numpy_ringbuffer import RingBuffer
from scipy import signal
import threading
import os
import datetime
import socket
import numpy as np
from time import sleep


# class Parameters(object):
#     def __init__(self):
#         self.trained_mdl =
#
#
# class GetWindow(object):
#     def __init__(self):
#         self.window_size = 100
#         self.window_size_overlap = 50
#
#     def read_sample(self):
#         # self.data =
#
#


class Filtering:
    def __init__(self, hp_thresh, lp_thresh, notch_thresh):
        self.data_filtered = []

        self.high_pass_threshold = 1. / hp_thresh
        self.low_pass_threshold = 1. / lp_thresh
        self.notch_freq = notch_thresh

        self.filter_obj = None
        self.filter_low_pass = None
        self.filter_z = None  # initial condition of the filter
        self.z_low_pass = None
        self.__num_taps = 150

        self.set_filter()

    def set_filter(self):
        self.filter_obj = signal.firwin(self.__num_taps,
                                        [self.low_pass_threshold, self.high_pass_threshold], pass_zero=False)
        self.filter_z = signal.lfilter_zi(self.filter_obj, 1)

    def filter(self, data_buffer_all):
        self.data_filtered = [signal.lfilter(self.filter_obj, 1, [x], zi=self.filter_z) for x in data_buffer_all]
        # self.data_filtered = signal.lfilter(self.filter_obj, 1, data_buffer_all, zi=self.filter_z)


class TcpIp(threading.Thread):
    def __init__(self, ip_add, port, buffer_size):
        threading.Thread.__init__(self)
        self.ip_add = ip_add
        self.port = port

        self.buffer_size = buffer_size
        self.socket_obj = None

        self.__connected = False

    def connect(self):  # connect to port
        self.socket_obj = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        count = 1
        while not self.__connected:
            try:
                self.socket_obj.connect((self.ip_add, self.port))
                self.__connected = True
            except socket.error:
                self.__connected = False
                print("Connection failed... reconnecting %d time..." % count)
                count += 1
                sleep(2)

        print("Successfully connected...")

    def read(self, buffer_leftover):  # read data from port
        num_bytes_recorded = 0
        buffer_read = np.array([], dtype=np.uint8)
        while num_bytes_recorded < self.buffer_size:
            buffer_part = self.socket_obj.recv(self.buffer_size - num_bytes_recorded)
            if buffer_part == '':
                raise RuntimeError("socket connection broken")

            buffer_read = np.append(buffer_read, np.frombuffer(buffer_part, dtype=np.uint8))

            num_bytes_recorded = num_bytes_recorded + len(buffer_part)

        return np.append(buffer_leftover, buffer_read)


class Processing(threading.Thread):
    def __init__(self, hp_thresh, lp_thresh, notch_thresh):
        threading.Thread.__init__(self)
        # Filtering.__init__(self, hp_thresh, lp_thresh, notch_thresh)
        self.data_orig = []
        self.data_processed = []
        self.buffer_process = []
        self.loc_start = []
        self.loc_start_orig = []

        self.__flag_start_bit = 165
        self.__flag_end_bit = 90
        self.__flag_counter = [0, 255]
        self.__sample_len = 25
        self.__channel_len = 10
        self.__counter_len = 1

        now = datetime.datetime.now()
        self.__saving_dir = "%d%02d%02d" % (now.year, now.month, now.day)
        self.__saving_filename = "data%s%02d%02d%02d%02d" % (self.__saving_dir, now.hour, now.minute, now.second, now.microsecond)
        self.__saving_full_filename = os.path.join(self.__saving_dir, self.__saving_filename) + ".csv"

        self.__create_saving_dir()  # create saving directory, skip if the file exists
        self.__saving_file_obj = open(self.__saving_full_filename, "a")

    def get_buffer(self, buffer_read):
        self.loc_start_orig = np.argwhere(np.array(buffer_read) == self.__flag_start_bit)

        self.loc_start = [x[0] for x in self.loc_start_orig
                          if x + self.__sample_len < len(buffer_read)
                          and buffer_read[x + self.__sample_len - 1] == self.__flag_end_bit
                          and np.isin(buffer_read[x+self.__sample_len-(self.__counter_len*2)-2], self.__flag_counter)]

        [self.buffer_process, buffer_leftover] = np.split(buffer_read, [self.loc_start[-1]+self.__sample_len-1])

        return buffer_leftover

    def demultiplex(self):  # obtain complete samples and form a matrix ( data_channel )
        data_all = [self.buffer_process[x:x + self.__sample_len-1] for x in self.loc_start]
        data_all = np.vstack(data_all)  # stack the arrays into one column

        self.data_processed = data_all[:, 1:self.__sample_len-1]

    def get_data_channel(self):
        len_data = len(self.data_processed)

        [data_channel, data_rest] = np.hsplit(self.data_processed, [self.__channel_len*2])
        [data_sync_pulse, data_counter] = np.hsplit(data_rest, [1])

        data_channel = np.roll(data_channel, 2)  # roll the data as the original matrix starts from channel 3

        # convert two bytes into one 16-bit integer
        data_channel = np.ndarray(shape=(len_data, self.__channel_len), dtype='>u2',
                                  buffer=np.array(data_channel, dtype=np.uint8))
        data_counter = np.ndarray(shape=(len_data, self.__counter_len), dtype='>u2',
                                  buffer=np.array(data_counter, dtype=np.uint8))

        self.data_processed = np.concatenate((data_channel, data_sync_pulse, data_counter), axis=1)

    def save(self, data):  # save the data
        np.savetxt(self.__saving_file_obj, data, fmt="%d", delimiter=",")

    def __create_saving_dir(self):
        if not os.path.exists(self.__saving_dir):
            os.makedirs(self.__saving_dir)


class ReadNDemultiplex(threading.Thread):
    def __init__(self, tcp_ip_obj, data_obj):
        threading.Thread.__init__(self)
        self.tcp_ip_obj = tcp_ip_obj
        self.data_obj = data_obj
        self.start()
        self.join()

    def run(self):
        self.tcp_ip_obj.connect()
        ring_buffer = []
        # ring_buffer = RingBuffer(capacity=40960, dtype=np.uint8)
        while True:
            ring_buffer = self.tcp_ip_obj.read(ring_buffer)
            ring_buffer = self.data_obj.get_buffer(ring_buffer)
            self.data_obj.demultiplex()  # demultiplex and get the channel data
            self.data_obj.get_data_channel()
            self.data_obj.save(data_obj.data_processed)


IP_ADD = "127.0.0.1"
PORT = 8888
BUFFER_SIZE = 25 * 65  # about 50 ms

HP_THRESH = 50
LP_THRESH = 3500
NOTCH_THRESH = 50

if __name__ == "__main__":
    buffer_obj = threading.Lock()
    buffer_leftover = []

    tcp_ip_obj = TcpIp(IP_ADD, PORT, BUFFER_SIZE)  # create port object
    data_obj = Processing(HP_THRESH, LP_THRESH, NOTCH_THRESH)  # create data class

    ReadNDemultiplex(tcp_ip_obj, data_obj)  # use one thread to do reading buffer and demultiplex

    # print("Finished...")
