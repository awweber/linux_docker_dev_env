GCC=gcc
CFLAGS=-Wall -Wextra -pthread -std=c2x
TARGET=realtime_task
SOURCES=realtime_task.c

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(GCC) $(CFLAGS) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)