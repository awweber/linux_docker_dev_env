obj-m += simple_char_device.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

install:
	sudo insmod simple_char_device.ko
	sudo mknod /dev/simple_char_device c $(shell dmesg | grep "Simple Char Device: Registered with major number" | tail -1 | grep -o '[0-9]\+') 0
	sudo chmod 666 /dev/simple_char_device

uninstall:
	sudo rmmod simple_char_device
	sudo rm -f /dev/simple_char_device

test:
	@echo "Testing the simple char device driver..."
	@echo "Writing 'Hello World' to device..."
	@echo "Hello World" | sudo tee /dev/simple_char_device > /dev/null
	@echo "Reading from device:"
	@sudo cat /dev/simple_char_device
	@echo "Test completed!"

.PHONY: all clean install uninstall test