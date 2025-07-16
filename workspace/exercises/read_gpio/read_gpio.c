#include <gpiod.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define GPIO_CHIP "/dev/gpiochip0"
#define GPIO_LINE 17 // BCM number, e.g., 17 for GPIO17

int main() {
    struct gpiod_chip *chip;
    struct gpiod_line *line;
    int value;

    chip = gpiod_chip_open(GPIO_CHIP);
    if (!chip) {
        perror("Open gpiochip failed");
        exit(EXIT_FAILURE);
    }

    line = gpiod_chip_get_line(chip, GPIO_LINE);
    if (!line) {
        perror("Get line failed");
        gpiod_chip_close(chip);
        exit(EXIT_FAILURE);
    }

    if (gpiod_line_request_input(line, "read_gpio") < 0) {
        perror("Request line as input failed");
        gpiod_chip_close(chip);
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < 10; ++i) {
        value = gpiod_line_get_value(line);
        if (value < 0) {
            perror("Read line value failed");
            gpiod_line_release(line);
            gpiod_chip_close(chip);
            exit(EXIT_FAILURE);
        }
        printf("GPIO Value: %d\n", value);
        usleep(500000); // 500ms
    }

    gpiod_line_release(line);
    gpiod_chip_close(chip);
    return 0;
}