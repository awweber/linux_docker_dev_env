GCC = gcc
CFLAGS = -Wall -Wextra
TARGET = filesystem_management
SRC = filesystem_management.c

all: $(TARGET)
#  Dateioperationen und der Implementierung eines einfachen Journaling-Mechanismus, um die Datenintegrität zu gewährleisten.
$(TARGET): $(SRC)
	$(GCC) $(CFLAGS) -o $(TARGET) $(SRC)

clean:
	rm -f $(TARGET)