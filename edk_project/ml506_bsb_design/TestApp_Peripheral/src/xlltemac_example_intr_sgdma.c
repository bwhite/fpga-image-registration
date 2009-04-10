#define TESTAPP_GEN

/* $Id: */
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
*       (c) Copyright 2007 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xlltemac_example_intr_sgdma.c
*
* Implements examples that utilize the TEMAC's interrupt driven SGDMA
* packet transfer mode to send and receive frames.
*
* These examples demonstrate:
*
* - How to perform simple send and receive
* - Interrupt coalescing
* - Checksum offload
* - Error handling
* - Device reset
*
* Functional guide to example:
*
* - TemacSgDmaIntrSingleFrameExample demonstrates the simplest way to send and
*   receive frames in in interrupt driven SGDMA mode.
*
* - TemacSgDmaIntrCoalescingExample demonstrates how to use interrupt
*   coalescing to increase throughput.
*
* - TemacSgDmaChecksumOffloadExample demonstrates the checksum offloading.
*   The HW must be setup for checksum offloading for this example to execute.
*
* - TemacTemacErrorHandler() demonstrates how to manage asynchronous errors.
*
* - TemacResetDevice() demonstrates how to reset the driver/HW without loosing
*   all configuration settings.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a rmm  06/01/05 First release
* 2.00a rmm  11/21/05 Added checksum offload example, added HW capability
*                     check prior to running example.
* 2.00a sv   06/12/06 Minor changes to comply to Doxygen and coding guidelines.
* 2.00b drg  02/08/08 Enable checksum offload example.
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xlltemac_example.h"
#include "xintc.h"

#ifdef __MICROBLAZE__
#include "mb_interface.h"
#else
#include "xexception_l.h"
#endif

#ifdef XPAR_XUARTNS550_NUM_INSTANCES
#include "xuartns550_l.h"
#endif
/*************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define TEMAC_DEVICE_ID   XPAR_LLTEMAC_0_DEVICE_ID
#define INTC_DEVICE_ID    XPAR_XPS_INTC_0_DEVICE_ID
#define TEMAC_IRPT_INTR   XPAR_INTC_0_LLTEMAC_0_VEC_ID 
#define DMA_RX_IRPT_INTR XPAR_INTC_0_MPMC_0_SDMA3_RX_INTOUT_VEC_ID 
#define DMA_TX_IRPT_INTR XPAR_INTC_0_MPMC_0_SDMA3_TX_INTOUT_VEC_ID 
#endif


#define RXBD_CNT        128	/* Number of RxBDs to use */
#define TXBD_CNT        128	/* Number of TxBDs to use */
#define BD_ALIGNMENT    XLLDMA_BD_MINIMUM_ALIGNMENT	/* Byte alignment of BDs */

#define CSUM_ENABLE     1
/*
 * Number of bytes to reserve for BD space for the number of BDs desired
 */
#define RXBD_SPACE_BYTES XLlDma_mBdRingMemCalc(BD_ALIGNMENT, RXBD_CNT)
#define TXBD_SPACE_BYTES XLlDma_mBdRingMemCalc(BD_ALIGNMENT, TXBD_CNT)


/*************************** Variable Definitions ****************************/

static EthernetFrame TxFrame;	/* Transmit buffer */
static EthernetFrame RxFrame;	/* Receive buffer */

/*
 * Aligned memory segments to be used for buffer descriptors
 */
char RxBdSpace[RXBD_SPACE_BYTES] __attribute__ ((aligned(BD_ALIGNMENT)));
char TxBdSpace[TXBD_SPACE_BYTES] __attribute__ ((aligned(BD_ALIGNMENT)));

/*
 * Counters to be incremented by callbacks
 */
static volatile int FramesRx;	/* Num of frames that have been received */
static volatile int FramesTx;	/* Num of frames that have been sent */
static volatile int DeviceErrors;	/* Num of errors detected in the device */

#ifndef TESTAPP_GEN
static XIntc IntcInstance;
#endif

/*************************** Function Prototypes *****************************/

/*
 * Examples
 */
int TemacSgDmaIntrExample(XIntc * IntcInstancePtr,
			  XLlTemac * TemacInstancePtr,
			  XLlDma * DmaInstancePtr,
			  u16 TemacDeviceId,
			  u16 TemacIntrId, u16 DmaRxIntrId, u16 DmaTxIntrId);


int TemacSgDmaIntrSingleFrameExample(XLlTemac * TemacInstancePtr,
				     XLlDma * DmaInstancePtr);

int TemacSgDmaIntrCoalescingExample(XLlTemac * TemacInstancePtr,
				    XLlDma * DmaInstancePtr);

int TemacSgDmaChecksumOffloadExample(XLlTemac * TemacInstancePtr,
				     XLlDma * DmaInstancePtr);


/*
 * Interrupt setup and Callbacks for examples
 */

static int TemacSetupIntrSystem(XIntc * IntcInstancePtr,
				XLlTemac * TemacInstancePtr,
				XLlDma * DmaInstancePtr,
				u16 TemacIntrId,
				u16 DmaRxIntrId, u16 DmaTxIntrId);

static void TemacDisableIntrSystem(XIntc * IntcInstancePtr,
				   u16 TemacIntrId,
				   u16 DmaRxIntrId, u16 DmaTxIntrId);

static void TemacErrorHandler(XLlTemac * Temac);
static void RxIntrHandler(XLlDma_BdRing * RxRingPtr);
static void TxIntrHandler(XLlDma_BdRing * TxRingPtr);

/*
 * Utility routines
 */
static int TemacResetDevice(XLlTemac * TemacInstancePtr,
			    XLlDma * DmaInstancePtr);


