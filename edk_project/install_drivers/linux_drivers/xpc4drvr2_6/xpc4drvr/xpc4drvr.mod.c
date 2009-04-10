#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
 .name = KBUILD_MODNAME,
 .init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
 .exit = cleanup_module,
#endif
 .arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__attribute_used__
__attribute__((section("__versions"))) = {
	{ 0xa024e4b1, "struct_module" },
	{ 0x852abecf, "__request_region" },
	{ 0xab807860, "kmalloc_caches" },
	{ 0x83e84bbe, "__mod_timer" },
	{ 0x7d11c268, "jiffies" },
	{ 0xcda10c1, "del_timer_sync" },
	{ 0xb407b205, "ioport_resource" },
	{ 0x1b7d4074, "printk" },
	{ 0x2f287f0d, "copy_to_user" },
	{ 0xa1c9f3d, "mod_timer" },
	{ 0xfb306753, "kmem_cache_alloc" },
	{ 0xefbdf052, "register_chrdev" },
	{ 0xef79ac56, "__release_region" },
	{ 0x679a54f2, "init_timer" },
	{ 0x37a0cba, "kfree" },
	{ 0x98adfde2, "request_module" },
	{ 0x9ef749e2, "unregister_chrdev" },
	{ 0xd6c963c, "copy_from_user" },
};

static const char __module_depends[]
__attribute_used__
__attribute__((section(".modinfo"))) =
"depends=";

