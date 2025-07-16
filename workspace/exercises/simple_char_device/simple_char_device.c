/* Aufgabe 10.A.01: Entwicklung und Integration eines einfachen Zeichengerätetreibers
Entwickele und integriere einen einfachen Zeichengerätetreiber für ein virtuelles Gerät unter Linux. Dein Treiber soll die folgenden Funktionen erfüllen:

- Initialisieren und Registrieren des Zeichengeräts.
- Implementieren der Geräteoperationen (Lese- und Schreibfunktionen).
- Laden und Entladen des Treibers als Kernel-Modul.

Anforderung:
Vervollständige den bereitgestellten Code für den einfachen Zeichengerätetreiber (simple_char_device.c), indem du die Initialisierungs- und Aufräumfunktionen 
sowie die Geräteoperationen implementierst.
Stelle sicher, dass der Treiber korrekt kompiliert und als Kernel-Modul geladen werden kann.
Teste den Treiber, indem du ihn lädst, eine Datei schreibst, liest und anschließend den Treiber entlädst.
*/

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/mutex.h>

#define DEVICE_NAME "simple_char_device"
#define BUF_LEN 1024

static int major;
static char *device_buffer;
static int device_buffer_size = 0;
static DEFINE_MUTEX(device_mutex);

// Funktionsprototypen
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);

/* File-Operationsstruktur*/
static struct file_operations fops = {
    .owner = THIS_MODULE,
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release
};

/* Initialisierungsfunktion */
static int __init simple_char_init(void) {
    printk(KERN_INFO "Simple Char Device: Initializing...\n");
    
    /* Speicher für den Puffer allokieren */
    device_buffer = kmalloc(BUF_LEN, GFP_KERNEL);
    if (!device_buffer) {
        printk(KERN_ALERT "Simple Char Device: Failed to allocate memory\n");
        return -ENOMEM;
    }
    
    /* Puffer initialisieren */
    memset(device_buffer, 0, BUF_LEN);
    device_buffer_size = 0;
    
    /* Character Device registrieren */
    major = register_chrdev(0, DEVICE_NAME, &fops);
    if (major < 0) {
        printk(KERN_ALERT "Simple Char Device: Failed to register device with %d\n", major);
        kfree(device_buffer);
        return major;
    }
    
    printk(KERN_INFO "Simple Char Device: Registered with major number %d\n", major);
    printk(KERN_INFO "To create device file, run: mknod /dev/%s c %d 0\n", DEVICE_NAME, major);
    
    return 0;
}

/* Aufräumfunktion */
static void __exit simple_char_exit(void) {
    /* Character Device deregistrieren */
    unregister_chrdev(major, DEVICE_NAME);
    
    /* Speicher freigeben */
    if (device_buffer) {
        kfree(device_buffer);
        device_buffer = NULL;
    }
    
    printk(KERN_INFO "Simple Char Device: Unregistered and cleaned up\n");
}

/* Gerät öffnen */
static int device_open(struct inode *inode, struct file *file) {
    printk(KERN_INFO "Simple Char Device: Device opened\n");
    
    /* Referenzzähler erhöhen */
    try_module_get(THIS_MODULE);
    
    return 0;
}

/* Gerät schließen */
static int device_release(struct inode *inode, struct file *file) {
    printk(KERN_INFO "Simple Char Device: Device closed\n");
    
    /* Referenzzähler verringern */
    module_put(THIS_MODULE);
    
    return 0;
}

/* Vom Gerät lesen */
static ssize_t device_read(struct file *filp, char __user *buffer, size_t length, loff_t *offset) {
    int bytes_read = 0;
    
    /* Mutex für Thread-Sicherheit */
    if (mutex_lock_interruptible(&device_mutex)) {
        return -ERESTARTSYS;
    }
    
    /* Überprüfen, ob noch Daten zu lesen sind */
    if (*offset >= device_buffer_size) {
        mutex_unlock(&device_mutex);
        return 0; /* EOF */
    }
    
    /* Anzahl der zu lesenden Bytes berechnen */
    bytes_read = min(length, (size_t)(device_buffer_size - *offset));
    
    /* Daten in den Benutzerpuffer kopieren */
    if (copy_to_user(buffer, device_buffer + *offset, bytes_read)) {
        mutex_unlock(&device_mutex);
        return -EFAULT;
    }
    
    /* Offset aktualisieren */
    *offset += bytes_read;
    
    mutex_unlock(&device_mutex);
    
    printk(KERN_INFO "Simple Char Device: Read %d bytes\n", bytes_read);
    
    return bytes_read;
}

/* Ins Gerät schreiben */
static ssize_t device_write(struct file *filp, const char __user *buff, size_t len, loff_t *off) {
    int bytes_to_write;
    
    /* Mutex für Thread-Sicherheit */
    if (mutex_lock_interruptible(&device_mutex)) {
        return -ERESTARTSYS;
    }
    
    /* Anzahl der zu schreibenden Bytes berechnen */
    bytes_to_write = min(len, (size_t)(BUF_LEN - 1));
    
    /* Daten vom Benutzerpuffer kopieren */
    if (copy_from_user(device_buffer, buff, bytes_to_write)) {
        mutex_unlock(&device_mutex);
        return -EFAULT;
    }
    
    /* Null-Terminierung sicherstellen */
    device_buffer[bytes_to_write] = '\0';
    device_buffer_size = bytes_to_write;
    
    mutex_unlock(&device_mutex);
    
    printk(KERN_INFO "Simple Char Device: Written %d bytes\n", bytes_to_write);
    
    return bytes_to_write;
}

/* Modul-Makros */
module_init(simple_char_init);
module_exit(simple_char_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("A simple character device driver");
MODULE_AUTHOR("Linux Driver Developer");
MODULE_VERSION("1.0");