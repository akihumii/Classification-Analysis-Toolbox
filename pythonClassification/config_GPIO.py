import RPi.GPIO as GPIO
import numpy as np


class ConfigGPIO:
    def __init__(self, pin, mode):
        self.pin = pin
        self.mode = mode

    def output_GPIO(self, data):
        for i in range(4):
            if data >> i & 1:
                for x in self.pin[i]:
                    GPIO.output(x, GPIO.HIGH)
            else:
                for x in self.pin[i]:
                    GPIO.output(x, GPIO.LOW)

    def input_GPIO(self):
        return GPIO.input(self.pin)

    def stop_GPIO(self):
        for x in np.reshape(self.pin, [np.size(self.pin)]):
            GPIO.cleanup(x)

    def setup_GPIO(self):
        GPIO.setmode(GPIO.BCM)  # Use "GPIO" pin numbering
    
        GPIO.setwarnings(False)  # suppress the warnings

        switcher_setup = {
            'out': self.__setup_out,
            'in': self.__setup_in
        }

        switcher_setup.get(self.mode)()
    
    def __setup_out(self):
        for x in np.reshape(self.pin, np.size(self.pin)):
            GPIO.setup(x, GPIO.OUT)

    def __setup_in(self):
        for x in np.reshape(self.pin, np.size(self.pin)):
            GPIO.setup(x, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
