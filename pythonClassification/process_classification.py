import multiprocessing as mp
import os
import numpy as np
import pickle
from time import sleep
# import globals
from saving import Saving
from classification_decision import ClassificationDecision
from features import Features
from numpy_ringbuffer import RingBuffer


class ProcessClassification(mp.Process, Saving, ClassificationDecision):
    def __init__(self, method, pin_led, channel_len, window_class, window_overlap, sampling_freq, ring_lock, ring_event, get_ring_event, ring_data):
        mp.Process.__init__(self)
        Saving.__init__(self)
        ClassificationDecision.__init__(self, method, pin_led, 'out')

        self.clf = None
        self.window_class = window_class  # seconds
        self.window_overlap = window_overlap  # seconds
        self.sampling_freq = sampling_freq
        self.counter = -1
        self.ring_lock = ring_lock
        self.ring_event = ring_event
        self.ring_data = ring_data
        self.get_ring_event = get_ring_event
        self.flag_channel_same_len = False

        self.__ring_channel_len = len(ring_data)
        self.__channel_len = channel_len
        self.__classify_flag = False

        self.data_raw = [RingBuffer(capacity=int(self.window_class * self.sampling_freq), dtype=np.float64)
                         for __ in range(self.__ring_channel_len)]
        self.data_buffer = [np.array([]) for __ in range(self.__ring_channel_len)]

        self.channel_decode = []

        self.prediction = 0

    def run(self):
        self.setup()  # setup GPIO/serial classification display output
        self.load_classifier()
        count = 1
        while True:
            # print("ring event status: %s" % self.ring_event.is_set())
            if not self.ring_event.is_set():
                print('pause processing...')
                sleep(2)
                break

            # print('in process_classification: %d' % count)
            #
            # count += 1

            # self.get_ring_data()
            #
            # print("length of data buffer: %d" % len(self.data_buffer[0]))
            #
            # if len(self.data_buffer[0]) > self.window_overlap * self.sampling_freq:
            #     self.fill_data_raw()

            # # print("checking if we can get ring data...")
            # if self.get_ring_event.isSet():
            #     # with self.ring_lock:
            #     # print("getting ring data...")
            #     # self.get_ring_data()
            #     print("after getting ring data: %d" % np.size(globals.ring_data[0]))
            #     print("clearing get_ring_event flag...")
            #     self.get_ring_event.clear()
            #     print("process_classificaiton after lock...")
                # self.get_ring_event.clear()

            # if self.__classify_flag:
            #     self.classify()
            #     self.save([np.array(self.data_raw[3])], "a")
                # self.save(np.vstack(np.array(self.data_raw)).transpose(), "a")

        self.stop()  # stop GPIO/serial classification display output

    def get_ring_data(self):
        # if len(globals.ring_data) > 0 and len(globals.ring_data[0]) >= (self.window_overlap * self.sampling_freq):
            # with self.ring_lock:

        for i in range(self.__ring_channel_len):
            # try:
            data_temp = self.ring_data[i].get_nowait()
            print("picking up data: %f " % data_temp)
            self.data_buffer[i] = np.append(self.data_buffer, data_temp)
            # except Queue.Empty:
            #     pass

            # self.data_raw[x].extend(np.array(globals.ring_data[x]))  # fetch the data from ring buffer

        # print('ring data size: %d...' % np.size(globals.ring_data[0]))

        # self.__clear_ring_data()  # clear the ring buffer

        # self.__classify_flag = True
        # else:
        # self.__classify_flag = False

    def fill_data_raw(self):
        for i in range(self.__ring_channel_len):
            print("filling data raw: %d" % i)
            print(self.data_buffer[i])
            self.data_raw[i].extend(np.array(self.data_buffer[i]))  # fetch the data from ring buffer

        print("clearing data buffer...")

        self.data_buffer = [np.array([]) for __ in range(self.__ring_channel_len)]  # clear data buffer

    def load_classifier(self):
        filename = sorted(x for x in os.listdir('classificationTmp') if x.startswith('classifier'))

        self.channel_decode = [x[x.find('Ch')+2] for x in filename]

        self.clf = [pickle.load(open(os.path.join('classificationTmp', x), 'rb')) for x in filename]

    def classify(self):  # feature extraction and classification
        for i, x in enumerate(self.channel_decode):
            feature_obj = Features(self.data_raw[int(x)-1], self.sampling_freq, [3, 7])
            features = feature_obj.extract_features()
            try:
                prediction = self.clf[i].predict([features]) - 1
                if prediction != (self.prediction >> i & 1):  # if prediction changes
                    self.prediction = self.output(i, prediction, self.prediction)
                    print('Prediction: %s' % format(self.prediction, 'b'))
            except ValueError:
                print('prediction failed...')

    def check_data_raw(self):
        check_len = [len(self.data_raw[x]) for x in range(10)]

        # flag is true when raw data has data, when all the ring buffers have same length of data and when
        # counter has increased
        if len(self.data_raw[0]) > 0 and \
                all(x == check_len[0] for x in check_len) and \
                self.counter != self.data_raw[-1][-1]:
            # print("running thread for process classification")
            self.counter = self.data_raw[-1][-1]
            self.flag_channel_same_len = True
            print(check_len)
        else:
            self.flag_channel_same_len = False

    def __clear_ring_data(self):
        for x in range(self.__ring_channel_len):
            globals.ring_data[x] = RingBuffer(capacity=globals.ring_data[x].maxlen, dtype=np.float)  # clear the ring buffer



