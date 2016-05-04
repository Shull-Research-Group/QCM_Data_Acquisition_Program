//
// This module is part of the VNA USB Interface.
// It (partially) emulates the parallel port IO
// module currently used by Roger and Ian for the WNA VB Windows app
//
// There are two functions, one input and one output.
// As far as possible, these follow the existing module defintions
// but in addition need to be able to return errors. For the output
// module this is by simply returning a bool. There is no diagnostic.
// If you want to know why a call failed, use DeviceIOControl()
// For the input, the returned value is a WORD (unsigned short). If this
// takes a value 0xFFFF, then the call failed. If it returns a value 0x0000
// to 0x00FF then that is thhe response from the VNA.
//
// Copyright (C) Dave Roberts G8KBB 2004
//

#include "stdafx.h"
#include "objbase.h"

#include "vnaio.h"


// in these functions we remap the parallel port to the usb pinout
//
// signal     parallel    usb
//-------------------------------------------
// RF_DDS        D0       PA5  
// LO_DDS        D1       PA6
// DDS_WCLK      D2       PA3
// DDS_FQ_UD     D3       PA2
// DDS_RESET     D4       PA4
// DET1_SCK      D5       PA0
// DET1_CS       D6       PA1
// DET1_nSDO     /BUSY    PA7 (input)

// handy labels for bits.
#define bmBIT0   0x01
#define bmBIT1   0x02
#define bmBIT2   0x04
#define bmBIT3   0x08
#define bmBIT4   0x10
#define bmBIT5   0x20
#define bmBIT6   0x40
#define bmBIT7   0x80

// this is the bit order of the signals on the parallel port
// all bar the input correspond to the data bus bits 0-6.
// The input bit is on the status port.

#define PAR_PORT_RF_DDS   bmBIT0
#define PAR_PORT_LO_DDS   bmBIT1
#define PAR_PORT_DDS_WCLK bmBIT2
#define PAR_PORT_DDS_FQUD bmBIT3
#define PAR_PORT_DDS_RESET bmBIT4
#define PAR_PORT_DET1_SCK bmBIT5
#define PAR_PORT_DET1_CS  bmBIT6
#define PAR_PORT_nSDO     bmBIT7		// status port not data port

#define bmADCnSdoPin    bmBIT7               // Input bit
#define bmLoDdsDataPin  bmBIT6
#define bmRfDdsDataPin  bmBIT5
#define bmResetDdsPin   bmBIT4
#define bmWClkDdsPin    bmBIT3
#define bmFQUDDdsPin    bmBIT2
#define bmADCnCsPin     bmBIT1
#define bmADCSClkPin    bmBIT0

// This function attempts to write to the data port.
// The returned value is true if it succeeds, false if not.
// The function remaps the parallel printer port bit definitions
// into USB port A bit order then writes to the VNA.


bool __declspec(dllexport) _stdcall Out32(short PortAddress, short data)
{
	VNA_TXBUFFER tx_data;
	VNADevice* VNA;				// Vector Network Analyzer hardware object
	bool result = false;
	BYTE outdata = 0;

	if( (PortAddress == 0x278) || (PortAddress == 0x378) )
	{
		VNA = new VNADevice;

		if (VNA->get_State() == 1 )
		{
			if( data & PAR_PORT_RF_DDS ) outdata |= bmRfDdsDataPin;
			if( data & PAR_PORT_LO_DDS ) outdata |= bmLoDdsDataPin;
			if( data & PAR_PORT_DDS_WCLK ) outdata |= bmWClkDdsPin;
			if( data & PAR_PORT_DDS_FQUD ) outdata |= bmFQUDDdsPin;
			if( data & PAR_PORT_DDS_RESET ) outdata |= bmResetDdsPin;
			if( data & PAR_PORT_DET1_SCK ) outdata |= bmADCSClkPin;
			if( data & PAR_PORT_DET1_CS ) outdata |= bmADCnCsPin;
			tx_data.raw.command_code = 0x5A;
			tx_data.raw.flags = 0x80;
			tx_data.raw.portA = outdata;
			tx_data.raw.portB = 0;

			result = VNA->Write( &tx_data, sizeof(tx_data.raw) );
		}
		delete VNA;
	}
	return result;
}

// This function tries to read VNA port A. If OK, it remaps
// the return value into that of the parallel port defintions.
// To do this it decides if the data or status port is being read.
// It only honours the status port BUSY bit as this is the only one used.
// It honours the data port bits 0-6. Bit 7 is unused and will read 0.

short __declspec(dllexport) _stdcall Inp32(short PortAddress)
{
	VNA_RXBUFFER message;
	VNADevice* VNA;				// Vector Network Analyzer hardware object
	short result = short(0xFFFF);
	short temp =  0;

	if( (PortAddress == 0x279) || (PortAddress == 0x379) ||
		(PortAddress == 0x278) || (PortAddress == 0x378) )
	{
		VNA = new VNADevice;

		if (VNA->get_State() == 1 )
		{
			if( VNA->Read( &message ) == true )
			{
				if( VNA->get_BytesReturned() >= 5 )
				{
					if( (PortAddress == 0x279) || (PortAddress == 0x379) )
					{
						if( (message.ioa & bmADCnSdoPin ) == 0 )
							temp |= PAR_PORT_nSDO;
					}
					else
					{
						if( message.ioa & bmRfDdsDataPin ) temp |= PAR_PORT_RF_DDS;
						if( message.ioa & bmLoDdsDataPin ) temp |= PAR_PORT_LO_DDS;
						if( message.ioa & bmWClkDdsPin ) temp |= PAR_PORT_DDS_WCLK;
						if( message.ioa & bmFQUDDdsPin ) temp |= PAR_PORT_DDS_FQUD;
						if( message.ioa & bmResetDdsPin ) temp |= PAR_PORT_DDS_RESET;
						if(	message.ioa & bmADCSClkPin ) temp |= PAR_PORT_DET1_SCK;
						if( message.ioa & bmADCnCsPin ) temp |= PAR_PORT_DET1_CS;
					}
					result = temp;
				}
			}
		}
		delete VNA;
	}
	return result;
}

