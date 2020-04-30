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
	short version;									/* Used internally */
	short data_version;								/* Used by the data.. */
	char file_name[MAXIMUM_WADFILE_NAME_LENGTH];
	uint32_t checksum;
	long directory_offset;
	short wad_count;
	short application_specific_directory_data_size;
	short entry_header_size;
	short directory_entry_base_size;
	uint32_t parent_checksum;	/* If non-zero, this is the checksum of our parent, and we are simply modifications! */
	short unused[20];
};

// Marathon 2/oo version
struct directory_entry { /* 10 bytes */
	int32_t offset_to_start; /* From start of file */
	int32_t length; /* Of total level */
	short index; /* For inplace modification of the wadfile! */
};

// Marathon 1 version
struct directory_entry_1 { /* 8 bytes */
	int32_t offset_to_start; /* From start of file */
	int32_t length; /* Of total level */
};


// Marathon 2/oo version
struct entry_header { /* 16 bytes */
	WadDataType tag;
	int32_t next_offset; /* From current file location-> ie directory_entry.offset_to_start+next_offset */
	int32_t length; /* Of entry */
	int32_t offset; /* Offset for inplace expansion of data */

	/* Data follows */
};

// Marathon 1 version
struct entry_header_1 { /* 12 bytes */
	WadDataType tag;
	int32_t next_offset; /* From current file location-> ie directory_entry.offset_to_start+next_offset */
	int32_t length; /* Of entry */

	/* Data follows */
};


#pragma pack(pop)
