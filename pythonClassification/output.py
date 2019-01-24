import RPi.GPIO as GPIO
import numpy as np
import serial


class Output:
    def __init__(self, mode):
        self.mode = mode
        self.channel_index = 0
        self.state = False
        self.value = 0
        self.result = 0

        self.switcher_setup = {
            'GPIO': self.__setup_GPIO,
            'serial': self.__setup_serial
        }
        self.switcher_setup.get(self.mode)()

        self.switcher_output = {
            'GPIO': self.__output_GPIO,
            'serial': self.__output_serial
        }

    def output(self, channel_index, state, value):
        self.channel_index = channel_index
        self.state = state
        self.value = value

        self.switcher_output.get(self.mode)()  # switch to the function and then execute it

        return self.result

    def __output_GPIO(self):
        if self.state:
            for x in self.led_pin[self.channel_index]:
                GPIO.output(x, GPIO.HIGH)
        else:
            for x in self.led_pin[self.channel_index]:
                GPIO.output(x, GPIO.LOW)

    def __output_serial(self):
        print('creating output...')
        if self.state:
            self.result = self.set_bit(self.value, self.channel_index)
        else:
            self.result = self.clear_bit(self.value, self.channel_index)

        self.ser.write('%d\n' % self.result)
        print('Sent %d...' % self.result)

    def __setup_GPIO(self):
        print("setup GPIO...")
        self.led_pin = [[18, 4],
                        [17, 27],
                        [22, 5],
                        [6, 13]]

        GPIO.setmode(GPIO.BCM)  # Use "GPIO" pin numbering

        try:
            for x in np.reshape(self.led_pin, np.size(self.led_pin)):
                GPIO.setup(x, GPIO.OUT)
        except RuntimeWarning:
            pass

    def __setup_serial(self):
        print("setup serial...")
        try:
            self.ser = serial.Serial(
                port='/dev/ttyACM0',  # Replace ttyS0 with ttyAM0 for Pi1,Pi2,Pi0
                baudrate=19200,
                timeout=1
            )
        except serial.serialutil.SerialException:
            self.ser = serial.Serial(
                port='/dev/ttyACM1',  # Replace ttyS0 with ttyAM0 for Pi1,Pi2,Pi0
                baudrate=19200,
                timeout=1
            )

    def set_bit(self, value, index):
        return value | 1 << index

    def clear_bit(self, value, index):
        return value & ~(1 << index)

    def switchoff(self):
        GPIO.cleanup()