/*****************************************************************************/
/**
*
* This is the main function for the Temac example. This function is not included
* if the example is generated from the TestAppGen test  tool.
*
* @param    None.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
****************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
	int Status;


#ifdef XPAR_XUARTNS550_NUM_INSTANCES
    XUartNs550_SetBaud(STDIN_BASEADDRESS, XPAR_XUARTNS550_CLOCK_HZ, 115200);
    XUartNs550_mSetLineControlReg(STDIN_BASEADDRESS, XUN_LCR_8_DATA_BITS);
#endif

	/*
	 * Call the Temac SGDMA interrupt example , specify the parameters generated
	 * in xparameters.h
	 */
	Status = TemacSgDmaIntrExample(&IntcInstance,
				       &TemacInstance,
				       &DmaInstance,
				       TEMAC_DEVICE_ID,
				       TEMAC_IRPT_INTR,
				       DMA_RX_IRPT_INTR, DMA_TX_IRPT_INTR);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Failure in Examples");
		return XST_FAILURE;
	}

	TemacUtilErrorTrap("Success in Examples");
	return XST_SUCCESS;

}
#endif



/*****************************************************************************/
/**
*
* This function demonstrates the usage usage of the TEMAC by sending by sending
* and receiving frames in interrupt driven SGDMA mode.
*
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc component.
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
* @param    TemacDeviceId is Device ID of the Temac Device , typically
*           XPAR_<TEMAC_instance>_DEVICE_ID value from xparameters.h.
* @param    TemacIntrId is the Interrupt ID and is typically
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSgDmaIntrExample(XIntc * IntcInstancePtr,
			  XLlTemac * TemacInstancePtr,
			  XLlDma * DmaInstancePtr,
			  u16 TemacDeviceId,
			  u16 TemacIntrId, u16 DmaRxIntrId, u16 DmaTxIntrId)
{
	int Status;
	u32 Rdy;
	int dma_mode;
	XLlTemac_Config *MacCfgPtr;
	XLlDma_BdRing *RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	XLlDma_BdRing *TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);
	XLlDma_Bd BdTemplate;

    /*************************************/
	/* Setup device for first-time usage */
    /*************************************/

	/*
	 *  Initialize instance. Should be configured for SGDMA
	 */
	MacCfgPtr = XLlTemac_LookupConfig(TemacDeviceId);
	Status = XLlTemac_CfgInitialize(TemacInstancePtr, MacCfgPtr,
					MacCfgPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error in initialize");
		return XST_FAILURE;
	}

	XLlDma_Initialize(DmaInstancePtr, TemacInstancePtr->Config.LLDevBaseAddress);

	/*
	 * Check whether the IPIF interface is correct for this example
	 */
	dma_mode = XLlTemac_IsDma(TemacInstancePtr);
	if (! dma_mode) {
		TemacUtilErrorTrap
			("Device HW not configured for SGDMA mode\r\n");
		return XST_FAILURE;
	}

	/*
	 * Set the MAC address
	 */
	Status = XLlTemac_SetMacAddress(TemacInstancePtr, TemacMAC);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting MAC address");
		return XST_FAILURE;
	}

	/*
	 * Setup RxBD space.
	 *
	 * We have already defined a properly aligned area of memory to store RxBDs
	 * at the beginning of this source code file so just pass its address into
	 * the function. No MMU is being used so the physical and virtual addresses
	 * are the same.
	 *
	 * Setup a BD template for the Rx channel. This template will be copied to
	 * every RxBD. We will not have to explicitly set these again.
	 */
	XLlDma_mBdClear(&BdTemplate);

	/*
	 * Create the RxBD ring
	 */
	Status = XLlDma_BdRingCreate(RxRingPtr, (u32) &RxBdSpace,
				     (u32) &RxBdSpace, BD_ALIGNMENT, RXBD_CNT);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting up RxBD space");
		return XST_FAILURE;
	}
	Status = XLlDma_BdRingClone(RxRingPtr, &BdTemplate);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error initializing RxBD space");
		return XST_FAILURE;
	}

	/*
	 * Setup TxBD space.
	 *
	 * Like RxBD space, we have already defined a properly aligned area of
	 * memory to use.
	 */

	/*
	 * Create the TxBD ring
	 */
	Status = XLlDma_BdRingCreate(TxRingPtr, (u32) &TxBdSpace,
				     (u32) &TxBdSpace, BD_ALIGNMENT, TXBD_CNT);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting up TxBD space");
		return XST_FAILURE;
	}
	/*
	 * We reuse the bd template, as the same one will work for both rx and tx.
	 */
	Status = XLlDma_BdRingClone(TxRingPtr, &BdTemplate);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error initializing TxBD space");
		return XST_FAILURE;
	}

	/* Make sure the hard temac is ready */
	Rdy = XLlTemac_ReadReg(TemacInstancePtr->Config.BaseAddress,
			       XTE_RDY_OFFSET);
	while ((Rdy & XTE_RDY_HARD_ACS_RDY_MASK) == 0) {
		Rdy = XLlTemac_ReadReg(TemacInstancePtr->Config.BaseAddress,
				       XTE_RDY_OFFSET);
	}

	/*
	 * Set PHY to loopback
	 */
	TemacUtilEnterLoopback(TemacInstancePtr, TEMAC_LOOPBACK_SPEED);

	/*
	 * Set PHY<-->MAC data clock
	 */
	XLlTemac_SetOperatingSpeed(TemacInstancePtr, TEMAC_LOOPBACK_SPEED);

	/*
	 * Setting the operating speed of the MAC needs a delay.  There
	 * doesn't seem to be register to poll, so please consider this
	 * during your application design.
	 */
	TemacUtilPhyDelay(2);

	/*
	 * Connect to the interrupt controller and enable interrupts
	 */
	Status = TemacSetupIntrSystem(IntcInstancePtr,
				      TemacInstancePtr,
				      DmaInstancePtr,
				      TemacIntrId, DmaRxIntrId, DmaTxIntrId);


    /****************************/
	/* Run through the examples */
    /****************************/

	/*
	 * Run the Temac SGDMA Single Frame Interrupt example
	 */
	Status = TemacSgDmaIntrSingleFrameExample(TemacInstancePtr,
						  DmaInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Run the Temac SGDMA Interrupt Coalescing example
	 */
	Status = TemacSgDmaIntrCoalescingExample(TemacInstancePtr,
						 DmaInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Run the Temac SGDMA Checksum Offload example. The HW needs to be
	 * configured for checksum offloading for running this example
	 */
	if ((XLlTemac_IsRxCsum(TemacInstancePtr) &&
	     XLlTemac_IsTxCsum(TemacInstancePtr))) {
		Status = TemacSgDmaChecksumOffloadExample(TemacInstancePtr,
							  DmaInstancePtr);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
	}

	/*
	 * Disable the interrupts for the Temac device
	 */
	TemacDisableIntrSystem(IntcInstancePtr, TemacIntrId, DmaRxIntrId,
			       DmaTxIntrId);

	/*
	 * Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}



/*****************************************************************************/
/**
*
* This function demonstrates the usage of the TEMAC by sending and receiving
* a single frame in SGDMA interrupt mode.
* The source packet will be described by two descriptors. It will be received
* into a buffer described by a single descriptor.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSgDmaIntrSingleFrameExample(XLlTemac * TemacInstancePtr,
				     XLlDma * DmaInstancePtr)
{
	int Status;
	u32 TxFrameLength;
	int PayloadSize = 1000;
	XLlDma_BdRing *RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	XLlDma_BdRing *TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);
	XLlDma_Bd *Bd1Ptr;
	XLlDma_Bd *Bd2Ptr;

	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesTx = 0;
	DeviceErrors = 0;

	/*
	 * Calculate the frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

	/*
	 * Setup packet to be transmitted
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

        /*
         * Flush the TX frame before giving it to DMA TX channel to transmit,
         * in case D-Caching is turned on.
         */
	XCACHE_FLUSH_DCACHE_RANGE(&TxFrame, TxFrameLength);

	/*
	 * Clear out receive packet memory area
	 */
	TemacUtilFrameMemClear(&RxFrame);

        /*
         * Invalidate the RX frame before giving it to DMA RX channel to
         * receive data, in case D-Caching is turned on.
         */
	XCACHE_INVALIDATE_DCACHE_RANGE(&RxFrame, TxFrameLength);

	/*
	 * Start the LLTEMAC device and enable the ERROR interrupt
	 */
	XLlTemac_Start(TemacInstancePtr);
	XLlTemac_IntEnable(TemacInstancePtr, XTE_INT_RECV_ERROR_MASK);

	/*
	 * Allocate 1 RxBD. Note that TEMAC utilizes an in-place allocation
	 * scheme. The returned Bd1Ptr will point to a free BD in the memory
	 * segment setup with the call to XLlTemac_SgSetSpace()
	 */
	Status = XLlDma_BdRingAlloc(RxRingPtr, 1, &Bd1Ptr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error allocating RxBD");
		return XST_FAILURE;
	}

	/*
	 * Setup the BD. The BD template used in the call to XLlTemac_SgSetSpace()
	 * set the "last" field of all RxBDs. Therefore we are not required to
	 * issue a XLlDma_Bd_mSetLast(Bd1Ptr) here.
	 */
	XLlDma_mBdSetBufAddr(Bd1Ptr, &RxFrame);
	XLlDma_mBdSetLength(Bd1Ptr, sizeof(RxFrame));
	XLlDma_mBdSetStsCtrl(Bd1Ptr, XLLDMA_BD_STSCTRL_SOP_MASK | XLLDMA_BD_STSCTRL_EOP_MASK);

	/*
	 * Enqueue to HW
	 */
	Status = XLlDma_BdRingToHw(RxRingPtr, 1, Bd1Ptr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error committing RxBD to HW");
		return XST_FAILURE;
	}

	/*
	 * Enable DMA RX interrupt.
	 *
	 * Interrupt coalescing parameters are left at their default settings
	 * which is to interrupt the processor after every frame has been
	 * processed by the DMA engine.
	 */
	XLlDma_mBdRingIntEnable(RxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);

	/*
	 * Start DMA RX channel. Now it's ready to receive data.
	 */
	Status = XLlDma_BdRingStart(RxRingPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Allocate, setup, and enqueue 2 TxBDs. The first BD will describe
	 * the first 32 bytes of TxFrame and the second BD will describe the
	 * rest of the frame.
	 *
	 * The function below will allocate two adjacent BDs with Bd1Ptr being
	 * set as the lead BD.
	 */
	Status = XLlDma_BdRingAlloc(TxRingPtr, 2, &Bd1Ptr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error allocating TxBD");
		return XST_FAILURE;
	}

	/*
	 * Setup TxBD #1
	 */
	XLlDma_mBdSetBufAddr(Bd1Ptr, &TxFrame);
	XLlDma_mBdSetLength(Bd1Ptr, 32);
	XLlDma_mBdSetStsCtrl(Bd1Ptr, XLLDMA_BD_STSCTRL_SOP_MASK);

	/*
	 * Setup TxBD #2
	 */
	Bd2Ptr = XLlDma_mBdRingNext(TxRingPtr, Bd1Ptr);
	XLlDma_mBdSetBufAddr(Bd2Ptr, (u32) (&TxFrame) + 32);
	XLlDma_mBdSetLength(Bd2Ptr, TxFrameLength - 32);
	XLlDma_mBdSetStsCtrl(Bd2Ptr, XLLDMA_BD_STSCTRL_EOP_MASK);

	/*
	 * Enqueue to HW
	 */
	Status = XLlDma_BdRingToHw(TxRingPtr, 2, Bd1Ptr);
	if (Status != XST_SUCCESS) {
		/*
		 * Undo BD allocation and exit
		 */
		XLlDma_BdRingUnAlloc(TxRingPtr, 2, Bd1Ptr);
		TemacUtilErrorTrap("Error committing TxBD to HW");
		return XST_FAILURE;
	}

	/*
	 * Enable DMA transmit interrupts
	 */
	XLlDma_mBdRingIntEnable(TxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);

	/*
	 * Start DMA TX channel. Transmission starts at once.
	 */
	Status = XLlDma_BdRingStart(TxRingPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Wait for transmission to complete
	 */
	while (!FramesTx);

	/*
	 * Now that the frame has been sent, post process our TxBDs.
	 * Since we have only submitted 2 to HW, then there should be only 2 ready
	 * for post processing.
	 */
	if (XLlDma_BdRingFromHw(TxRingPtr, 2, &Bd1Ptr) == 0) {
		TemacUtilErrorTrap("TxBDs were not ready for post processing");
		return XST_FAILURE;
	}

	/*
	 * Examine the TxBDs.
	 *
	 * There isn't much to do. The only thing to check would be DMA exception
	 * bits. But this would also be caught in the error handler. So we just
	 * return these BDs to the free list
	 */
	Status = XLlDma_BdRingFree(TxRingPtr, 2, Bd1Ptr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error freeing up TxBDs");
		return XST_FAILURE;
	}


	/*
	 * Wait for Rx indication
	 */
	while (!FramesRx);

	/*
	 * Now that the frame has been received, post process our RxBD.
	 * Since we have only submitted 1 to HW, then there should be only 1 ready
	 * for post processing.
	 */
	if (XLlDma_BdRingFromHw(RxRingPtr, 1, &Bd1Ptr) == 0) {
		TemacUtilErrorTrap("RxBD was not ready for post processing");
		return XST_FAILURE;
	}

	/*
	 * There is no device status to check. If there was a DMA error, it
	 * should have been reported to the error handler. Check the receive
	 * length against the transmitted length, then verify the data.
	 *
	 * Note in LLTEMAC case, USR4_OFFSET word in the RX BD is used to store
	 * the real length of the received packet
	 */
	if (XLlDma_mBdRead(Bd1Ptr, XLLDMA_BD_USR4_OFFSET) != TxFrameLength) {
		TemacUtilErrorTrap("Length mismatch");
	}


	if (TemacUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
		TemacUtilErrorTrap("Data mismatch");
	}

	/*
	 * Return the RxBD back to the channel for later allocation. Free the
	 * exact number we just post processed.
	 */
	Status = XLlDma_BdRingFree(RxRingPtr, 1, Bd1Ptr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error freeing up TxBDs");
		return XST_FAILURE;
	}

	/*
	 * Finished this example. If everything worked correctly, all TxBDs and
	 * RxBDs should be free for allocation. Stop the device.
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This example sends frames with the interrupt coalescing settings altered
* from their defaults.
*
* The default settings will interrupt the processor after every frame has been
* sent. This example will increase the threshold resulting in lower CPU
* utilization since it spends less time servicing interrupts.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSgDmaIntrCoalescingExample(XLlTemac * TemacInstancePtr,
				    XLlDma * DmaInstancePtr)
{
	int Status;
	u32 TxFrameLength;
	int TxFramesToSend = 1000;
	int TxFramesSent = 0;
	int PayloadSize = XTE_MTU;
	u32 Index;
	u32 NumBd;
	u16 Threshold = 64;
	XLlDma_BdRing *RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	XLlDma_BdRing *TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);
	XLlDma_Bd *BdPtr, *BdCurPtr;

	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesTx = 0;
	DeviceErrors = 0;

	/*
	 * Calculate the frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

	/*
	 * Setup packet to be transmitted. The same packet will be transmitted
	 * over and over
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

        /*
         * Flush the TX frame before giving it to DMA TX channel to transmit,
         * in case D-Caching is turned on.
         */
	XCACHE_FLUSH_DCACHE_RANGE(&TxFrame, TxFrameLength);

	/*
	 * We don't care about the receive channel for this example, so turn it off
	 */
	Status = XLlTemac_ClearOptions(TemacInstancePtr,
				       XTE_RECEIVER_ENABLE_OPTION);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error clearing option");
		return XST_FAILURE;
	}

	/*
	 * Set the interrupt coalescing parameters for the test. The waitbound timer
	 * is set to 1 (ms) to catch the last few frames.
	 *
	 * If you set variable Threshold to some value larger than TXBD_CNT, then
	 * there can never be enough frames sent to meet the threshold. In this case
	 * the waitbound timer will always cause the interrupt to occur.
	 */
	Status = XLlDma_BdRingSetCoalesce(TxRingPtr, Threshold, 1);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting coalescing settings");
		return XST_FAILURE;
	}

	/*
	 * Prime the engine, allocate all BDs and assign them to the same buffer
	 */
	Status = XLlDma_BdRingAlloc(TxRingPtr, TXBD_CNT, &BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error allocating TxBDs prior to starting");
		return XST_FAILURE;
	}

	/*
	 * Setup the TxBDs
	 */
	BdCurPtr = BdPtr;

	for (Index = 0; Index < TXBD_CNT; Index++) {
		XLlDma_mBdSetBufAddr(BdCurPtr, &TxFrame);
		XLlDma_mBdSetLength(BdCurPtr, TxFrameLength);
		XLlDma_mBdSetStsCtrl(BdCurPtr, XLLDMA_BD_STSCTRL_SOP_MASK |
				     XLLDMA_BD_STSCTRL_EOP_MASK);
		BdCurPtr = XLlDma_mBdRingNext(TxRingPtr, BdCurPtr);
	}

	/*
	 *  Enqueue all TxBDs to HW
	 */
	Status = XLlDma_BdRingToHw(TxRingPtr, TXBD_CNT, BdPtr);

	TxFramesSent += TXBD_CNT;
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error committing TxBDs prior to starting");
		return XST_FAILURE;
	}

	/*
	 * Enable the send interrupts. Nothing should be transmitted yet as the
	 * device has not been started
	 */
	XLlDma_mBdRingIntEnable(TxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);
	/* Enable temac interrupts to capture errors */
	XLlTemac_IntEnable(TemacInstancePtr, XTE_INT_RECV_ERROR_MASK);

	/*
	 * Start the device. Transmission commences now!
	 */
	XLlTemac_Start(TemacInstancePtr);

	/*
	 * As DMA TX channel has been started in
	 * TemacSgDmaIntrSingleFrameExample() above, there is no need to start
	 * it again here
	 */

	while (TxFramesSent < TxFramesToSend) {
		/*
		 * Wait for the interrupt
		 */
		while (!FramesTx);

		/*
		 * Some TxBDs are ready for post processing. Get all that are available
		 * at the moment, free them, then allocate the same number and
		 * re-enqueue back to HW. At the same time this all occurs here,
		 * the DMA engine should be processing other TxBDs. If we can stay ahead
		 * of the transmitter like this, then throughput should be at or near
		 * line-rate.
		 *
		 * Note that this retrieves up to TXBD_CNT outstanding packets,
		 * so we may be processing more packets here than the threshold
		 * value, which may result in a seemingly spurious interrupt
		 * next time if we grab twice (or more) of the threshold value
		 * this time around (clear as mud, eh!).  Bottom line is that we
		 * ignore if NumBd returns as zero.
		 */
		NumBd = XLlDma_BdRingFromHw(TxRingPtr, TXBD_CNT, &BdPtr);
		if (NumBd > 0) {
			TxFramesSent += NumBd;

			/*
			 * Don't bother to check the BDs status, just free them
			 */
			Status = XLlDma_BdRingFree(TxRingPtr, NumBd, BdPtr);
			if (Status != XST_SUCCESS) {
				TemacUtilErrorTrap("Error freeing TxBDs");
			}

			/*
			 * Allocate the same number of BDs just freed
			 */
			Status = XLlDma_BdRingAlloc(TxRingPtr, NumBd, &BdPtr);
			if (Status != XST_SUCCESS) {
				TemacUtilErrorTrap("Error allocating TxBDs");
				return XST_FAILURE;
			}

			/*
			 * Setup the TxBDs
			 */
			BdCurPtr = BdPtr;
			for (Index = 0; Index < NumBd; Index++) {
				XLlDma_mBdSetBufAddr(BdCurPtr, &TxFrame);
				XLlDma_mBdSetLength(BdCurPtr, TxFrameLength);
				XLlDma_mBdSetStsCtrl(BdCurPtr,
						     XLLDMA_BD_STSCTRL_SOP_MASK
						     |
						     XLLDMA_BD_STSCTRL_EOP_MASK);
				BdCurPtr =
					XLlDma_mBdRingNext(TxRingPtr, BdCurPtr);
			}

			/*
			 * Enqueue TxBDs to HW
			 */
			Status = XLlDma_BdRingToHw(TxRingPtr, NumBd, BdPtr);
			if (Status != XST_SUCCESS) {
				TemacUtilErrorTrap
					("Error committing TxBDs prior to starting");
				return XST_FAILURE;
			}
		}

		/*
		 * Re-enable the interrupts
		 */
		FramesTx = 0;
		XLlDma_mBdRingIntEnable(TxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);
	}

	/*
	 * Wait a second and collect any remaining frames that had been
	 * queued up but not post processed
	 */
#ifndef __MICROBLAZE__
	usleep(1000000);
#else
	/*
	 * Not sure if we should depend on there being a timer core in a
	 * microblaze system
	 */
	TemacUtilPhyDelay(1);
#endif

	NumBd = XLlDma_BdRingFromHw(TxRingPtr, 0xFFFFFFFF, &BdPtr);

	if (NumBd > 0) {
		Status = XLlDma_BdRingFree(TxRingPtr, NumBd, BdPtr);
		if (Status != XST_SUCCESS) {
			TemacUtilErrorTrap("Error freeing TxBDs");
		}
	}

	/*
	 * Done sending frames. Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This example sends and receives a single packet in loopback mode with checksum
* offloading support.
*
* The transmit frame will be checksummed over the entire Ethernet payload
* and inserted into the last 2 bytes of the frame.
*
* On receive, HW should calculate the Ethernet payload checksum and return a
* value of 0xFFFF which means the payload data was likely not corrupted.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSgDmaChecksumOffloadExample(XLlTemac * TemacInstancePtr,
				     XLlDma * DmaInstancePtr)
{
	int Status;
	u32 TxFrameLength;
	int PayloadSize = 1000;
	XLlDma_BdRing *RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	XLlDma_BdRing *TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);
	XLlDma_Bd *BdPtr;

	/*
	 * Cannot run this example if checksum offloading support is not available
	 */
	if (!(XLlTemac_IsRxCsum(TemacInstancePtr) &&
	      XLlTemac_IsTxCsum(TemacInstancePtr))) {
		TemacUtilErrorTrap("Checksum offloading not available");
		return XST_FAILURE;
	}

	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesTx = 0;
	DeviceErrors = 0;

	/*
	 * Calculate frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

	/*
	 * Setup the packet to be transmitted,
	 * Last 2 bytes are reserved for checksum
	 */
	TemacUtilFrameMemClear(&TxFrame);
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize - 2);

        /*
         * Flush the TX frame before giving it to DMA TX channel to transmit,
         * in case D-Caching is turned on.
         */
	XCACHE_FLUSH_DCACHE_RANGE(&TxFrame, TxFrameLength);

	/*
	 * Clear out receive packet memory area
	 */
	TemacUtilFrameMemClear(&RxFrame);

        /*
         * Invalidate the RX frame before giving it to DMA RX channel to
         * receive data, in case D-Caching is turned on.
         */
	XCACHE_INVALIDATE_DCACHE_RANGE(&RxFrame, TxFrameLength);

	/*
	 * Interrupt coalescing parameters are set to their default settings
	 * which is to interrupt the processor after every frame has been
	 * processed by the DMA engine.
	 */
	Status = XLlDma_BdRingSetCoalesce(TxRingPtr, 1, 1);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting coalescing for transmit");
		return XST_FAILURE;
	}

	Status = XLlDma_BdRingSetCoalesce(RxRingPtr, 1, 1);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting coalescing for recv");
		return XST_FAILURE;
	}

	/*
	 * Make sure Tx and Rx are enabled
	 */
	Status = XLlTemac_SetOptions(TemacInstancePtr,
				     XTE_RECEIVER_ENABLE_OPTION |
				     XTE_TRANSMITTER_ENABLE_OPTION);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting options");
		return XST_FAILURE;
	}

	/*
	 * Start the LLTEMAC and enable its ERROR interrupts
	 */
	XLlTemac_Start(TemacInstancePtr);
	XLlTemac_IntEnable(TemacInstancePtr, XTE_INT_RECV_ERROR_MASK);

	/*
	 * Allocate 1 RxBD. Note that TEMAC utilizes an in-place allocation
	 * scheme. The returned BdPtr will point to a free BD in the memory
	 * segment setup with the call to XLlTemac_SgSetSpace()
	 */
	Status = XLlDma_BdRingAlloc(RxRingPtr, 1, &BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error allocating RxBD");
		return XST_FAILURE;
	}

	/*
	 * Setup the BD. The BD template used in the call to XLlTemac_SgSetSpace()
	 * set the SOP and EOP fields of all RxBDs.
	 */
	XLlDma_mBdSetBufAddr(BdPtr, &RxFrame);
	XLlDma_mBdSetLength(BdPtr, sizeof(RxFrame));
	XLlDma_mBdSetStsCtrl(BdPtr, XLLDMA_BD_STSCTRL_SOP_MASK |
			     XLLDMA_BD_STSCTRL_EOP_MASK);


	/*
	 * Enqueue to HW
	 */
	Status = XLlDma_BdRingToHw(RxRingPtr, 1, BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error committing RxBD to HW");
		return XST_FAILURE;
	}

	/*
	 * Enable DMA receive related interrupts
	 */
	XLlDma_mBdRingIntEnable(RxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);

	/*
	 * As DMA RX channel has been started in
	 * TemacSgDmaIntrSingleFrameExample() above, there is no need to start
	 * it again here
	 */

	/*
	 * Allocate 1 TxBD
	 */
	Status = XLlDma_BdRingAlloc(TxRingPtr, 1, &BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error allocating TxBD");
		return XST_FAILURE;
	}

	/*
	 * Setup the TxBD
	 */
	XLlDma_mBdSetBufAddr(BdPtr, &TxFrame);
	XLlDma_mBdSetLength(BdPtr, TxFrameLength);
	XLlDma_mBdSetStsCtrl(BdPtr, XLLDMA_BD_STSCTRL_SOP_MASK |
			     XLLDMA_BD_STSCTRL_EOP_MASK);

	/*
	 * Setup TxBd checksum offload attributes.
	 * Note that the checksum offload values can be set globally for all TxBds
	 * when XLlDma_BdRingClone() is called to setup Tx BD space. This would
	 * eliminate the need to set them here.
	 */

	/* Enable hardware checksum computation for the buffer descriptor */
	XLlDma_mBdWrite((BdPtr), XLLDMA_BD_STSCTRL_USR0_OFFSET,
			(XLlDma_mBdRead((BdPtr), XLLDMA_BD_STSCTRL_USR0_OFFSET)
			 | CSUM_ENABLE));
	/* Write Start Offset and Insert Offset into BD */
	XLlDma_mBdWrite(BdPtr, XLLDMA_BD_USR1_OFFSET,
					XTE_HDR_SIZE << 16 | TxFrameLength - 2);
	/* Write 0, as the seed value, to the BD */
	XLlDma_mBdWrite(BdPtr, XLLDMA_BD_USR2_OFFSET, 0);
	/*
	 * Enqueue to HW
	 */
	Status = XLlDma_BdRingToHw(TxRingPtr, 1, BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error committing TxBD to HW");
		return XST_FAILURE;
	}

	/*
	 * Enable DMA transmit related interrupts
	 */
	XLlDma_mBdRingIntEnable(TxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);

	/*
	 * As DMA TX channel has been started in
	 * TemacSgDmaIntrSingleFrameExample() above, there is no need to start
	 * it again here
	 */

	/*
	 * Wait for transmission to complete
	 */
	while (!FramesTx);
	/*
	 * Now that the frame has been sent, post process our TxBDs.
	 * Since we have only submitted 2 to HW, then there should be only 2 ready
	 * for post processing.
	 */
	if (XLlDma_BdRingFromHw(TxRingPtr, 1, &BdPtr) == 0) {
		TemacUtilErrorTrap("TxBDs were not ready for post processing");
		return XST_FAILURE;
	}

	/*
	 * Examine the TxBDs.
	 *
	 * There isn't much to do. The only thing to check would be DMA exception
	 * bits. But this would also be caught in the error handler. So we just
	 * return these BDs to the free list
	 */
	Status = XLlDma_BdRingFree(TxRingPtr, 1, BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error freeing up TxBDs");
		return XST_FAILURE;
	}

	/*
	 * Wait for Rx indication
	 */
	while (!FramesRx);
	/*
	 * Now that the frame has been received, post process our RxBD.
	 * Since we have only submitted 1 to HW, then there should be only 1 ready
	 * for post processing.
	 */
	if (XLlDma_BdRingFromHw(RxRingPtr, 1, &BdPtr) == 0) {
		TemacUtilErrorTrap("RxBD was not ready for post processing");
		return XST_FAILURE;
	}

	/*
	 * There is no device status to check. If there was a DMA error, it should
	 * have been reported to the error handler. Check the receive length against
	 * the transmitted length, then verify the data.
	 *
	 * Note in LLTEMAC case, USR4_OFFSET word in the RX BD is used to store
	 * the real length of the received packet
	 */
	if (XLlDma_mBdRead(BdPtr, XLLDMA_BD_USR4_OFFSET) != TxFrameLength) {
		TemacUtilErrorTrap("Length mismatch");
	}

	/*
	 * Verify the checksum as computed by HW. It should add up to 0xFFFF
	 * if frame was uncorrupted
	 */
	if ((u16) (XLlDma_mBdRead(BdPtr, XLLDMA_BD_USR3_OFFSET))
		!= 0xFFFF) {
		TemacUtilErrorTrap("Rx checksum incorrect");
		return XST_FAILURE;
	}

	/*
	 * Return the RxBD back to the channel for later allocation. Free the
	 * exact number we just post processed.
	 */
	Status = XLlDma_BdRingFree(RxRingPtr, 1, BdPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error freeing up TxBDs");
		return XST_FAILURE;
	}

	/*
	 * Finished this example. If everything worked correctly, all TxBDs and
	 * RxBDs should be free for allocation. Stop the device.
	 */
	XLlTemac_Stop(TemacInstancePtr);
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This is the DMA TX callback function to be called by TX interrupt handler.
* This function handles BDs finished by hardware.
*
* @param    TxRingPtr is a pointer to TX channel of the DMA engine.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void TxCallBack(XLlDma_BdRing * TxRingPtr)
{
	/*
	 * Disable the transmit related interrupts
	 */
	XLlDma_mBdRingIntDisable(TxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);
	/*
	 * Increment the counter so that main thread knows something happened
	 */
	FramesTx++;
}

