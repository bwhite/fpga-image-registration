#define TESTAPP_GEN

/* $Id: xuartns550_intr_example.c,v 1.3.8.1 2008/02/18 12:35:21 svemula Exp $ */
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
*       (c) Copyright 2002-2006 Xilinx Inc.
*       All rights reserved.
*
*******************************************************************************/
/******************************************************************************/
/**
*
* @file     xuartns550_intr_example.c
*
* This file contains a design example using the UART 16450/16550 driver
* (XUartNs550) and hardware device using interrupt mode.
* This example works with a PPC processor. Refer the examples of Interrupt
* controller (XIntc) for an example of using interrupts with the MicroBlaze
* processor.
*
*
* @note
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- ----------------------------------------------------------
* 1.00b jhl  02/13/02 First release
* 1.00b sv   06/08/05 Minor changes to comply to Doxygen and coding guidelines
* 1.01a sv   05/08/06 Minor changes for supporting Test App Interrupt examples
* </pre>
******************************************************************************/

/***************************** Include Files **********************************/

#include "xparameters.h"
#include "xuartns550.h"
#include "xintc.h"

#ifdef __MICROBLAZE__
#include "mb_interface.h"
#else
#include "xexception_l.h"
#endif

/************************** Constant Definitions ******************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define UART_DEVICE_ID              XPAR_UARTNS550_0_DEVICE_ID
#define INTC_DEVICE_ID              XPAR_INTC_0_DEVICE_ID
#define UART_IRPT_INTR              XPAR_INTC_0_UARTNS550_0_VEC_ID
#endif

/*
 * The following constant controls the length of the buffers to be sent
 * and received with the UART.
 */
#define TEST_BUFFER_SIZE            100


/**************************** Type Definitions ********************************/


/************************** Function Prototypes *******************************/

XStatus UartNs550IntrExample(XIntc *IntcInstancePtr,
                             XUartNs550 *UartInstancePtr,
                             Xuint16 UartDeviceId,
                             Xuint16 UartIntrId);

void UartNs550IntrHandler(void *CallBackRef, Xuint32 Event,
                          unsigned int EventData);


static XStatus UartNs550SetupIntrSystem(XIntc *IntcInstancePtr,
                                        XUartNs550 *UartInstancePtr,
                                        Xuint16 UartIntrId);

static void UartNs550DisableIntrSystem(XIntc *IntcInstancePtr,
                                       Xuint16 UartIntrId);



/************************** Variable Definitions ******************************/

#ifndef TESTAPP_GEN
XUartNs550 UartNs550Instance;       /* Instance of the UART Device */
XIntc IntcInstance;                 /* Instance of the Interrupt Controller */
#endif

/*
 * The following buffers are used in this example to send and receive data
 * with the UART.
 */
Xuint8 SendBuffer[TEST_BUFFER_SIZE];    /* Buffer for Transmitting Data */
Xuint8 RecvBuffer[TEST_BUFFER_SIZE];    /* Buffer for Receiving Data */

/*
 * The following counters are used to determine when the entire buffer has
 * been sent and received.
 */
static volatile int TotalReceivedCount;
static volatile int TotalSentCount;
static volatile int TotalErrorCount;


