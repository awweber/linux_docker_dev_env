/* Aufgabe: Entwicklung eines Kernel-Moduls zur Verwaltung von GPIO-Pins
Entwickele ein Kernel-Modul, das die Steuerung von GPIO-Pins (General Purpose Input/Output) ermöglicht. 
Dein Modul soll folgende Funktionen erfüllen:

1. Initialisieren und Registrieren des GPIO-Moduls.
2. Setzen eines GPIO-Pins auf HIGH oder LOW.
3. Lesen des Status eines GPIO-Pins.
4. Laden und Entladen des Moduls als Kernel-Modul.

Anforderung:
1. Vervollständige den bereitgestellten Code für das GPIO-Kernel-Modul (gpio_module.c), indem du die Funktionen 
    zur Initialisierung, Registrierung, Lese- und Schreiboperationen sowie zum Laden und Entladen des Moduls 
    implementierst.
2. Stelle sicher, dass das Modul korrekt kompiliert und als Kernel-Modul geladen werden kann.
3. Teste das Modul, indem du es lädst, den GPIO-Pin auf HIGH und LOW setzt und den Status des Pins liest.
4. Entlade das Modul nach dem Testen.*/

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h>
#include <linux/fs.h>
#include <linux/uaccess.h>

#define DEVICE_NAME "gpio_device"
#define GPIO_PIN 17

static int major;
static int gpio_value = 0;

static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release
};
static int __init gpio_init(void) {
    int result;
    // Register the character device
    major = register_chrdev(0, DEVICE_NAME, &fops);
    if (major < 0) {
        printk(KERN_ALERT "Registering char device failed with %d\n", major);
        return major;
    }
    // Request the GPIO pin
    result = gpio_request(GPIO_PIN, "sysfs");
    if (result) {
        printk(KERN_ALERT "GPIO request failed with %d\n", result);
        unregister_chrdev(major, DEVICE_NAME);
        return result;
    }
    // Set the GPIO direction
    result = gpio_direction_output(GPIO_PIN, gpio_value);
    if (result) {
        printk(KERN_ALERT "GPIO direction set failed with %d\n", result);
        gpio_free(GPIO_PIN);
        unregister_chrdev(major, DEVICE_NAME);
        return result;
    }
    printk(KERN_INFO "GPIO module loaded with device major number %d\n", major);
    return 0;
}
static void __exit gpio_exit(void) {
    gpio_set_value(GPIO_PIN, 0);
    gpio_free(GPIO_PIN);
    unregister_chrdev(major, DEVICE_NAME);
    printk(KERN_INFO "GPIO module unloaded\n");
}
static int device_open(struct inode *inode, struct file *file) {
    try_module_get(THIS_MODULE);
    return 0;
}
static int device_release(struct inode *inode, struct file *file) {
    module_put(THIS_MODULE);
    return 0;
}
static ssize_t device_read(struct file *filp, char *buffer, size_t length, loff_t * offset) {
    int bytes_read = 0;
    char gpio_str[3];
    // Read the GPIO value
    gpio_value = gpio_get_value(GPIO_PIN);
    sprintf(gpio_str, "%d\n", gpio_value);
    while (length && gpio_str[bytes_read]) {
        put_user(gpio_str[bytes_read++], buffer++);
        length--;
    }
    return bytes_read;
}
static ssize_t device_write(struct file *filp, const char *buffer, size_t length, loff_t * off) {
    char cmd;
    // Get the command from the user
    get_user(cmd, buffer);
    // Set the GPIO value based on the command
    if (cmd == '1') {
        gpio_set_value(GPIO_PIN, 1);
        gpio_value = 1;
    } else if (cmd == '0') {
        gpio_set_value(GPIO_PIN, 0);
        gpio_value = 0;
    } else {
        printk(KERN_ALERT "Invalid command: %c\n", cmd);
        return -EINVAL;
    }
    return length;
}
module_init(gpio_init);
module_exit(gpio_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("A simple GPIO device");
MODULE_AUTHOR("Ihr Name");