/*****************************************************************************/
/**
*
* This is the DMA TX Interrupt handler function.
*
* @param    Callback is a pointer to TX channel of the DMA engine.
*
* @return   None.
*
* @note     This Interrupt handler MUST clear pending interrupts before
*           handling them by calling the call back. Otherwise the following
*           corner case could raise some issue:
*
*           - A packet was transmitted and asserted an TX interrupt, and if
*             this interrupt handler calls the call back before clears the
*             interrupt, another packet could get transmitted (and assert the
*             interrupt) between when the call back function returned and when
*             the interrupt clearing operation begins, and the interrupt
*             clearing operation will clear the interrupt raised by the second
*             packet and won't never process its according buffer descriptors
*             until a new interrupt occurs.
*
*           Changing the sequence to "Clear interrupts, then handle" solve this
*           issue. If the interrupt raised by the second packet is before the
*           the interrupt clearing operation, the descriptors associated with
*           the second packet must have been finished by hardware and ready for
*           the handling by the call back; otherwise, the interrupt raised by
*           the second packet is after the interrupt clearing operation,
*           the packet's buffer descriptors will be handled by the call back in
*           current pass, if the descriptors are finished before the call back
*           is invoked, or next pass otherwise. Please note that if the second
*           packet is handled by the call back in current pass, the next pass
*           could find no buffer descriptor finished by the hardware.
*
******************************************************************************/
static void TxIntrHandler(XLlDma_BdRing * TxRingPtr)
{
	u32 IrqStatus;

	/* Read pending interrupts */
	IrqStatus = XLlDma_mBdRingGetIrq(TxRingPtr);

	/* Acknowledge pending interrupts */
	XLlDma_mBdRingAckIrq(TxRingPtr, IrqStatus);

	/* If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XLLDMA_IRQ_ALL_ERR_MASK)) {
		DeviceErrors++;
		TemacUtilErrorTrap
		("LlDma: Error: IrqStatus & XLLDMA_IRQ_ALL_ERR_MASK");
		XLlDma_Reset(&DmaInstance);
		return;
	}

	/*
	 * If Transmit done interrupt is asserted, call TX call back function
	 * to handle the processed BDs and raise the according flag
	 */
	if ((IrqStatus & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
		TxCallBack(TxRingPtr);
	}
}



/*****************************************************************************/
/**
*
* This is the DMA RX callback function to be called by RX interrupt handler.
* This function handles finished BDs by hardware, attaches new buffers to those
* BDs, and give them back to hardware to receive more incoming packets
*
* @param    RxRingPtr is a pointer to RX channel of the DMA engine.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void RxCallBack(XLlDma_BdRing * RxRingPtr)
{
	/*
	 * Disable the receive related interrupts
	 */
	XLlDma_mBdRingIntDisable(RxRingPtr, XLLDMA_CR_IRQ_ALL_EN_MASK);

	/*
	 * Increment the counter so that main thread knows something happened
	 */
	FramesRx++;
}


