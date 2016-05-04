#ifndef _VNAIO_
#define _VNAIO_

// plagiarised from the TAPR VNA design.
// as a consequence, the rights of Thomas C. McDermott, N5EG are acknowledged.
// Here is the licence text from his code. The only part used in this way
// is the basic structure of the VNA device and helper.
// All else is different 
// All the other code is Copyright (C) Dave Roberts G8KBB 2004
//
// ----------------- Extract from USB_EZ_interface.cpp -----------------
//    Copyright 2004, Thomas C. McDermott, N5EG
//    This file is part of VNAR - the Vector Network Analyzer program.
//
//    VNAR is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    VNAR is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with VNAR, if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
// ------------------------End Extract ----------------------------------

#include "stdafx.h"

extern "C"
{
    // Declare USB constants and structures
	#include "ezusbsys.h"  // Ezusb IOCTL codes
}

#define DLL_VERSION 23

#define USB_STRING			char[256]

// This is the structure used for messages returned to the caller
// from the USB chip.

typedef struct _VNA_RXBUFFER {
	unsigned char last_command;		// command type last received
	unsigned char return_status;	// see below for status flag defintions
	unsigned char ioa;				// FX2 PortA data
	unsigned char iob;				// FX2 PortB data
	unsigned char ADC_reads_done;	// Number of ADC reads performed
	unsigned char data[250];		// VARIABLE nuumber of ADC reads performed
} VNA_RXBUFFER;

// bit definitions in VNA_RXBUFFER.return_status
//
#define bVnaStatusAdcTimeoutFlag	0x80	// If set, FX2 timed out ADC read operation
#define bVnaStatusNoVnaPowerFlag	0x40	// If set, portB bit 7 is low so no VNA power
#define bVnaStatusAdcDataReadyFlag	0x20	// If set, the data[] part conatins ADC data
#define bVnaStatusAdcConvPendFlag	0x10	// Internal flag, if high FX2 is waiting to start ADC read operations

// There are two types of message that we may send to the VNA. This is managed as a union.
// The first one is a raw port write to FX2 ports A and/or B.

typedef struct _VNA_TXBUFFER_RAW {
	unsigned char command_code;		// set to 0x5A to signal raw write
	unsigned char flags;			// see below for definitions		
	unsigned char portA;			// value to write to port A if flag set
	unsigned char portB;			// value to write to port B if flag set
} VNA_TXBUFFER_RAW;
//
// bit definitions for Flags for raw command
//
#define CmdVnaRawDataFlagsWriteA 0x80              //if set, write specifiied value to port A
#define CmdVnaRawDataFlagsWriteB 0x40              //if set, write specifiied value to port B

// This is the second message type we might send. A high level command to the FX2 CPU
// The flags tell the FX2 what to do with the DDS (reset them / write to them )
// After this, it will delay at least adc_del msec before doing ADC reads
// It then performs a series of back to back ADC reads before returning the result
// of all ADC reads in a message as structured above (VNA_RXBUFFER).

typedef struct _VNA_TXBUFFER_CMD {
	unsigned char command_code;		// command code 0x55 for Set command
	unsigned char flags;			// see belo for definitions
	unsigned char adc_delay;		// min delay period (0-255 msec) before ADC reads
	unsigned char adc_reads;		// number of ADC reads to perform
	unsigned char adc_mode;			// adc selection & OSR bits
	unsigned char lo[5];			// LO data to write to DDS
	unsigned char rf[5];			// RF data to write to DDS
} VNA_TXBUFFER_CMD;
//
// bit definitions for flags for set command
//
#define bCmdVnaSetDdsFlagsReset           0x80  //if set, reset DDS
#define bCmdVnaSetDdsFlagsDdsSet          0x40  //if set, configure both DDS
#define bCmdVnaSetDdsFlagsDelayIsUsec     0x20  //if set, delay AdcDel is in usec not millisec
#define bCmdVnaSetDdsFlagsPauseDataIn     0x10  //if set, stop returning IN data until ADC conversions done
#define bCmdVnaSetDdsFlagsPauseDataOut    0x08  //if set, do not process incoming messages till ADC done
//
// bit defintions for adc_mode for set command
//
#define CmdVnaSetDdsAdcModeDet2          0x80         //if set use second detector
// bits 6,5 unused
// bits 4..0 are LTC2440 OSR4..0

// And this is the union for the messages

typedef union _VNA_TXBUFFER {
	VNA_TXBUFFER_RAW raw;
	VNA_TXBUFFER_CMD cmd;
} VNA_TXBUFFER;

// ****************************************************************
// Here is the main interface to the VNA - the VNADevice class.
// the IO32 and vnawrapper functions use this. Use it if you can
// otherwise use vnawrapper, and if all else fails use IO32 but it is slow


class VNADevice
{
private:
	bool Result;					// DeviceIoControl result
	int state;						// -1=no device +1=device OK
	class Helper * d;				// holds the USB device state

	void GetHandle(void);
	void ReleaseHandle(void);
	bool ToggleReset(bool hold);

public:
	__declspec(dllexport) _stdcall VNADevice();			// Constructor: open device, set state
	__declspec(dllexport) _stdcall ~VNADevice();		// Destructor: release __nogc objects and structs
	__declspec(dllexport) bool _stdcall  Init(void);	// Build descriptors, get pipes
	__declspec(dllexport) int _stdcall get_State();		// -1 = no device  +1 = device OK
	__declspec(dllexport)  bool _stdcall Start();		// Release reset of the 8051 processor on VNA
	__declspec(dllexport)  bool _stdcall Stop();		// Halt the 8051 processor on VNA
	__declspec(dllexport) int _stdcall get_Instance();	// get instance of VNA (0..9)
	__declspec(dllexport) bool _stdcall set_Instance(int instance); // set instance (0..9)
	__declspec(dllexport)  int _stdcall get_BytesReturned(); // tell me how many bytes were read last time
	__declspec(dllexport)  bool _stdcall Read(VNA_RXBUFFER * readbuf);		// read the VNA
	__declspec(dllexport)  bool _stdcall Write(VNA_TXBUFFER * writebuf, int message_size); // write to the VNA
	__declspec(dllexport) int _stdcall VNADevice::GetVersions();
	__declspec(dllexport) int _stdcall VNADevice::GetDeviceId();
};

// emulation of parallel port driver interface
bool __declspec(dllexport) _stdcall Out32(short PortAddress, short data);
short __declspec(dllexport) _stdcall Inp32(short PortAddress);

// simple VNA usb interface
bool __declspec(dllexport) _stdcall vnawrite(void *message, short bytecount);
bool __declspec(dllexport) _stdcall vnaread(void *message, short *bytecount);


#endif
