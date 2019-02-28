import threading
from saving import Saving
from classification_decision import ClassificationDecision


class ReadNDemultiplex(ClassificationDecision, Saving):
    def __init__(self, tcp_ip_sylph, data_obj, pin_off, ring_lock):
        Saving.__init__(self)
        self.data_obj = data_obj
        self.pin_off = pin_off
        self.tcp_ip_sylph = tcp_ip_sylph
        self.ring_lock = ring_lock
        self.buffer_leftover = []

        self.empty_buffer_flag = True

    def run(self):
            buffer_read = self.tcp_ip_sylph.read(self.buffer_leftover)

            self.buffer_leftover, self.empty_buffer_flag = self.data_obj.get_buffer(buffer_read)

            if not self.empty_buffer_flag:
                self.data_obj.get_data_channel()  # demultiplex and get the channel data

                # print(self.data_obj.data_processed[-1, -1])

                self.save(self.data_obj.data_processed, "a")

                self.data_obj.fill_ring_data(self.ring_lock)  # fill the ring buffer




