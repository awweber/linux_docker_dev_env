GCC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -lpthread

TARGET = dvfs
SOURCES = dvfs.c
OBJECTS = $(SOURCES:.c=.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(GCC) $(OBJECTS) -o $@ $(LDFLAGS)

clean:
	rm -f $(OBJECTS) $(TARGET)