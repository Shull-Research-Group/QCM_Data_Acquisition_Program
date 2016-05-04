//
// This is the main VNA interface code. It sits on top of the USB
// driver (currently ezusb.sys) which uses windows USB drivers to
// communicate with the VNA.
// The interface is defined in vnaio.h - this is the place to start...


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

//#define LOG_COMMANDS
//#define CACHELOG
//#define TRACESIZE 1000000

#include "stdio.h"

#include "stdafx.h"
#include "objbase.h"
//#include "iostream.h"
#include "Setupapi.h"

#include ".\cyapi\inc\cyapi.h"
extern "C"
{
    // Declare USB constants and structures
	#include "winioctl.h"				// IOCTL definitions
//	#include "c:\ntddk\inc\usb100.h"	// general USB
//	#include "c:\ntddk\inc\usbdi.h"		// USB Device Interface
//	#include "c:\ntddk\inc\devioctl.h"	// Device IOCTL definitions
}

#include "vnaio.h"


class Helper		// Holds the USB device state while hiding it from other code
					// Helper is not on the managed heap, and requies explicit lifetime control.
					// Neither it nor it's contents get moved in memory by the garbage collector
{
public:
	BULK_TRANSFER_CONTROL * pInPipe;
	BULK_TRANSFER_CONTROL * pOutPipe;
	PUSB_DEVICE_DESCRIPTOR pDevDescr;
	PEZUSB_DRIVER_VERSION pDrvVerEzusb;
	ULONG * pDrvVers;
	GET_STRING_DESCRIPTOR_IN * pStrDescr;
	PUSB_INTERFACE_DESCRIPTOR pInterfaceInfo;
	PUSB_CONFIGURATION_DESCRIPTOR pConfigDescr;
	char * pDevString;					// USB Device Identifier, string version
	HANDLE DevDrvHandle;
	LPDWORD pBytesReturned;
	int instance;
	CCyUSBDevice *USBDevice;
	bool bUsingCyUSB;
#ifdef CACHELOG
	char *traceblock, *traceptr;
#endif
	Helper()
	{
//		cout << "Helper Constructor called\n";
		pInPipe = new BULK_TRANSFER_CONTROL;
		pOutPipe = new BULK_TRANSFER_CONTROL;
		pDevDescr = new USB_DEVICE_DESCRIPTOR;
		pDrvVers = new ULONG;
		pDrvVerEzusb = new EZUSB_DRIVER_VERSION ;
		pStrDescr = new GET_STRING_DESCRIPTOR_IN;
		pInterfaceInfo = new USB_INTERFACE_DESCRIPTOR;
		pDevString = new USB_STRING;
		pConfigDescr = new USB_CONFIGURATION_DESCRIPTOR;
		pBytesReturned = new DWORD;
		instance = 0xff;
	}
	~Helper()
	{
//		cout << "Helper Destructor called\n";
		delete pInPipe;
		delete pOutPipe;
		delete pDevDescr;
		delete pDrvVers;
		delete pDrvVerEzusb;
		delete pStrDescr;
		delete pInterfaceInfo;
		delete pDevString;
		delete pConfigDescr;
		delete pBytesReturned;
	}
};

// The functions below relate to the declaration in vnaio.h
// and define its public interface

// on initialisation of the VNA device, instance is set to FF so
// it then searches for the first device it can find. The instance
// (0..9) can then be read with GetInstance(). A specific instance may
// be set by setting the instance.

// {AE18AA60-7F6A-11d4-97DD-00010229B959}
//static GUID CYUSBDRV_GUID = {0xae18aa60, 0x7f6a, 0x11d4, 0x97, 0xdd, 0x0, 0x1, 0x2, 0x29, 0xb9, 0x59};

// {C63859BD-5C4B-474d-9572-CE604E611D73}
static const GUID N2PK_USB_GUID  = 
{ 0xc63859bd, 0x5c4b, 0x474d, { 0x95, 0x72, 0xce, 0x60, 0x4e, 0x61, 0x1d, 0x73 } };

#define MY_GUID N2PK_USB_GUID

