all: bootloader

CFLAGS = -g -Wall -O2

bootloader: bootloader.c
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -rf bootloader bootloader.o
