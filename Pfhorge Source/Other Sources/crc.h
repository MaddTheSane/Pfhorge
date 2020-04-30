/////////////////////////////////////////////////////////////////////////
// $Id: crc.h,v 1.2 2004/05/04 15:21:21 jagil Exp $
/////////////////////////////////////////////////////////////////////////

/*
	crc.h
	Sunday, March 5, 1995 6:25:36 PM
	
	Calculate the 32 bit CRC for a given file.
*/

//uint32 calculate_crc_for_file(FileDesc *file);
//uint32 calculate_crc_for_opened_file(int16 refnum);

#import <Foundation/Foundation.h>

unsigned int calculate_crc_for_nsdata(NSData *fileData);
unsigned int calculate_data_crc(unsigned char *buffer, long length);
