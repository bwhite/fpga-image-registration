#define TESTAPP_GEN

/* $Id: xtmrctr_intr_example.c,v 1.4.8.1 2008/02/18 12:55:41 svemula Exp $ */
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
*       (c) Copyright 2002-2007 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
* @file  xtmrctr_intr_example.c
*
* This file contains a design example using the timer counter driver
* (XTmCtr) and hardware device using interrupt mode.This example assumes
* that the interrupt controller is also present as a part of the system
*
* This file can be used as a standalone example or by the TestAppGen utility
* to include a test for Timer interrupts.
*
* As a standalone example, it has been designed for the Microblaze Architecture.
* See the Interrupt Controller examples for an example of using the interrupts
* with PPC405 processor.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  02/13/02 First release
* 1.00b sv   04/26/05 Minor changes to comply to Doxygen and coding guidelines
* 1.00b sn   05/09/06 Modified to be used by TestAppGen to include test for
*                     interrupts.
*</pre>
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xtmrctr.h"
#include "xintc.h"
#ifdef __MICROBLAZE__
#include "mb_interface.h"
#endif

/************************** Constant Definitions *****************************/
#ifndef TESTAPP_GEN
/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are only defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define TMRCTR_DEVICE_ID            XPAR_TMRCTR_0_DEVICE_ID
#define INTC_DEVICE_ID              XPAR_INTC_0_DEVICE_ID
#define TMRCTR_INTERRUPT_ID         XPAR_INTC_0_TMRCTR_0_VEC_ID

/*
 * The following constant determines which timer counter of the device that is
 * used for this example, there are currently 2 timer counters in a device
 * and this example uses the first one, 0, the timer numbers are 0 based
 */
#define TIMER_CNTR_0                 0

#endif
/*
 * The following constant is used to set the reset value of the timer counter,
 * making this number larger reduces the amount of time this example consumes
 * because it is the value the timer counter is loaded with when it is started
 */
#define RESET_VALUE                     0xF0000000



/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

XStatus TmrCtrIntrExample(XIntc* IntcInstancePtr,
                          XTmrCtr* InstancePtr,
                          Xuint16 DeviceId,
                          Xuint16 IntrId,
                          Xuint8 TmrCtrNumber);

static XStatus TmrCtrSetupIntrSystem(XIntc* IntcInstancePtr,
                                    XTmrCtr* InstancePtr,
                                    Xuint16 DeviceId,
                                    Xuint16 IntrId,
                                    Xuint8 TmrCtrNumber);

void TimerCounterHandler(void *CallBackRef, Xuint8 TmrCtrNumber);

void TmrCtrDisableIntr(XIntc* IntcInstancePtr, Xuint16 IntrId);

/************************** Variable Definitions *****************************/
#ifndef TESTAPP_GEN
XIntc InterruptController;  /* The instance of the Interrupt Controller */

XTmrCtr TimerCounterInst;       /* The instance of the Timer Counter */
#endif
/*
 * The following variables are shared between non-interrupt processing and
 * interrupt processing such that they must be global.
 */
volatile int TimerExpired;


/*****************************************************************************/
/**
* This function is the main function of the Tmrctr example using Interrupts.
*
* @param    None
*
* @return   XST_SUCCESS to indicate success, else XST_FAILURE to indicate a
*           Failure.
*
* @note     None
*
******************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{

    XStatus Status;

    /*
     * Run the Timer Counter - Interrupt example.
     */
   Status = TmrCtrIntrExample(&InterruptController,
                              &TimerCounterInst,
                              TMRCTR_DEVICE_ID,
                              TMRCTR_INTERRUPT_ID,
                              TIMER_CNTR_0);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;

}
#endif

