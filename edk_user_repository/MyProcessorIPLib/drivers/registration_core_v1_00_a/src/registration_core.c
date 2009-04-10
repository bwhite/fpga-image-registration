//////////////////////////////////////////////////////////////////////////////
// Filename:          /home/brandyn/Xilinx10.1i/edk_user_repository/MyProcessorIPLib/drivers/registration_core_v1_00_a/src/registration_core.c
// Version:           1.00.a
// Description:       registration_core Driver Source File
// Date:              Wed Mar 18 00:17:50 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "registration_core.h"
#include "xparameters.h"
#include "stdio.h"
#include "xbasic_types.h"
#include "xuartlite.h"

#define UARTLITE_DEVICE_ID          XPAR_RS232_UART_1_BASEADDR
#define REGCORE XPAR_REGISTRATION_CORE_0_BASEADDR
XUartLite UartLite;         /* Instance of the UartLite device */

/************************** Function Definitions ***************************/

int flip_endian(int val) {
  int out = 0;
  int i = 0;
  for (i = 0; i < 32; i++)
    out |= ((val & (1 << i)) >> i) << (31 - i);
  return out;
}

int read_reg(int reg_num) {
  int val = 0;
  switch(reg_num) {
  case 0:
    val=REGISTRATION_CORE_mReadSlaveReg0(REGCORE,0);
    break;
  case 1:
    val=REGISTRATION_CORE_mReadSlaveReg1(REGCORE,0);
    break;
  case 2:
    val=REGISTRATION_CORE_mReadSlaveReg2(REGCORE,0);
    break;
  }
  return val;
}

void write_reg(int reg_num, int val) {
  switch(reg_num) {
  case 0:
    REGISTRATION_CORE_mWriteSlaveReg0(REGCORE,0,val);
  case 1:
    REGISTRATION_CORE_mWriteSlaveReg1(REGCORE,0,val);
    break;
  case 2:
    REGISTRATION_CORE_mWriteSlaveReg2(REGCORE,0,val);
    break;
  }
}

void write_byte_reg(int reg_num, int byte_num, int val) {
  int cur = read_reg(reg_num);
  val &= 0x000000FF;
  switch(byte_num) {
  case 0:
    cur &= 0xFFFFFF00;
    cur |= val;
    break;
  case 1:
    cur &= 0xFFFF00FF;
    cur |= val << 8;
    break;
  case 2:
    cur &= 0xFF00FFFF;
    cur |= val << 16;
    break;
  case 3:
    cur &= 0x00FFFFFF;
    cur |= val << 24;
    break;
  }
  switch(reg_num) {
  case 0:
    REGISTRATION_CORE_mWriteSlaveReg0(REGCORE,0,cur);
    break;
  case 1:
    REGISTRATION_CORE_mWriteSlaveReg1(REGCORE,0,cur);
    break;
  case 2:
    REGISTRATION_CORE_mWriteSlaveReg2(REGCORE,0,cur);
    break;
  }
}

void wait_till_done() {
  while(read_reg(1));
}

void wait_till_busy() {
  while(!read_reg(1));
  write_byte_reg(0,1,0x00000000);
}

void wait_till_busy_nclr() {
  while(!read_reg(1));
}

void print_h() {
  int i,j;
  int val;
  int perm[]={0,2,4,1,3,5};
  int whole_val;
  char sign_char;
  // Dec
  print("Decimal Affine\r\n");
  for (i=0; i < 6; i++) {
    write_byte_reg(0,2,perm[i]);
    val=read_reg(2);
    int frac_sum = 0;
    int b = 5000000;
    for (j = 0; j < 19; j++) {
      if ((val >> j) & 1) {
	frac_sum+= (b >> (18-j));
      }
    }
    if (val < 0)
      frac_sum = (b << 1) - frac_sum;

    if (val > -524288 && val < 0) {
      whole_val = 0;
      sign_char = '-';
    } else {
      whole_val = val >> 19;
      sign_char = ' ';
    }
      
    xil_printf("%c%d.%07d",sign_char,whole_val,frac_sum);
    print(" ");
    if (i == 2)
      print("\r\n");
  }

  xil_printf("\r\n %d.%07d ",0,0);
  xil_printf(" %d.%07d ",0,0);
  xil_printf(" %d.%07d",1,0);

  // Hex
  print("\r\n\nHex Affine\r\n");
  for (i=0; i < 6; i++) {
    write_byte_reg(0,2,perm[i]);
    val=read_reg(2);
    
    putnum(val);
    print(" ");
    if (i == 2)
      print("\r\n");
  }
}

