GCC=gcc
CFLAGS=-Wall
SOURCES=controller.c
OBJECTS=$(SOURCES:.c=.o)
TARGET=controller

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(GCC) -o $@ $^

%.o: %.c
	$(GCC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)
