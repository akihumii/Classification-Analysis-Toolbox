import codecs
from scipy import signal, zeros, random
from subprocess import call
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

    def filter(self, data_orig):
        self.data_filtered = [signal.lfilter(self.filter_obj, 1, [x], zi=self.filter_z) for x in data_orig]
        # self.data_filtered = signal.lfilter(self.filter_obj, 1, data_orig, zi=self.filter_z)


class TcpIp:
    def __init__(self, ip_add, port, buffer_size):
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

    def read(self):  # read data from port
        data_buffer_all = []
        num_bytes_recorded = 0
        while num_bytes_recorded < self.buffer_size:
            data_buffer_part = self.socket_obj.recv(self.buffer_size - num_bytes_recorded)
            # data_buffer_part = self.socket_obj.recv(min(self.buffer_size - num_bytes_recorded, 2048))
            if data_buffer_part == '':
                raise RuntimeError("socket connection broken")

            data_buffer_part = np.frombuffer(data_buffer_part, dtype=np.uint8)
            # data_buffer_part = np.array([ord(x) for x in data_buffer_part], dtype=np.uint8)

            data_buffer_all = np.append(data_buffer_all, data_buffer_part)
            num_bytes_recorded = num_bytes_recorded + len(data_buffer_part)

        return data_buffer_all
        # return ''.join(data_buffer_all)


class Processing(Filtering):
    def __init__(self, hp_thresh, lp_thresh, notch_thresh):
        Filtering.__init__(self, hp_thresh, lp_thresh, notch_thresh)
        self.data_channel = []

        self.__flag_start_bit = 165
        self.__flag_end_bit = 90
        self.__sample_len = 24

        now = datetime.datetime.now()
        self.__saving_dir = "%d%02d%02d" % (now.year, now.month, now.day)
        self.__saving_filename = "data%s%02d%02d%02d%02d" % (self.__saving_dir, now.hour, now.minute, now.second, now.microsecond)
        self.__saving_full_filename = os.path.join(self.__saving_dir, self.__saving_filename) + ".csv"

        self.__create_saving_dir()  # create saving directory, skip if the file exists
        self.__saving_file_obj = open(self.__saving_full_filename, "a")

    def demultiplex(self, data_orig):  # obtain complete samples and form a matrix ( data_channel )
        loc_start_orig = np.argwhere(data_orig == self.__flag_start_bit)
        loc_end_orig = np.argwhere(data_orig == self.__flag_end_bit)

        loc_start = [x[0] for x in loc_start_orig
                     if loc_end_orig[np.argmax(loc_end_orig > x)] - x == self.__sample_len]

        data_all = [data_orig[x:x + self.__sample_len+1] for x in loc_start]
        data_all = np.vstack(data_all)  # stack the arrays into one column

        self.data_channel = data_all
        # self.data_channel = data_all[:, 1:self.__sample_len-1]

        return self.data_channel

    def get_data_channel(self):
        self.data_channel = np.ndarray(shape=(len(self.data_channel), 5), dtype='>u2',
                                       buffer=np.array(self.data_channel, dtype=np.uint8).tobytes)

    def save(self):  # save the data
        np.savetxt(self.__saving_file_obj, self.data_channel, fmt="%d", delimiter=",")
        # print("Saved file %s ..." % self.__saving_full_filename)

    def __create_saving_dir(self):
        if not os.path.exists(self.__saving_dir):
            os.makedirs(self.__saving_dir)


IP_ADD = "127.0.0.1"
PORT = 8888
BUFFER_SIZE = 25 * 130  # about 50 ms

HP_THRESH = 50
LP_THRESH = 3500
NOTCH_THRESH = 50

if __name__ == "__main__":
    # setup and connect ot port
    tcp_ip_obj = TcpIp(IP_ADD, PORT, BUFFER_SIZE)  # create port object
    tcp_ip_obj.connect()  # connect to port

    data_obj = Processing(HP_THRESH, LP_THRESH, NOTCH_THRESH)  # create data class

    count = 1
    while 1:
        # print("Loop %d:" % count)

        # read data
        data_orig = tcp_ip_obj.read()

        # demultiplex and get the channel data
        Processing.demultiplex(data_obj, data_orig)
        # Processing.get_data_channel(data_obj)
        Processing.save(data_obj)

        count += 1

    # print("Finished...")
