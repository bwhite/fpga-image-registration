/* 
 * Source file for WinDriver Linux.
 *
 * This file may be distributed only as part of the 
 * application you are distributing, and only if it 
 * significantly contributes to the functionality of your 
 * application. (see \windriver\docs\license.txt for details).
 *
 * Web site: http://www.jungo.com
 * Email:    support@jungo.com
 *
 * (C) Jungo 2003 - 2007
 */

#include "linux_common.h"
#if defined (LINUX_USB_SUPPORT)
#include <linux/usb.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#endif
#include "linux_wrappers.h"
#include "windrvr.h"
#define PRCHANDLE int
#include "wdusb_interface.h"

//definitions from wddebug.h
int __cdecl KDBG_func(DWORD dwLevel, DWORD dwSection, const char *format, ...);
#define KDBG KDBG_func

#if defined (LINUX_USB_SUPPORT)
#define MAX_PACKETS 900
#define SUCCESS_NO_NEW_URB -100 /* Arbitrary value */

#define spinlock_wait LINUX_spin_lock_irqsave
#define spinlock_release LINUX_spin_unlock_irqrestore
#define spinlock_init LINUX_spin_lock_init
#define spinlock_uninit LINUX_spin_lock_uninit

static void tc_destroy(void *os_trans_ctx);

struct usb_dev_info
{
    struct usb_device *udev; /* stored usb device pointer */
    struct usb_interface *interface; /* the interface for this device */
    int device_connected;
};

struct trans_ctx;
struct urb_ctx
{
    struct urb *urb;
    void *urb_buf;
    unsigned long urb_buf_size;
    struct trans_ctx *tc;
};

struct trans_ctx 
{
    struct urb_ctx *urbs;
    unsigned int num_urbs;
    unsigned int pending_urbs;
    pipe_t *pipe;
    struct usb_dev_info *dev;
    wait_queue_head_t usb_submit_sync_event;
    int is_finished;
    int status;
    int high_speed;
    trans_t *trans;
    unsigned long offset; /* offset from the page list beginning */
    void *page_list_h; 
    int timeout;
    int is_read;
    unsigned int options;
    unsigned long bytes_transferred;
    unsigned long expire;
    long len;
    unsigned char *setup_packet;
    os_spinlock_t spinlock;
    void (*urb_process_cb)(struct urb *urb);
};


#if defined(LINUX_26)
    #define FILL_BULK_URB usb_fill_bulk_urb
    #define FILL_INT_URB usb_fill_int_urb
    #define FILL_CONTROL_URB  usb_fill_control_urb
    #define USB_ISO_ASAP URB_ISO_ASAP
#else
    #define URB_ASYNC_UNLINK USB_ASYNC_UNLINK
#endif

#if defined(LINUX_26)
    #define DESC(x) (&((x).desc))
#else
    #define DESC(x) (&x)
#endif

static int issue_new_transfer(struct trans_ctx *tc);
static int urb_build(struct urb *urb, struct usb_dev_info *dev, pipe_t *pipe,
    DWORD is_read, void *buf, DWORD bytes, BYTE *setup_packet, 
    BOOL is_high_speed);
static int urb_issue(struct urb_ctx *uctx);

static void LINUX_urb_unlink(struct urb *urb)
{
#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,9)
    usb_unlink_urb(urb);
#else
    usb_kill_urb(urb);
#endif
}

static void set_pipe_info(WDU_PIPE_INFO *pipe_info,
    struct usb_endpoint_descriptor *endp)
{
    pipe_info->dwNumber = endp->bEndpointAddress;
    pipe_info->dwMaximumPacketSize = WDU_GET_MAX_PACKET_SIZE(endp->wMaxPacketSize);
    pipe_info->type = endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK;
    if (pipe_info->type == PIPE_TYPE_CONTROL)
        pipe_info->direction = WDU_DIR_IN_OUT;
    else
    {
        pipe_info->direction = endp->bEndpointAddress & USB_ENDPOINT_DIR_MASK ?
            WDU_DIR_IN : WDU_DIR_OUT;
    }
    pipe_info->dwInterval = endp->bInterval;
}

static void fill_alt_settings_data(WDU_ALTERNATE_SETTING *pAlternateSettings, 
    struct usb_interface *interface, int alt_index)
{
    WDU_ENDPOINT_DESCRIPTOR *pEndpointDescriptors;
    struct usb_endpoint_descriptor *ep_desc;
    struct usb_interface_descriptor *if_desc;
    int i;

    if_desc = DESC(interface->altsetting[alt_index]);

    for (i=0; i<if_desc->bNumEndpoints; i++)    
    {
        pEndpointDescriptors = &pAlternateSettings->pEndpointDescriptors[i];
        ep_desc = DESC(interface->altsetting[alt_index].endpoint[i]);
        memcpy(pEndpointDescriptors, ep_desc, sizeof(WDU_ENDPOINT_DESCRIPTOR));
        set_pipe_info(&pAlternateSettings->pPipes[i], ep_desc);
    }
    memcpy(&pAlternateSettings->Descriptor, if_desc, USB_DT_INTERFACE_SIZE);
}

static int calc_device_info_size(struct usb_device *udev)
{
    uint i, j, k;
    int count;

    count = sizeof(WDU_DEVICE);
    for (i=0; i<udev->descriptor.bNumConfigurations; i++)
    {
        struct usb_config_descriptor *conf_desc;
        conf_desc = DESC(udev->config[i]);
        count+=sizeof(WDU_CONFIGURATION);
        count+=sizeof(WDU_INTERFACE) * conf_desc->bNumInterfaces;

        // loop over all alternate settings
        for (j=0; j<conf_desc->bNumInterfaces; j++)
        {
            struct usb_interface *interface = 
#if !defined(LINUX_26)
                &
#endif
                udev->config[i].interface[j];
            for(k=0; k<interface->num_altsetting; k++)
            {
                u8 bNumEndpoints;
                bNumEndpoints = DESC(interface->altsetting[k])->bNumEndpoints;
                count+=sizeof(WDU_ALTERNATE_SETTING);
                count+=(sizeof(WDU_ENDPOINT_DESCRIPTOR)+sizeof(WDU_PIPE_INFO))*bNumEndpoints;
            }
        }
    }
    return count;
}
    
#if defined(LINUX_26)
static int usb_generic_probe(struct usb_interface *interface, 
    const struct usb_device_id *id)
#else
static void *usb_generic_probe(struct usb_device *udev, unsigned int ifnum, 
    const struct usb_device_id *id)
