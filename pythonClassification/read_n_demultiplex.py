import threading


class ReadNDemultiplex(threading.Thread):
    def __init__(self, tcp_ip_obj, data_obj, ring_lock):
        threading.Thread.__init__(self, target=ReadNDemultiplex)
        self.tcp_ip_obj = tcp_ip_obj
        self.data_obj = data_obj
        self.ring_lock = ring_lock

    def run(self):
        self.tcp_ip_obj.connect()
        buffer_leftover = []
        # ring_buffer = RingBuffer(capacity=40960, dtype=np.uint8)
        while True:
            buffer_read = self.tcp_ip_obj.read(buffer_leftover)
            buffer_leftover = self.data_obj.get_buffer(buffer_read)
            self.data_obj.get_data_channel()  # demultiplex and get the channel data
            self.data_obj.save(self.data_obj.data_processed, "a")
            self.data_obj.fill_ring_data(self.ring_lock)  # fill the ring buffer



