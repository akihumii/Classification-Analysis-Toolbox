import threading
import os
import numpy as np
import pickle
import globals
from saving import Saving
from output import Output
from features import Features
from numpy_ringbuffer import RingBuffer


class ProcessClassification(threading.Thread, Saving, Output):
    def __init__(self, mode, channel_len, window_class, window_overlap, sampling_freq, ring_lock):
        threading.Thread.__init__(self)
        Saving.__init__(self)
        Output.__init__(self, mode)

        self.clf = None
        self.window_class = window_class  # seconds
        self.window_overlap = window_overlap  # seconds
        self.sampling_freq = sampling_freq
        self.counter = -1
        self.ring_lock = ring_lock
        self.flag_channel_same_len = False

        self.__ring_channel_len = len(globals.ring_data)
        self.__channel_len = channel_len

        self.data_raw = [RingBuffer(capacity=int(self.window_class * self.sampling_freq), dtype=np.float64)
                         for __ in range(self.__ring_channel_len)]

        self.channel_decode = []

        self.prediction = 0
        # self.prediction = [[] for __ in range(self.__channel_len)]

    def run(self):
        self.load_classifier()
        try:
            while True:
                self.get_ring_data()
                # self.check_data_raw()
                self.classify()
                self.save(np.vstack(np.array(self.data_raw)).transpose(), "a")
        finally:
            self.switchoff()

    def get_ring_data(self):
        while len(globals.ring_data[0]) <= (self.window_overlap * self.sampling_freq):
            continue

        # when ring data has enough sample
        with self.ring_lock:
            for x in range(self.__ring_channel_len):
                self.data_raw[x].extend(np.array(globals.ring_data[x]))  # fetch the data from ring buffer
                globals.ring_data[x] = RingBuffer(capacity=globals.ring_data[x].maxlen, dtype=np.float)  # clear the ring buffer

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
                    print('Prediction: %s' % self.prediction)
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


