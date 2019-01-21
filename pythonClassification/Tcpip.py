import numpy as np
import socket
from time import sleep


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


