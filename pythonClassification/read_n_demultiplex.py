import threading
import numpy as np
from saving import Saving
from classification_decision import ClassificationDecision
from time import sleep


class ReadNDemultiplex(ClassificationDecision, Saving):
    def __init__(self, tcpip_odin, tcp_ip_sylph, data_obj, pin_off, ring_lock, ring_event, get_ring_event, WINDOW_OVERLAP):
        # threading.Thread.__init__(self, target=ReadNDemultiplex)
        Saving.__init__(self)
        self.tcp_ip_sylph = tcp_ip_sylph
        self.tcp_ip_odin = tcpip_odin
        self.data_obj = data_obj
        self.pin_off = pin_off
        self.ring_lock = ring_lock
        self.ring_event = ring_event
        self.get_ring_event = get_ring_event
        self.buffer_read = []
        self.buffer_leftover = []
        self.window_overlap = WINDOW_OVERLAP

        self.connected_flag = False
        self.empty_buffer_flag = True

    def run(self):
            buffer_leftover = []
            # print('on...')

            # print('in read_n_demultiplex: %d' % count)
            # count += 1
            # sleep(1)

            # while True:
            # if not self.ring_event.isSet():
            #     print('stop processing...')
            #     break

            if not self.connected_flag:
                self.connected_flag = self.tcp_ip_sylph.connect()
                self.connected_flag = self.tcp_ip_odin.connect()

            if self.connected_flag:
                # print("read buffer...")
                self.buffer_read = self.tcp_ip_sylph.read(self.buffer_leftover)

                # print("get buffer...")
                self.buffer_leftover, self.empty_buffer_flag = self.data_obj.get_buffer(self.buffer_read)

                if not self.empty_buffer_flag:
                    # print("get channel data...")
                    self.data_obj.get_data_channel()  # demultiplex and get the channel data

                    # print("save data...")
                    self.save(self.data_obj.data_processed, "a")
                    print('%d %d' % (np.size(self.data_obj.data_processed), self.data_obj.data_processed[-1, -1]))

                # self.data_obj.fill_ring_data(self.ring_lock, self.get_ring_event, self.window_overlap)  # fill the ring buffer

            # self.tcp_ip_odin.write_disconnect()  # write 16 char to odin socket
            # self.tcp_ip_sylph.write_disconnect()
            # self.tcp_ip_odin.close()
            # self.tcp_ip_sylph.close()



