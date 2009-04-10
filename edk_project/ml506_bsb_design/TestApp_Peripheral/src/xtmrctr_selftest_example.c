#define TESTAPP_GEN

/* $Id: xtmrctr_selftest_example.c,v 1.1.8.1 2008/02/18 12:55:41 svemula Exp $ */
/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2002-2005 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
* @file xtmrctr_selftest_example.c
*
* This file contains a example for  using the Timer Counter hardware and
* driver
*
* @note
*
* None
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a sv   04/25/05 Initial release for TestApp integration.
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xparameters.h"
#include "xtmrctr.h"


/************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define TMRCTR_DEVICE_ID  XPAR_TMRCTR_0_DEVICE_ID

/*
 * This example only uses the 1st of the 2 timer counters contained in a
 * single timer counter hardware device
 */
#define TIMER_COUNTER_0     0

/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions *******************/


/************************** Function Prototypes ****************************/

XStatus TmrCtrSelfTestExample(Xuint16 DeviceId, Xuint8 TmrCtrNumber);

/************************** Variable Definitions **************************/

XTmrCtr TimerCounter; /* The instance of the timer counter */


/*****************************************************************************/
/**
* Main function to call the example. This function is not included if the
* example is generated from the TestAppGen test tool.
*
* @param    None
*
* @return   XST_SUCCESS to indicate success, else XST_FAILURE to indicate
*           a Failure.
*
* @note     None
*
******************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
    XStatus Status;

    Status = TmrCtrSelfTestExample(TMRCTR_DEVICE_ID, TIMER_COUNTER_0);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}
#endif


/*****************************************************************************/
/**
*
* This function does a minimal test on the TmrCtr device and driver as a
* design example. The purpose of this function is to illustrate
* how to use the XTmrCtr component.
*
*
* @param    DeviceId is the XPAR_<TMRCTR_instance>_DEVICE_ID value from
*           xparameters.h
* @param    TmrCtrNumber is the timer counter of the device to operate on. Each
*           device may contain multiple timer counters. The timer number is a
*           zero based number with a range of 0 - (XTC_DEVICE_TIMER_COUNT - 1).
*
* @return   XST_SUCCESS if successful, XST_FAILURE if unsuccessful
*
* @note     None
*
****************************************************************************/
XStatus TmrCtrSelfTestExample(Xuint16 DeviceId, Xuint8 TmrCtrNumber)
{
    XStatus Status;
    XTmrCtr *TmrCtrInstancePtr = &TimerCounter;

    /*
     * Initialize the TmrCtr driver so that it iss ready to use
     */
    Status = XTmrCtr_Initialize(TmrCtrInstancePtr, DeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Perform a self-test to ensure that the hardware was built
     * correctly, use the 1st timer in the device (0)
     */
    Status = XTmrCtr_SelfTest(TmrCtrInstancePtr, TmrCtrNumber);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }


    return XST_SUCCESS;
}