/******************************************************************************/
/**
*
* Main function to call the UartNs550 interrupt example.
*
* @param    None
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None
*
*******************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
    XStatus Status;

    /*
     * Run the UartNs550 Interrupt example.
     */
    Status = UartNs550IntrExample(&IntcInstance,
                                  &UartNs550Instance,
                                  UART_DEVICE_ID,
                                  UART_IRPT_INTR);
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
* This function transmits data and expects to receive the same data through the
* UART using the local loopback of the hardware.
*
* This function uses interrupt driver mode of the UART.
*
* @param    IntcInstancePtr is a pointer to the instance of the INTC component.
* @param    UartInstancePtr is a pointer to the instance of the UART component.
* @param    UartDeviceId is the device Id and is typically
*           XPAR_<UARTNS550_instance>_DEVICE_ID value from  xparameters.h.
* @param    UartIntrId is the interrupt Id and is typically
*           XPAR_<INTC_instance>_<UARTNS550_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note
*
* This function contains an infinite loop such that if interrupts are not
* working it may never return.
*
*******************************************************************************/
XStatus UartNs550IntrExample(XIntc *IntcInstancePtr,
                             XUartNs550 *UartInstancePtr,
                             Xuint16 UartDeviceId,
                             Xuint16 UartIntrId)
{
    XStatus Status;
    Xuint32 Index;
    Xuint16 Options;
    Xuint32 BadByteCount = 0;


    /*
     * Initialize the UART driver so that it's ready to use.
     */
    Status = XUartNs550_Initialize(UartInstancePtr, UartDeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Perform a self-test to ensure that the hardware was built correctly.
     */
    Status = XUartNs550_SelfTest(UartInstancePtr);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Connect the UART to the interrupt subsystem such that interrupts can
     * occur. This function is application specific.
     */
    Status = UartNs550SetupIntrSystem(IntcInstancePtr,
                                      UartInstancePtr,
                                      UartIntrId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Setup the handlers for the UART that will be called from the interrupt
     * context when data has been sent and received, specify a pointer to the
     * UART driver instance as the callback reference so the handlers are able
     * to access the instance data.
     */
    XUartNs550_SetHandler(UartInstancePtr, UartNs550IntrHandler,
                          UartInstancePtr);

    /*
     * Enable the interrupt of the UART so interrupts will occur, setup
     * a local loopback so data that is sent will be received, and keep the
     * FIFOs enabled.
     */
    Options = XUN_OPTION_DATA_INTR | XUN_OPTION_LOOPBACK |
              XUN_OPTION_FIFOS_ENABLE;
    XUartNs550_SetOptions(UartInstancePtr, Options);


    /*
     * Initialize the send buffer bytes with a pattern to send and the
     * the receive buffer bytes to zero to allow the receive data to be
     * verified.
     */
    for (Index = 0; Index < TEST_BUFFER_SIZE; Index++)
    {
        SendBuffer[Index] = Index + 'A';
        RecvBuffer[Index] = 0;
    }

    /*
     * Start receiving data before sending it since there is a loopback,
     * ignoring the number of bytes received as the return value since we
     * know it will be zero and we are using interrupt mode.
     */
    XUartNs550_Recv(UartInstancePtr, RecvBuffer, TEST_BUFFER_SIZE);

    /*
     * Send the buffer using the UART and ignore the number of bytes sent
     * as the return value since we are using it in interrupt mode.
     */
    XUartNs550_Send(UartInstancePtr, SendBuffer, TEST_BUFFER_SIZE);

    /*
     * Wait for the entire buffer to be received, letting the interrupt
     * processing work in the background, this function may get locked
     * up in this loop if the interrupts are not working correctly.
     */
    while ((TotalReceivedCount != TEST_BUFFER_SIZE) ||
           (TotalSentCount != TEST_BUFFER_SIZE))
    {
    }

    /*
     * Verify the entire receive buffer was successfully received.
     */
    for (Index = 0; Index < TEST_BUFFER_SIZE; Index++)
    {
        if (RecvBuffer[Index] != SendBuffer[Index])
        {
            BadByteCount++;
        }
    }

    /*
     * Disable the UartNs550 interrupt.
     */
    UartNs550DisableIntrSystem(IntcInstancePtr, UartIntrId);


    /*
     * If any bytes were not correct, return an error.
     */
    if (BadByteCount != 0)
    {
        return XST_FAILURE;
    }


    return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function is the handler which performs processing to handle data events
* from the UartNs550.  It is called from an interrupt context such that the
* amount of processing performed should be minimized.
*
* This handler provides an example of how to handle data for the UART and
* is application specific.
*
* @param    CallBackRef contains a callback reference from the driver, in this
*           case it is the instance pointer for the UART driver.
* @param    Event contains the specific kind of event that has occurred.
* @param    EventData contains the number of bytes sent or received for sent and
*           receive events.
*
* @return   None.
*
* @note     None.
*
*******************************************************************************/
void UartNs550IntrHandler(void *CallBackRef,
                          Xuint32 Event,
                          unsigned int EventData)
{
    Xuint8 Errors;
    XUartNs550 *UartNs550Ptr = (XUartNs550 *)CallBackRef;

    /*
     * All of the data has been sent.
     */
    if (Event == XUN_EVENT_SENT_DATA)
    {
        TotalSentCount = EventData;
    }

    /*
     * All of the data has been received.
     */
    if (Event == XUN_EVENT_RECV_DATA)
    {
        TotalReceivedCount = EventData;
    }

    /*
     * Data was received, but not the expected number of bytes, a
     * timeout just indicates the data stopped for 4 character times.
     */
    if (Event == XUN_EVENT_RECV_TIMEOUT)
    {
        TotalReceivedCount = EventData;
    }

    /*
     * Data was received with an error, keep the data but determine
     * what kind of errors occurred.
     */
    if (Event == XUN_EVENT_RECV_ERROR)
    {
        TotalReceivedCount = EventData;
        TotalErrorCount++;
        Errors = XUartNs550_GetLastErrors(UartNs550Ptr);
    }
}

/******************************************************************************/
/**
*
* This function setups the interrupt system such that interrupts can occur
* for the UART.  This function is application specific since the actual
* system may or may not have an interrupt controller.  The UART could be
* directly connected to a processor without an interrupt controller.  The
* user should modify this function to fit the application.
*
* @param    IntcInstancePtr is a pointer to the instance of the INTC component.
* @param    UartInstancePtr is a pointer to the instance of the UART component.
* @param    UartIntrId is the interrupt Id and is typically
*           XPAR_<INTC_instance>_<UARTNS550_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE
*
*
* @note     None
*
*******************************************************************************/
static XStatus UartNs550SetupIntrSystem(XIntc *IntcInstancePtr,
                                        XUartNs550 *UartInstancePtr,
                                        Xuint16 UartIntrId)
{
    XStatus Status;

#ifndef TESTAPP_GEN
    /*
     * Initialize the interrupt controller driver so that it is ready to use.
     */
    Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
#endif

    /*
     * Connect a device driver handler that will be called when an interrupt
     * for the device occurs, the device driver handler performs the specific
     * interrupt processing for the device.
     */
    Status = XIntc_Connect(IntcInstancePtr, UartIntrId,
                           (XInterruptHandler)XUartNs550_InterruptHandler,
                           (void *)UartInstancePtr);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

#ifndef TESTAPP_GEN
   /*
     * Start the interrupt controller such that interrupts are enabled for
     * all devices that cause interrupts, specific real mode so that
     * the UART can cause interrupts thru the interrupt controller.
     */
    Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
#endif

    /*
     * Enable the interrupt for the UartNs550.
     */
    XIntc_Enable(IntcInstancePtr, UartIntrId);

#ifndef TESTAPP_GEN

    /*
     * Initialize the PPC exception table.
     */
    XExc_Init();

    /*
     * Register the interrupt controller handler with the exception table.
     */
    XExc_RegisterHandler(XEXC_ID_NON_CRITICAL_INT,
                         (XExceptionHandler)XIntc_InterruptHandler,
                         IntcInstancePtr);

    /*
     * Enable non-critical exceptions.
     */
    XExc_mEnableExceptions(XEXC_NON_CRITICAL);

#endif /* TESTAPP_GEN */

    return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This function disables the interrupts that occur for the UartNs550 device.
*
* @param    IntcInstancePtr is the pointer to the instance of the INTC
*           component.
* @param    UartIntrId is the interrupt Id and is typically
*           XPAR_<INTC_instance>_<UARTNS550_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void UartNs550DisableIntrSystem(XIntc *IntcInstancePtr,
                                       Xuint16 UartIntrId)
{

    /*
     * Disconnect and disable the interrupt for the UartNs550 device.
     */
    XIntc_Disconnect(IntcInstancePtr, UartIntrId);

}