/*****************************************************************************/
/**
*
* This is the Receive handler function for examples 1 and 2.
* It will increment a shared  counter, receive and validate the frame.
*
* @param    RxRingPtr is a pointer to the DMA ring instance.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void RxIntrHandler(XLlDma_BdRing * RxRingPtr)
{
	u32 IrqStatus;

	/* Read pending interrupts */
	IrqStatus = XLlDma_mBdRingGetIrq(RxRingPtr);

	/* Acknowledge pending interrupts */
	XLlDma_mBdRingAckIrq(RxRingPtr, IrqStatus);

	/* If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XLLDMA_IRQ_ALL_ERR_MASK)) {
		DeviceErrors++;
		TemacUtilErrorTrap ("LlDma: Error: IrqStatus & XLLDMA_IRQ_ALL_ERR_MASK");
		XLlDma_Reset(&DmaInstance);
		return;
	}

	/*
	 * If Reception done interrupt is asserted, call RX call back function
	 * to handle the processed BDs and then raise the according flag.
	 */
	if ((IrqStatus & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
		RxCallBack(RxRingPtr);
	}
}

/*****************************************************************************/
/**
*
* This is the Error handler callback function and this function increments the
* the error counter so that the main thread knows the number of errors.
*
* @param    Temac is a reference to the Temac device instance.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void TemacErrorHandler(XLlTemac * Temac)
{
	u32 Pending = XLlTemac_IntPending(Temac);

	if (Pending & XTE_INT_RXRJECT_MASK) {
		TemacUtilErrorTrap("Temac: Rx packet rejected");
	}

	if (Pending & XTE_INT_RXFIFOOVR_MASK) {
		TemacUtilErrorTrap("Temac: Rx fifo over run");
	}

	XLlTemac_IntClear(Temac, Pending);

	/*
	 * Bump counter
	 */
	DeviceErrors++;
}


