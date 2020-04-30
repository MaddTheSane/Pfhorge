//
//  TerminalSection.m
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


#import "TerminalSection.h"
#import "LEExtras.h"
#import "LELevelData.h"

@implementation TerminalSection

// **************************  Coding/Copy Protocal Methods  *************************
#pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeObj(coder, theText);
        // May want to encode loosely (Conditionaly)...
    encodeConditionalObject(coder, permutationObject);
    
    encodeShort(coder, flags);
    encodeShort(coder, type);
    encodeShort(coder, permutation);
    
    encodeShort(coder, text_offset);
    encodeShort(coder, text_length);
    
    encodeShort(coder, lines);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    theText = decodeObjRetain(coder);
    
        // May Need To Retain...
    permutationObject = decodeObj(coder);
    
    flags = decodeShort(coder);
    type = decodeShort(coder);
    permutation = decodeShort(coder);
    text_offset = decodeShort(coder);
    text_length = decodeShort(coder);
    lines = decodeShort(coder);
    
    /*if (useIndexNumbersInstead)
        [theLELevelDataST addPlatform:self];*/
    
    useIndexNumbersInstead = NO;
    
    return self;
}

// **************************  Dealloc/Init Methods  *************************
#pragma mark -
#pragma mark ********* Dealloc/Init Methods *********

-(void)dealloc
{
    [regularFont release];
    regularFont = nil;
    [boldFont release];
    boldFont = nil;
    
    [theText release];
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    theText = [[NSMutableAttributedString alloc]
                    initWithString:@""
                    
                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSColor greenColor],
                    NSForegroundColorAttributeName,
                    
                    [NSFont fontWithName:@"Courier" size:12.0],
                    NSFontAttributeName, nil]];
    
    flags = 0;		/* section flags, see above */
    type = 1;		/* section type, see above */
    permutation = 0;	/* meaning varies with type */
    text_offset = -1;	/* offset to the first character in the text */
    text_length = -1;	/* number of characters in the text */
    lines = -1;		/* number of lines in the text. Absent in the preview (demo?) */
    
    [self setType:1];
    
    permutationObject = nil;
    
    return self;
}

