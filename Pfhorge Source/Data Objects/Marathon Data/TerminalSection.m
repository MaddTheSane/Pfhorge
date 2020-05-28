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
    if (coder.allowsKeyedCoding) {
        [coder encodeObject:theText forKey:@"theText"];
        [coder encodeConditionalObject:permutationObject forKey:@"permutationObject"];
        
        [coder encodeInt:flags forKey:@"flags"];
        [coder encodeInt:type forKey:@"type"];
        [coder encodeInt:permutation forKey:@"permutation"];
        
        [coder encodeInt:text_offset forKey:@"textOffset"];
        [coder encodeInt:text_length forKey:@"textLength"];
        
        [coder encodeInt:lines forKey:@"lines"];
    } else {
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
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        theText = [coder decodeObjectForKey:@"theText"];
        permutationObject = [coder decodeObjectForKey:@"permutationObject"];
        
        flags = [coder decodeIntForKey:@"flags"];
        type = [coder decodeIntForKey:@"type"];
        permutation = [coder decodeIntForKey:@"permutation"];
        
        text_offset = [coder decodeIntForKey:@"textOffset"];
        text_length = [coder decodeIntForKey:@"textLength"];
        
        lines = [coder decodeIntForKey:@"lines"];
    } else {
        /*int versionNum = */decodeNumInt(coder);
        
        theText = decodeObjRetain(coder);
        
        // May Need To Retain...
        permutationObject = decodeObj(coder);
        
        flags = decodeShort(coder);
        type = decodeShort(coder);
        permutation = decodeShort(coder);
        text_offset = decodeShort(coder);
        text_length = decodeShort(coder);
        lines = decodeShort(coder);
    }
    
    /*if (useIndexNumbersInstead)
        [theLELevelDataST addPlatform:self];*/
    
    useIndexNumbersInstead = NO;
    
    return self;
}

// **************************  Dealloc/Init Methods  *************************
#pragma mark -
#pragma mark ********* Dealloc/Init Methods *********

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    theText = [[NSMutableAttributedString alloc]
               initWithString:@""
               attributes:@{NSForegroundColorAttributeName: [NSColor greenColor],
                            NSFontAttributeName: [NSFont fontWithName:@"Courier" size:12.0]}];
    
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
    int fontLength = (int)[fontData length];
    NSInteger newTextLength = 0;
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
    
    regularFont = [NSFont fontWithName:@"Courier" size:12.0];
    boldFont = [NSFont fontWithName:@"Courier-Bold" size:12.0];
    
    /* [theParagraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]]; */
    
    self = [super init];
    
    if (self == nil)
        return nil;
    
    flags = loadShortFromNSData(data, 0);
    // / NSLog(@"   term section flags: %d", flags);
    type = loadShortFromNSData(data, 2);
    [self setNameAndReturnStyleFromType];
    // / NSLog(@"   term section type: %d   type name: %@", type, [self phName]);
    permutation = loadShortFromNSData(data, 4);
    // / NSLog(@"   term section permutation: %d", permutation);
    text_offset = loadShortFromNSData(data, 6);
    // / NSLog(@"   term section text_offset: %d", text_offset);
    text_length = loadShortFromNSData(data, 8);
    // / NSLog(@"   term section text_length: %d", text_length);
    lines = loadShortFromNSData(data, 10);
    // / NSLog(@"   term section lines: %d", lines);
    
    
    if (type == PhTerminalSectionTypeInMapTeleport)
    {
        permutationObject = [theMapPolysST objectAtIndex:permutation];
        [theLELevelDataST namePolygon:permutationObject to:stringFromInt([(LEMapStuffParent*)permutationObject index])];
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
               attributes:@{NSForegroundColorAttributeName: [NSColor greenColor],
                            NSFontAttributeName:regularFont}];
    
    newTextLength = [theText length];
    
    for (i = 0; i < fontLength; i += 6)
    {
        [fontData getBytes:&theCurrentFont range:NSMakeRange(i, 6)];
        
        if (NSLocationInRange(theCurrentFont.offset, theTextRange))
        {
            NSColor *theTextColor = nil;
            NSFontTraitMask    theFontAtributeMast = 0;
            NSUnderlineStyle	underlineValue = NSUnderlineStyleNone;
            NSFont *theFontToUse = nil;
            NSNumber *italicValue = @NO;
            NSNumber *boldValue = @NO;
            NSNumber *colorValue = @(theCurrentFont.color);
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
            
            theFontToUse = regularFont;
            
            if (theCurrentFont.face & PhTerminalSectionItalic) {
                theFontAtributeMast |= NSItalicFontMask;
                italicValue = @YES;
            }
            if (theCurrentFont.face & PhTerminalSectionBold) {
                // NSBoldFontMask
                theFontToUse = boldFont;
                boldValue = @YES;
            }
            if (theCurrentFont.face & PhTerminalSectionUnderline) {
                underlineValue = NSUnderlineStyleSingle;
            }
            
            [theText setAttributes:@{
                NSForegroundColorAttributeName: theTextColor,
                NSFontAttributeName: [fontManager convertFont:theFontToUse toHaveTrait:theFontAtributeMast],
                PhTerminalItalicAttributeName: italicValue,
                PhTerminalBoldAttributeName: boldValue,
                PhTerminalColorAttributeName: colorValue,
                NSUnderlineStyleAttributeName: @(underlineValue),
                NSParagraphStyleAttributeName: theParagraphStyle}
                             range:NSMakeRange((theCurrentFont.offset - text_offset),
                                               (newTextLength - (theCurrentFont.offset - text_offset)))];
        }
    }
    
    //[theParagraphStyle release];
    
    return self;
}