void VNADevice::GetHandle(void)
{
	HANDLE hDevice = INVALID_HANDLE_VALUE;
	int i;


	if (d->USBDevice->DeviceCount() && !d->USBDevice->Open(0)) 
	{
		d->USBDevice->Reset();
		d->USBDevice->Open(0);
	}
	if (d->USBDevice->IsOpen())
	{
		hDevice = d->USBDevice->DeviceHandle();
		d->bUsingCyUSB = true;
	}
	else
	{
		d->bUsingCyUSB = false;
		char usbdevname[32];
		ZeroMemory( usbdevname, sizeof( usbdevname ) );
		strcpy_s( usbdevname, sizeof( usbdevname ), "\\\\.\\ezusb-0" );
//		char  * usbdevname = "\\\\.\\ezusb-0";		// device 0

		if( d->instance != 0xff )
		{
			usbdevname[10] = d->instance +'0';
			hDevice = CreateFile(usbdevname,		// try device 0
				GENERIC_WRITE,
				FILE_SHARE_WRITE,
				NULL,
				OPEN_EXISTING,
				0,
				NULL);
		}
		if( hDevice==INVALID_HANDLE_VALUE )
		{
			for( i=0; i<10; i++)
			{
				usbdevname[10] = i + '0';
				hDevice = CreateFile(usbdevname,	// try device i
					GENERIC_WRITE,
					FILE_SHARE_WRITE,
					NULL,
					OPEN_EXISTING,
					0,
					NULL);
				if (hDevice!=INVALID_HANDLE_VALUE)
				{
					d->instance = i;
					break;
				}
			}
		}
	}
	if (hDevice==INVALID_HANDLE_VALUE)
		state = -1;						// open failed
	else
		state = 1;						// open succeded
	d->DevDrvHandle = hDevice;
};

void VNADevice::ReleaseHandle(void)
{
	if( !d->bUsingCyUSB )
	{
		if (d->DevDrvHandle != INVALID_HANDLE_VALUE )
			CloseHandle(d->DevDrvHandle);
	}
	d->DevDrvHandle = INVALID_HANDLE_VALUE;
};

bool VNADevice::ToggleReset(bool hold)
{
	if( d->bUsingCyUSB )
	{
		d->USBDevice->Reset();
		return( 1 );
	}
	else
	{
		 //use the vendor request type to set/release the reset register in the 8051

		VENDOR_REQUEST_IN  * pRequest = new VENDOR_REQUEST_IN;

		pRequest->bRequest = 0xA0;			// Anchorchips Vendor Request Type
		pRequest->wValue = CPUCS_REG_EZUSB;		// 8051 Control / Status Register
		pRequest->wIndex = 0x00;
		pRequest->wLength = 0x01;
		pRequest->bData = (hold) ? 1 : 0;	// 1 holds 8051 in reset, 0 starts 8051 (at 0x0000)
		pRequest->direction = 0x00;

		GetHandle();

		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_Ezusb_VENDOR_REQUEST,
			pRequest,
			sizeof(VENDOR_REQUEST_IN),
			NULL,
			0,
			d->pBytesReturned,
			NULL);

		ReleaseHandle();
		return(Result);
	}
};



__declspec(dllexport) _stdcall VNADevice::VNADevice()							// Construct the VNADevice
{
//		cout << "VNADevice Constructor called\n";
	d = new Helper;					// Allocate a Helper to the VNADevice
	d->USBDevice = NULL;
	d->USBDevice = new CCyUSBDevice(NULL, MY_GUID);
	GetHandle();
	ReleaseHandle();
#ifdef CACHELOG
	int i;
	d->traceblock = (char *)malloc( TRACESIZE );
	if( d->traceblock != NULL )
	{
		i = sprintf(d->traceblock, "Cache created\n");
		d->traceptr = d->traceblock + i;
	}
#endif
};

