/**
*
* This module defines the error messages corresponding to the codes that
* can appear in _OSERR.  
*
*/

int os_nerr = 88;	/* Highest valid error number */

char *os_errlist[] = {	
			"Unknown error code",
/* 01 */		"Invalid function number",
/* 02 */		"File not found",
/* 03 */		"Path not found",
/* 04 */		"No many files opened",
/* 05 */		"Access denied",
/* 06 */		"Invalid handle",
/* 07 */		"Memory control blocks destroyed",
/* 08 */		"Insufficient memory",
/* 09 */		"Invalid memory block address",
/* 10 */		"Invalid environment",
/* 11 */		"Invalid format",
/* 12 */		"Invalid access code",
/* 13 */		"Invalid data",
/* 14 */		"Error 14",
/* 15 */		"Invalid drive code",
/* 16 */		"Can't remove current directory",
/* 17 */		"Not same device",
/* 18 */		"No more files",
/* 19 */		"Can't write on protected device",
/* 20 */		"Unknown unit",
/* 21 */		"Drive not ready",
/* 22 */		"Unknown command",
/* 23 */		"Data error",
/* 24 */		"Bad request structure length",
/* 25 */		"Seek error",
/* 26 */		"Unknown media type",
/* 27 */		"Sector not found",
/* 28 */		"Printer paper alarm",
/* 29 */		"Write fault",
/* 30 */		"Read fault",
/* 31 */		"General failure",
/* 32 */		"Sharing violation",
/* 33 */		"Lock violation",
/* 34 */		"Invalid disk change", 
/* 35 */		"FCB unavailable",
/* 36 */		"Sharing buffer overflow",
/* 37 */		"Error 37",
/* 38 */		"Error 38",
/* 39 */		"Error 39",
/* 40 */		"Error 40",
/* 41 */		"Error 41",
/* 42 */		"Error 42",
/* 43 */		"Error 43",
/* 44 */		"Error 44",
/* 45 */		"Error 45",
/* 46 */		"Error 46",
/* 47 */		"Error 47",
/* 48 */		"Error 48",
/* 49 */		"Error 49",
/* 50 */		"Network request not supported",
/* 51 */		"Remote computer not listening",
/* 52 */		"Duplicate name on network",
/* 53 */		"Network name not found",
/* 54 */		"Network busy",
/* 55 */		"Network device no longer exists",
/* 56 */		"Net BIOS command limit exceeded",
/* 57 */		"Network adaptor hardware error",
/* 58 */		"Incorrect response from network",
/* 59 */		"Unexpected network error",
/* 60 */		"Incompatible remote adaptor",
/* 61 */		"Print queue full",
/* 62 */		"Not enough space for print file",
/* 63 */		"Print file was deleted",
/* 64 */		"Network name was deleted",
/* 65 */		"Access denied",
/* 66 */		"Incorrect network device type",
/* 67 */		"Network name not found",
/* 68 */		"Network name limit exceeded",
/* 69 */		"Net BIOS session limit exceeded",
/* 70 */		"Temporarily paused",
/* 71 */		"Network request not accepted",
/* 72 */		"Print or disk redirection is paused",
/* 73 */		"Error 73",
/* 74 */		"Error 74",
/* 75 */		"Error 75",
/* 76 */		"Error 76",
/* 77 */		"Error 77",
/* 78 */		"Error 78",
/* 79 */		"Error 79",
/* 80 */		"File exists",
/* 81 */		"Error 81",
/* 82 */		"Cannot make directory entry",
/* 83 */		"Fail on INT 24",
/* 84 */		"Too many redirections",
/* 85 */		"Duplicate redirection",
/* 86 */		"Invalid password",
/* 87 */		"Invalid parameter",
/* 88 */		"Network device fault"};