-(NSMutableParagraphStyle *)setNameAndReturnStyleFromType
{

    NSMutableParagraphStyle *theParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [theParagraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    
    switch (type) {
        case PhTerminalSectionTypeLogOn:
            [self setPhName:@"Logon"];
            [theParagraphStyle setAlignment:NSTextAlignmentCenter];
            break;
        case PhTerminalSectionTypeUnfinished:
            [self setPhName:@"Unfinished"];
            break;
        case PhTerminalSectionTypeSuccess:
            [self setPhName:@"Success"];
            break;
        case PhTerminalSectionTypeFailure:
            [self setPhName:@"Failure"];
            break;
        case PhTerminalSectionTypeInformation:
            [self setPhName:@"Information"];
            break;
        case PhTerminalSectionTypeDelimiter:
            [self setPhName:@"Delimiter"];
            break;
        case PhTerminalSectionTypeLevelTeleport:
            [self setPhName:@"New Level"];
            break;
        case PhTerminalSectionTypeInMapTeleport:
            [self setPhName:@"Teleporter"];
            break;
        case PhTerminalSectionTypeCheckpoint:
            [self setPhName:@"Checkpoint"];
            break; 
        case PhTerminalSectionTypePict:
            [self setPhName:@"Picture"];
            break;
        case PhTerminalSectionTypeLogOff:
            [self setPhName:@"Logoff"];
            [theParagraphStyle setAlignment:NSTextAlignmentCenter];
            break;
        case PhTerminalSectionTypeCamera:
            [self setPhName:@"Camera"];
            break;
        case PhTerminalSectionTypeStatic:
            [self setPhName:@"Static"];
            break;
        case PhTerminalSectionTypeTag:
            [self setPhName:@"Tag"];
            break;
        // *** *** *** *** *** *** *** *** ***
        case PhTerminalSectionTypeSound:
            [self setPhName:@"Sound"];
            break;
        case PhTerminalSectionTypeMovie:
            [self setPhName:@"Movie"];
            break;
        case PhTerminalSectionTypeTrack:
            [self setPhName:@"Track"];
            theText = nil;
            break;
        // *** *** *** *** *** *** *** *** ***
        default:
            [self setPhName:[NSString stringWithFormat:@"Unknown Type: %d", type]];
            theText = nil;
            break;
    }
    
    return theParagraphStyle;
}

// **************************  Accsessor Methods  *************************
#pragma mark -
#pragma mark ********* Accsessor Methods *********

@synthesize type;

-(void)setType:(PhTerminalSectionType)value
{
    NSMutableParagraphStyle *theParagraphStyle;
    
    if (value != PhTerminalSectionTypeInMapTeleport)
        [self setPermutationObject:nil];
    
    if (value == PhTerminalSectionTypeLevelTeleport)
        [self setPermutation:0];
    
    type = value;
    theParagraphStyle = [self setNameAndReturnStyleFromType];
    
    [theText addAttributes:@{NSParagraphStyleAttributeName: theParagraphStyle}
                     range:NSMakeRange(0, [theText length])];
}

@synthesize permutation;
@synthesize permutationObject;

-(NSMutableAttributedString *)text { return [theText copy]; }
-(NSMutableAttributedString *)textPointer { return theText; }
-(void)setText:(NSAttributedString *)value { [theText setAttributedString:value]; }

-(void)appendMarathonToText:(NSMutableData *)theTextData toFonts:(NSMutableData *)theFontData toGroups:(NSMutableData *)theGroupData
{
    NSString *theTextAsString;
    term_section theSection;
    term_style theStyle;
    int baseOffsetOfText;
    NSNumber *numberWithOne = @(NSUnderlineStyleSingle);
    
    theSection.flags = flags;
    theSection.type = type;
    
    if (type != PhTerminalSectionTypeInMapTeleport)
        theSection.permutation = permutation;
    else
        theSection.permutation = [permutationObject index];
    
    baseOffsetOfText = (int)[theTextData length];
    
    // These Three Are Cacutalted Dynamicaly
    // And Only If There Is Any Text...
    theSection.text_offset = baseOffsetOfText;
    theSection.text_length = 1;
    theSection.lines = 0;
    
    if (theText != nil && [[theText string] length] > 0) {
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
        
        while (limitRange.length > 0) {
            colorValue = [attrStr attribute:PhTerminalColorAttributeName
                                    atIndex:limitRange.location longestEffectiveRange:&effectiveRange
                                    inRange:limitRange];
            
            /*underlineValue = [attrStr attribute:NSUnderlineStyleAttributeName
            atIndex:limitRange.location longestEffectiveRange:&effectiveRange
            inRange:limitRange];*/
            
            theStyle.offset = (baseOffsetOfText + limitRange.location);
            theStyle.face = PhTerminalSectionPlain;
            
            if ([boldValue boolValue])
                theStyle.face |= PhTerminalSectionBold;
            if ([italicValue boolValue])
                theStyle.face |= PhTerminalSectionItalic;
            if ([underlineValue isEqualTo:numberWithOne])
                theStyle.face |= PhTerminalSectionUnderline;
            
            theStyle.color = [colorValue shortValue];
            
            // / NSLog(@"color:   %d", theStyle.color);
            // / NSLog(@"face:    %d", theStyle.face);
            // / NSLog(@"offset:  %d", theStyle.offset);
            
            ///[theFontData appendBytes:&theStyle length:6];
            
			saveShortToNSData(theStyle.offset, theFontData);
			saveShortToNSData(theStyle.face, theFontData);
			saveShortToNSData(theStyle.color, theFontData);
        
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
    
    saveShortToNSData(theSection.flags, theGroupData);
    saveShortToNSData(theSection.type, theGroupData);
    saveShortToNSData(theSection.permutation, theGroupData);
    saveShortToNSData(theSection.text_offset, theGroupData);
    saveShortToNSData(theSection.text_length, theGroupData);
    saveShortToNSData(theSection.lines, theGroupData);
    
    ///[theGroupData appendBytes:&theSection length:6];
}

@end