int main (void) {
   print("-- Entering main() --\r\n");
   char command;
   int i,j,b;
   // Board Input
   // REG0[0]: DIP - Write
   // REG0[1]: SW  - Write
   // REG0[2]: H Element Selector - Write

   // Board Status
   // REG1[0] - Cur State

   // Affine Elements
   // REG1[0]: H_0_0 TODO - Read
   for (;;) {
     command=XUartLite_RecvByte(UARTLITE_DEVICE_ID);
     XUartLite_SendByte(UARTLITE_DEVICE_ID,command);
     switch(command) {
            case 'c': // Calibrate
     case 'C':
       print("Calibrate VGA\r\n");
       write_byte_reg(0,0,0x00000004);
       write_byte_reg(0,1,0x00000011);
       wait_till_busy_nclr();
       wait_till_done();
	   wait_till_busy_nclr();
	   wait_till_done();
       wait_till_busy();
       wait_till_done();
       break;
	   case 'n':
       print("Dec VGA V\r\n");
       write_byte_reg(0,0,0x00000004);
       write_byte_reg(0,1,0x0000001A);
		wait_till_busy_nclr();
       wait_till_done();
       wait_till_busy();
       wait_till_done();
       break;
    case 'h': // Clear H
     case 'H':
       print("CLEAR H\r\n");
       write_byte_reg(0,0,0x0000003F);
       write_byte_reg(0,1,0x00000010);
       write_byte_reg(0,1,0x00000000);
       
	   break;
     case 'v': // VGA0
     case 'V':
       print("VGA0\r\n");
       write_byte_reg(0,0,0x00000004);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy_nclr();
       wait_till_done();
       wait_till_busy();
       wait_till_done();
       break;
     case 'w': // VGA1
     case 'W':
       print("VGA1\r\n");
       write_byte_reg(0,0,0x00000084);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy_nclr();
       wait_till_done();
       wait_till_busy();
       wait_till_done();
       break;
     case 'd': // DVI0
     case 'D':
       print("DVI0\r\n");
       write_byte_reg(0,0,0x00000008);
       write_byte_reg(0,1,0x00000010);
       
       break;
     case 'e': // DVI1
     case 'E':
       print("DVI1\r\n");
       write_byte_reg(0,0,0x00000088);
       write_byte_reg(0,1,0x00000010);
       
       break;
     case 't': // TEST PATTERN0
     case 'T':
       print("TEST PATTERN0\r\n");
       write_byte_reg(0,0,0x00000001);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       break;
     case 'u': // TEST PATTERN1
     case 'U':
       print("TEST PATTERN1\r\n");
       write_byte_reg(0,0,0x00000081);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       break;
     case 's': // SMOOTH
       print("SMOOTH0\r\n");
       write_byte_reg(0,0,0x00000010);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       break;
     case 'S':
       print("SMOOTH1\r\n");
       write_byte_reg(0,0,0x00000090);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       break;
     case 'r': // REGISTER
       print("REGISTER0\r\n");
       write_byte_reg(0,0,0x00000018);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       print_h();
       break;
     case 'R':
       print("REGISTER1\r\n");
       write_byte_reg(0,0,0x00000098);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
       wait_till_done();
       print_h();
       break;
	 case 'B':
       print("START Bench REGISTER\r\n");
	   for (b=0; b < 5000; b++) {
	    write_byte_reg(0,0,0x00000018);
       write_byte_reg(0,1,0x00000010);
       wait_till_busy();
	   if (b & 31)
		  xil_printf("%d\r\n",b);
	   //putnum(b);
       wait_till_done();
	   
	   //print_h();
	   }
	   print("STOP Bench REGISTER\r\n");
       break;
	case 'f':
	print("10x REGISTER0\r\n");
		for (b=0; b < 10; b++) {
			write_byte_reg(0,0,0x00000018);
			write_byte_reg(0,1,0x00000010);
			wait_till_busy();
			wait_till_done();
			print_h();
	   }
	  break; 
   case 'F':
	print("10x REGISTER1\r\n");
		for (b=0; b < 10; b++) {
			write_byte_reg(0,0,0x00000098);
			write_byte_reg(0,1,0x00000010);
			wait_till_busy();
			wait_till_done();
			print_h();
	   }
       break;
     default:
       print("Invalid Selection!\r\n");
       for (i = 0; i < 3; i++) {
	 print("REG:");
	 putnum(read_reg(i));
	 print("\r\n");
       }
print_h();	   
     }
     
  }
   print("-- Exiting main() --\r\n");
   return 0;
}
