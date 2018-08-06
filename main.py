import time
from machine import Pin

spray_length = 3		# how long to spray in seconds
pump_length = 90		# how long to pump in seconds
spray_interval = 900	# 15 minutes - time between spraying
pump_interval = 32		# (900sec * 32 = 8h) nr of spray_interval's between pump runs

# suitable values for debugging
#spray_length = 1		# how long to spray in seconds
#pump_length = 5			# how long to pump in seconds
#spray_interval = 15		# 15 sec time between spraying
#pump_interval = 4		# (15 sec * 4 = 1min) nr of spray_interval's between pump runs


# Initalize pins
spray_pin = Pin(5, Pin.OUT)	# wemos D1
pump_pin = Pin(4, Pin.OUT)	# wemos D2
spray_pin.on()		# relayboard is inverted, on = off
pump_pin.on()

def spray(seconds):
	print("spray start")
	spray_pin.off()
	time.sleep(seconds)
	spray_pin.on()
	print("spray stop")

def pump(seconds):
	print("pump start")
	pump_pin.off()
	time.sleep(seconds)
	pump_pin.on()
	print("pump stop")

# First pump run
print("First pump run for", pump_length, "seconds")
pump(pump_length)

# do the stuff
while True:
	for i in range(pump_interval):
		print("spray nr", i, ",spraying for", spray_length, "seconds")
		spray(spray_length)
		print("sleeping for", spray_interval - spray_length, "seconds")
		time.sleep(spray_interval - spray_length)
		if i == pump_interval - 1:
			print("Pumping when pump interval =", pump_interval, "for", pump_length, "seconds")
			pump(pump_length)
                        time.sleep(spray_interval - pump_lenght)
