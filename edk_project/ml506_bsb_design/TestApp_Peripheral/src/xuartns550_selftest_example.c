#define TESTAPP_GEN

/* $Id: xuartns550_selftest_example.c,v 1.2.8.1 2008/02/18 12:35:21 svemula Exp $ */
/*****************************************************************************
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
*       (c) Copyright 2005 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xuartns550_selftest_example.c
*
* This file contains a design example using the Uart 16450/550 driver
* (XUartNs550) and hardware device using polled mode.
*
* @note
*
* None
*
* MODIFICATION HISTORY:
* <pre>
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a sv   10/07/05 Created for Test App integration
* </pre>
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xuartns550.h"

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define UART_DEVICE_ID          XPAR_UARTNS550_0_DEVICE_ID
#endif

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

XStatus UartNs550SelfTestExample(Xuint16 DeviceId);

/************************** Variable Definitions *****************************/

XUartNs550 UartNs550;           /* Instance of the UART Device */

/*****************************************************************************/
/**
*
* Main function to call the example. This function is not included if the
* example is generated from the TestAppGen test tool.
*
* @param    None
*
* @return   XST_SUCCESS if succesful, otherwise XST_FAILURE
*
* @note     None
*
******************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
    XStatus Status;

    /*
     *  Run the UartNs550  selftest example
     */
    Status = UartNs550SelfTestExample(UART_DEVICE_ID);
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
* This function does a minimal test on the UartNs550 device and driver as a
* design example. The purpose of this function is to illustrate how to use the
* XUartNs550 component.
*
*
* @param    DeviceId is the XPAR_<uartns550_instance>_DEVICE_ID value from
*           xparameters.h
*
* @return   XST_SUCCESS if succesful, otherwise XST_FAILURE
*
* @note     None
*
****************************************************************************/
XStatus UartNs550SelfTestExample(Xuint16 DeviceId)
{
    XStatus Status;

    /*
     * Initialize the UartNs550 driver so that it's ready to use
     */
    Status = XUartNs550_Initialize(&UartNs550, DeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Perform a self-test to ensure that the hardware was built correctly
     */
    Status = XUartNs550_SelfTest(&UartNs550);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}