__declspec(dllexport) _stdcall VNADevice::~VNADevice()
{
//		cout << "VNAdevice Destructor called\n";
	ReleaseHandle();
#ifdef CACHELOG
	int i;
	if( d->traceblock != NULL )
	{
		i = sprintf(d->traceptr, "Cache closed\n");
		d->traceptr += i;
		FILE *fp = fopen( "c:\\vnalog.txt", "a");
		if( fp != NULL )
		{
			fwrite( d->traceblock, 1, d->traceptr - d->traceblock, fp );
			fclose(fp);
		}
		free( d->traceblock );
		d->traceptr = d->traceblock = NULL;
	}
#endif
	ReleaseHandle();
	if( d->bUsingCyUSB )
		d->USBDevice->Close();
	delete d->USBDevice;
	delete d;						// since d is on the unmanaged heap

}

// empty code - other than checking the VNA is responding OK and checking
// the pipe descriptions there is not a lot to do here. Will fill
// these in later.

__declspec(dllexport) bool _stdcall VNADevice::Init(void)						// Build Device Descriptors and Pipes
{
	GetHandle();
	if( d->bUsingCyUSB )
	{
		d->USBDevice->GetDeviceDescriptor( d->pDevDescr );
		*d->pDrvVers = d->USBDevice->DriverVersion;
		d->USBDevice->GetConfigDescriptor( d->pConfigDescr );
	}
	else
	{
		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_Ezusb_GET_DEVICE_DESCRIPTOR,
			NULL,
			0,
			d->pDevDescr,
			sizeof(USB_DEVICE_DESCRIPTOR),
			d->pBytesReturned,
			NULL);
		if( Result != true ) return Result;

		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_EZUSB_GET_DRIVER_VERSION,
			NULL,
			0,
			d->pDrvVerEzusb,
			sizeof(EZUSB_DRIVER_VERSION),
			d->pBytesReturned,
			NULL);
		if( Result != true ) return Result;

		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_Ezusb_GET_CONFIGURATION_DESCRIPTOR,
			NULL,
			0,
			d->pConfigDescr,
			sizeof(USB_CONFIGURATION_DESCRIPTOR),
			d->pBytesReturned,
			NULL);
		if( Result != true ) return Result;

		//	Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
		//		IOCTL_Ezusb_GET_PIPE_INFO,
		//		NULL,
		//		0,
		//		d->pInterfaceInfo,
		//		sizeof(EZUSB_PIPE),
		//		d->pBytesReturned,
		//		NULL);
		//	if( Result != true ) return Result;
	}
	ReleaseHandle();
	return(true); // guarantee success
};

__declspec(dllexport) int _stdcall VNADevice::get_State() {return state;};

__declspec(dllexport) int _stdcall VNADevice::get_BytesReturned() { return *(d->pBytesReturned); };

__declspec(dllexport) bool _stdcall VNADevice::Start() { return(ToggleReset(0)); };		// Release reset on the 8051 processor

__declspec(dllexport) bool _stdcall VNADevice::Stop()	 { return(ToggleReset(1)); };		// Halt the 8051 processor

__declspec(dllexport) int _stdcall VNADevice::get_Instance() {return d->instance;};

__declspec(dllexport) int _stdcall VNADevice::GetVersions() 
{ 
	if( d->bUsingCyUSB )
		return (d->USBDevice->BcdDevice & 0xff) + (DLL_VERSION<<8); 
	else
		return (d->pDevDescr->bcdDevice & 0xff) + (DLL_VERSION<<8);
};

__declspec(dllexport) int _stdcall VNADevice::GetDeviceId() 
{ 
	if( d->bUsingCyUSB )
		return (d->USBDevice->BcdDevice ); 
	else
		return (d->pDevDescr->bcdDevice ); 
}

__declspec(dllexport) bool _stdcall VNADevice::set_Instance(int instance)
{
	if( unsigned(instance) > 9 )
		return false;
	
	d->instance = instance;
	return true;
};


__declspec(dllexport) bool _stdcall VNADevice::Read(VNA_RXBUFFER * readbuf)				// Read data from BULK endpoint
{
	void  * rb = readbuf;			// pin the readbuf in memory
	LONG len = 255;
	Result = 0;
	
	if( d->DevDrvHandle == INVALID_HANDLE_VALUE )
		GetHandle();
	if( d->bUsingCyUSB )
	{
		if( d->USBDevice->BulkInEndPt )
			Result = d->USBDevice->BulkInEndPt->XferData( (PUCHAR)rb, len );
		*(d->pBytesReturned) = len;
	}
	else
	{
		d->pInPipe->pipeNum = 1;			// most likely

		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_EZUSB_BULK_READ,
			d->pInPipe,
			sizeof(BULK_TRANSFER_CONTROL),
			rb,								// readbuf
			255,
			d->pBytesReturned,
			NULL);
	}

