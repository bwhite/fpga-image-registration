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
* @file xlltemac_example.h
*
* Defines common data types, prototypes, and includes the proper headers
* for use with the TEMAC example code residing in this directory.
*
* This file along with xlltemac_example_util.c are utilized with the specific
* example code in the other source code files provided.

* These examples are designed to be compiled and utilized within the EDK
* standalone BSP development environment. The readme file contains more
* information on build requirements needed by these examples.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a jvb  04/05/07 First release
* </pre>
*
******************************************************************************/
#ifndef XTEMAC_EXAMPLE_H
#define XTEMAC_EXAMPLE_H


/***************************** Include Files *********************************/

#include "xparameters.h"	/* defines XPAR values */
#include "xlltemac.h"		/* defines XLlTemac API */
#include "xllfifo.h"
#include "xlldma.h"
#include "stdio.h"		/* stdio */


/************************** Constant Definitions ****************************/


#define TEMAC_LOOPBACK_SPEED 100	/* 10, 100, or 1000 */
#define TEMAC_PHY_DELAY_SEC  4	/* Amount of time to delay waiting on PHY */
				  /* to reset */

/***************** Macros (Inline Functions) Definitions *********************/


/**************************** Type Definitions ******************************/

/*
 * Define an aligned data type for an ethernet frame. This declaration is
 * specific to the GNU compiler
 */
typedef char EthernetFrame[XTE_MAX_FRAME_SIZE] __attribute__ ((aligned(8)));


/************************** Function Prototypes *****************************/



/*
 * Utility functions implemented in xlltemac_example_util.c
 */
void TemacUtilSetupUart(void);
void TemacUtilFrameHdrFormatMAC(EthernetFrame * FramePtr, char *DestAddr);
void TemacUtilFrameHdrFormatType(EthernetFrame * FramePtr, u16 FrameType);
void TemacUtilFrameSetPayloadData(EthernetFrame * FramePtr, int PayloadSize);
int TemacUtilFrameVerify(EthernetFrame * CheckFrame,
			 EthernetFrame * ActualFrame);
void TemacUtilFrameMemClear(EthernetFrame * FramePtr);
int TemacUtilEnterLoopback(XLlTemac * TemacInstancePtr, int Speed);
void TemacUtilErrorTrap(char *Message);
void TemacUtilPhyDelay(unsigned int Seconds);

/************************** Variable Definitions ****************************/

extern XLlTemac TemacInstance;	/* Temac device instance used throughout examples */
extern XLlFifo FifoInstance;	/* Fifo device instance used throughout examples */
extern XLlDma DmaInstance;	/* Dma device instance used throughout example */
extern char TemacMAC[];		/* Local MAC address */


#endif /* XTEMAC_EXAMPLE_H */