-(id)initWithData:(NSData *)data
        withFonts:(NSData *)fontData
         withText:(NSData *)textData
        withLevel:(LELevelData *)levelDataObj
{
    int fontLength = [fontData length];
    int newTextLength = 0;
    int i = 0;
    NSMutableParagraphStyle *theParagraphStyle; /* = [[NSMutableParagraphStyle alloc] init]; */
    
    
    
    /// , NSFontAttributeName,
                        
    //NSFont *myFont = [fontManager convertFont:regularFont toHaveTrait:NSItalicFontMask];
    
    term_style theCurrentFont;
    NSRange theTextRange;
    NSString *theRawString;
    NSData *sectionText;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    
    [levelDataObj setUpArrayPointersFor:self];
    
    regularFont = [[NSFont fontWithName:@"Courier" size:12.0] retain];
    boldFont = [[NSFont fontWithName:@"Courier-Bold" size:12.0] retain];
    
    /* [theParagraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]]; */
    
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [data getBytes:&flags range:NSMakeRange(0, 2)];
    // / NSLog(@"   term section flags: %d", flags);
    [data getBytes:&type range:NSMakeRange(2, 2)];
    [self setNameAndReturnStyleFromType];
    // / NSLog(@"   term section type: %d   type name: %@", type, [self getPhName]);
    [data getBytes:&permutation range:NSMakeRange(4, 2)];
    // / NSLog(@"   term section permutation: %d", permutation);
    [data getBytes:&text_offset range:NSMakeRange(6, 2)];
    // / NSLog(@"   term section text_offset: %d", text_offset);
    [data getBytes:&text_length range:NSMakeRange(8, 2)];
    // / NSLog(@"   term section text_length: %d", text_length);
    [data getBytes:&lines range:NSMakeRange(10, 2)];
    // / NSLog(@"   term section lines: %d", lines);
    
    
    if (type == _map_teleport_section)
    {
        permutationObject = [theMapPolysST objectAtIndex:permutation];
        [theLELevelDataST namePolygon:permutationObject to:stringFromInt([permutationObject getIndex])];
    }
    else
        permutationObject = nil;
    
    
    theParagraphStyle = [self setNameAndReturnStyleFromType];
    
    theTextRange = NSMakeRange(text_offset, text_length);
    
    sectionText = [textData subdataWithRange:theTextRange];

    theRawString = [[NSString alloc] initWithData:sectionText
                    encoding:NSMacOSRomanStringEncoding];
                    /*NSASCIIStringEncoding*/
    
    theText = [[NSMutableAttributedString alloc]
                    initWithString:theRawString
                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor greenColor],
                    NSForegroundColorAttributeName,
                    regularFont,
                    NSFontAttributeName, nil]];
    
    newTextLength = [theText length];
    
    for (i = 0; i < fontLength; i += 6)
    {
        [fontData getBytes:&theCurrentFont range:NSMakeRange(i, 6)];
        
        if (NSLocationInRange(theCurrentFont.offset, theTextRange))
        {
            NSColor *theTextColor = nil;
            long    theFontAtributeMast = 0;
            int underlineValue = 0;
            NSFont *theFontToUse = nil;
            NSString *italicValue = @"NO";
            NSString *boldValue = @"NO";
            NSNumber *colorValue = [NSNumber numberWithInt:((int)theCurrentFont.color)];
            /*
                0=green, 1=white, 2=red, 3=dim green,
                4=cyan, 5=yellow, 6=dim red, 7=blue.
                for exact info, see the last eight colours
                of clut #130 in the Marathon 2 application
            */
            
            switch (theCurrentFont.color)
            {
                case 0:
                    theTextColor = [NSColor greenColor];
                    break;
                case 1:
                    theTextColor = [NSColor whiteColor];
                    break;
                case 2:
                    theTextColor = [NSColor redColor];
                    break;
                case 3: // dim green
                    theTextColor = [NSColor colorWithCalibratedRed:0.00 green:0.50 blue:0.00 alpha:1.00];
                    break;
                case 4:
                    theTextColor = [NSColor cyanColor];
                    break;
                case 5:
                    theTextColor = [NSColor yellowColor];
                    break;
                case 6:  // dim red
                    theTextColor = [NSColor colorWithCalibratedRed:0.50 green:0.00 blue:0.00 alpha:1.00];
                    break;
                case 7:
                    theTextColor = [NSColor blueColor];
                    break;
                default:
                    theTextColor = [NSColor greenColor];
                    break;
            }
            
            underlineValue = 0;
            theFontToUse = regularFont;
            
            if (theCurrentFont.face & _italic_text)
            {
                theFontAtributeMast |= NSItalicFontMask;
                italicValue = @"YES";
            }
            if (theCurrentFont.face & _bold_text) // NSBoldFontMask
            {
                theFontToUse = boldFont;
                boldValue = @"YES";
            }
            if (theCurrentFont.face & _underline_text)
                underlineValue = 1;
            
            [theText setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                    theTextColor,
                    NSForegroundColorAttributeName,
                    
                    [fontManager convertFont:theFontToUse toHaveTrait:theFontAtributeMast],
                    NSFontAttributeName,
                    
                    italicValue,
                    @"PhItalicTerminalAttribute",
                    
                    boldValue,
                    @"PhBoldTerminalAttribute",
                    
                    colorValue,
                    @"PhColorTerminalAttribute",
                    
                    [NSNumber numberWithInt:underlineValue],
                    NSUnderlineStyleAttributeName,
                    
                    theParagraphStyle,
                    NSParagraphStyleAttributeName, nil]
                    
                    range:NSMakeRange((theCurrentFont.offset - text_offset),
                    (newTextLength - (theCurrentFont.offset - text_offset)))];
        }
    }
    
    //[theParagraphStyle release];
    
    return self;
    
    /*
    NSAttributedString *attrStr;
    NSRange limitRange;
    NSRange effectiveRange;
    id attributeValue;
    
    limitRange = NSMakeRange(0, [attrStr length]);
    
    while (limitRange.length > 0) {
        attributeValue = [attrStr attribute:NSFontAttributeName
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];
        [analyzer recordFontChange:attributeValue];
        limitRange = NSMakeRange(NSMaxRange(effectiveRange),
            NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
    }
    */
    
}

-(NSMutableParagraphStyle *)setNameAndReturnStyleFromType
{

    NSMutableParagraphStyle *theParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [theParagraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    
    switch (type)
    {
        case _logon_section:
            [self setPhName:@"Logon"];
            [theParagraphStyle setAlignment:NSCenterTextAlignment];
            break;
        case _unfinished_section:
            [self setPhName:@"Unfinished"];
            break;
        case _success_section:
            [self setPhName:@"Success"];
            break;
        case _failure_section:
            [self setPhName:@"Failure"];
            break;
        case _information_section:
            [self setPhName:@"Information"];
            break;
        case _delimiter_section:
            [self setPhName:@"Delimiter"];
            break;
        case _new_level_teleport_section:
            [self setPhName:@"New Level"];
            break;
        case _map_teleport_section:
            [self setPhName:@"Teleporter"];
            break;
        case _checkpoint_section:
            [self setPhName:@"Checkpoint"];
            break; 
        case _pict_section:
            [self setPhName:@"Picture"];
            break;
        case _logoff_section:
            [self setPhName:@"Logoff"];
            [theParagraphStyle setAlignment:NSCenterTextAlignment];
            break;
        case _camera_section:
            [self setPhName:@"Camera"];
            break;
        case _static_section:
            [self setPhName:@"Static"];
            break;
        case _tag_section:
            [self setPhName:@"Tag"];
            break;
        // *** *** *** *** *** *** *** *** ***
        case _sound_section:
            [self setPhName:@"Sound"];
            break;
        case _movie_section:
            [self setPhName:@"Movie"];
            break;
        case _track_section:
            [self setPhName:@"Track"];
            theText = nil;
            break;
        // *** *** *** *** *** *** *** *** ***
        default:
            [self setPhName:[NSString stringWithFormat:@"Unknown Type: %d", type]];
            theText = nil;
            break;
    }
    
    return [theParagraphStyle autorelease];
}

// **************************  Accsessor Methods  *************************
#pragma mark -
#pragma mark ********* Accsessor Methods *********

-(short)type { return type; }

-(void)setType:(short)value
{
    NSMutableParagraphStyle *theParagraphStyle;
    
    if (value != _map_teleport_section)
        [self setPermutationObject:nil];
    
    if (value == _new_level_teleport_section)
        [self setPermutation:0];
    
    type = value;
    theParagraphStyle = [self setNameAndReturnStyleFromType];
    
    [theText addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            
            theParagraphStyle,
            NSParagraphStyleAttributeName, nil]
            
            range:NSMakeRange(0, [theText length])];
}