/******************************************************************************/
/**
* This function resets the device but preserves the options set by the user.
*
* The descriptor list could be reinitialized with the same calls to
* XLlTemac_SgSetSpace() as used in main(). Doing this is a matter of preference.
* In many cases, an OS may have resources tied up in the descriptors.
* Reinitializing in this case may bad for the OS since its resources may be
* permamently lost.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS if successful, else XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static int TemacResetDevice(XLlTemac * TemacInstancePtr,
				XLlDma * DmaInstancePtr)
{
	int Status;
	u8 MacSave[6];
	u32 Options;
	u32 RxThreshold = 1;
	u32 TxThreshold = 1;
	u32 RxWaitbound = 0;
	u32 TxWaitbound = 0;
	XLlDma_BdRing * RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	XLlDma_BdRing * TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);

	/*
	 * Stop LLTEMAC device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	/*
	 * Save the device state
	 */
	XLlTemac_GetMacAddress(TemacInstancePtr, MacSave);
	Options = XLlTemac_GetOptions(TemacInstancePtr);

	/*
	 * Stop and reset the device
	 */
	XLlTemac_Reset(TemacInstancePtr, XTE_NORESET_HARD);

	/*
	 * Restore the state
	 */
	Status = XLlTemac_SetMacAddress(TemacInstancePtr, MacSave);
	Status |= XLlTemac_SetOptions(TemacInstancePtr, Options);
	Status |= XLlTemac_ClearOptions(TemacInstancePtr, ~Options);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error restoring state after reset");
		return XST_FAILURE;
	}

	/*
	 * Restart the device
	 */
	XLlTemac_Start(TemacInstancePtr);
	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This function setups the interrupt system so interrupts can occur for the