#endif
{
    struct usb_dev_info *dev;
    u32 config_index, interface_index;
    int ret = 0;
#if defined(LINUX_26)
    struct usb_device *udev = interface_to_usbdev(interface);
#else
    struct usb_interface *interface = &udev->actconfig->interface[ifnum];
#endif 

    dev = LINUX_kmalloc(sizeof(struct usb_dev_info), 
        in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
    if (dev == NULL) 
    {
        KDBG(D_ERROR, S_USB, "usb_generic_probe: Out of memory");
        ret = -ENOMEM;
        goto Exit;
    }

    config_index = DESC(udev->config[0])->bConfigurationValue;
    interface_index = DESC(interface->altsetting[0])->bInterfaceNumber;
    dev->udev = udev;
    dev->interface = interface;
    dev->device_connected = 1;

    ret = Usb_device_attach(dev, interface_index, config_index);
    if (ret)
    {
        LINUX_kfree(dev);
        dev = NULL;
    }
Exit:
#if defined(LINUX_26)
    usb_set_intfdata (interface, dev);
    return ret;
#else
    return dev;
#endif
}

#if defined(LINUX_26)
static void usb_generic_disconnect(struct usb_interface *interface)
#else
static void usb_generic_disconnect(struct usb_device *udev, void *ptr)
#endif
{
    struct usb_dev_info *dev;
#if defined(LINUX_26)
    dev = usb_get_intfdata (interface);
    usb_set_intfdata (interface, NULL);
#else
    dev = (struct usb_dev_info *)ptr;
#endif
    dev->device_connected = 0;
    Usb_device_detach(dev);
    LINUX_kfree(dev);
}

static DWORD map_error_status(int err)
{
    DWORD ret;
    if (!err)
        return WD_STATUS_SUCCESS;

    switch (err)
    {
    case -EPIPE: 
        ret = WD_USBD_STATUS_STALL_PID;
        break;
    case -EILSEQ:
        ret = WD_USBD_STATUS_CRC;
        break;
    case -EPROTO:
        ret = WD_USBD_STATUS_BTSTUFF;
        break;
    case -EOVERFLOW:
        ret = WD_USBD_STATUS_DATA_OVERRUN;
        break;
    case -EREMOTEIO:
        ret = WD_USBD_STATUS_DATA_UNDERRUN;
        break;
    case -ECOMM:
        ret = WD_USBD_STATUS_BUFFER_OVERRUN;
        break;
    case -ENOSR:
        ret = WD_USBD_STATUS_BUFFER_UNDERRUN; 
        break;
    case -ETIMEDOUT:
        ret = WD_TIME_OUT_EXPIRED;
        break;
    case -EINVAL:
        ret = WD_INVALID_PARAMETER; 
        break;
    case -ENOMEM:
        ret = WD_INSUFFICIENT_RESOURCES; 
        break;
    case -ENODEV:
        ret = WD_DEVICE_NOT_FOUND;
        break;
    case -ECONNABORTED:
    case -ECONNRESET:
    case -ENOENT:
        ret = WD_USBD_STATUS_CANCELED;
        break;
    case -EBUSY:
        ret = WD_USBD_STATUS_ERROR_BUSY;
        break;
    case -EAGAIN:
        ret = WD_TRY_AGAIN;
        break;
    case -ENXIO:
        ret = WD_USBD_STATUS_REQUEST_FAILED;
        break;
    case -EXDEV:
        ret = WD_USBD_STATUS_ISOCH_REQUEST_FAILED;
        break;
    case -EINPROGRESS:
    case -EMSGSIZE:
    case -EFBIG:
    case -EEXIST:
    default:
        ret = WD_SYSTEM_INTERNAL_ERROR;

    }
    return ret;
}

u32 get_match_flag(WDU_MATCH_TABLE *mt)
{
    u32 match_flags = 0;
    if (mt->wVendorId)
        match_flags |= USB_DEVICE_ID_MATCH_VENDOR;
    if (mt->wProductId)
        match_flags |= USB_DEVICE_ID_MATCH_PRODUCT;
    if (mt->bDeviceClass)
        match_flags |= USB_DEVICE_ID_MATCH_DEV_CLASS;
    if (mt->bDeviceSubClass)
        match_flags |= USB_DEVICE_ID_MATCH_DEV_SUBCLASS;
    if (mt->bInterfaceClass)
        match_flags |= USB_DEVICE_ID_MATCH_INT_CLASS;
    if (mt->bInterfaceSubClass)
        match_flags |= USB_DEVICE_ID_MATCH_INT_SUBCLASS;
    if (mt->bInterfaceProtocol)
        match_flags |= USB_DEVICE_ID_MATCH_INT_PROTOCOL;
    return match_flags;
}

#define WD_USB_MATCH_ALL 1
DWORD OS_register_devices(void **register_ctx, WDU_MATCH_TABLE *match_tables, 
    DWORD mt_count)
{
    int rc;
    struct usb_device_id *id;
    struct usb_driver *driver;
    int i,mt_alloc_size;
    char *name = NULL;
    static int name_id = 0;

    mt_alloc_size = sizeof(struct usb_device_id) * (mt_count + 1);
    id = (struct usb_device_id *)LINUX_kmalloc(mt_alloc_size, GFP_KERNEL);
    if (!id)
        return WD_INSUFFICIENT_RESOURCES;
    
    driver = (struct usb_driver *)
        LINUX_kmalloc(sizeof(struct usb_driver), GFP_KERNEL);
    if (!driver)
    {
        rc = -ENOMEM;   
        goto Error;
    }

    name = (char *)LINUX_kmalloc(256, GFP_KERNEL);
    if (!name)
    {
        rc = -ENOMEM;
        goto Error;
    }
    
    memset(id, 0, mt_alloc_size); 
    BZERO(*driver);
    driver->probe = usb_generic_probe;
    driver->disconnect = usb_generic_disconnect;
    sprintf(name, "%s_%d", LINUX_get_driver_name(), name_id++);
    driver->name = name;
    driver->id_table = id;
    for (i=0; i<mt_count; i++)
    {
        id[i].match_flags = get_match_flag(&match_tables[i]);
        id[i].idVendor = match_tables[i].wVendorId;
        id[i].idProduct = match_tables[i].wProductId;
        if (!id[i].match_flags)
            id[i].driver_info = WD_USB_MATCH_ALL;
    }
    rc = usb_register(driver);
    if (rc)
        goto Error;
    *register_ctx= (WDU_REGISTER_DEVICES_HANDLE)driver;
    return WD_STATUS_SUCCESS;

Error:
    if (id)
        LINUX_kfree(id);
    if (driver)
        LINUX_kfree(driver);
    if (name)
        LINUX_kfree(name);
    return map_error_status(rc);
}

DWORD OS_unregister_devices(void *register_handle)
{
    struct usb_driver *driver = (struct usb_driver *)register_handle;  
    if (driver)
    {
        usb_deregister(driver);
        LINUX_kfree(driver->name);
        LINUX_kfree(driver->id_table);
        LINUX_kfree(driver);
    }
    return WD_STATUS_SUCCESS;
}

static int find_alt_set_index(struct usb_interface *iface, int alt_num)
{
    u8 i;

    for (i = 0; i < iface->num_altsetting; i++)
        if (DESC(iface->altsetting[i])->bAlternateSetting == alt_num)
            return i;
    KDBG(D_ERROR, S_USB, "find_alt_set_index: failed to find alternate"
        " setting %d", alt_num);
    return -1;
}


DWORD OS_set_interface(HANDLE os_dev_h, 
    WDU_ALTERNATE_SETTING **alt_setting_info, DWORD ifnum, 
    DWORD alt_num)
{
    struct usb_dev_info *dev = os_dev_h;
    struct usb_interface *interface;
    size_t altsetting_size;
    WDU_ALTERNATE_SETTING *pAlternateSettings;
    HANDLE buf_h;
    int num_endp;
    int rc;
    void *buf;
    struct usb_interface_descriptor *if_desc = NULL;
    int alt_index;

    *alt_setting_info = NULL;
    interface = usb_ifnum_to_if(dev->udev, ifnum);
    if (!interface)
    {
        KDBG(D_ERROR, S_USB, "LINUX_usb_set_interface: invalid interface num "
           "selected  %d\b", ifnum);
        return WD_INVALID_PARAMETER; 
    }

    alt_index = find_alt_set_index(interface, alt_num);
    if (alt_index == -1)
    {
        KDBG(D_ERROR, S_USB, "LINUX_usb_set_interface: invalid alternate num "
            "selected  %d\b", alt_num);
        return WD_INVALID_PARAMETER; 
    } 

    if_desc = DESC(interface->altsetting[alt_index]);
    rc = usb_set_interface(dev->udev, ifnum, alt_num);
    if (rc)
    {
        KDBG(D_ERROR, S_USB, "LINUX_usb_set_interface: failed set interface %d "
            "alternate setting %d rc %d\n", ifnum, alt_num, rc);
        return map_error_status(rc);
    }

    num_endp = if_desc->bNumEndpoints;
    altsetting_size = sizeof(WDU_ALTERNATE_SETTING) + 
        (sizeof(WDU_ENDPOINT_DESCRIPTOR) + sizeof(WDU_PIPE_INFO)) * 
        (num_endp);

    buf = vmalloc(altsetting_size);
    if (!buf)
        return WD_INSUFFICIENT_RESOURCES;

    buf_h = buf_init(buf);
    if (!buf_h)
    {
        KDBG(D_ERROR, S_USB, "LINUX_usb_set_interface: cannot allocate interface buf memory\n");
        if (buf)
            vfree(buf);
        return WD_INSUFFICIENT_RESOURCES;
    }

    pAlternateSettings  = buf_malloc(buf_h, sizeof(WDU_ALTERNATE_SETTING));
    pAlternateSettings->pEndpointDescriptors = (WDU_ENDPOINT_DESCRIPTOR *)
        buf_malloc(buf_h, sizeof(WDU_ENDPOINT_DESCRIPTOR)*(num_endp));
    pAlternateSettings->pPipes = (WDU_PIPE_INFO *) 
        buf_malloc(buf_h, sizeof(WDU_PIPE_INFO *)*(num_endp));

    fill_alt_settings_data(pAlternateSettings, interface, alt_index);
    *alt_setting_info = pAlternateSettings;
    buf_uninit(buf_h);
    return WD_STATUS_SUCCESS;
}

static u32 create_usb_pipe(struct usb_device *dev, 
    const WDU_ENDPOINT_DESCRIPTOR *endp)
{
    u32 result = 0;
    u32 direction = endp->bEndpointAddress & USB_ENDPOINT_DIR_MASK;
    u32 type = endp->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK; 
    u32 endpoint = endp->bEndpointAddress; 

    KDBG(D_TRACE, S_USB, "create_usb_pipe: endpoint %x, type %x, direction "
        "%x packet size 0x%x, interval %d\n", endpoint, type, direction, 
        endp->wMaxPacketSize, endp->bInterval);
    switch (direction)
    {
    case USB_DIR_IN:
        switch (type)
        {
        case  USB_ENDPOINT_XFER_ISOC:
            result = usb_rcvisocpipe(dev, endpoint);
            break;
        case  USB_ENDPOINT_XFER_BULK:
            result = usb_rcvbulkpipe(dev, endpoint);
            break;
        case  USB_ENDPOINT_XFER_INT:
            result = usb_rcvintpipe(dev, endpoint);
            break;
        }
        break;
    case USB_DIR_OUT:
        switch (type)
        {
        case  USB_ENDPOINT_XFER_ISOC:
            result = usb_sndisocpipe(dev, endpoint);
            break;
        case  USB_ENDPOINT_XFER_BULK:
            result = usb_sndbulkpipe(dev, endpoint);
            break;
        case  USB_ENDPOINT_XFER_INT:
            result = usb_sndintpipe(dev, endpoint);
            break;
        }
        break;
    }
    return result;
}

DWORD OS_open_pipe(HANDLE os_dev_h, const WDU_ENDPOINT_DESCRIPTOR 
    *endpoint_desc, pipe_t *pipe)
{
    struct usb_dev_info *dev = os_dev_h;

    pipe->handle = (HANDLE)(unsigned long)create_usb_pipe(dev->udev, endpoint_desc);
    return WD_STATUS_SUCCESS;
}

DWORD OS_get_device_property(HANDLE os_dev_h, void *buf, 
    DWORD *buf_size, WD_DEVICE_REGISTRY_PROPERTY prop)
{
    DWORD needed_buf_size, actual_buf_size = *buf_size;
    struct usb_device *udev;

    switch (prop)
    {
    case WdDevicePropertyAddress:
    case WdDevicePropertyBusNumber:
        needed_buf_size = sizeof(unsigned int);
        break;
    default:
        return WD_NOT_IMPLEMENTED;
    }

    *buf_size = needed_buf_size;

    if (!buf)
        return WD_STATUS_SUCCESS;

    if (actual_buf_size < needed_buf_size)
        return WD_INVALID_PARAMETER; /* TODO: add a new error code */

    udev = ((struct usb_dev_info *)os_dev_h)->udev;
    switch (prop)
    {
    case WdDevicePropertyAddress:
        *(unsigned int *)buf = udev->devnum;
        break;
    case WdDevicePropertyBusNumber:
        *(unsigned int *)buf = udev->bus->busnum;
        break;
    default:
        return WD_NOT_IMPLEMENTED;
    }

    return WD_STATUS_SUCCESS;
}

DWORD OS_get_device_info(HANDLE os_dev_h, void *buf, 
    DWORD *buf_size, DWORD active_config, DWORD active_ifnum, 
    DWORD active_setting, BOOL is_kernelmod, DWORD dwOptions)
{
    // dwOptions param currently not used for this OS
    struct usb_dev_info *dev = os_dev_h;
    struct usb_device *udev = dev->udev;
    struct usb_config_descriptor *config;
    struct usb_interface *interface;
    WDU_DEVICE *dev_buf;
    WDU_CONFIGURATION *pConfig;
    WDU_INTERFACE *pInterface;
    WDU_ALTERNATE_SETTING *pActiveAltSetting = NULL;
    HANDLE buf_h;
    uint i, j, k;

    if (!buf)
    {
        *buf_size = calc_device_info_size(udev);
        return WD_STATUS_SUCCESS;
    }
           
    buf_h = buf_init(buf);
    if (!buf_h)
    {
        KDBG(D_ERROR, S_USB, "OS_get_device_info: cannot allocate device buf memory\n");
        return WD_INSUFFICIENT_RESOURCES;
    }

    dev_buf = (WDU_DEVICE *)buf_malloc(buf_h, sizeof(WDU_DEVICE));
    memcpy(&dev_buf->Descriptor, &udev->descriptor, USB_DT_DEVICE_SIZE);
    dev_buf->pConfigs = (WDU_CONFIGURATION *)buf_malloc(buf_h, 
        udev->descriptor.bNumConfigurations * sizeof(WDU_CONFIGURATION));

    for (i=0; i<udev->descriptor.bNumConfigurations; i++)
    {
        pConfig = &dev_buf->pConfigs[i];
        config = DESC(udev->config[i]);

        if (config->bConfigurationValue == active_config)
            dev_buf->pActiveConfig = pConfig;
        memcpy(&pConfig->Descriptor, config, USB_DT_CONFIG_SIZE);
        pConfig->dwNumInterfaces = config->bNumInterfaces;
        pConfig->pInterfaces=(WDU_INTERFACE *)buf_malloc(buf_h, 
            sizeof(WDU_INTERFACE)*config->bNumInterfaces);

        for (j=0; j<config->bNumInterfaces; j++)
        {
            u8 interface_index;
            pInterface = &pConfig->pInterfaces[j];
            interface = 
#if !defined(LINUX_26)
                &
#endif
                udev->config[i].interface[j];
            pInterface->dwNumAltSettings = interface->num_altsetting;
            pInterface->pAlternateSettings = 
                (WDU_ALTERNATE_SETTING *)buf_malloc(buf_h, 
                    sizeof(WDU_ALTERNATE_SETTING) * interface->num_altsetting);
            interface_index = DESC(interface->altsetting[0])->bInterfaceNumber;
            if (interface_index == active_ifnum)
                dev_buf->pActiveInterface[0] = pInterface;
            for(k=0; k<interface->num_altsetting; k++)
            {
                WDU_ALTERNATE_SETTING *pAlternateSetting = 
                    &pInterface->pAlternateSettings[k];
                struct usb_interface_descriptor *altsetting = 
                    DESC(interface->altsetting[k]);
                int num_endp = altsetting->bNumEndpoints;
                if (active_setting == altsetting->bAlternateSetting && 
                    interface_index == active_ifnum)
                {
                    pActiveAltSetting = pAlternateSetting;
                }
                pAlternateSetting->pEndpointDescriptors = (WDU_ENDPOINT_DESCRIPTOR *)
                    buf_malloc(buf_h, sizeof(WDU_ENDPOINT_DESCRIPTOR)*(num_endp));
                pAlternateSetting->pPipes = (WDU_PIPE_INFO *) 
                    buf_malloc(buf_h, sizeof(WDU_PIPE_INFO)*(num_endp));
                fill_alt_settings_data(pAlternateSetting, interface, k);
            }
        }
    }
    buf_uninit(buf_h);
    if (!dev_buf->pActiveInterface[0])
        dev_buf->pActiveInterface[0] = &dev_buf->pActiveConfig->pInterfaces[0];
    dev_buf->pActiveInterface[0]->pActiveAltSetting = pActiveAltSetting ?
        pActiveAltSetting : &dev_buf->pActiveInterface[0]->pAlternateSettings[0];
    return WD_STATUS_SUCCESS;
}

DWORD OS_reset_pipe(HANDLE os_dev_h, pipe_t *pipe)
{
    int rc;
    struct usb_dev_info *dev = os_dev_h;

    rc = usb_clear_halt(dev->udev, (unsigned long)pipe->handle);
    if (rc)
    {
        KDBG(D_ERROR, S_USB, "LINUX_usb_reset_pipe: failed reset pipe Num %ld "
            "rc %d\n", (unsigned long)pipe->handle, rc);
    }
    return map_error_status(rc);
}

DWORD OS_halt_transfer(void *os_trans_ctx)
{
    struct trans_ctx *tc = (struct trans_ctx *)os_trans_ctx;
    int i;
    
    for (i = 0; i < tc->num_urbs; i ++)
        LINUX_urb_unlink(tc->urbs[i].urb);

    return WD_STATUS_SUCCESS;
}

static void transfer_complete(struct urb *urb)
{
    struct trans_ctx *tc = ((struct urb_ctx *)urb->context)->tc;

    tc->is_finished = TRUE;
    wmb();
    wake_up(&tc->usb_submit_sync_event);
}

static void urb_complete_async(struct urb *urb)
{
    struct urb_ctx *uctx = (struct urb_ctx *)urb->context;
    struct trans_ctx *tc = uctx->tc;
    u32 type = tc->pipe->attributes & USB_ENDPOINT_XFERTYPE_MASK;

    spinlock_wait(&tc->spinlock);
    tc->pending_urbs--;
    /* Sanity check */
    if (urb->transfer_buffer_length < urb->actual_length)
    {
        KDBG(D_ERROR, S_USB, "usb_transfer - transfered (%d) more "
            "than requested (%d)\n", urb->actual_length, 
            urb->transfer_buffer_length);
        goto urb_completed;
    }

    if (tc->is_read)
    {
        LINUX_page_list_copyin(tc->page_list_h, tc->offset, uctx->urb_buf, 
            urb->actual_length); 
        tc->offset += urb->actual_length;
    }
    tc->bytes_transferred += urb->actual_length;
    if ((type != PIPE_TYPE_ISOCHRONOUS) && 
        (urb->actual_length < urb->transfer_buffer_length))
    {
        KDBG(D_TRACE, S_USB, "LINUX_usb_transfer short packet : %d %d "
            "exiting\n", urb->actual_length, urb->transfer_buffer_length);
        goto urb_completed;
    }

    if (tc->len <= 0 || tc->timeout <= 0 || !tc->dev->device_connected || 
        tc->trans->is_halted)
    {
        goto urb_completed;
    }

    spinlock_release(&tc->spinlock);
    /* Further transfers are required, reuse urb */
    if (urb_issue(uctx))
    {
        spinlock_wait(&tc->spinlock);
        goto urb_completed;
    }

    return;

urb_completed:
    if (urb->status)
        tc->status = urb->status;

    /* Wait for all urbs to complete, the last completion routine 
     * finishes the transfer */
    if (tc->pending_urbs > 0)
    {
        unsigned int pending_urbs = tc->pending_urbs;

        spinlock_release(&tc->spinlock);
        KDBG(D_TRACE, S_MISC, "%s: pending urbs %d\n", __FUNCTION__, 
            pending_urbs);
        return;
    }
    
    /* This segment completes the transfer */
    spinlock_release(&tc->spinlock);
    transfer_complete(urb);
}

static int urb_issue(struct urb_ctx *uctx)
{
    int rc = 0;
    struct trans_ctx *tc = uctx->tc;
    u32 type = tc->pipe->attributes & USB_ENDPOINT_XFERTYPE_MASK;
    unsigned int packet_size = tc->pipe->max_packet_size;
    long single_len;
   
    spinlock_wait(&tc->spinlock);
    single_len = MIN(tc->len, uctx->urb_buf_size);
    if (single_len <= 0)
    {
        spinlock_release(&tc->spinlock);
        return SUCCESS_NO_NEW_URB;
    }

    if (type == PIPE_TYPE_ISOCHRONOUS) 
    {
        if (single_len > packet_size)
            single_len = single_len / packet_size * packet_size;
        else if ((tc->len < packet_size) && 
            (tc->options & USB_ISOCH_FULL_PACKETS_ONLY))
        {
            spinlock_release(&tc->spinlock);
            KDBG(D_ERROR, S_USB, "%s: exiting on "
                "USB_ISOCH_FULL_PACKETS_ONLY flag\n", __FUNCTION__);
            return SUCCESS_NO_NEW_URB;
        }       
    }
    if (!tc->is_read)
    {
        LINUX_page_list_copyout(tc->page_list_h, tc->offset, uctx->urb_buf, 
            single_len);
        tc->offset += single_len;
    }
    tc->len -= single_len;
    tc->pending_urbs++;
    spinlock_release(&tc->spinlock);
    rc = urb_build(uctx->urb, tc->dev, tc->pipe, tc->is_read, uctx->urb_buf, 
        single_len, tc->setup_packet, tc->high_speed);
    if (rc)
        goto Exit;

    uctx->urb->context = uctx;

#if defined(LINUX_26)
    /* Since we may be called from within a completion routine
     * we need to use GFP_ATOMIC - see usb_submit_urb man page */
    rc = usb_submit_urb(uctx->urb, GFP_ATOMIC);
#else
    rc = usb_submit_urb(uctx->urb);
#endif

Exit:
    if (rc)
    {
        spinlock_wait(&tc->spinlock);
        tc->pending_urbs--;
        spinlock_release(&tc->spinlock);
    }

    return rc;
}

static int issue_new_transfer(struct trans_ctx *tc)
{
    int i, rc = 0;

    KDBG(D_TRACE, S_USB, "%s: entered\n", __FUNCTION__); 
    for (i = 0; i < tc->num_urbs; i++)
    {
        rc = urb_issue(&tc->urbs[i]);

        if (rc != 0)
            goto Exit;
    }
Exit:
    return rc == SUCCESS_NO_NEW_URB ? 0 : rc;
}

#if defined(LINUX_26) && (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20))
static void usb_common_completion(struct urb *urb, struct pt_regs *dummy)
#else
static void usb_common_completion(struct urb *urb)
#endif
{
    struct urb_ctx *uctx = (struct urb_ctx *)urb->context;
    struct trans_ctx *tc = uctx->tc;
    
    /* For Isochronous pipes, urb->status indicates only if the urb had been
     * unlinked, and urb->actual_length is always 0 */
    if (!urb->status && usb_pipeisoc(urb->pipe))
    {
        int i;
        unsigned int offset = 0;

        for (i = 0; i < urb->number_of_packets; i++)
        {
            if (urb->iso_frame_desc[i].status)
            {
                KDBG(D_TRACE, S_USB, "%s: packet %d, status: 0x%x\n", 
                    __FUNCTION__, i, urb->iso_frame_desc[i].status);
                continue;
            }

            if (usb_pipein(urb->pipe) && 
                offset != urb->iso_frame_desc[i].offset &&
                urb->iso_frame_desc[i].actual_length)
            {
                char *buf = (char *)urb->transfer_buffer;

                memcpy(buf + offset, buf + urb->iso_frame_desc[i].offset,
                    urb->iso_frame_desc[i].actual_length);
            }
            offset += urb->iso_frame_desc[i].actual_length;
        }
        // Update the URB actual_length for our later internal use (the usb
        // drivers update this field only for non-isoch eps)
        urb->actual_length = offset;
    }
#if defined(LINUX_24)
    /* Prevent EHCI from resubmitting this urb */
    else if (usb_pipeint(urb->pipe) && tc->high_speed)
        urb->status = -ENOENT;
#endif

    if (tc->timeout)
    {
        u32 tmp;

        tmp = jiffies;
        spinlock_wait(&tc->spinlock);
        if (tmp > tc->expire)
            tc->timeout = 0;
        else
            tc->timeout = tc->expire - tmp;
        spinlock_release(&tc->spinlock);
    }

    KDBG(D_TRACE, S_USB, "usb_common_completion: transferred 0x%x from 0x%x "
        "bytes status %d\n", urb->actual_length, urb->transfer_buffer_length, 
        urb->status);
    tc->urb_process_cb(urb);
}

static int usb_submit_sync(struct usb_dev_info *dev, 
    int timeout, int* actual_length, struct trans_ctx *tc)
{ 
    DECLARE_WAITQUEUE(wait, current);
    int status;
    struct urb *urb = tc->urbs[0].urb;

    init_waitqueue_head(&tc->usb_submit_sync_event);
    tc->is_finished = FALSE;

    set_current_state(TASK_UNINTERRUPTIBLE);
    add_wait_queue(&tc->usb_submit_sync_event, &wait);

    urb->context = &tc->urbs[0];

#if defined(LINUX_26)
    status = usb_submit_urb(urb, GFP_NOIO);
#else
    status = usb_submit_urb(urb);
#endif
    if (status) 
    {
        set_current_state(TASK_RUNNING);
        remove_wait_queue(&tc->usb_submit_sync_event, &wait);
        return status;
    }

    while (timeout && !tc->is_finished)
    {
        timeout = schedule_timeout(timeout);
        set_current_state(TASK_UNINTERRUPTIBLE);
        rmb();
    }

    set_current_state(TASK_RUNNING);
    remove_wait_queue(&tc->usb_submit_sync_event, &wait);
    if (!timeout && !tc->is_finished) 
    {
        if (urb->status != -EINPROGRESS)
        {
            KDBG(D_ERROR, S_USB, "usb_submit_sync: internal error - status %d "
                "pipe 0x%x time left %d\n",
                urb->status, urb->pipe, timeout);
            status = urb->status;
        }
        else
        {
            LINUX_urb_unlink(urb);
            status = -ETIMEDOUT;
        }
    } 
    else
        status = (!tc->status) ? 0 : urb->status;

    if (actual_length)
        *actual_length = urb->actual_length;
    return status;
}

#define SETUP_PACKET_LEN 8
static int urb_build(struct urb *urb, struct usb_dev_info *dev, pipe_t *pipe,
    DWORD is_read, void *buf, DWORD bytes, BYTE *setup_packet, 
    BOOL is_high_speed)
{
    u32 type = pipe->attributes & USB_ENDPOINT_XFERTYPE_MASK;
    struct usb_device *udev = dev->udev;
    unsigned long pipe_handle = (unsigned long)pipe->handle;
    unsigned char *dr = NULL;
    unsigned int packet_size = pipe->max_packet_size;
    int i, status;
  
    switch (type)
    {
    case PIPE_TYPE_CONTROL:
        dr = (unsigned char *)LINUX_kmalloc(SETUP_PACKET_LEN, GFP_KERNEL);
        if (!dr)
        {
            status = -ENOMEM;
            goto Exit;
        }
        memcpy(dr, setup_packet, SETUP_PACKET_LEN);
        pipe_handle = is_read ? usb_rcvctrlpipe(udev, pipe->endpoint_address):
            usb_sndctrlpipe(udev, pipe->endpoint_address);
        FILL_CONTROL_URB(urb, udev, pipe_handle, dr, buf, bytes,
            usb_common_completion, NULL);
        break;
    case PIPE_TYPE_INTERRUPT:
    #if defined(LINUX_26)
        i = pipe->interval;
    #else
        /* 
         * EHCI can't handle interval smaller then 8, since it allocate bus 
         * time for interrupt pipe only in frames (and not micro frame)
         */
        i = is_high_speed ? MAX(8, pipe->interval) : 0;
    #endif
        FILL_INT_URB(urb, udev, pipe_handle, buf, bytes, usb_common_completion,
            NULL, i);
        break;
    case PIPE_TYPE_BULK:
        FILL_BULK_URB(urb, udev, pipe_handle, buf, bytes, usb_common_completion,
            NULL);
        break;
    case PIPE_TYPE_ISOCHRONOUS:
        urb->number_of_packets = (bytes + packet_size - 1)/packet_size;
        urb->dev = udev;
        urb->pipe = pipe_handle;
        urb->transfer_buffer = buf;
        urb->transfer_buffer_length = bytes;
        urb->context = NULL;
        urb->complete = usb_common_completion;
        urb->transfer_flags = USB_ISO_ASAP;
        urb->interval = pipe->interval;

        for (i=0; i< urb->number_of_packets; i++)
        {
            urb->iso_frame_desc[i].offset = i * packet_size;
            urb->iso_frame_desc[i].length = packet_size;
        }
        // set the last packet
        if (bytes%packet_size)
            urb->iso_frame_desc[i-1].length = bytes%packet_size;
        break;
    default:
        status = -EEXIST;
        goto Exit;
    }

    return 0;

Exit:
    if (dr)
        LINUX_kfree(dr);
    return status;
}

#define MAX_ALLOC_SIZE   0x10000  //64k half of linux maximum
DWORD OS_get_max_urb_transfer_size(BOOL high_speed, const pipe_t *pipe)
{
    /* FIXME - max_urb_transfer_size is not used */
    return MAX_ALLOC_SIZE;
}

static void *try_allocate(unsigned long len, pipe_t *pipe, 
    unsigned long *allocated)
{
    u32 packet_size, alloc_size;  
    u32 type = pipe->attributes & USB_ENDPOINT_XFERTYPE_MASK;
    void *buf;

    alloc_size = MIN(len, MAX_ALLOC_SIZE);
    packet_size = pipe->max_packet_size;

    if (type == PIPE_TYPE_INTERRUPT)
        alloc_size = MIN(len, pipe->max_packet_size);
    else if (type == PIPE_TYPE_ISOCHRONOUS)
    {
        if (!packet_size)
        {
            KDBG(D_ERROR, S_USB, "LINUX_usb_transfer can't issue transfer "
                "with non zero lengh and zero packet_size\n");
            return NULL;
        }
        if (alloc_size / packet_size > MAX_PACKETS)
            alloc_size = MAX_PACKETS * packet_size; 
        else if (alloc_size > packet_size)
        {
            // we need to transfer complete packets. partial packet affect the
            // device, it tells him that the transfer is completed.
            alloc_size = (((alloc_size - 1)/ packet_size) + 1) * packet_size;
        }
    }

    while(1)
    {
        buf = LINUX_kmalloc(alloc_size, GFP_KERNEL);
        if (buf)
            break;
        if (alloc_size > PAGE_SIZE)
        {
            if (type == PIPE_TYPE_ISOCHRONOUS)
                alloc_size = (alloc_size / 2) / packet_size * packet_size;
            else
                alloc_size /= 2;
        }
        else
        {
            KDBG(D_ERROR, S_USB, "LINUX_usb_transfer: failed allocate 0x%x(%d) "
                "bytes\n", alloc_size, alloc_size);
            break;
        }
    }
    *allocated = alloc_size;
    return buf;
}

static int uctx_get(pipe_t *pipe, DWORD bytes, struct urb_ctx *uctx)
{
    u32 type = pipe->attributes & USB_ENDPOINT_XFERTYPE_MASK;
    int packets = 0;

    KDBG(D_TRACE, S_USB, "%s: entered\n", __FUNCTION__);

    if (type == PIPE_TYPE_ISOCHRONOUS)
    {
        packets = (MIN(bytes, MAX_ALLOC_SIZE) + pipe->max_packet_size - 1) / 
            pipe->max_packet_size;
    }

#if defined(LINUX_26)
    uctx->urb = usb_alloc_urb(packets, GFP_KERNEL);
#else
    uctx->urb = usb_alloc_urb(packets);
#endif
    if (!uctx->urb)
        return -ENOMEM;

    if (!bytes)
        return 0; /* No need to allocate an additional buffer */

    uctx->urb_buf = try_allocate(bytes , pipe, &uctx->urb_buf_size);
    if (!uctx->urb_buf)
        goto Err;

    return 0;

Err:
    if (uctx->urb)
        usb_free_urb(uctx->urb);
    return -ENOMEM;
}

static void uctx_put(struct urb_ctx *uctx)
{
    if (uctx->urb)
    {
        usb_free_urb(uctx->urb);
        uctx->urb = NULL;
    }
    if (uctx->urb_buf)
    {
        LINUX_kfree(uctx->urb_buf);
        uctx->urb_buf = NULL;
    }
}

struct trans_ctx *tc_alloc(pipe_t *pipe, DWORD num_urbs)
{
    struct trans_ctx *tc;

    KDBG(D_TRACE, S_USB, "%s: entered\n", __FUNCTION__);
    tc = (struct trans_ctx *)vmalloc(sizeof(struct trans_ctx));
    if (!tc)
        return NULL;

    tc->num_urbs = num_urbs;
    tc->urbs = (struct urb_ctx *)vmalloc(sizeof(struct urb_ctx) * tc->num_urbs);
    if (!tc->urbs)
        goto Error;

    memset(tc->urbs, 0, sizeof(struct urb_ctx) * tc->num_urbs);
    return tc;

Error:
    tc_destroy(tc);
    return NULL;
}

static void tc_destroy(void *os_trans_ctx)
{
    struct trans_ctx *tc = (struct trans_ctx *)os_trans_ctx;
    int i;

    spinlock_wait(&tc->spinlock);
    for (i = 0; i < tc->num_urbs; i++)
        uctx_put(&tc->urbs[i]);

    spinlock_release(&tc->spinlock);
    spinlock_uninit(&tc->spinlock);
    vfree(tc->urbs);
    vfree(tc);
}

#define MAX_URBS_TO_USE 4
static DWORD tc_create(HANDLE os_dev_h, pipe_t *pipe,DWORD is_read, 
    DWORD options, void *page_list_h, DWORD bytes, BYTE *setup_packet, 
    DWORD tout, struct trans_ctx **ctx)
{
    int rc = 0;
    struct usb_dev_info *dev = os_dev_h;
    unsigned long expire = 0;
    unsigned long timeout = (unsigned long)MAX_SCHEDULE_TIMEOUT;
    struct trans_ctx *tc = NULL;
    unsigned int num_urbs = MIN(MAX_URBS_TO_USE, 
        (bytes + MAX_ALLOC_SIZE) / MAX_ALLOC_SIZE);
    int i;

    num_urbs = MAX(num_urbs, 1);
    tc = tc_alloc(pipe, num_urbs);
    if (!tc)
    {   
        rc = -ENOMEM;
        goto Err;
    }

    if (tout)
    {
        timeout = LINUX_msecs_to_jiffies(tout);
        expire = jiffies + timeout;
    }

    tc->high_speed = (dev->udev->speed == USB_SPEED_HIGH);
    tc->offset = 0;
    tc->page_list_h = page_list_h;
    tc->len = bytes;
    tc->bytes_transferred = 0;
    tc->pipe = pipe;
    tc->dev = dev;
    tc->is_read = is_read;
    tc->setup_packet = setup_packet;
    tc->is_finished = FALSE;
    tc->options = options;
    tc->timeout = timeout;
    tc->expire = expire;
    tc->pending_urbs = 0;
    spinlock_init(&tc->spinlock);
    /* Init URBS */
    for (i = 0; i < num_urbs; i++)
    {
        struct urb_ctx *uctx = &tc->urbs[i];

        /* Allocation is blocked at MAX_ALLOC_SIZE, therefore
         * we always ask for full "bytes" allocation */
        if (uctx_get(pipe, bytes, uctx))
            goto Err;

        uctx->tc = tc;
    }
    *ctx = tc;
    return 0;

Err:
    *ctx = NULL;
    return map_error_status(rc);
}

DWORD OS_transfer(HANDLE os_dev_h, pipe_t *pipe, void *file_h, PRCHANDLE prc_h,
    DWORD is_read, DWORD options, void *buf, DWORD bytes,
    DWORD *bytes_transferred, BYTE *setup_packet, DWORD tout,
    PVOID ioctl_context)
{
    DECLARE_WAITQUEUE(wait, current);
    int rc = 0;
    struct trans_ctx *tc = NULL;
    trans_t *trans = NULL;      
    void *pl_h = NULL;
    
    *bytes_transferred = 0;

    if (bytes)
    {
        rc = LINUX_user_page_list_get(buf, bytes, &pl_h);
        if (rc)
            goto Exit;
    }

    /* Create transfer context, Pre-allocate URB's */
    rc = tc_create(os_dev_h, pipe, is_read, options, pl_h, bytes, 
        setup_packet, tout, &tc);   
    if (!tc)
        goto Exit;

    /* Add the OS transfer context to the common list */
    trans = create_transfer(pipe, tc, tc_destroy);
    if (!trans)
    {
        rc = -ENOMEM;
        goto Exit;
    }

    tc->trans = trans;

    if (!bytes)
    {
        /* Zero transfer */
        rc = urb_build(tc->urbs[0].urb, tc->dev, pipe, is_read, NULL, 0, 
            setup_packet, tc->high_speed);
        if (rc)
            goto Exit;

        tc->urb_process_cb = transfer_complete;
        rc = usb_submit_sync(tc->dev, tc->timeout, (int *)bytes_transferred, tc);
        goto Exit;
    }

    /* Non-zero transfer */
    tc->urb_process_cb = urb_complete_async;
    init_waitqueue_head(&tc->usb_submit_sync_event);
    set_current_state(TASK_UNINTERRUPTIBLE);
    add_wait_queue(&tc->usb_submit_sync_event, &wait);

    /* Submit the URBs */
    rc = issue_new_transfer(tc);
    while (!rc && tc->timeout && !tc->is_finished) 
    {
        tc->timeout = schedule_timeout(tc->timeout);
        set_current_state(TASK_UNINTERRUPTIBLE);
        rmb();
    }

    set_current_state(TASK_RUNNING);
    remove_wait_queue(&tc->usb_submit_sync_event, &wait);
    if (rc)
    {
        OS_halt_transfer(tc);
        goto Exit;
    }

    if (!tc->timeout && !tc->is_finished) 
    {
        OS_halt_transfer(tc);
        rc = -ETIMEDOUT;
    } 
    *bytes_transferred = tc->bytes_transferred; 

Exit:
    if (trans)
        release_transfer(trans);
    if (pl_h)
        LINUX_user_page_list_put(pl_h);
    return map_error_status(rc);
}

void OS_set_stream_context(HANDLE file_h, stream_context_t *context)
{
    struct file *filp = (struct file *)file_h;
    
    if (!filp)
        return;

    filp->private_data = (void *)context;
}

stream_context_t* OS_get_stream_context(HANDLE file_h)
{
    struct file *filp = (struct file *)file_h;
    
    if (!filp)
        return NULL;

    return (stream_context_t*)(filp->private_data);
}

DWORD OS_stream_request_insert(stream_t *stream, void *request)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

BOOL OS_is_stream_requests_queue_empty(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return TRUE;
}

DWORD OS_stream_transfer_create(HANDLE os_dev_h, pipe_t *pipe)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_start(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_stop(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_flush(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_close(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

void OS_stream_action_timer_cb(void *ctx)
{   
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
}

DWORD OS_close_device(HANDLE os_dev_h)
{
    return WD_STATUS_SUCCESS;
}

DWORD OS_selective_suspend(HANDLE os_dev_h, DWORD options)
{
    KDBG(D_ERROR, S_USB, "OS_selective_suspend: Not supported on this platform yet\n");
    return WD_NOT_IMPLEMENTED;
}

BOOL OS_init()
{
    // nothing to do here
    return TRUE;
}

void OS_uninit()
{
   // nothing to do here
}
#else
DWORD OS_register_devices(void **register_ctx, WDU_MATCH_TABLE *match_tables, 
    DWORD match_tabs_number)
{
    KDBG(D_ERROR, S_USB, "OS_register_devices: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED; 
}

DWORD OS_unregister_devices(void *register_handle)
{
    KDBG(D_ERROR, S_USB, "OS_unregister_devices: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}
DWORD OS_get_device_info(HANDLE os_dev_h, void *buf, 
    DWORD *buf_size, DWORD active_config, DWORD active_interface, 
    DWORD active_setting, BOOL is_kernelmode, DWORD dwOptions)
{
    KDBG(D_ERROR, S_USB, "OS_get_device_info: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_set_interface(HANDLE os_dev_h, 
    WDU_ALTERNATE_SETTING **alt_setting_info, 
    DWORD interface_num, DWORD alt_num)
{
    KDBG(D_ERROR, S_USB, "OS_set_interface: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_get_max_urb_transfer_size(BOOL high_speed, const pipe_t *pipe)
{
    KDBG(D_ERROR, S_USB, "OS_get_max_urb_transfer_size: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_open_pipe(HANDLE os_dev_h, 
    const WDU_ENDPOINT_DESCRIPTOR *endpoint_desc, pipe_t *pipe)
{
    KDBG(D_ERROR, S_USB, "OS_open_pipe: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_get_device_property(HANDLE os_dev_h, void *buf, 
    DWORD *buf_size, WD_DEVICE_REGISTRY_PROPERTY prop)
{
    KDBG(D_ERROR, S_USB, "OS_get_device_property: Not supported on this "
        "platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_close_device(HANDLE os_dev_h)
{
    KDBG(D_ERROR, S_USB, "OS_close_device: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_reset_pipe(HANDLE os_dev_h, pipe_t *pipe)
{
    KDBG(D_ERROR, S_USB, "OS_reset_pipe: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_selective_suspend(HANDLE os_dev_h, DWORD options)
{
    KDBG(D_ERROR, S_USB, "OS_selective_suspend: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_transfer(HANDLE os_dev_h, pipe_t *pipe, void *file_h, PRCHANDLE prc_h,
    DWORD is_read, DWORD options, void *buf, DWORD bytes,
    DWORD *bytes_transferred, BYTE *setup_packet, DWORD tout,
    PVOID ioctl_context)
{
    KDBG(D_ERROR, S_USB, "OS_transfer: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_halt_transfer(void *os_trans_ctx)
{
    KDBG(D_ERROR, S_USB, "OS_halt_transfer: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

BOOL OS_init()
{
    // nothing to do here
    return TRUE;
}

void OS_uninit()
{
   // nothing to do here
}

void OS_set_stream_context(HANDLE file_h, stream_context_t *context)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
}

stream_context_t * OS_get_stream_context(HANDLE file_h)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return (stream_context_t *)0;
}

DWORD OS_stream_request_insert(stream_t *stream, void *request)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

BOOL OS_is_stream_requests_queue_empty(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return TRUE;
}

DWORD OS_stream_transfer_create(HANDLE os_dev_h, pipe_t *pipe)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_start(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_stop(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_flush(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_stream_transfer_close(stream_t *stream)
{
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
    return WD_NOT_IMPLEMENTED;
}

void OS_stream_action_timer_cb(void *ctx)
{   
    KDBG(D_ERROR, S_USB, "%s: Not supported on this platform\n", __FUNCTION__);
}
#endif

DWORD OS_wakeup(HANDLE os_dev_h, DWORD options)
{
    KDBG(D_ERROR, S_USB, "OS_wakeup: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}

DWORD OS_reset_device(HANDLE os_dev_h, DWORD options)
{
    KDBG(D_ERROR, S_USB, "OS_reset_device: Not supported on this platform\n");
    return WD_NOT_IMPLEMENTED;
}
