import threading
from classification_decision import ClassificationDecision


class ReadNDemultiplex(threading.Thread, ClassificationDecision):
    def __init__(self, tcpip_odin, tcp_ip_sylph, data_obj, pin_off, ring_lock, ring_event):
        threading.Thread.__init__(self, target=ReadNDemultiplex)
        self.tcp_ip_sylph = tcp_ip_sylph
        self.tcp_ip_odin = tcpip_odin
        self.data_obj = data_obj
        self.pin_off = pin_off
        self.ring_lock = ring_lock
        self.ring_event = ring_event

    def run(self):
            buffer_leftover = []
            try:
                self.ring_event.set()
                print('on...')
                count = 1
                while self.ring_event.isSet():
                    print('RND: %d ...' % count)
                    count += 1
                    self.tcp_ip_sylph.connect()
                    self.tcp_ip_odin.connect()

                    buffer_read = self.tcp_ip_sylph.read(buffer_leftover)
                    buffer_leftover = self.data_obj.get_buffer(buffer_read)
                    self.data_obj.get_data_channel()  # demultiplex and get the channel data
                    self.data_obj.save(self.data_obj.data_processed, "a")
                    self.data_obj.fill_ring_data(self.ring_lock)  # fill the ring buffer

                print('off...')
                print('closing port...')
                self.tcp_ip_odin.close()
                self.tcp_ip_sylph.close()
            except RuntimeError:  # if GPIO is just nice cleared off by thread 2
                pass



