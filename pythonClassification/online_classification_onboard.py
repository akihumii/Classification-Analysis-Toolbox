import threading
import globals
import RPi.GPIO as GPIO
from time import sleep
from tcpip import TcpIp
from demultiplex import Demultiplex
from read_n_demultiplex import ReadNDemultiplex
from process_classification import ProcessClassification
from config_GPIO import ConfigGPIO


IP_SYLPH = "127.0.0.1"
IP_ODIN = "192.168.4.1"
PORT_SYLPH = 8888
PORT_ODIN = 30000
BUFFER_SIZE = 25 * 65  # about 50 ms
RINGBUFFER_SIZE = 40960
CHANNEL_LEN = 10
CHANNEL_DECODE = [4, 5, 6, 7]
PIN_LED = [[18, 4],
           [17, 27],
           [22, 5],
           [6, 13]]
PIN_OFF = 24
METHOD = 'GPIO'  # METHOD for output display

WINDOW_CLASS = 0.2  # second
WINDOW_OVERLAP = 0.05  # second
SAMPLING_FREQ = 1250  # sample/second

HP_THRESH = 0
LP_THRESH = 0
NOTCH_THRESH = 50

if __name__ == "__main__":
    process_obj = ConfigGPIO(PIN_OFF, 'in')
    process_obj.setup_GPIO()

    count = 1
    count2 = 1
    while True:
        if process_obj.input_GPIO():
                globals.initialize()  # initialize global variable ring data

                ring_lock = threading.Lock()
                ring_event = threading.Event()
                ring_event.set()

                tcp_ip_sylph = TcpIp(IP_SYLPH, PORT_SYLPH, BUFFER_SIZE)  # create sylph socket object
                tcp_ip_odin = TcpIp(IP_ODIN, PORT_ODIN, BUFFER_SIZE)  # create odin socket object

                data_obj = Demultiplex(RINGBUFFER_SIZE, CHANNEL_LEN, SAMPLING_FREQ, HP_THRESH, LP_THRESH, NOTCH_THRESH)  # create data class

                thread_read_and_demultiplex = ReadNDemultiplex(tcp_ip_odin, tcp_ip_sylph, data_obj, PIN_OFF, ring_lock, ring_event)  # thread 1: reading buffer and demultiplex
                thread_process_classification = ProcessClassification(METHOD, PIN_LED, CHANNEL_LEN, WINDOW_CLASS, WINDOW_OVERLAP, SAMPLING_FREQ, ring_lock, ring_event)  # thread 2: filter, extract features, classify

                thread_read_and_demultiplex.start()  # start thread 1
                thread_process_classification.start()  # start thread 2

                # print('join threads...')
                while process_obj.input_GPIO():
                    print('Sub main waiting for connection: %d...' % count2)
                    count2 += 1
                    sleep(3)

                ring_event.clear()

                thread_read_and_demultiplex.join()  # terminate thread 1
                thread_process_classification.join()  # terminate thread 2

                print('ring event cleared...')
        else:
            print('Main waiting for connection: %d...' % count)
            count += 1
            sleep(3)

    # process_obj.stop_GPIO()  # stop GPIO and serial output
    # print('cleared GPIO...')
    # sleep(3)

    # print("Finished...")
