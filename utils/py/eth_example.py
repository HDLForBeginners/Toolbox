import tkinter as tk
import socket
import time
import threading

interface = "enp2s0"

my_ip = [10,0,0,10]
fpga_ip = [10,0,0,240]

my_mac = b"\xe8\x6a\x64\xe7\xe8\x29"
fpga_mac = b"\xe8\x6a\x64\xe7\xe8\x30"

send_string = "LEDs CHANGED!     "

class EthExampleApp:
    def __init__(self, root, interface, my_ip, fpga_ip, my_mac, fpga_mac, send_string):

        self.root = root

        self.running = True  # Control flag for the thread

        # Network details
        self.interface = interface
        self.my_ip = my_ip
        self.fpga_ip = fpga_ip
        self.my_mac = my_mac
        self.fpga_mac = fpga_mac
        self.send_string = send_string

        self.createSocket()
        self.createWindow()


        # Start the counter thread
        self.sw_thread = threading.Thread(target=self.updateSwitches)
        self.sw_thread.start()

        # Ensure proper shutdown
        root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def createSocket(self):
        """
        Creates the socket connection
        """
        # Bind to ethernet socket (Requires user rights or sudo)
        ETH_P_ALL=3
        self.s_inst=socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
        self.s_inst.bind((self.interface, 0))

    def createWindow(self):
        """
        Creates the tkinter window
        """

        root = self.root

        #Create TKinter window
        # Create the main application window
        # Create a Label widget to provide LED values
        self.instruction_label = tk.Label(root, text="LED value")
        self.instruction_label.pack(pady=5)  # Add some padding around the widget

        # Create an Entry widget to enter LED value desired
        self.entry_text = tk.StringVar()
        self.entry = tk.Entry(root, textvariable=self.entry_text)
        self.entry.pack(pady=10)  # Add some padding around the widget

        # Create a Button widget to trigger LED packet creation
        self.button = tk.Button(root, text="Set LED value", command=self.setLEDValue)
        self.button.pack(pady=10)

        # Create a Button widget to trigger LED packet creation
        self.button = tk.Button(root, text="Switches to LEDs", command=self.switchesToLeds)
        self.button.pack(pady=10)

        # Create a Label widget to display the LED value
        self.led_label = tk.Label(root, text="")
        self.led_label.pack(pady=10)

        # Create a Label widget to display the Switches label
        self.switches_label = tk.Label(root, text="")
        self.switches_label.pack(pady=10)

    def sendLEDpacket(self, value):


        # String to send over network


        # base packet
        packet = bytearray(b"\xe8\x6a\x64\xe7\xe8\x30\xec\x08\x6b\x0d\xfc\x31\x08\x00\x45\x00\x00\x41\x00\x00\x00\x00\x40\x11\x65\xb3\x0a\x00\x00\x0a\x0a\x00\x00\xf0\xff\xff\xff\xff\x00\x2d\x00\x00\x53\x57\x49\x54\x43\x48\x45\x53\x20\x43\x48\x41\x4e\x47\x45\x44\x21\x20\x4e\x45\x57\x20\x56\x41\x4c\x55\x45\x3a\x20\x30\x78\x00\x01\x38\x30\x0a\x0d")

        # Put IP values into packet
        packet[26:29] = self.my_ip
        packet[30:33] = self.fpga_ip

        # update packet
        packet[73] = int(value)//256
        packet[74] = int(value)%256

        # Put string into packet
        for index, letter in enumerate(self.send_string):
            packet[42+index] = ord(letter)


        self.s_inst.send(packet)

    def getSWValue(self):

        r=self.s_inst.recv(2000)
        # check if packet matches
        if r[0:6]==self.my_mac and r[6:12]==self.fpga_mac:
            return r[42:].decode("utf-8")

    def updateSwitches(self):
        while self.running:
            sw_value =  self.getSWValue()
            if sw_value is not None:
                self.sw_value = sw_value
                self.switches_label.config(text=f'Switches: {self.sw_value[-8:-1]}')


    # Function to get the content of the Entry widget and update the led_label
    def setLEDValue(self):
        led_value = int(self.entry.get())  # Retrieve the text from the Entry widget
        self.led_label.config(text=f'Leds: 0x{led_value:04x}')  # Update the led_label
        self.sendLEDpacket(led_value)

    # Function to get the content of the Entry widget and update the led_label
    def switchesToLeds(self):
        self.led_label.config(text=f'Leds: {self.sw_value[-8:-1]}')  # Update the led_label
        self.sendLEDpacket(int(self.sw_value[-6:-1], 16))
        self.entry_text.set(f'{int(self.sw_value[-6:-1], 16)}')

    def on_closing(self):
        # Stop the counter thread and close the window
        self.running = False
        self.sw_thread.join()  # Wait for the thread to finish
        self.root.destroy()

# Create the main application window
root = tk.Tk()

# Create an instance of the CounterApp class
app = EthExampleApp(root,interface,my_ip, fpga_ip, my_mac, fpga_mac, send_string)

# Run the Tkinter event loop
root.mainloop()
