/////////////////////////////////////////////////////////////////////////
// $Id: crc.m,v 1.2 2004/05/04 15:21:21 jagil Exp $
/////////////////////////////////////////////////////////////////////////

/*
	crc.c
	Sunday, March 5, 1995 6:21:30 PM

	CRC Checksum generation for a file.
*/

//#include "cseries.h"
//#include "portable_files.h"
#include "crc.h"
#include <Carbon/Carbon.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>

typedef unsigned int uint32;
typedef int int32;
typedef unsigned short uint16;
typedef short int16;

//#ifdef mpwc
//	#pragma segment file_io
//#endif

// •••••••••••••••••••••• Below Is For Caculating the crc (checksum) •••••••••••••••••••••••••••
#pragma mark ••••••••• Below Is For Caculating the crc (checksum) •••••••••


/* ---------- constants */
#define TABLE_SIZE (256)
#define CRC32_POLYNOMIAL 0xEDB88320L
#define BUFFER_SIZE 1024

/* ---------- local data */
static uint32 *crc_table= NULL;

/* ---------- local prototypes ------- */
//static uint32 calculate_file_crc(unsigned char *buffer, 
//	int16 buffer_size, int16 refnum);
static uint32 calculate_file_crc(unsigned char *buffer, int16 buffer_size, NSData *fileData);
static uint32 calculate_buffer_crc(int32 count, uint32 crc, void *buffer);
static bool build_crc_table(void);
static void free_crc_table(void);

/* -------------- Entry Point ----------- */
/*uint32 calculate_crc_for_file(
	FileDesc *file) 
{
	int16 refnum;
	uint32 crc;
	
	refnum= open_file_for_reading(file);
	if(refnum!=NONE)
	{
		crc= calculate_crc_for_opened_file(refnum);
		close_file(refnum);
	}
	
	return crc;
}*/

unsigned int calculate_crc_for_nsdata(NSData *fileData) 
{
	uint32 crc=0;
	unsigned char *buffer;

	// Build the crc table
	if(build_crc_table())
	{
		buffer= (unsigned char *) malloc(BUFFER_SIZE*sizeof(unsigned char));
		if(buffer) 
		{
			crc = calculate_file_crc(buffer, BUFFER_SIZE, fileData);
			
			free(buffer);
		}
		
		// free the crc table!
		free_crc_table();
	}

	return crc;
}

/* Calculate the crc for a file using the given buffer.. */
unsigned int calculate_data_crc(
	unsigned char *buffer,
	long length)
{
	uint32 crc= 0l;

	assert(buffer);
	
	/* Build the crc table */
	if(build_crc_table())
	{
		/* The odd permutions ensure that we get the same crc as for a file */
		crc = 0xFFFFFFFFL;
		crc = calculate_buffer_crc(length, crc, buffer);
		crc ^= 0xFFFFFFFFL;

		/* free the crc table! */
		free_crc_table();
	}

	return crc;
}

/* ---------------- Private Code --------------- */
static bool build_crc_table(void)
{
	bool success= FALSE;

	assert(!crc_table);
	crc_table= (uint32 *) malloc(TABLE_SIZE*sizeof(uint32));
	if(crc_table)
	{
		/* Build the table */
		int16 index, j;
		uint32 crc;

		for(index= 0; index<TABLE_SIZE; ++index)
		{
			crc= index;
			for(j=0; j<8; j++)
			{
				if(crc & 1) crc=(crc>>1) ^ CRC32_POLYNOMIAL;
				else crc>>=1;
			}
			crc_table[index] = crc;
		}
		
		success= TRUE;
	}
	
	return success;
}

static void free_crc_table(void)
{
	assert(crc_table);
	free(crc_table);
	crc_table= NULL;
}

/* Calculate for a block of data incrementally */
static uint32 calculate_buffer_crc(
	int32 count, 
	uint32 crc, 
	void *buffer)
{
	unsigned char *p;
	uint32 a;
	uint32 b;

	p= (unsigned char *) buffer;
	while (count--) 
	{
		a= (crc >> 8) & 0x00FFFFFFL;
		b= crc_table[((int) crc ^ *p++) & 0xff];
		crc= a^b;
	}
	return crc;
}

/* Calculate the crc for a file using the given buffer.. */
static uint32 calculate_file_crc(
	unsigned char *buffer, 
	int16 buffer_size,
	NSData *fileData)
{
	uint32 crc;
	int32 count;
	//FileError err;
	NSInteger file_length;
	int32 place = 0;
	
	// Save and restore the initial file position
	//initial_position= get_fpos(refnum);

	// Get the file_length
	file_length= [fileData length];
	
	// Set to the start of the file
	//set_fpos(refnum, 0l);

	crc = 0xFFFFFFFFL;
	while(file_length) {
		if(file_length>buffer_size)
		{
			count= buffer_size;
		} else {
			count= (int32_t)file_length;
		}

		//err= read_file(refnum, count, buffer);
		[fileData getBytes:buffer range:NSMakeRange(place, count)];
		//vassert(!err, csprintf(temporary, "Error: %d", err));
		
		crc = calculate_buffer_crc(count, crc, buffer);
		file_length -= count;
		place += count;
	}
	
	// Restore the file position
	//set_fpos(refnum, initial_position);

	return (crc ^= 0xFFFFFFFFL);
}
