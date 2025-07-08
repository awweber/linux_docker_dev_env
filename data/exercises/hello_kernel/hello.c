#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/moduleparam.h>

static int myparam = 0;
module_param(myparam, int, 0);
MODULE_PARM_DESC(myparam, "Ein Integer-Parameter für das Modul");

static int __init hello_init(void) {
    printk(KERN_INFO "Hello, Kernel! Parameter myparam = %d\n", myparam);
    return 0;
}

static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye, Kernel! Parameter myparam war = %d\n", myparam);
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Alexander");
MODULE_DESCRIPTION("A simple Linux kernel module with a counter.");
MODULE_VERSION("0.01");