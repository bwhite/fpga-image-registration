#define TESTAPP_GEN

/* $Id: tmrctr_intr_header.h,v 1.1 2007/05/15 08:52:32 mta Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"


XStatus TmrCtrIntrExample(XIntc* IntcInstancePtr,
                          XTmrCtr* InstancePtr,
                          Xuint16 DeviceId,
                          Xuint16 IntrId,
                          Xuint8 TmrCtrNumber);


