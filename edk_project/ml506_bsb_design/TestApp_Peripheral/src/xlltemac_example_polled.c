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
* @file xlltemac_example_polled.c
*
* Implements examples that utilize the TEMAC's FIFO direct frame transfer
* mode in a polled fashion to send and receive frames.
*
* These examples demonstrate:
*
* - How to perform simple polling send and receive.
* - Advanced frame processing
* - Error handling
*
* Functional guide to example:
*
* - TemacSingleFramePolledExample() demonstrates the simplest way to send and
*   receive frames in polled mode.
*
* - TemacMultipleFramesPolledExample() demonstrates how to transmit a "burst" of
*   frames by queueing up several in the packet FIFO prior to transmission.
*
* - TemacPollForTxStatus() demonstrates how to poll for transmit complete status
*   and how to handle error conditions.
*
* - TemacPollForRxStatus() demonstrates how to poll for receive status and how
*   to handle error conditions.
*
* - TemacResetDevice() demonstrates how to reset the driver/HW without losing
*   all configuration settings.
*
* Note that the advanced frame processing algorithms shown here are not limited
* to polled mode operation. The same techniques can be used for FIFO direct
* interrupt driven mode as well.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a rmm  06/01/05 First release
* 2.00a rmm  11/21/05 Added call to TemaUtilEnterLoopback(),
* 2.00a sv   06/12/06 Minor changes to comply to Doxygen and coding guidelines
*
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xlltemac_example.h"

/************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define TEMAC_DEVICE_ID   XPAR_LLTEMAC_0_DEVICE_ID
#define FIFO_DEVICE_ID    XPAR_LLFIFO_0_DEVICE_ID
#endif

/************************** Variable Definitions ****************************/

EthernetFrame TxFrame;		/* Transmit frame buffer */
EthernetFrame RxFrame;		/* Receive frame buffer */

/************************** Function Prototypes *****************************/

int TemacPolledExample(u16 TemacDeviceId, u16 FifoDeviceId);
int TemacSingleFramePolledExample();
int TemacMultipleFramesPolledExample();

int TemacPollForTxStatus();
int TemacPollForRxStatus();
int TemacResetDevice();

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


	/*
	 * Call the Temac polled example , specify the Device ID generated in
	 * xparameters.h
	 */
	Status = TemacPolledExample(TEMAC_DEVICE_ID, FIFO_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;

}
#endif

/*****************************************************************************/
/**
*
* This function demonstrates the usage of the TEMAC by sending and receiving
* frames in polled mode.
*
*
* @param    TemacDeviceId is device ID of the Temac Device , typically
*           XPAR_<TEMAC_instance>_DEVICE_ID value from xparameters.h
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE
*
* @note     None.
*
******************************************************************************/
int TemacPolledExample(u16 TemacDeviceId, u16 FifoDeviceId)
{
	int Status;
	XLlTemac_Config *MacCfgPtr;
	u32 Rdy;

	/*************************************/
	/* Setup device for first-time usage */
	/*************************************/

	/*
	 * Initialize the FIFO and TEMAC instance
	 */
	MacCfgPtr = XLlTemac_LookupConfig(TemacDeviceId);
	Status = XLlTemac_CfgInitialize(&TemacInstance, MacCfgPtr,
					MacCfgPtr->BaseAddress);

	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error in initialize");
		return XST_FAILURE;
	}
	XLlFifo_Initialize(&FifoInstance,
			    XLlTemac_LlDevBaseAddress(&TemacInstance));

	/*
	 * Check whether the IPIF interface is correct for this example
	 */
	if (!XLlTemac_IsFifo(&TemacInstance)) {
		TemacUtilErrorTrap
			("Device HW not configured for FIFO direct mode\r\n");
		return XST_FAILURE;
	}

	/*
	 * Set the MAC  address
	 */
	Status = XLlTemac_SetMacAddress(&TemacInstance, (u8 *) TemacMAC);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting MAC address");
		return XST_FAILURE;
	}

        /* Make sure the hard temac is ready */
	Rdy = XLlTemac_ReadReg(TemacInstance.Config.BaseAddress,
			       XTE_RDY_OFFSET);
	while ((Rdy & XTE_RDY_HARD_ACS_RDY_MASK) == 0) {
		Rdy = XLlTemac_ReadReg(TemacInstance.Config.BaseAddress,
				       XTE_RDY_OFFSET);
	}

	/*
	 * Set PHY to loopback
	 */
	Status = TemacUtilEnterLoopback(&TemacInstance, TEMAC_LOOPBACK_SPEED);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting the PHY loopback");
		return XST_FAILURE;
	}


	/*
	 * Set PHY<-->MAC data clock
	 */
	XLlTemac_SetOperatingSpeed(&TemacInstance, TEMAC_LOOPBACK_SPEED);

	/*
	 * Setting the operating speed of the MAC needs a delay.  There
	 * doesn't seem to be register to poll, so please consider this
	 * during your application design.
	 */
	TemacUtilPhyDelay(2);

	/****************************/
	/* Run through the examples */
	/****************************/

	/*
	 * Run the Single Frame polled example
	 */
	Status = TemacSingleFramePolledExample();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Run the Multiple Frames polled example
	 */
	Status = TemacMultipleFramesPolledExample();
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;


}


