from scipy import signal


class Filtering:
    def __init__(self, hp_thresh, lp_thresh, notch_thresh):
        self.data_filtered = []

        self.high_pass_threshold = 1. / hp_thresh
        self.low_pass_threshold = 1. / lp_thresh
        self.notch_freq = notch_thresh

        self.filter_obj = None
        self.filter_low_pass = None
        self.filter_z = None  # initial condition of the filter
        self.z_low_pass = None
        self.__num_taps = 150

        self.set_filter()

    def set_filter(self):
        self.filter_obj = signal.firwin(self.__num_taps,
                                        [self.low_pass_threshold, self.high_pass_threshold], pass_zero=False)
        self.filter_z = signal.lfilter_zi(self.filter_obj, 1)

    def filter(self, data_buffer_all):
        self.data_filtered = [signal.lfilter(self.filter_obj, 1, [x], zi=self.filter_z) for x in data_buffer_all]
        # self.data_filtered = signal.lfilter(self.filter_obj, 1, data_buffer_all, zi=self.filter_z)


