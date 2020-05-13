//
//  PhRandomSound.m
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

#import "PhRandomSound.h"
#import "LEExtras.h"

@implementation PhRandomSound

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
    ExportShort(delta_volume);
    ExportShort(period);
    ExportShort(delta_period);
    ExportShort(direction);
    ExportShort(delta_direction);
    
    ExportLong(pitch);
    ExportLong(delta_pitch);
    
    ExportShort(phase);
    
    // *** End Exporting ***
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
    NSLog(@"Exporting Random Sound: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ([index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Random Sound: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    ImportUnsignedShort(flags);
    
    ImportShort(sound_index);
    ImportShort(volume);
    ImportShort(delta_volume);
    ImportShort(period);
    ImportShort(delta_period);
    ImportShort(direction);
    ImportShort(delta_direction);
    
    ImportInt(pitch);
    ImportInt(delta_pitch);
    
    ImportShort(phase);
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		[coder encodeInt:flags forKey:@"flags"];
		
		[coder encodeInt:sound_index forKey:@"soundIndex"];
		[coder encodeInt:volume forKey:@"volume"];
		[coder encodeInt:delta_volume forKey:@"deltaVolume"];
		[coder encodeInt:period forKey:@"period"];
		[coder encodeInt:delta_period forKey:@"deltaPeriod"];
		[coder encodeInt:direction forKey:@"direction"];
		[coder encodeInt:delta_direction forKey:@"deltaDirection"];
		[coder encodeInt:pitch forKey:@"pitch"];
		[coder encodeInt:delta_pitch forKey:@"deltaPitch"];
		
		[coder encodeInt:phase forKey:@"phase"];
	} else {
		encodeNumInt(coder, 0);
		
		
		encodeUnsignedShort(coder, flags);
		
		encodeShort(coder, sound_index);
		encodeShort(coder, volume);
		encodeShort(coder, delta_volume);
		encodeShort(coder, period);
		encodeShort(coder, delta_period);
		encodeShort(coder, direction);
		encodeShort(coder, delta_direction);
		encodeLong(coder, pitch);
		encodeLong(coder, delta_pitch);
		
		encodeShort(coder, phase);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		flags = [coder decodeIntForKey:@"flags"];
		
		sound_index = [coder decodeIntForKey:@"soundIndex"];
		volume = [coder decodeIntForKey:@"volume"];
		delta_volume = [coder decodeIntForKey:@"deltaVolume"];
		period = [coder decodeIntForKey:@"period"];
		delta_period = [coder decodeIntForKey:@"deltaPeriod"];
		direction = [coder decodeIntForKey:@"direction"];
		delta_direction = [coder decodeIntForKey:@"deltaDirection"];
		pitch = [coder decodeIntForKey:@"pitch"];
		delta_pitch = [coder decodeIntForKey:@"deltaPitch"];
		
		phase = [coder decodeIntForKey:@"phase"];
	} else {
		versionNum = decodeNumInt(coder);
		
		flags = decodeUnsignedShort(coder);
		
		sound_index = decodeShort(coder);
		volume = decodeShort(coder);
		delta_volume = decodeShort(coder);
		period = decodeShort(coder);
		delta_period = decodeShort(coder);
		direction  = decodeShort(coder);
		delta_direction = decodeShort(coder);
		pitch = decodeInt(coder);
		delta_pitch = decodeInt(coder);
		
		phase = decodeShort(coder);
	}
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhRandomSound *copy = [[PhRandomSound allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// *************** Overridden Standard Methods ****************
-(short)index { return [theRandomSoundsST indexOfObjectIdenticalTo:self]; }

@synthesize flags;
@synthesize soundIndex=sound_index;
@synthesize volume;
@synthesize deltaVolume=delta_volume;
@synthesize period;
@synthesize deltaPeriod=delta_period;
@synthesize direction;
@synthesize deltaDirection=delta_direction;
@synthesize pitch;
@synthesize deltaPitch=delta_pitch;
@synthesize phase;

@end