/*****************************************************************************/
/**
*
* This function demonstrates the usage of the TEMAC by sending and receiving
* a single frame in polled mode.
*
* @param    None.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSingleFramePolledExample(void)
{
	int Status;
	u32 FifoFreeBytes;
	int PayloadSize = 100;
	u32 TxFrameLength;
	u32 RxFrameLength;

	/*
	 * Start the TEMAC device
	 */
	XLlTemac_Start(&TemacInstance);

	/*
	 * Setup the packet to be transmitted
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

	/*
	 * Clear out the receive packet memory area
	 */
	TemacUtilFrameMemClear(&RxFrame);

	/*
	 * Calculate frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

    /*******************/
	/* Send the packet */
    /*******************/

	/*
	 * Wait for enough room in FIFO to become available
	 */
	do {
		FifoFreeBytes = XLlFifo_TxVacancy(&FifoInstance);
	} while (FifoFreeBytes < TxFrameLength);

	/*
	 * Write the frame data to FIFO
	 */
	XLlFifo_Write(&FifoInstance, TxFrame, TxFrameLength);

	/*
	 * Initiate transmit
	 */
	XLlFifo_TxSetLen(&FifoInstance, TxFrameLength);

	/*
	 * Wait for status of the transmitted packet
	 */
	switch (TemacPollForTxStatus()) {
	case XST_SUCCESS:	/* Got a sucessfull transmit status */
		break;

	case XST_NO_DATA:	/* Timed out */
		TemacUtilErrorTrap("Tx timeout");
		return XST_FAILURE;

	default:		/* Some other error */
		return XST_FAILURE;
	}

    /**********************/
	/* Receive the packet */
    /**********************/

	/*
	 * Wait for packet Rx
	 */
	switch (TemacPollForRxStatus()) {
	case XST_SUCCESS:	/* Got a sucessfull receive status */
		break;

	case XST_NO_DATA:	/* Timed out */
		TemacUtilErrorTrap("Rx timeout");
		return XST_FAILURE;

	default:		/* Some other error */
		return XST_FAILURE;
	}

	/*
	 * A packet as arrived, get its length
	 */
	RxFrameLength = XLlFifo_RxGetLen(&FifoInstance);

	/*
	 * Read the received packet data
	 */
	XLlFifo_Read(&FifoInstance, &RxFrame, RxFrameLength);

	/*
	 * Verify the received frame length
	 */
	if ((RxFrameLength) != TxFrameLength) {
		TemacUtilErrorTrap("Receive length incorrect");
		return XST_FAILURE;
	}

	/*
	 * Validate frame data
	 */
	if (TemacUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
		TemacUtilErrorTrap("Receive Data mismatch");
		return XST_FAILURE;
	}

	/*
	 * Stop device
	 */
	XLlTemac_Stop(&TemacInstance);

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This example uses polled mode to queue up multiple frames in the packet
* FIFOs before sending them in a single burst. Receive packets are handled in
* a similar way.
*
* @param    None.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacMultipleFramesPolledExample(void)
{
	u32 FramesToLoopback;
	u32 PayloadSize;
	int Status;
	u32 TxFrameLength;
	u32 RxFrameLength;
	u32 FifoFreeBytes;
	u32 Index;

	/*
	 * Start the TEMAC device
	 */
	XLlTemac_Start(&TemacInstance);

	/*
	 * Setup the number of frames to loopback (FramesToLoopback) and the size
	 * of the frame (PayloadSize) to loopback. The default settings should
	 * work for every case. Modifying the settings can cause problems, see
	 * discussion below:
	 *
	 * If PayloadSize is set small and FramesToLoopback high, then it is
	 * possible to cause the transmit status FIFO to overflow.
	 *
	 * If PayloadSize is set large and FramesToLoopback high, then it is
	 * possible to cause the transmit packet FIFO to overflow.
	 *
	 * Either of these scenarios may be worth trying out to observe how the
	 * driver reacts. The exact values to cause these types of errors
	 * will vary due to the sizes of the FIFOs selected at hardware build
	 * time. But the following settings should create problems for all
	 * FIFO sizes:
	 *
	 * Transmit status FIFO overflow
	 *    PayloadSize = 1
	 *    FramesToLoopback = 1000
	 *
	 * Transmit packet FIFO overflow
	 *    PayloadSize = 1500
	 *    FramesToLoopback = 16
	 *
	 * These values should always work without error
	 *    PayloadSize = 100
	 *    FramesToLoopback = 5
	 */
	PayloadSize = 100;
	FramesToLoopback = 5;

	/*
	 * Calculate Tx frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

	/*
	 * Setup the packet to be transmitted
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

    /****************/
	/* Send packets */
    /****************/

	/*
	 * Since we may be interested to see what happens when FIFOs overflow, don't
	 * check for room in the transmit packet FIFO prior to writing to it.
	 */

	/*
	 * Write frame data to FIFO
	 * Fifo core only allows loading and sending one frame at a time.
	 */
	for (Index = 0; Index < FramesToLoopback; Index++) {
		/* Make sure there is room in the FIFO */
		do {
			FifoFreeBytes = XLlFifo_TxVacancy(&FifoInstance);
		} while (FifoFreeBytes < TxFrameLength);

		XLlFifo_Write(&FifoInstance, TxFrame, TxFrameLength);
		XLlFifo_TxSetLen(&FifoInstance, TxFrameLength);

		switch (TemacPollForTxStatus()) {
		case XST_SUCCESS:	/* Got a sucessfull transmit status */
			break;

		case XST_NO_DATA:	/* Timed out */
			TemacUtilErrorTrap("Tx timeout");
			return XST_FAILURE;
			break;

		default:	/* Some other error */
			TemacResetDevice();
			return XST_FAILURE;
		}
	}

    /**********************/
	/* Receive the packet */
    /**********************/

	/*
	 * Wait for the packets to arrive
	 * The Fifo core only allows us to pull out one frame at a time.
	 */
	for (Index = 0; Index < FramesToLoopback; Index++) {
		/*
		 * Wait for packet Rx
		 */
		switch (TemacPollForRxStatus()) {
		case XST_SUCCESS:	/* Got a successfull receive status */
			break;

		case XST_NO_DATA:	/* Timed out */
			TemacUtilErrorTrap("Rx timeout");
			return XST_FAILURE;
			break;

		default:	/* Some other error */
			TemacResetDevice();
			return XST_FAILURE;
		}

		/*
		 * A packet has arrived, get its length
		 */
		RxFrameLength = XLlFifo_RxGetLen(&FifoInstance);

		/*
		 * Verify the received frame length
		 */
		if ((RxFrameLength) != TxFrameLength) {
			TemacUtilErrorTrap("Receive length incorrect");
			return XST_FAILURE;
		}
		/*
		 * Read the received packet data
		 */
		XLlFifo_Read(&FifoInstance, &RxFrame, RxFrameLength);

		if (TemacUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
			TemacUtilErrorTrap("Receive Data Mismatch");
			return XST_FAILURE;
		}
	}

	/*
	 * Stop device
	 */
	XLlTemac_Stop(&TemacInstance);

	return XST_SUCCESS;
}


