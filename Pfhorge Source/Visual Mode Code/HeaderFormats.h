// Structures for M2/Moo data-file headers


#pragma once

#include <stdint.h>

#pragma pack(push, 2)


#define MAXIMUM_DIRECTORY_ENTRIES_PER_FILE 64
#define MAXIMUM_WADFILE_NAME_LENGTH 64
#define MAXIMUM_UNION_WADFILES 16
#define MAXIMUM_OPEN_WADFILES 3

/* ------------- typedefs */

typedef unsigned int WadDataType;

/* ------------- file structures */
struct wad_header { /* 128 bytes */
	/*! Used internally */
	short version;
	/*! Used by the data.. */
	short data_version;
	char file_name[MAXIMUM_WADFILE_NAME_LENGTH];
	uint32_t checksum;
	long directory_offset;
	short wad_count;
	short application_specific_directory_data_size;
	short entry_header_size;
	short directory_entry_base_size;
	/*! If non-zero, this is the checksum of our parent, and we are simply modifications! */
	uint32_t parent_checksum;
	short unused[20];
};

//! Marathon 2/∞ version of the directory entry
struct directory_entry { /* 10 bytes */
	/*! From start of file */
	int32_t offset_to_start;
	/*! length of total level */
	int32_t length;
	/*! For inplace modification of the wadfile! */
	short index;
};

//! Marathon 1 version of the directory entry
struct directory_entry_1 { /* 8 bytes */
	/*! From start of file */
	int32_t offset_to_start;
	/*! Of total level */
	int32_t length;
};


//! Marathon 2/∞ version of entry header
struct entry_header { /* 16 bytes */
	WadDataType tag;
	/*! From current file location-> ie directory_entry.offset_to_start+next_offset */
	int32_t next_offset;
	/*! length of entry */
	int32_t length;
	/*! Offset for inplace expansion of data */
	int32_t offset;

	/* Data follows */
};

//! Marathon 1 version of entry header
struct entry_header_1 { /* 12 bytes */
	WadDataType tag;
	/*! From current file location-> ie directory_entry.offset_to_start+next_offset */
	int32_t next_offset;
	/*! length of entry */
	int32_t length;

	/* Data follows */
};


#pragma pack(pop)