#ifdef LOG_COMMANDS
	int i;
	FILE *fp = fopen( "c:\\vnalog.txt", "a");
	fprintf(fp,"Read command, count = %d Data =", *d->pBytesReturned );
	if( *d->pBytesReturned > 0 && *d->pBytesReturned < 255 )
	{
		for( i=0; i<*d->pBytesReturned; i++)
			fprintf(fp, "%02x ",*((unsigned char *)rb+i) &0xff);
	}
	fprintf(fp,"\n");
	fclose(fp);
#endif
#ifdef CACHELOG
	int i,j;
	if( d->traceblock != NULL )
	{
		if( d->traceptr - d->traceblock > TRACESIZE - 1024 )
		{
			FILE *fp = fopen( "c:\\vnalog.txt", "a");
			if( fp != NULL )
			{
				fwrite( d->traceblock, 1, d->traceptr - d->traceblock, fp );
				fclose(fp);
			}
			d->traceptr = d->traceblock;
		}

		j = 0;
		j += sprintf(d->traceptr+j, "Read command, count = %d Data =", *d->pBytesReturned);
		if( *d->pBytesReturned > 0 && *d->pBytesReturned < 255 )
		{
			for( i=0; i<*d->pBytesReturned; i++)
				j += sprintf(d->traceptr+j, "%02x ", *((unsigned char *)rb+i) & 0xff);
		}
		j += sprintf(d->traceptr+j,"\n");

		d->traceptr += j;
	}
#endif

//	ReleaseHandle();
	return(Result);
};

__declspec(dllexport) bool _stdcall VNADevice::Write(VNA_TXBUFFER * writebuf, int message_size)					// Write data to BULK endpoint
{
	void  * wb = writebuf;				// pin the writebuf in memory
	LONG len = message_size;
	Result = 0;

	if( d->DevDrvHandle == INVALID_HANDLE_VALUE )
		GetHandle();

	if( d->bUsingCyUSB )
	{
		if( d->USBDevice->BulkOutEndPt )
			Result = d->USBDevice->BulkOutEndPt->XferData( (PUCHAR)wb, len );
	}
	else
	{
		d->pOutPipe->pipeNum = 0;			// most likely

#ifdef LOG_COMMANDS
	FILE *fp = fopen( "c:\\vnalog.txt", "a");
	if( fp != NULL )
	{
		int i;

		fprintf(fp, "Write Length %d: Message = ", message_size);
		for( i=0; i<message_size; i++)
			fprintf(fp, "%02x ", *((unsigned char *)wb+i));
		fprintf(fp,"\n");
		fclose(fp);
	}
#endif
#ifdef CACHELOG
	int i,j;
	if( d->traceblock != NULL )
	{
		if( d->traceptr - d->traceblock > TRACESIZE - 1024 )
		{
			FILE *fp = fopen( "c:\\vnalog.txt", "a");
			if( fp != NULL )
			{
				fwrite( d->traceblock, 1, d->traceptr - d->traceblock, fp );
				fclose(fp);
			}
			d->traceptr = d->traceblock;
		}

		j = 0;
		j += sprintf(d->traceptr+j, "Write Length %d: Message = ", message_size);
		for( i=0; i<message_size; i++)
			j += sprintf(d->traceptr+j, "%02x ", *((unsigned char *)wb+i));
		j += sprintf(d->traceptr+j,"\n");

		d->traceptr += j;
	}
#endif

		Result = DeviceIoControl((HANDLE)d->DevDrvHandle,
			IOCTL_EZUSB_BULK_WRITE,
			d->pOutPipe,
			sizeof(BULK_TRANSFER_CONTROL),
			wb,									// writebuf
			message_size,
			d->pBytesReturned,
			NULL);
	}


//	ReleaseHandle();
	return(Result);
};


