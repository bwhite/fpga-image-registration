//////////////////////////////////////////////////////////////////////////////
// Filename:          /home/brandyn/Xilinx10.1i/edk_user_repository/MyProcessorIPLib/drivers/registration_core_v1_00_a/src/registration_core_selftest.c
// Version:           1.00.a
// Description:       Contains a diagnostic self-test function for the registration_core driver
// Date:              Wed Mar 18 00:17:50 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "registration_core.h"

/************************** Constant Definitions ***************************/


/************************** Variable Definitions ****************************/


/************************** Function Definitions ***************************/

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the REGISTRATION_CORE instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus REGISTRATION_CORE_SelfTest(void * baseaddr_p)
{
  int     Index;
  Xuint32 baseaddr;
  Xuint8  Reg8Value;
  Xuint16 Reg16Value;
  Xuint32 Reg32Value;
  
  /*
   * Check and get the device address
   */
  XASSERT_NONVOID(baseaddr_p != XNULL);
  baseaddr = (Xuint32) baseaddr_p;

  xil_printf("******************************\n\r");
  xil_printf("* User Peripheral Self Test\n\r");
  xil_printf("******************************\n\n\r");

  /*
   * Write to user logic slave module register(s) and read back
   */
  xil_printf("User logic slave module test...\n\r");
  xil_printf("   - write 1 to slave register 0 word 0\n\r");
  REGISTRATION_CORE_mWriteSlaveReg0(baseaddr, 0, 1);
  Reg32Value = REGISTRATION_CORE_mReadSlaveReg0(baseaddr, 0);
  xil_printf("   - read %d from register 0 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) (1+1) )
  {
    xil_printf("   - slave register 0 word 0 write/read failed\n\r");
    //return XST_FAILURE;
  }
  xil_printf("   - write 2 to slave register 1 word 0\n\r");
  REGISTRATION_CORE_mWriteSlaveReg1(baseaddr, 0, 2);
  Reg32Value = REGISTRATION_CORE_mReadSlaveReg1(baseaddr, 0);
  xil_printf("   - read %d from register 1 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) (2+1) )
  {
    xil_printf("   - slave register 1 word 0 write/read failed\n\r");
    //return XST_FAILURE;
  }
  xil_printf("   - write 3 to slave register 2 word 0\n\r");
  REGISTRATION_CORE_mWriteSlaveReg2(baseaddr, 0, 3);
  Reg32Value = REGISTRATION_CORE_mReadSlaveReg2(baseaddr, 0);
  xil_printf("   - read %d from register 2 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) (3+1) )
  {
    xil_printf("   - slave register 2 word 0 write/read failed\n\r");
    //return XST_FAILURE;
  }
  xil_printf("   - slave register write/read passed\n\n\r");

  return XST_SUCCESS;
}
