import threading
from tcpip import TcpIp
from demultiplex import Demultiplex
from read_n_demultiplex import ReadNDemultiplex
from process_classification import ProcessClassification


IP_ADD = "127.0.0.1"
PORT = 8888
BUFFER_SIZE = 25 * 65  # about 50 ms
RINGBUFFER_SIZE = 40960
CHANNEL_LEN = 10
CHANNEL_DECODE = [4, 5, 6, 7]

WINDOW_CLASS = 0.2  # second
WINDOW_OVERLAP = 0.05  # second
SAMPLING_FREQ = 1250  # sample/second

HP_THRESH = 50
LP_THRESH = 3500
NOTCH_THRESH = 50

if __name__ == "__main__":
    ring_lock = threading.Lock()

    tcp_ip_obj = TcpIp(IP_ADD, PORT, BUFFER_SIZE)  # create port object
    data_obj = Demultiplex(RINGBUFFER_SIZE, CHANNEL_LEN, HP_THRESH, LP_THRESH, NOTCH_THRESH)  # create data class

    thread_read_and_demultiplex = ReadNDemultiplex(tcp_ip_obj, data_obj, ring_lock)  # thread 1: reading buffer and demultiplex
    thread_process_classification = ProcessClassification(CHANNEL_LEN, WINDOW_CLASS, WINDOW_OVERLAP, SAMPLING_FREQ, ring_lock)  # thread 2: filter, extract features, classify

    thread_read_and_demultiplex.start()  # start thread 1
    thread_process_classification.start()  # start thread 2

    thread_read_and_demultiplex.join()  # join thread 1
    thread_process_classification.join()  # join thread 2

    # print("Finished...")
