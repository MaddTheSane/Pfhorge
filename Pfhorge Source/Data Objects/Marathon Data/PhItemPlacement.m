//
//  PhItemPlacement.m
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

#import "PhItemPlacement.h"
#import "LEExtras.h"

@implementation PhItemPlacement

+ (PhItemPlacement *)itemPlacementObjWithDefaults
{
    return [[[PhItemPlacement alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    flags = 0;
    
    initial_count = 0;
    minimum_count = 0;
    maximum_count = 0;
    
    random_count = 0;
    random_chance = 0;
    
    return self;
}

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
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
    
    ExportShort(initial_count);
    ExportShort(minimum_count);
    ExportShort(maximum_count);
    
    ExportShort(random_count);
    ExportUnsignedShort(random_chance);
    
    // *** End Exporting ***
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
    NSLog(@"Exporting Item Placement: %d  -- Position: %lu --- myData: %lu", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
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
    NSLog(@"Importing Item Placement: %d  -- Position: %lu  --- Length: %ld", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    ImportUnsignedShort(flags);
    
    ImportShort(initial_count);
    ImportShort(minimum_count);
    ImportShort(maximum_count);
    
    ImportShort(random_count);
    ImportUnsignedShort(random_chance);
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeUnsignedShort(coder, flags);
    
    encodeShort(coder, initial_count);
    encodeShort(coder, minimum_count);
    encodeShort(coder, maximum_count);
    
    encodeShort(coder, random_count);
    encodeUnsignedShort(coder, random_chance);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    flags = decodeUnsignedShort(coder);
    
    initial_count = decodeShort(coder);
    minimum_count = decodeShort(coder);
    maximum_count = decodeShort(coder);
    
    random_count = decodeShort(coder);
    random_chance = decodeUnsignedShort(coder);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhItemPlacement *copy = [[PhItemPlacement allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// *************** Overridden Standard Methods ****************
-(short)getIndex { return [theMapItemPlacmentST indexOfObjectIdenticalTo:self]; }

- (void)adjustTheInitalCountBy:(int)value { initial_count += value; }

// ************************** Get Accsessors *************************
@synthesize flags;
	
- (short)initialCount { return initial_count; }
- (short)minimumCount { return minimum_count; }
- (short)maximumCount { return maximum_count; }
	
- (short)randomCount { return random_count; }
- (unsigned short)randomChance { return random_chance; }

// ************************** Set Accsessors *************************

- (void)setInitialCount:(short)v { initial_count = v; }
- (void)setMinimumCount:(short)v { minimum_count = v; }
- (void)setMaximumCount:(short)v { maximum_count = v; }

- (void)setRandomCount:(short)v { random_count = v; }
- (void)setRandomChance:(unsigned short)v { random_chance = v; }

@end