-(short)permutation { return permutation; }
-(void)setPermutation:(short)value { permutation = value; }

-(id)permutationObject { return permutationObject; }
-(void)setPermutationObject:(id)value { permutationObject = value; }

-(NSMutableAttributedString *)text { return [[theText copy] autorelease]; }
-(NSMutableAttributedString *)textPointer { return theText; }
-(void)setText:(NSMutableAttributedString *)value { [theText setAttributedString:value]; }

-(void)appendMarathonToText:(NSMutableData *)theTextData toFonts:(NSMutableData *)theFontData toGroups:(NSMutableData *)theGroupData
 {
    NSString *theTextAsString;
    term_section theSection;
    term_style theStyle;
    int baseOffsetOfText;
    NSNumber *numberWithOne = @1;
    
    theSection.flags = flags;
    theSection.type = type;
    
    if (type != _map_teleport_section)
        theSection.permutation = permutation;
    else
        theSection.permutation = [permutationObject getIndex];
    
    baseOffsetOfText = [theTextData length];
    
    // These Three Are Cacutalted Dynamicaly
    // And Only If There Is Any Text...
    theSection.text_offset = baseOffsetOfText;
    theSection.text_length = 1;
    theSection.lines = 0;
    
    if (theText != nil && [[theText string] length] > 0)
    {
        NSAttributedString *attrStr = theText; 
        NSRange limitRange;
        NSRange effectiveRange;
        NSString *italicValue = nil;
        NSString *boldValue = nil;
        NSNumber *underlineValue = nil;
        NSNumber *colorValue = nil;
        
        
        theTextAsString =	[theText string];

        theSection.text_length = [theTextAsString length]+2;
        
        // Append the text...
        [theTextData appendData:[@"\r" dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:YES]];
        [theTextData appendData:[theTextAsString dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:YES]];
        [theTextData appendData:[@"\r" dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:YES]];
        
        // / NSLog(@"theTextData length: %d \nTEXT:\n%@", [theTextData length], theTextAsString);
        
        // Append the font changes...
        
        limitRange = NSMakeRange(0, [attrStr length]);
        
        while (limitRange.length > 0)
        {
            /*italicValue = [attrStr attribute:@"PhItalicTerminalAttribute"
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];
            
            boldValue = [attrStr attribute:@"PhBoldTerminalAttribute"
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];*/
            
            colorValue = [attrStr attribute:@"PhColorTerminalAttribute"
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];
            
            /*underlineValue = [attrStr attribute:NSUnderlineStyleAttributeName
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];*/
            
            theStyle.offset = (baseOffsetOfText + limitRange.location);
            theStyle.face = _plain_text;
            
            if ([boldValue isEqualTo:@"YES"])
                theStyle.face |= _bold_text;
            if ([italicValue isEqualTo:@"YES"])
                theStyle.face |= _italic_text;
            if ([underlineValue isEqualTo:numberWithOne])
                theStyle.face |= _underline_text;
            
            theStyle.color = ((short)[colorValue intValue]);
            
            // / NSLog(@"color:   %d", theStyle.color);
            // / NSLog(@"face:    %d", theStyle.face);
            // / NSLog(@"offset:  %d", theStyle.offset);
            
            ///[theFontData appendBytes:&theStyle length:6];
            
            [theFontData appendBytes:&(theStyle.offset) length:2];
            [theFontData appendBytes:&(theStyle.face) length:2];
            [theFontData appendBytes:&(theStyle.color) length:2];
        
            limitRange = NSMakeRange(NSMaxRange(effectiveRange),
            NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
            
            theSection.lines = 1;
        }
    }
    else
    {
        char zeronullchar = '\0';
        [theTextData appendBytes:&zeronullchar length:1];
    }
    
    [theGroupData appendBytes:&(theSection.flags) length:2];
    [theGroupData appendBytes:&(theSection.type) length:2];
    [theGroupData appendBytes:&(theSection.permutation) length:2];
    [theGroupData appendBytes:&(theSection.text_offset) length:2];
    [theGroupData appendBytes:&(theSection.text_length) length:2];
    [theGroupData appendBytes:&(theSection.lines) length:2];
    
    ///[theGroupData appendBytes:&theSection length:6];
 }

@end



