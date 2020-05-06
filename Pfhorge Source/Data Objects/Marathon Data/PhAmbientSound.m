//
//  PhAmbientSound.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jul 08 2001.
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

#import "PhAmbientSound.h"
#import "LEExtras.h"

@implementation PhAmbientSound

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
 {
    long theNumber = [index indexOfObjectIdenticalTo:self];
    long tmpLong = 0;
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
    
    ExportUnsignedShort(flags);
    
    ExportShort(sound_index);
    ExportShort(volume);
    
    // *** End Exporting ***
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
     NSLog(@"Exporting Ambient Sound: %d  -- Position: %lu --- myData: %lu", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self getIndex], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Ambient Sound: %d  -- Position: %lu  --- Length: %ld", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    ImportUnsignedShort(flags);
    
    ImportShort(sound_index);
    ImportShort(volume);
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeUnsignedShort(coder, flags);
    
    encodeShort(coder, sound_index);
    encodeShort(coder, volume);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    flags = decodeUnsignedShort(coder);
    
    sound_index = decodeShort(coder);
    volume = decodeShort(coder);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhAmbientSound *copy = [[PhAmbientSound allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// *****************   Set Accsessors   *****************

-(void)setFlags:(unsigned short)v { flags = v; }

-(void)setSoundIndex:(short)v { sound_index = v; }
-(void)setVolume:(short)v { volume = v; }

// *****************   Get Accsessors   *****************

-(unsigned short)flags { return flags; }

-(short)soundIndex { return sound_index; }
-(short)volume { return volume; }

 // **************************  Overriden Standard Methods  *************************

-(short) getIndex
{
    return [theAmbientSoundsST indexOfObjectIdenticalTo:self];
}

-(void)update
{

}

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }

-(id)init
{
    self = [super init];
    if (self != nil)
    {
            //[self setP1:-1];
            //[self setP2:-1];
    }
    return self;
}

@end
