//
//  Terminal.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Mar 10 2002.
//  Copyright (c) 2001 Joshua D. Orr. All rights reserved.
//  
//  E-Mail:   dragons@xmission.com
//  
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  or you can read it by running the program and selecting Phorge->About Phorge


#import "Terminal.h"
#import "TerminalSection.h"
#import "LEExtras.h"
#import "LELevelData.h"

static void encode_text(NSMutableData *terminal_text_data)
{
    long length = [terminal_text_data length];
    UInt8	*p = [terminal_text_data mutableBytes];
    int		i;
    
    NSLog(@"Proccsessing Encryption Of Terminal Text...");
    /*[terminal_text getCString:p maxLength:length];
    NSLog(@"Done Converting To C String...");*/
    for (i = 0; i < length / 4; i++) {
        p	+= 2;
        
        /*if (i != 0)
            *p++ ^= 0x00;
        else
            *p ^= 0x00;
        
        *p++	^= 0x00;*/
        *p++	^= 0xfe;
        *p++	^= 0xed;
    }
    for (i = 0; i < length % 4; i++) {
        *p++	^= 0xfe;
    }

    //terminal_text->flags |= _text_is_encoded_flag;
    
    return;
}


static void convertLFtoCR(NSMutableData *theRawTextData)
{
    long	length = [theRawTextData length];
    unsigned char	*p = [theRawTextData mutableBytes];
    int		i;
    
    NSLog(@"Proccsessing LF's to CR's...");
    /*[terminal_text getCString:p maxLength:length];
    NSLog(@"Done Converting To C String...");*/
    for (i = 0; i < length; i++) {
        if (*p == 0x0A)
            *p = 0x0D;
		p++;
    }

    //terminal_text->flags |= _text_is_encoded_flag;
    
    return;
}


@implementation Terminal

// **************************  Coding/Copy Protocal Methods  *************************
#pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********


- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    int tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound)
    {
        return theNumber;
    }
    
    NSInteger myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    // *** Start Exporting ***
    //[NSArchiver archivedDataWithRootObject:theLevel];
    
    
    // *** End Exporting ***
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = (int)[myData length];
    saveIntToNSData(tmpLong, theData);
    [theData appendData:myData];
    [theData appendData:futureData];
    
    //NSLog(@"Exporting Line: %d  -- Position: %d --- myData: %d", [self index], [index indexOfObjectIdenticalTo:self], [myData length]);
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg
{
    //NSLog(@"Importing Line: %d  -- Position: %d  --- Length: %d", [self index], [index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    /*
    ImportShort(type);
    ImportShort(speed);
    ImportShort(delay);
    ImportShort(maximum_height);
    ImportShort(minimum_height);
    ImportUnsignedLong(static_flags);
    
    ImportObj(polygon_object);
    
    ImportTag(tagObject);*/
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		[coder encodeObject:theSections forKey:@"theSections"];
		
		[coder encodeInt:flags forKey:@"flags"];
		[coder encodeInt:lineCount forKey:@"lineCount"];
		[coder encodeBool:textEncoded forKey:@"textEncoded"];
	} else {
		encodeNumInt(coder, 0);
		
		
		encodeObj(coder, theSections);
		
		encodeUnsignedShort(coder, flags);
		encodeShort(coder, lineCount);
		encodeBOOL(coder, textEncoded);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        theSections = [coder decodeObjectForKey:@"theSections"];
        
        flags = [coder decodeIntForKey:@"flags"];
        lineCount = [coder decodeIntForKey:@"lineCount"];
        textEncoded = [coder decodeBoolForKey:@"textEncoded"];
    } else {
        /*int versionNum = */decodeNumInt(coder);
        
        theSections = decodeObjRetain(coder);
        
        flags = decodeUnsignedShort(coder);
        lineCount = decodeShort(coder);
        textEncoded = decodeBOOL(coder);
    }
    
    /*if (useIndexNumbersInstead)
        [theLELevelDataST addPlatform:self];*/
    
    useIndexNumbersInstead = NO;
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    theSections = [[NSMutableArray alloc] initWithCapacity:0];
    flags = 0;
    lineCount = -1;
    textEncoded = NO;
    
    return self;
}

