import codecs
from subprocess import call
import os
import datetime
import csv
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
# class Filtering:
#     def __init__(self):
#         self.high_pass_threshold = 50
#         self.low_pass_threshold = 3500
#         self.notch_freq = 50


class TcpIp:
    def __init__(self):
        self.ip_add = ""
        self.port = ""
        self.buffer_size = 0
        self.socket_obj = None
        self.__connected = False

    def set(self, ip_add, port, buffer_size):  # setup port
        self.ip_add = ip_add
        self.port = port
        self.buffer_size = buffer_size

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
        chunks = []
        bytes_recd = 0
        while bytes_recd < self.buffer_size:
            chunk = self.socket_obj.recv(min(self.buffer_size - bytes_recd, 2048))
            if chunk == '':
                raise RuntimeError("socket connection broken")

            # for byteChar in chunk:
            #     chunks.append("%02X" % ord(byteChar))
            chunk = np.array([ord(x) for x in chunk])
            # chunk = ''.join(["%02X " % ord(x) for x in chunk]).strip()

            chunks = np.append(chunks, chunk)
            bytes_recd = bytes_recd + len(chunk)

        return chunks
        # return ''.join(chunks)


class Processing:
    def __init__(self):
        self.data_channel = []

        self.__flag_start_bit = 165
        self.__flag_end_bit = 90
        self.__sample_len = 24

        now = datetime.datetime.now()
        self.__saving_dir = "%d%02d%02d" % (now.year, now.month, now.day)
        self.__saving_filename = "data%s%02d%02d%02d" % (self.__saving_dir, now.minute, now.second, now.microsecond)
        self.__saving_full_filename = os.path.join(self.__saving_dir, self.__saving_filename) + ".csv"

        self.__create_saving_dir()  # create saving directory, skip if the file exists
        self.__saving_file_obj = open(self.__saving_full_filename, "a")

    def demultiplex(self, data_orig):  # obtain complete samples and form a matrix ( data_channel )
        loc_start_orig = np.argwhere(data_orig == self.__flag_start_bit)
        loc_end_orig = np.argwhere(data_orig == self.__flag_end_bit)
        # locs_start_orig = [i for i, x in enumerate(data_orig) if x == self.__flag_start]
        # locs_end_orig = [i for i, x in enumerate(data_orig) if x == self.__flag_end]

        loc_start = [x[0] for x in loc_start_orig if loc_end_orig[np.argmax(loc_end_orig > x)] - x == self.__sample_len]
        # loc_start = [x for i, x in enumerate(loc_start_orig) if loc_end_orig > loc_start_orig]

        data_all = [data_orig[x:x+self.__sample_len] for x in loc_start]
        data_all = np.vstack(data_all)  # stack the arrays into one column

        self.data_channel = data_all[:, 1:self.__sample_len-1]

        return self.data_channel

    def __create_saving_dir(self):
        if not os.path.exists(self.__saving_dir):
            os.makedirs(self.__saving_dir)

    def save(self):  # save the data
        np.savetxt(self.__saving_file_obj, self.data_channel, fmt="%d")
        # print("Saved file %s ..." % self.__saving_full_filename)


IP_ADD = "127.0.0.1"
PORT = 8888
BUFFER_SIZE = 25 * 66  # about 50 ms

if __name__ == "__main__":
    # setup and connect ot port
    tcp_ip_obj = TcpIp()
    tcp_ip_obj.set(IP_ADD, PORT, BUFFER_SIZE)
    tcp_ip_obj.connect()
    print("Connected...")

    data = Processing()
    print("Created data class...")

    count = 1
    while 1:
        print("Loop %d:" % count)

        # read data
        data_orig = tcp_ip_obj.read()
        # print("\ndata_orig: \n")
        # print(data_orig)
        #
        # print("\ntype of element in data_orig: \n")
        #
        # print("Finished reading data...")

        # demultiplex and get the channel data
        Processing.demultiplex(data, data_orig)
        Processing.save(data)
        # print(data_orig)

        count += 1
        # sleep(2)

    # print("Finished...")