* TEMAC.  This function is application-specific since the actual system may or
* may not have an interrupt controller.  The TEMAC could be directly connected
* to a processor without an interrupt controller.  The user should modify this
* function to fit the application.
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc component.
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
* @param    TemacIntrId is the Interrupt ID and is typically
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static int TemacSetupIntrSystem(XIntc *IntcInstancePtr,
				XLlTemac *TemacInstancePtr,
				XLlDma *DmaInstancePtr,
				u16 TemacIntrId,
				u16 DmaRxIntrId,
				u16 DmaTxIntrId)
{
	XLlDma_BdRing * TxRingPtr = &XLlDma_mGetTxRing(DmaInstancePtr);
	XLlDma_BdRing * RxRingPtr = &XLlDma_mGetRxRing(DmaInstancePtr);
	int Status;
#ifndef TESTAPP_GEN
	/*
	 * Initialize the interrupt controller and connect the ISR
	 */
	Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Unable to intialize the interrupt controller");
		return XST_FAILURE;
	}
#endif
	Status = XIntc_Connect(IntcInstancePtr, TemacIntrId,
			       (XInterruptHandler)
			       TemacErrorHandler,
			       TemacInstancePtr);
	Status |= XIntc_Connect(IntcInstancePtr, DmaTxIntrId,
				(XInterruptHandler) TxIntrHandler,
				TxRingPtr);
	Status |= XIntc_Connect(IntcInstancePtr, DmaRxIntrId,
				(XInterruptHandler) RxIntrHandler,
				RxRingPtr);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Unable to connect ISR to interrupt controller");
		return XST_FAILURE;
	}

