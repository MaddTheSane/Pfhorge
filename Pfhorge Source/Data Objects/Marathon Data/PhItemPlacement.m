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
    
    NSLog(@"Exporting Item Placement: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Item Placement: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
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
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:flags forKey:@"flags"];
        encodeUnsignedShort(coder, flags);
        
        [coder encodeInt:initial_count forKey:@"initial_count"];
        [coder encodeInt:minimum_count forKey:@"minimum_count"];
        [coder encodeInt:maximum_count forKey:@"maximum_count"];
        
        [coder encodeInt:random_count forKey:@"random_count"];
        [coder encodeInt:random_chance forKey:@"random_chance"];
    } else {
        encodeNumInt(coder, 0);
        
        
        encodeUnsignedShort(coder, flags);
        
        encodeShort(coder, initial_count);
        encodeShort(coder, minimum_count);
        encodeShort(coder, maximum_count);
        
        encodeShort(coder, random_count);
        encodeUnsignedShort(coder, random_chance);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        flags = [coder decodeIntForKey:@"flags"];
        
        initial_count = [coder decodeIntForKey:@"initial_count"];
        minimum_count = [coder decodeIntForKey:@"minimum_count"];
        maximum_count = [coder decodeIntForKey:@"maximum_count"];
        
        random_count = [coder decodeIntForKey:@"random_count"];
        random_chance = [coder decodeIntForKey:@"random_chance"];
    } else {
        /*int versionNum = */decodeNumInt(coder);
        
        flags = decodeUnsignedShort(coder);
        
        initial_count = decodeShort(coder);
        minimum_count = decodeShort(coder);
        maximum_count = decodeShort(coder);
        
        random_count = decodeShort(coder);
        random_chance = decodeUnsignedShort(coder);
    }
    
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
-(short)index { return [theMapItemPlacmentST indexOfObjectIdenticalTo:self]; }

- (void)adjustTheInitalCountBy:(int)value { initial_count += value; }

// ************************** Accsessors *************************
@synthesize flags;
	
@synthesize initialCount=initial_count;
@synthesize minimumCount=minimum_count;
@synthesize maximumCount=maximum_count;
	
@synthesize randomCount=random_count;
@synthesize randomChance=random_chance;

@end
