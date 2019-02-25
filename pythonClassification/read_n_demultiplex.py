import threading
from pathos import multiprocessing
from saving import Saving
from classification_decision import ClassificationDecision


class ReadNDemultiplex(ClassificationDecision, Saving):
    def __init__(self, tcpip_odin, tcp_ip_sylph, data_obj, pin_off, ring_lock, ring_event):
        Saving.__init__(self)
        self.tcp_ip_sylph = tcp_ip_sylph
        self.tcp_ip_odin = tcpip_odin
        self.data_obj = data_obj
        self.pin_off = pin_off
        self.ring_lock = ring_lock
        self.ring_event = ring_event
        self.buffer_leftover = []
        self.pool = multiprocessing.ProcessPool(2)

        self.connected_flag = False
        self.empty_buffer_flag = True

    def run(self):
        buffer_read = self.tcp_ip_sylph.read(self.buffer_leftover)

        # buffer_leftover, self.empty_buffer_flag = self.pool.map(self.data_obj.get_buffer, [buffer_read])
        buffer_leftover, self.empty_buffer_flag = self.data_obj.get_buffer(buffer_read)

        if not self.empty_buffer_flag:
            self.pool.map(self.data_obj.get_data_channel, [1])  # demultiplex and get the channel data

            print('%d' % self.data_obj.data_processed[-1, -1])
            # self.save(self.data_obj.data_processed, "a")

            # self.data_obj.fill_ring_data(self.ring_lock)  # fill the ring buffer




