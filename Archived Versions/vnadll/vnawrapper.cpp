//
// This module is a "simple" wrapper to the VNA class for read/write
// For writing, given a message as an array of bytes and a byte count
// it attempts to write that message to the VNA. The caller must format
// the message in such a way that the USB chip will understand it.
// The message is either a raw write or a set command. The set command
// is preferred - the raw interface is a poor (i.e. slow) way to talk
// to the VNA.
// Even better is use the VNA class directly.
//
// Copyright (C) Dave Roberts G8KBB 2004
//


#include "stdafx.h"
#include "objbase.h"

#include "vnaio.h"

VNADevice *VNA = NULL;

bool __declspec(dllexport) _stdcall vnawrite(void *message, short bytecount)
{
//	VNADevice* VNA;				// Vector Network Analyzer hardware object
	bool result = false;

if( VNA == NULL)
	VNA = new VNADevice;

	if (VNA->get_State() == 1 )
	{
		result = VNA->Write( (VNA_TXBUFFER *)message, bytecount );
	}
//	delete VNA;
	return result;


}

bool __declspec(dllexport) _stdcall vnaread(void *message, short *bytecount)
{
//	VNADevice* VNA;				// Vector Network Analyzer hardware object
	bool result = false;

	*bytecount = 0;

if( VNA == NULL)
	VNA = new VNADevice;

	if (VNA->get_State() == 1 )
	{
		result = VNA->Read( (VNA_RXBUFFER *)message );
		if( result == true )
		{
			*bytecount = VNA->get_BytesReturned();
		}
	}
//	delete VNA;
	return result;
}