/*****************************************************************************/
/**
* This function does a minimal test on the timer counter device and driver as a
* design example.  The purpose of this function is to illustrate how to use the
* XTmrCtr component.  It initializes a timer counter and then sets it up in
* compare mode with auto reload such that a periodic interrupt is generated.
*
* This function uses interrupt driven mode of the timer counter.
*
* @param    IntcInstancePtr is a pointer to the Interrupt Controller
*           driver Instance
* @param    TmrCtrInstancePtr is a pointer to the XTmrCtr driver Instance
* @param    DeviceId is the XPAR_<TmrCtr_instance>_DEVICE_ID value from
*           xparameters.h
* @param    IntrId is XPAR_<INTC_instance>_<TmrCtr_instance>_INTERRUPT_INTR
*           value from xparameters.h
* @param    TmrCtrNumber is the number of the timer to which this
*           handler is associated with.
*
* @return   XST_SUCCESS if the Test is successful, otherwise XST_FAILURE
*
* @note     This function contains an infinite loop such that if interrupts are
*			not working it may never return.
*
*****************************************************************************/
XStatus TmrCtrIntrExample(XIntc* IntcInstancePtr,
                          XTmrCtr* TmrCtrInstancePtr,
                          Xuint16 DeviceId,
                          Xuint16 IntrId,
                          Xuint8 TmrCtrNumber)
{
    XStatus Status;
    int LastTimerExpired = 0;

    /*
     * Initialize the timer counter so that it's ready to use,
     * specify the device ID that is generated in xparameters.h
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

    /*
     * Connect the timer counter to the interrupt subsystem such that
     * interrupts can occur.  This function is application specific.
     */
    Status = TmrCtrSetupIntrSystem(IntcInstancePtr,
                                   TmrCtrInstancePtr,
                                   DeviceId,
                                   IntrId,
                                   TmrCtrNumber);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Setup the handler for the timer counter that will be called from the
     * interrupt context when the timer expires, specify a pointer to the
     * timer counter driver instance as the callback reference so the handler
     * is able to access the instance data
     */
    XTmrCtr_SetHandler(TmrCtrInstancePtr, TimerCounterHandler,
                       TmrCtrInstancePtr);

    /*
     * Enable the interrupt of the timer counter so interrupts will occur
     * and use auto reload mode such that the timer counter will reload
     * itself automatically and continue repeatedly, without this option
     * it would expire once only
     */
    XTmrCtr_SetOptions(TmrCtrInstancePtr, TmrCtrNumber,
                       XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);

    /*
     * Set a reset value for the timer counter such that it will expire
     * eariler than letting it roll over from 0, the reset value is loaded
     * into the timer counter when it is started
     */
    XTmrCtr_SetResetValue(TmrCtrInstancePtr, TmrCtrNumber, RESET_VALUE);

    /*
     * Start the timer counter such that it's incrementing by default,
     * then wait for it to timeout a number of times
     */
    XTmrCtr_Start(TmrCtrInstancePtr, TmrCtrNumber);

    while (1)
    {
        /*
         * Wait for the first timer counter to expire as indicated by the
         * shared variable which the handler will increment
         */
        while (TimerExpired == LastTimerExpired)
        {
        }
        LastTimerExpired = TimerExpired;

        /*
         * If it has expired a number of times, then stop the timer counter
         * and stop this example
         */
        if (TimerExpired == 3)
        {

            XTmrCtr_Stop(TmrCtrInstancePtr, TmrCtrNumber);
            break;
        }
    }

    TmrCtrDisableIntr(IntcInstancePtr, DeviceId);
    return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function is the handler which performs processing for the timer counter.
* It is called from an interrupt context such that the amount of processing
* performed should be minimized.  It is called when the timer counter expires
* if interrupts are enabled.
*
* This handler provides an example of how to handle timer counter interrupts
* but is application specific.
*
* @param    CallBackRef is a pointer to the callback function
* @param    TmrCtrNumber is the number of the timer to which this
*           handler is associated with.
*
* @return   None
*
* @note     None
*
******************************************************************************/
void TimerCounterHandler(void *CallBackRef, Xuint8 TmrCtrNumber)
{
    XTmrCtr *InstancePtr = (XTmrCtr *)CallBackRef;

    /*
     * Check if the timer counter has expired, checking is not necessary
     * since that's the reason this function is executed, this just shows
     * how the callback reference can be used as a pointer to the instance
     * of the timer counter that expired, increment a shared variable so
     * the main thread of execution can see the timer expired
     */
    if (XTmrCtr_IsExpired(InstancePtr, TmrCtrNumber))
    {
        TimerExpired++;
        if(TimerExpired == 3)
        {
	    XTmrCtr_SetOptions(InstancePtr, TmrCtrNumber, 0);
	 }
    }
}

/*****************************************************************************/
/**
* This function setups the interrupt system such that interrupts can occur
* for the timer counter.  This function is application specific since the actual
* system may or may not have an interrupt controller.  The timer counter could
* be directly connected to a processor without an interrupt controller.  The
* user should modify this function to fit the application.
*
* @param    IntcInstancePtr is a pointer to the Interrupt Controller
*           driver Instance
* @param    TmrCtrInstancePtr is a pointer to the XTmrCtr driver Instance
* @param    DeviceId is the XPAR_<TmrCtr_instance>_DEVICE_ID value from
*           xparameters.h
* @param    IntrId is XPAR_<INTC_instance>_<TmrCtr_instance>_INTERRUPT_INTR
*           value from xparameters.h
* @param    TmrCtrNumber is the number of the timer to which this
*           handler is associated with.
*
* @return   XST_SUCCESS if the Test is successful, otherwise XST_FAILURE
*
* @note     This function contains an infinite loop such that if interrupts are
*			not working it may never return.
*
******************************************************************************/
static XStatus TmrCtrSetupIntrSystem(XIntc* IntcInstancePtr,
                                     XTmrCtr* TmrCtrInstancePtr,
                                     Xuint16 DeviceId,
                                     Xuint16 IntrId,
                                     Xuint8 TmrCtrNumber)
{
     XStatus Status;

 #ifndef TESTAPP_GEN
    /*
     * Initialize the interrupt controller driver so that
     * it's ready to use, specify the device ID that is generated in
     * xparameters.h
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
     * interrupt processing for the device
     */

    Status = XIntc_Connect(IntcInstancePtr, IntrId,
                           (XInterruptHandler)XTmrCtr_InterruptHandler,
                           (void *)TmrCtrInstancePtr);

    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

#ifndef TESTAPP_GEN
    /*
     * Start the interrupt controller such that interrupts are enabled for
     * all devices that cause interrupts, specific real mode so that
     * the timer counter can cause interrupts thru the interrupt controller.
     */
    Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);

    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
#endif

    /*
     * Enable the interrupt for the timer counter
     */
    XIntc_Enable(IntcInstancePtr, IntrId);
#ifndef TESTAPP_GEN
    /*
     * Enable the Interrupts on the Microblaze
     */
    microblaze_enable_interrupts();
#endif
    return XST_SUCCESS;
}


/******************************************************************************/
/**
*
* This function disables the interrupts for the Timer
*
* @param    IntcInstancePtr is a reference to the Interrupt Controller
*           driver Instance
* @param    IntrId is XPAR_<INTC_instance>_<Timer_instance>_INTERRUPT_INTR
*           value from xparameters.h
*
* @return   None
*
* @note     None.
*
******************************************************************************/
void TmrCtrDisableIntr(XIntc* IntcInstancePtr, Xuint16 IntrId)
{
    /*
     * Disable the interrupt for the timer counter
     */
    XIntc_Disable(IntcInstancePtr, IntrId);

    return;
}





