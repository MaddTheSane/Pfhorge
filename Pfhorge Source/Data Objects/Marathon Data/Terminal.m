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
    //NSLog(@"Importing Line: %d  -- Position: %d  --- Length: %d", [self index], [index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
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
    int versionNum = 0;
    self = [super initWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		theSections = [coder decodeObjectForKey:@"theSections"];
		
		flags = [coder decodeIntForKey:@"flags"];
		lineCount = [coder decodeIntForKey:@"lineCount"];
		textEncoded = [coder decodeBoolForKey:@"textEncoded"];
	} else {
		versionNum = decodeNumInt(coder);
		
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
    
    
   /* char test [5000];
    test[0] = 0x534954210001000034EE724C6175020000000016000000001E48617473204F666620746F204569676874204E696E657465656E2E736974946AAA0000000000000000000000000000000000000000000000000000FFFFFFFF53495444534954210100AE1ACAD4AE1ACAD4000000000000346800000000000034680000CAF90000000000004A2153495421000100003468724C617502000000001600000D0D1A48617473204F666620746F204569676874204E696E657465656E0001537E94897D0000000000000000000000000000000000000000000000000000FFFFFFFF7363653232362EB00100AE1AA710AE1ACAC40000087A0000738C0000057100002E7177DCF747000000000000EFB60B005D796C65E775CA8EB02347B984114E5646B8114E5847B8E498849F479E93E347FBB5EC08CB8F30B24A23C7098B3CCBC31B2DC2093D4EB81EDE2897F09530326087377E86279C3C7BF192A31CCFC988BFD7D993A747669C1C23134638E164CA927072FC24CF8F1CA79EFC0566A33C2F3D0302A02F3BC28D3C2748648403AF029F238095318331965FC5D8227C99FD62F78617DE1918ED6EC311B368530FEB69375AA82C5BBDE3E0F0D1E25ECE8BC343C5DE23CEC07071CF91417BD8B60737984CFF8E1EB2BBBB376DF816BA3E622FCFCBF867BE5EFD7981B1A3A7A0FA3DAD4BF36516D4BEC4DAD8BC5A8D6A79F00A6B79A051D916AA871D7F88CAB550178D9602E760B7F656A37A1EA1CC05D4968BFA92BD9CBD3C775FCD6EB0E566B38335535C772C7C5B483D065BF2E01E1DF71E61F53CE46C03D7827D0BD3B7FB1B6CCB186BCE0D33B66EBD7061EB566676754D4E7675B14CA170FD7AA1A0592727B52D8C9D3E8D1DC61E3BA6DD626CDF3E1D55C6D6AFC7BE9831B031B6249F1F1FC7A53D9FBF74097BC7DAB5E3E31B37B2A55D5DE3E36082E207D3F26A6E5F7785162791F485EF70EEA6BC5D702E70EAAF5A9CD7852983F8477AFE2AAD4824485C7000FBAE552AF5F6F6CFF2BCE3F2332072DC599E8A8CE74BF50B6DFE8DCC64CC4F85E13A759E87206765BF55DADDE086CB1B22C7CFF4734780516B7D63A565F5BEEEC9F857DA3C45AB7C40AC534F5B1677B8F0A4544ACAC86BA8BB6424718366556724DCF727AC7269DB9A0B57AF5E11DEEFF4DC1F944D7CB75CEA4D4BF94FAC7E47F3C63F532101BBEF9E7FEBFC9713BB4A80C5093D798D96D4606319167881FA9E96A8C817E270A9F48113FE454FDCA045896F5B5C48F51DE593C83F6B95B78BF03AADBC05915120643C818374B917DCA4A5B7B42D5FC16E15DFA2A766288394006746524E53A62665FCC3DC1A4E5353B1B84EEBC051B3ACBE9B9419EEB7635CA7AC7205245396350812C1BC3A59292D4BA4904122EC3EA29AF0827BD4069B284A258B53481076384B591548DF8B6F6A438413C4B78981A02326AA0A518107C20B536A438E02901E32404F2912149CDC1F92CEB3C4AAE2FB64AA44A594F347A9CA4F860D3482F48240A9C80BEE5247E272217C8E8C925233C492BA326A32A54EE40BCD61EF97440B1A77995507C664AAC2818C5C2283D0E7FBEF50CE75C22A17C09830AC8E8008EF1E99AE13DCD7668AF00EA2E387C10CE5A41825DF1BADD336734CC4B364F8DE0C3543D3771DE8483CAFE679506A26521BE78B789A0C11CE472F441EE3DA3465234908629D4A06C9FBD494334801B232709BB2BE47910F01C6949AA5B6314A22A450ABD1C9543AC74604658BC67C71B2A21444EC324F5AA3B3649E295590B9B1FEC191F2765871B6B473AA54AEC08A2A4768D9899433F860564B7D9052E5BC729BCCDAE13E6839B3DDB62B2E1FA8D3818E1AAA4321762AB2079087D5480252C703A2041F643751A2DC1FD6ECDE4A83323E0A2745E452758F3223659D17783EFA37B52591EB8EDEA7BCF47C118E090FED78D0A4C44F79DEE64E00FF7D81B60852CAD704BA540488BFC8A0BE3D585673454366E74A20BC49CC6FF09C00A1A4A82EDB43D48737D7F60E0CCDF91201A55A1D622C58825E4182337050071011C751C94821C94910016AA8F8FA5C13E5E228503034554D6A9FE24E8522FDD210A10E3DEAA5011715083ACFE9C610217AA136E25CA3FCA748915D215A760E084D377F2E802781D35AFD090751297CA1DBDC918A6A3EDAE51A757C464CA602C522FF243CB2F0CA393EFFD27A9CC3C08349FCF4145971B9D17A3EE2F8F1C2EB10A7FFF6C73FF806E3FEFD53C0287F38D1A91F9B6BD83E66BCB6735B19042B766EDBBB0798677365EDDBFC3C5368368B2C7760EE8800E21DFB933EAD280D8DBCF9B65DDC32A2FF317875C8191AFC1F000E00EB37EAB4CECBEBECBC0CCF06793DBD2EB300;
    
    NSLog(@"TEST %d", test);*/
    
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
    
    NSLog(@"%@ grouping_count: %d  section objects: %lu", [self getPhName], grouping_count, (unsigned long)[theSections count]);
    
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
