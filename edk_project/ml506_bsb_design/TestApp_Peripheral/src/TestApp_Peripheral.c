/*
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * Xilinx EDK 10.1.03 EDK_K_SP3.6
 *
 * This file is a sample test application
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * XPS project when you run the "Generate Libraries" menu item
 * in XPS.
 *
 * Your XPS project directory is at:
 *    C:\ml506_bsb_design\
 */


// Located in: microblaze_0/include/xparameters.h
#include "xparameters.h"

#include "stdio.h"

#include "xintc.h"
#include "intc_header.h"
#include "xuartns550_l.h"
#include "uartns550_header.h"
#include "xuartns550.h"
#include "uartns550_intr_header.h"
#include "xbasic_types.h"
#include "xgpio.h"
#include "gpio_header.h"
#include "iic_header.h"
#include "xlltemac.h"
#include "xlltemac_example.h"
#include "lltemac_header.h"
#include "lltemac_intr_header.h"
#include "xlldma.h"
#include "xsysace.h"
#include "sysace_header.h"
#include "xtmrctr.h"
#include "tmrctr_header.h"
#include "tmrctr_intr_header.h"
#include "uartlite_header.h"

//====================================================

int main (void) {


   static XIntc intc;

   /*
    * Enable and initialize cache
    */
   #if XPAR_MICROBLAZE_0_USE_ICACHE
      microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);
      microblaze_enable_icache();
   #endif

   #if XPAR_MICROBLAZE_0_USE_DCACHE
      microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);
      microblaze_enable_dcache();
   #endif


   /* Initialize RS232_Uart_1 - Set baudrate and number of stop bits */
   XUartNs550_SetBaud(XPAR_RS232_UART_1_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, 9600);
   XUartNs550_mSetLineControlReg(XPAR_RS232_UART_1_BASEADDR, XUN_LCR_8_DATA_BITS);
   static XUartNs550 RS232_Uart_2_UartNs550;
   static XLlTemac Hard_Ethernet_MAC_LlTemac;
   static XLlDma  Hard_Ethernet_MAC_LlDma;


   static XTmrCtr xps_timer_1_Timer;
   print("-- Entering main() --\r\n");


   {
      XStatus status;
      
      print("\r\n Runnning IntcSelfTestExample() for xps_intc_0...\r\n");
      
      status = IntcSelfTestExample(XPAR_XPS_INTC_0_DEVICE_ID);
      
      if (status == 0) {
         print("IntcSelfTestExample PASSED\r\n");
      }
      else {
         print("IntcSelfTestExample FAILED\r\n");
      }
   } 
	
   {
       XStatus Status;

       Status = IntcInterruptSetup(&intc, XPAR_XPS_INTC_0_DEVICE_ID);
       if (Status == 0) {
          print("Intc Interrupt Setup PASSED\r\n");
       } 
       else {
         print("Intc Interrupt Setup FAILED\r\n");
      } 
   }

   /*
    * Peripheral SelfTest will not be run for RS232_Uart_1
    * because it has been selected as the STDOUT device
    */



   {
      XStatus status;

      print("\r\nRunning UartNs550SelfTestExample() for RS232_Uart_2...\r\n");
      status = UartNs550SelfTestExample(XPAR_RS232_UART_2_DEVICE_ID);
      if (status == 0) {
         print("UartNs550SelfTestExample PASSED\r\n");
      }
      else {
         print("UartNs550SelfTestExample FAILED\r\n");
      }
   }
   {
      XStatus Status;

      print("\r\n Running Interrupt Test for RS232_Uart_2...\r\n");
      
      Status = UartNs550IntrExample(&intc, &RS232_Uart_2_UartNs550, \
                                  XPAR_RS232_UART_2_DEVICE_ID, \
                                  XPAR_XPS_INTC_0_RS232_UART_2_IP2INTC_IRPT_INTR);
	
      if (Status == 0) {
         print("UartNs550 Interrupt Test PASSED\r\n");
      } 
      else {
         print("UartNs550 Interrupt Test FAILED\r\n");
      }

   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioOutputExample() for LEDs_8Bit...\r\n");

      status = GpioOutputExample(XPAR_LEDS_8BIT_DEVICE_ID,8);
      
      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioOutputExample() for LEDs_Positions...\r\n");

      status = GpioOutputExample(XPAR_LEDS_POSITIONS_DEVICE_ID,5);
      
      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioInputExample() for Push_Buttons_5Bit...\r\n");

      Xuint32 DataRead;
      
      status = GpioInputExample(XPAR_PUSH_BUTTONS_5BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      Xuint32 status;
      
      print("\r\nRunning GpioInputExample() for DIP_Switches_8Bit...\r\n");

      Xuint32 DataRead;
      
      status = GpioInputExample(XPAR_DIP_SWITCHES_8BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      XStatus status;
            
      
      print("\r\n Runnning IicSelfTestExample() for IIC_EEPROM...\r\n");
      
      status = IicSelfTestExample(XPAR_IIC_EEPROM_DEVICE_ID);
      
      if (status == 0) {
         print("IicSelfTestExample PASSED\r\n");
      }
      else {
         print("IicSelfTestExample FAILED\r\n");
      }
   }

   /* TemacPolledExample does not support SGDMA      
   {
      XStatus status;

      print("\r\n Runnning TemacPolledExample() for Hard_Ethernet_MAC...\r\n");

      status = TemacPolledExample( XPAR_HARD_ETHERNET_MAC_CHAN_0_DEVICE_ID,
                                   );

      if (status == 0) {
         print("TemacPolledExample PASSED\r\n");
      }
      else {
         print("TemacPolledExample FAILED\r\n");
      }

   }
   */

   {
      XStatus Status;

      print("\r\nRunning TemacSgDmaIntrExample() for Hard_Ethernet_MAC...\r\n");

      Status = TemacSgDmaIntrExample(&intc, &Hard_Ethernet_MAC_LlTemac,
                     &Hard_Ethernet_MAC_LlDma,
                     XPAR_HARD_ETHERNET_MAC_CHAN_0_DEVICE_ID,
                     XPAR_XPS_INTC_0_HARD_ETHERNET_MAC_TEMACINTC0_IRPT_INTR,
                     XPAR_LLTEMAC_0_LLINK_CONNECTED_DMARX_INTR,
                     XPAR_LLTEMAC_0_LLINK_CONNECTED_DMATX_INTR);

      if (Status == 0) {
         print("Temac Interrupt Test PASSED.\r\n");
      } 
      else {
         print("Temac Interrupt Test FAILED.\r\n");
      }

   }


   {
      XStatus status;
      
      print("\r\nRunning SysAceSelfTestExample() for SysACE_CompactFlash...\r\n");
      status = SysAceSelfTestExample(XPAR_SYSACE_COMPACTFLASH_DEVICE_ID);
      if (status == 0) {
         print("SysAceSelfTestExample PASSED\r\n");
      }
      else {
         print("SysAceSelfTestExample FAILED\r\n");
      }
   }


   {
      XStatus status;
      
      print("\r\n Running TmrCtrSelfTestExample() for xps_timer_1...\r\n");
      
      status = TmrCtrSelfTestExample(XPAR_XPS_TIMER_1_DEVICE_ID, 0x0);
      
      if (status == 0) {
         print("TmrCtrSelfTestExample PASSED\r\n");
      }
      else {
         print("TmrCtrSelfTestExample FAILED\r\n");
      }
   }
   {
      XStatus Status;

      print("\r\n Running Interrupt Test  for xps_timer_1...\r\n");
      
      Status = TmrCtrIntrExample(&intc, &xps_timer_1_Timer, \
                                 XPAR_XPS_TIMER_1_DEVICE_ID, \
                                 XPAR_XPS_INTC_0_XPS_TIMER_1_INTERRUPT_INTR, 0);
	
      if (Status == 0) {
         print("Timer Interrupt Test PASSED\r\n");
      } 
      else {
         print("Timer Interrupt Test FAILED\r\n");
      }

   }


   {
      XStatus status;
      
      print("\r\nRunning UartLiteSelfTestExample() for debug_module...\r\n");
      status = UartLiteSelfTestExample(XPAR_DEBUG_MODULE_DEVICE_ID);
      if (status == 0) {
         print("UartLiteSelfTestExample PASSED\r\n");
      }
      else {
         print("UartLiteSelfTestExample FAILED\r\n");
      }
   }
   /*
    * Disable cache and reinitialize it so that other
    * applications can be run with no problems
    */
   #if XPAR_MICROBLAZE_0_USE_DCACHE
      microblaze_disable_dcache();
      microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);
   #endif

   #if XPAR_MICROBLAZE_0_USE_ICACHE
      microblaze_disable_icache();
      microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);
   #endif


   print("-- Exiting main() --\r\n");
   return 0;
}