/******************************************************************************/
/**
* This functions polls the Tx status and waits for an indication that a frame
* has been transmitted successfully or a transmit related error has occurred.
* If an error is reported, it handles all the possible  error conditions.
*
* @param    None.
*
* @return   Status is the status of the last call to the
*           XLlTemac_FifoQuerySendStatus() function.
*
* @note     None.
*
******************************************************************************/
int TemacPollForTxStatus(void)
{
	u32 SendStatus;
	int Status = XST_NO_DATA;
	int Attempts = 100000;	/* Number of attempts to get status before giving
				   up */

	/*
	 * Wait for transmit complete indication
	 */
	do {

		if (--Attempts <= 0)
			break;	/* Give up? */

		if (XLlFifo_Status(&FifoInstance) & XLLF_INT_TC_MASK) {
			XLlFifo_IntClear(&FifoInstance, XLLF_INT_TC_MASK);
			Status = XST_SUCCESS;
		}
		if (XLlFifo_Status(&FifoInstance) & XLLF_INT_ERROR_MASK) {
			Status = XST_FIFO_ERROR;
		}

	} while (Status == XST_NO_DATA);


	switch (Status) {
	case XST_SUCCESS:	/* Frame sent without error */
	case XST_NO_DATA:	/* Timeout */
		break;

	case XST_FIFO_ERROR:
		TemacUtilErrorTrap("FIFO error");
		TemacResetDevice();
		break;

	default:
		TemacUtilErrorTrap("Driver returned unknown transmit status");
		break;
	}

	return (Status);
}


