import multiprocessing
import os
import numpy as np
import pickle
import globals
from saving import Saving
from classification_decision import ClassificationDecision
from features import Features
from numpy_ringbuffer import RingBuffer


class ProcessClassification(multiprocessing.Process, Saving, ClassificationDecision):
    def __init__(self, method, pin_led, channel_len, window_class, window_overlap, sampling_freq, ring_lock, ring_event):
        multiprocessing.Process.__init__(self)
        Saving.__init__(self)
        ClassificationDecision.__init__(self, method, pin_led, 'out')

        self.clf = None
        self.window_class = window_class  # seconds
        self.window_overlap = window_overlap  # seconds
        self.sampling_freq = sampling_freq
        self.counter = -1
        self.ring_lock = ring_lock
        self.ring_event = ring_event
        self.flag_channel_same_len = False

        self.__ring_channel_len = len(globals.ring_data)
        self.__channel_len = channel_len
        self.__classify_flag = False

        self.data_raw = [RingBuffer(capacity=int(self.window_class * self.sampling_freq), dtype=np.float64)
                         for __ in range(self.__ring_channel_len)]

        self.channel_decode = []

        self.prediction = 0

    def run(self):
        self.setup()  # setup GPIO/serial classification display output
        self.load_classifier()
        while True:
            if not self.ring_event.is_set():
                print('pause processing...')
                break

            self.get_ring_data()

            if self.__classify_flag:
                self.classify()
                # self.save([np.array(self.data_raw[3])], "a")
                # self.save(np.vstack(np.array(self.data_raw)).transpose(), "a")

        self.stop()  # stop GPIO/serial classification display output

    def get_ring_data(self):
        # print('ring data in process classification: %d' % len(globals.ring_data[0]))

        if len(globals.ring_data) > 0 and len(globals.ring_data[0]) >= (self.window_overlap * self.sampling_freq):
            with self.ring_lock:
                for x in range(self.__ring_channel_len):
                    self.data_raw[x].extend(np.array(globals.ring_data[x]))  # fetch the data from ring buffer

                self.__clear_ring_data()  # clear the ring buffer

            self.__classify_flag = True
        else:
            self.__classify_flag = False

    def load_classifier(self):
        filename = sorted(x for x in os.listdir('classificationTmp') if x.startswith('classifier'))

        self.channel_decode = [x[x.find('Ch')+2] for x in filename]

        self.clf = [pickle.load(open(os.path.join('classificationTmp', x), 'rb')) for x in filename]

    def classify(self):
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