-(id)initWithTerminalData:(NSData *)data terminalNumber:(int)theTerminalNumber withLevel:(LELevelData *)levelDataObj
{
    long 	   position = 0;
    int		   	  i = 0;
    unsigned short length;
    //unsigned short flags;
    short 	   lines_per_page;
    unsigned short grouping_count;
    unsigned short font_changes_count;
    long	   textStartsAt;
    long	   fontStartsAt;
    
    NSData	  *textData;
    NSData	  *fontData;
    
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [levelDataObj setUpArrayPointersFor:self];
    
    [self setPhName:[NSString stringWithFormat:@"Terminal %d", theTerminalNumber]];
    
    // *** Load The Terminal Data ***
    
    length = loadShortFromNSData(data, 0);
    // / NSLog(@"term %d  length: %d", theTerminalNumber, length);
    flags = loadShortFromNSData(data, 2);
    // / NSLog(@"term %d  flags: %d", theTerminalNumber, flags);
    lines_per_page = loadShortFromNSData(data, 4);
    // / NSLog(@"term %d  lines_per_page: %d", theTerminalNumber, lines_per_page);
    grouping_count = loadShortFromNSData(data, 6);
    font_changes_count = loadShortFromNSData(data, 8);
    
    lineCount = lines_per_page;
    
    textStartsAt = ((6 * font_changes_count) + (12 * grouping_count)) + 10;
    fontStartsAt = (12 * grouping_count) + 10;
    
    textData = [data subdataWithRange:NSMakeRange(textStartsAt, length - textStartsAt)];
    fontData = [data subdataWithRange:NSMakeRange(fontStartsAt, (6 * font_changes_count))];
    
    // *** Process The Raw Terminal Data ***
    
    theSections = [[NSMutableArray alloc] initWithCapacity:grouping_count];
    
    if (flags & term_disguised)
        textEncoded = YES;
    else
        textEncoded = NO;
    
    // Set position to start of
    // terminal sections...
    position = 10;
    
    if (textEncoded)
    { // If Nessary, Decode Encrypted Terminal...
        NSMutableData *theNewData = [[NSMutableData alloc] initWithData:textData];
        //[textData release]; // Autoreleased already...
        textData = nil;
        encode_text(theNewData);
        textData = theNewData;
    }
    
    for (i = 0; i < grouping_count; i++)
    {
        [theSections addObject:[[TerminalSection alloc]
                                 initWithData:[data subdataWithRange:NSMakeRange(position, 12)]
                                    withFonts:fontData
                                     withText:textData
                                    withLevel:theLELevelDataST]];
        position += 12;
    }
    
    NSLog(@"%@ grouping_count: %d  section objects: %lu", [self phName], grouping_count, (unsigned long)[theSections count]);
    
    return self;
}

@synthesize theSections;
-(BOOL)doYouHaveThisSection:(TerminalSection *)theSec { return [theSections containsObject:theSec]; }
@synthesize flags;
@synthesize lineCount;

-(NSData *)getTerminalAsMarathonData
{
    NSMutableData *terminalData = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableData *terminalText = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableData *terminalFonts = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableData *terminalGroups = [[NSMutableData alloc] initWithCapacity:0];
    term_head theTerminalHeader;
    
    // / NSLog(@"theSections count: %d", [theSections count]);
    
    for (TerminalSection *terminalSection in theSections)
        [terminalSection appendMarathonToText:terminalText toFonts:terminalFonts toGroups:terminalGroups];
    
    theTerminalHeader.size = ([terminalText length] + [terminalFonts length] + [terminalGroups length] + 10);
    theTerminalHeader.flags = 0;
    theTerminalHeader.line_count = 22;
    theTerminalHeader.section_count = [theSections count];
    theTerminalHeader.style_count = ([terminalFonts length] / 6);
        
	saveShortToNSData(theTerminalHeader.size, terminalData);
	saveShortToNSData(theTerminalHeader.flags, terminalData);
	saveShortToNSData(theTerminalHeader.line_count, terminalData);
	saveShortToNSData(theTerminalHeader.section_count, terminalData);
	saveShortToNSData(theTerminalHeader.style_count, terminalData);
    
    convertLFtoCR(terminalText);
    
    [terminalData appendData:terminalGroups];
    [terminalData appendData:terminalFonts];
    [terminalData appendData:terminalText];
    
    return [terminalData copy];
}

-(short)index { return [theTerminalsST indexOfObjectIdenticalTo:self]; }

@end