/******************************************************************************/
/**
* This functions polls the Rx status and waits for an indication that a frame
* has arrived or a receive related error has occurred. If an error is reported,
* handle all the possible  error conditions.
*
* @param    None.
*
* @return   Status is the status of the last call to the
*           XLlTemac_FifoQueryRecvStatus() function.
*
* @note     None.
*
******************************************************************************/
int TemacPollForRxStatus(void)
{
	int Status = XST_NO_DATA;
	int Attempts = 1000000;	/* number of times to get a status before
					   giving up */

	/*
	 * There are two ways to poll for a received frame:
	 *
	 * XLlTemac_Recv() can be used and repeatedly called until it returns a
	 * length,  but this method does not provide any error detection.
	 *
	 * XLlTemac_FifoQueryRecvStatus() can be used and this function provides
	 * more information to handle error conditions.
	 */

	/*
	 * Wait for something to happen
	 */
	do {
		if (--Attempts <= 0)
			break;	/* Give up? */

		/*
		 * Try to get status
		 * We could have polled the status bits instead. Either way works.
		 */
		if (!XLlFifo_IsRxEmpty(&FifoInstance)) {
			Status = XST_SUCCESS;
		}
		if (XLlFifo_Status(&FifoInstance) & XLLF_INT_ERROR_MASK) {
			Status = XST_FIFO_ERROR;
		}
		if (XLlTemac_Status(&TemacInstance) & XTE_INT_RXRJECT_MASK) {
			Status = XST_DATA_LOST;
		}
		/* When the RXFIFOOVR bit is set, the RXRJECT bit also gets set */
		if (XLlTemac_Status(&TemacInstance) & XTE_INT_RXFIFOOVR_MASK) {
			Status = XST_DATA_LOST;
		}
	} while (Status == XST_NO_DATA);

	switch (Status) {
	case XST_SUCCESS:	/* Frame has arrived */
	case XST_NO_DATA:	/* Timeout */
		break;

	case XST_DATA_LOST:
		TemacUtilErrorTrap("Frame was dropped");
		break;

	case XST_FIFO_ERROR:
		TemacUtilErrorTrap("FIFO error");
		TemacResetDevice();
		break;

	default:
		TemacUtilErrorTrap("Driver returned invalid transmit status");
		break;
	}

	return (Status);
}


/******************************************************************************/
/**
* This function resets the device but preserves the options set by the user.
*
* @param    None.
*
* @return   XST_SUCCESS if successful, else XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacResetDevice(void)
{
	int Status;
	u8 MacSave[6];
	u32 Options;

	/*
	 * Stop device
	 */
	XLlTemac_Stop(&TemacInstance);

	/*
	 * Save the device state
	 */
	XLlTemac_GetMacAddress(&TemacInstance, MacSave);
	Options = XLlTemac_GetOptions(&TemacInstance);

	/*
	 * Stop and reset both the fifo and the temac the devices
	 */
	XLlFifo_Reset(&FifoInstance);
	XLlTemac_Reset(&TemacInstance, XTE_NORESET_HARD);

	/*
	 * Restore the state
	 */
	Status = XLlTemac_SetMacAddress(&TemacInstance, MacSave);
	Status |= XLlTemac_SetOptions(&TemacInstance, Options);
	Status |= XLlTemac_ClearOptions(&TemacInstance, ~Options);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error restoring state after reset");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