#ifndef TESTAPP_GEN
	/*
	 * Start the interrupt controller
	 */
	Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error starting intc");
		return XST_FAILURE;
	}
#endif


	/*
	 * Enable interrupts from the hardware
	 */
	XIntc_Enable(IntcInstancePtr, TemacIntrId);
	XIntc_Enable(IntcInstancePtr, DmaTxIntrId);
	XIntc_Enable(IntcInstancePtr, DmaRxIntrId);
#ifndef TESTAPP_GEN
#ifdef __PPC__
	/*
	 * Initialize the PPC exception table
	 */
	XExc_Init();
	/*
	 * Register the interrupt controller with the exception table
	 */
	XExc_RegisterHandler(XEXC_ID_NON_CRITICAL_INT,
				(XExceptionHandler)
				XIntc_InterruptHandler,
				IntcInstancePtr);
	/*
	 * Enable non-critical exceptions
	 */
	XExc_mEnableExceptions(XEXC_NON_CRITICAL);
#else
	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the microblaze processor.
	 */
	microblaze_register_handler((XInterruptHandler)
			XIntc_InterruptHandler, IntcInstancePtr);

	/*
	* Enable interrupts in the Microblaze
	*/
	microblaze_enable_interrupts();
#endif
#endif
	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function disables the interrupts that occur for Temac.
*
* @param    IntcInstancePtr is the pointer to the instance of the Intc
*           component.
* @param    TemacIntrId is interrupt ID and is typically
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void TemacDisableIntrSystem(XIntc *IntcInstancePtr,
				   u16 TemacIntrId,
				   u16 DmaRxIntrId,
				   u16 DmaTxIntrId)
{

	/* Disconnect the interrupts for the DMA TX and RX channels */

	XIntc_Disconnect(IntcInstancePtr, DmaTxIntrId);
	XIntc_Disconnect(IntcInstancePtr, DmaRxIntrId);
	/*
	 * Disconnect and disable the interrupt for the Temac device
	 */
	XIntc_Disconnect(IntcInstancePtr, TemacIntrId);
}

