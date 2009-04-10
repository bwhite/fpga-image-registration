#define TESTAPP_GEN

/* $Id: uartns550_intr_header.h,v 1.2 2007/05/18 06:55:23 svemula Exp $ */

#include "xbasic_types.h"
#include "xstatus.h"

XStatus UartNs550IntrExample(XIntc* IntcInstancePtr, \
                             XUartNs550* UartLiteInstancePtr, \
                             Xuint16 UartNs550DeviceId, \
                             Xuint16 UartNs550IntrId);


