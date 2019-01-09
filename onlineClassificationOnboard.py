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
    def __init__(self, ip_add, port, buffer_size, buffer_obj):
        threading.Thread.__init__(self)
        self.ip_add = ip_add
        self.port = port

        self.buffer_size = buffer_size
        self.socket_obj = None
        self.buffer_obj = buffer_obj

        self.__connected = False

    def run(self):  # for thread running
        self.connect()
        while True:
            self.read()

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

    def read(self):  # read data from port
        global ring_buffer
        # if not self.buffer_obj.isSet():  # wait until demultiplexing finishes
        num_bytes_recorded = 0
        data_buffer_all = []
        while num_bytes_recorded < self.buffer_size:
            data_buffer_part = self.socket_obj.recv(self.buffer_size - num_bytes_recorded)
            # data_buffer_part = self.socket_obj.recv(min(self.buffer_size - num_bytes_recorded, 2048))
            if data_buffer_part == '':
                raise RuntimeError("socket connection broken")

            data_buffer_part = np.frombuffer(data_buffer_part, dtype=np.uint8)
            # data_buffer_part = np.array([ord(x) for x in data_buffer_part], dtype=np.uint8)

            data_buffer_all = np.append(data_buffer_all, data_buffer_part)
            # data_buffer_all = np.append(data_buffer_all, data_buffer_part)
            num_bytes_recorded = num_bytes_recorded + len(data_buffer_part)

        self.buffer_obj.acquire()  # lock the mutex ring buffer
        # print("lock in reading...")
        for x in data_buffer_all:
            ring_buffer.append(x)
        self.buffer_obj.release()  # release the mutex ring buffer
        # print("release in reading...")

        # self.buffer_obj.set()  # stop it temporarily while waiting for demultiplexing process grabs the buffer
        # print("In reading, threading event is %s" % self.buffer_obj.isSet())

        # return ''.join(data_buffer_all)


class Processing(threading.Thread):
    def __init__(self, hp_thresh, lp_thresh, notch_thresh, buffer_obj):
        threading.Thread.__init__(self)
        # Filtering.__init__(self, hp_thresh, lp_thresh, notch_thresh)
        self.buffer_obj = buffer_obj

        self.data_orig = []
        self.data_channel = []

        self.__flag_start_bit = 165
        self.__flag_end_bit = 90
        self.__sample_len = 24
        self.__process_flag = False

        now = datetime.datetime.now()
        self.__saving_dir = "%d%02d%02d" % (now.year, now.month, now.day)
        self.__saving_filename = "data%s%02d%02d%02d%02d" % (self.__saving_dir, now.hour, now.minute, now.second, now.microsecond)
        self.__saving_full_filename = os.path.join(self.__saving_dir, self.__saving_filename) + ".csv"

        self.__create_saving_dir()  # create saving directory, skip if the file exists
        self.__saving_file_obj = open(self.__saving_full_filename, "a")

    def run(self):  # for thread running
        global ring_buffer
        while True:
            self.get_buffer()
            if self.__process_flag:
                self.demultiplex()  # demultiplex and get the channel data
                # Processing.get_data_channel(data_obj)
                self.save()

    def get_buffer(self):
        self.buffer_obj.acquire()  # lock the mutex ring buffer
        # print("lock in grabbing...")
        global ring_buffer
        # data_orig = np.array(ring_buffer)
        # ring_buffer = RingBuffer(capacity=40980, dtype=np.uint8)
        if len(ring_buffer) > 0:
            # print("ring buffer size > 0...")
            # print(len(ring_buffer))
            self.data_orig = np.array([ring_buffer.popleft() for x in range(len(ring_buffer))])
            self.__process_flag = True
            # print(len(ring_buffer))
        # else:
            # print("ring buffer size == 0...")
        self.buffer_obj.release()  # release the mutex ring buffer
        # print("release in grabbing...")

    def demultiplex(self):  # obtain complete samples and form a matrix ( data_channel )
        loc_start_orig = np.argwhere(self.data_orig == self.__flag_start_bit)
        # loc_end_orig = np.argwhere(self.data_orig == self.__flag_end_bit)

        loc_start = [x[0] for x in loc_start_orig
                     if x+self.__sample_len <= len(self.data_orig)
                     and self.data_orig[x+self.__sample_len] == self.data_orig[x-1]
                     and self.data_orig[x-1] == self.__flag_end_bit]

        # loc_start = [x[0] for x in loc_start_orig
        #              if loc_end_orig[np.argmax(loc_end_orig > x)] - x == self.__sample_len]

        data_all = [self.data_orig[x:x + self.__sample_len+1] for x in loc_start]
        data_all = np.vstack(data_all)  # stack the arrays into one column

        self.data_channel = data_all[:, 1:self.__sample_len]
        # self.data_channel = data_all[:, 1:self.__sample_len-1]

    def get_data_channel(self):
        self.data_channel = np.ndarray(shape=(len(self.data_channel), 5), dtype='>u2',
                                       buffer=np.array(self.data_channel, dtype=np.uint8).tobytes)

    def save(self):  # save the data
        # np.savetxt(self.__saving_file_obj, self.data_orig, fmt="%d", delimiter=",")
        np.savetxt(self.__saving_file_obj, self.data_channel, fmt="%d", delimiter=",")
        # print("Saved file %s ..." % self.__saving_full_filename)

    def __create_saving_dir(self):
        if not os.path.exists(self.__saving_dir):
            os.makedirs(self.__saving_dir)


IP_ADD = "127.0.0.1"
PORT = 8888
BUFFER_SIZE = 25 * 65  # about 50 ms

HP_THRESH = 50
LP_THRESH = 3500
NOTCH_THRESH = 50

if __name__ == "__main__":
    buffer_obj = threading.Lock()
    ring_buffer = RingBuffer(capacity=40980, dtype=np.uint8)  # global variable

    # setup and connect ot port
    tcp_ip_obj = TcpIp(IP_ADD, PORT, BUFFER_SIZE, buffer_obj)  # create port object
    data_obj = Processing(HP_THRESH, LP_THRESH, NOTCH_THRESH, buffer_obj)  # create data class

    tcp_ip_obj.start()
    data_obj.start()

    tcp_ip_obj.join()
    data_obj.join()

    # print("Finished...")
