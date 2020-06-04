//
//  PhPlatform.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 10 2001.
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

#import "PhPlatform.h"
#import "LEExtras.h"
#import "LELevelData.h"
#import "PhTag.h"
#import "LEPolygon.h"


#define PF(f) ((((static_flags)&(f)) != 0) ? YES : NO)
#define PFs(f, h) ((PF(f)) ? [NSString stringWithFormat:@"%@: %@\n", h, @"YES", nil] : [NSString stringWithFormat:@"%@: %@\n", h, @"NO", nil])

@implementation PhPlatform

 // **************************  Coding/Copy/Init Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy/Init Protocal Methods *********

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
    
    ExportShort(type);
    ExportShort(speed);
    ExportShort(delay);
    ExportShort(maximum_height);
    ExportShort(minimum_height);
    ExportUnsignedLong(static_flags);
    
    if (polygon_object != nil && [mainObjs containsObject:polygon_object])
    {
        ExportObj(polygon_object);
    }
    else
    {
        ExportNil();
    }
    
    ExportTag(tagObject);
    
    // *** End Exporting ***
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
	NSLog(@"Exporting Platform: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
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
    NSLog(@"Importing Platform: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    ImportShort(type);
    ImportShort(speed);
    ImportShort(delay);
    ImportShort(maximum_height);
    ImportShort(minimum_height);
    ImportUnsignedInt(static_flags);
    
    ImportObj(polygon_object);
    
    ImportTag(tagObject);
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}

- (void)copyInDynamicPlatformData:(NSData *)theData at:(long)locationOfBytes
{
    ///struct platform_data2 theDynamicData; /* 140 bytes */
    
    //[theData getBytes:&theDynamicData range:NSMakeRange(locationOfBytes, 140)];
    
    /*
    
    > 	For from-the-floor:
> min_height = min_floor
> max_height = max_floor
>
> 	For from-the-ceiling:
> min_height = min_ceiling
> max_height = max_ceiling
>
> 	For from-both:
> min_height = min_floor
> max_height = max_ceiling
>

*/
    BOOL fromFloor = NO;
    BOOL fromCeiling = NO;
    
	type = loadShortFromNSData(theData, locationOfBytes);
	static_flags = loadIntFromNSData(theData, locationOfBytes+2);
	speed = loadShortFromNSData(theData, locationOfBytes+6);
	delay = loadShortFromNSData(theData, locationOfBytes+8);
    
    if (static_flags & _platform_comes_from_floor)
        fromFloor = YES;
        
    if (static_flags & _platform_comes_from_ceiling)
        fromCeiling = YES;
    
    if (fromFloor && !fromCeiling)
    {
		minimum_height = loadShortFromNSData(theData, locationOfBytes+10);
		maximum_height = loadShortFromNSData(theData, locationOfBytes+12);
    }
    else if (fromCeiling && !fromFloor)
    {
		minimum_height = loadShortFromNSData(theData, locationOfBytes+14);
		maximum_height = loadShortFromNSData(theData, locationOfBytes+16);
    }
    else if (fromCeiling && fromFloor)
    {
		minimum_height = loadShortFromNSData(theData, locationOfBytes+10);
		maximum_height = loadShortFromNSData(theData, locationOfBytes+16);
    }
    else // if (!fromCeiling && !fromFloor)
    {
       NSLog(@"*** ERROR: Problem With Map Data Importing: Dynamic Platfrom is neither floor or ceiling... ***");
		minimum_height = loadShortFromNSData(theData, locationOfBytes+10); // floor
		maximum_height = loadShortFromNSData(theData, locationOfBytes+12); // floor
    }
    
    
	polygon_index = loadShortFromNSData(theData, locationOfBytes+18);
	tag = loadShortFromNSData(theData, locationOfBytes+94);
    
    [self setTag:tag];
    
    /*type = theDynamicData.type;
    speed = theDynamicData.speed;
    delay = theDynamicData.delay;
    maximum_height = theDynamicData.polygon_index;
    minimum_height = theDynamicData.ticks_until_restart;
    static_flags = theDynamicData.static_flags;
    
    polygon_index = theDynamicData.polygon_index;*/
    
    //if (alreadyLogedResults != 37563)
    {
        //alreadyLogedResults = 37563;
        
        //NSLog(@"fMin: %d - fMax: %d || cMin: %d - cMax: %d || f: %d | c: %D |%d|%d|| PolyIndex:%d", theDynamicData.minimum_floor_height, theDynamicData.maximum_floor_height, theDynamicData.minimum_ceiling_height, theDynamicData.maximum_ceiling_height, theDynamicData.floor_height, theDynamicData.ceiling_height, theDynamicData.type, 123, [self index]);
    }
    
    if (polygon_index >= ((int)[theMapPolysST count]) || polygon_index < 0)
    {
       NSLog(@"*** ERROR: Platform#%d polygon pointer beyond bounds: %d *** ", [self index], polygon_index);
       polygon_index = -1;
       polygon_object = nil;
    }
    else
        polygon_object = [theMapPolysST objectAtIndex:polygon_index];
    
    [polygon_object calculateSidesForAllLines];
    
   // tag = theDynamicData.tag;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		[coder encodeInt:type forKey:@"type"];
		[coder encodeInt:speed forKey:@"speed"];
		[coder encodeInt:delay forKey:@"delay"];
		
		[coder encodeInt:maximum_height forKey:@"maximum_height"];
		[coder encodeInt:minimum_height forKey:@"minimum_height"];
		
		[coder encodeInt:static_flags forKey:@"static_flags"];
		
		[coder encodeObject:polygon_object forKey:@"polygon_object"];
		
		[coder encodeInt:tag forKey:@"tag"];
		[coder encodeObject:tagObject forKey:@"tagObject"];
	} else {
		encodeNumInt(coder, 0);
		
		
		encodeShort(coder, type);
		encodeShort(coder, speed);
		encodeShort(coder, delay);
		
		encodeShort(coder, maximum_height);
		encodeShort(coder, minimum_height);
		
		encodeUnsignedLong(coder, static_flags);
		
		encodeObj(coder, polygon_object);
		
		encodeShort(coder, tag);
		encodeObj(coder, tagObject);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		type = [coder decodeIntForKey:@"type"];
		speed = [coder decodeIntForKey:@"type"];
		delay = [coder decodeIntForKey:@"type"];
		
		maximum_height = [coder decodeIntForKey:@"maximum_height"];
		minimum_height = [coder decodeIntForKey:@"minimum_height"];
		
		static_flags = [coder decodeIntForKey:@"static_flags"];
		
		polygon_object = [coder decodeObjectOfClass:[LEPolygon class] forKey:@"polygon_object"];
		
		tag = [coder decodeIntForKey:@"tag"];
		tagObject = [coder decodeObjectOfClass:[PhTag class] forKey:@"tagObject"];
	} else {
		/*int versionNum = */decodeNumInt(coder);
		
		type = decodeShort(coder);
		speed = decodeShort(coder);
		delay = decodeShort(coder);
		
		maximum_height = decodeShort(coder);
		minimum_height = decodeShort(coder);
		
		static_flags = decodeUnsignedInt(coder);
		
		polygon_object = decodeObj(coder);
		
		tag = decodeShort(coder);
		tagObject = decodeObj(coder);
	}
	if (useIndexNumbersInstead)
		[theLELevelDataST addPlatform:self];
	
	useIndexNumbersInstead = NO;
	
	return self;
}

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhPlatform *copy = [[PhPlatform allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    [self copySettingsTo:copy];
    
    return copy;
}



// *************** Overridden Standard Methods ****************
#pragma mark -
#pragma mark ********* Overridden Standard Methods *********
/*enum // static platform flags
{
	_platform_is_initially_active = 0x00000001,	// otherwise inactive
	_platform_is_initially_extended = 0x00000002, // high for floor platforms, low for ceiling platforms, closed for two_way platforms
        
        // These both can not be set to true a the same time...
	_platform_deactivates_at_each_level = 0x00000004, // this platform will deactivate each time it reaches a discrete level
	_platform_deactivates_at_initial_level = 0x00000008, // this platform will deactivate upon returning to its original position
        
	_platform_activates_adjacent_platforms_when_deactivating = 0x00000010,
	_platform_extends_floor_to_ceiling = 0x00000020, // i.e. there is no empty space when the platform is fully extended
	_platform_comes_from_floor = 0x00000040, // platform rises from floor
	_platform_comes_from_ceiling = 0x00000080, // platform lowers from ceiling
	_platform_causes_damage = 0x00000100, // when obstructed by monsters, this platform causes damage
	_platform_does_not_activate_parent = 0x00000200, // does not reactive its parent (i.e. that platform which activated it)
	_platform_activates_only_once = 0x00000400,
	_platform_activates_light = 0x00000800, // activates floor and ceiling light sources while activating
	_platform_deactivates_light = 0x00001000, // deactivates floor and ceiling lightsources while deactivating
	_platform_is_player_controllable = 0x00002000, // i.e. door: players can use action key to change the state and/or direction of this platform
	_platform_is_monster_controllable = 0x00004000, // i.e. door: monsters can expect to be able to move this platofrm even if inactive
	_platform_reverses_direction_when_obstructed = 0x00008000,
	_platform_cannot_be_externally_deactivated = 0x00010000, // when acctive, can only be deactivated by itself
	_platform_uses_native_polygon_heights = 0x00020000, // complicated interpretation; uses native polygon heights during automatic min,max calculation
	_platform_delays_before_activation = 0x00040000, // whether or not the platform begins with the maximum delay before moving
	_platform_activates_adjacent_platforms_when_activating = 0x00080000,
	_platform_deactivates_adjacent_platforms_when_activating = 0x00100000,
	_platforms_deactivates_adjacent_platforms_when_deactivating = 0x00200000,
	_platform_contracts_slower = 0x00400000,
	_platform_activates_adjacent_platforms_at_each_level = 0x00800000,
	_platform_is_locked = 0x01000000,
	_platform_is_secret = 0x02000000,
	_platform_is_door = 0x04000000,
	NUMBER_OF_STATIC_PLATFORM_FLAGS // <= 32
};*/
- (void)displayInfo
{
    NSMutableString *tis = [[NSMutableString alloc] init];
    
    [tis appendString:[NSString stringWithFormat:@"Info on Platform %d\n\n", [self index]]];
    
    [tis appendString:[NSString stringWithFormat:@"Polygon Index: %d\n", [polygon_object index], nil]];
    
    
    [tis appendString:@"Platform Type: "];
    
    switch (type)
    {
        case _platform_is_spht_door:
            [tis appendString:@"_platform_is_spht_door"];
            break;
        case _platform_is_spht_split_door:
            [tis appendString:@"_platform_is_spht_split_door"];
            break;
        case _platform_is_locked_spht_door:
            [tis appendString:@"_platform_is_locked_spht_door"];
            break;
        case _platform_is_spht_platform:
            [tis appendString:@"_platform_is_spht_platform"];
            break;
        case _platform_is_noisy_spht_platform:
            [tis appendString:@"_platform_is_noisy_spht_platform"];
            break;
        case _platform_is_heavy_spht_door:
            [tis appendString:@"_platform_is_heavy_spht_door"];
            break;
        case _platform_is_pfhor_door:
            [tis appendString:@"_platform_is_pfhor_door"];
            break;
        case _platform_is_heavy_spht_platform:
            [tis appendString:@"_platform_is_heavy_spht_platform"];
            break;
        case _platform_is_pfhor_platform:
            [tis appendString:@"_platform_is_pfhor_platform"];
            break;
        default:
            [tis appendString:@"unknown"];
            break;
    }
    
    [tis appendString:@"\n"];
    [tis appendString:[NSString stringWithFormat:@"Speed : %d\n", [self speed]]];
    [tis appendString:[NSString stringWithFormat:@"Delay : %d\n", [self delay]]];
    [tis appendString:[NSString stringWithFormat:@"Tag Index : %d\n", [self tag]]];
    
    [tis appendString:[NSString stringWithFormat:@"Floor Height : %d\n", [self minimumHeight], nil]];
    [tis appendString:[NSString stringWithFormat:@"Ceiling Height : %d\n", [self maximumHeight], nil]];
    
    [tis appendString:@"Platform Flags : \n"];
    [tis appendString:PFs(_platform_is_initially_active, @"_platform_is_initially_active")];
    [tis appendString:PFs(_platform_is_initially_extended, @"_platform_is_initially_extended")];
    [tis appendString:PFs(_platform_deactivates_at_each_level, @"_platform_deactivates_at_each_level")];
    [tis appendString:PFs(_platform_deactivates_at_initial_level, @"_platform_deactivates_at_initial_level")];
    [tis appendString:PFs(_platform_activates_adjacent_platforms_when_deactivating, @"_platform_activates_adjacent_platforms_when_deactivating")];
    [tis appendString:PFs(_platform_extends_floor_to_ceiling, @"_platform_extends_floor_to_ceiling")];
    [tis appendString:PFs(_platform_comes_from_floor, @"_platform_comes_from_floor")];
    [tis appendString:PFs(_platform_comes_from_ceiling, @"_platform_comes_from_ceiling")];
    [tis appendString:PFs(_platform_causes_damage, @"_platform_causes_damage")];
    [tis appendString:PFs(_platform_does_not_activate_parent, @"_platform_does_not_activate_parent")];
    [tis appendString:PFs(_platform_activates_only_once, @"_platform_activates_only_once")];

    [tis appendString:PFs(_platform_is_player_controllable, @"_platform_is_player_controllable")];
    [tis appendString:PFs(_platform_is_monster_controllable, @"_platform_is_monster_controllable")];
    [tis appendString:PFs(_platform_reverses_direction_when_obstructed, @"_platform_reverses_direction_when_obstructed")];
    [tis appendString:PFs(_platform_cannot_be_externally_deactivated, @"_platform_cannot_be_externally_deactivated")];
    [tis appendString:PFs(_platform_uses_native_polygon_heights, @"_platform_uses_native_polygon_heights")];
    [tis appendString:PFs(_platform_delays_before_activation, @"_platform_delays_before_activation")];
    [tis appendString:PFs(_platform_activates_adjacent_platforms_when_activating, @"_platform_activates_adjacent_platforms_when_activating")];
    [tis appendString:PFs(_platform_deactivates_adjacent_platforms_when_activating, @"_platform_deactivates_adjacent_platforms_when_activating")];
    [tis appendString:PFs(_platforms_deactivates_adjacent_platforms_when_deactivating, @"_platforms_deactivates_adjacent_platforms_when_deactivating")];
    [tis appendString:PFs(_platform_contracts_slower, @"_platform_contracts_slower")];
    [tis appendString:PFs(_platform_activates_adjacent_platforms_at_each_level, @"_platform_activates_adjacent_platforms_at_each_level")];
    [tis appendString:PFs(_platform_is_locked, @"_platform_is_locked")];
    [tis appendString:PFs(_platform_is_secret, @"_platform_is_secret")];
    [tis appendString:PFs(_platform_is_door, @"_platform_is_door")];
  
  //[tis appendString:PFs(, @"")];
    
    [tis appendString:@"\n"];
    
    SEND_INFO_MSG_TITLE(tis, @"Detailed Platform Info…");
    
    [tis release];
}



-(void)copySettingsTo:(id)target
{
    PhPlatform *theTarget = (PhPlatform *)target;
    
    [theTarget setType:type];
    [theTarget setSpeed:speed];
    [theTarget setDelay:delay];
    [theTarget setMaximumHeight:maximum_height];
    [theTarget setMinimumHeight:minimum_height];
    [theTarget setStaticFlags:static_flags];
    [theTarget setPolygonIndex:-1];
    [theTarget setPolygonObject:nil];
    [theTarget setTag:tag];
}

-(short)index { return [theMapPlatformsST indexOfObjectIdenticalTo:self]; }

-(void) updateIndexesNumbersFromObjects
{
   /* if (everythingLoadedST == NO)
        return;
    
    if (polygon_object == nil)
        polygon_index = -1;
    else
        polygon_index = [theMapPolysST indexOfObjectIdenticalTo:polygon_object];*/
}

-(void) updateObjectsFromIndexes
{ //  Called Just After Loading Time...
    /*if (everythingLoadedST == NO)
        return;
    
    if (polygon_index == -1)
        polygon_object = nil;
    else if (everythingLoadedST)
        polygon_object = [theMapPolysST objectAtIndex:polygon_index];*/
}

// ************************** Get Accsessors *************************
@synthesize type;
@synthesize speed;
@synthesize delay;
@synthesize maximumHeight=maximum_height;
@synthesize minimumHeight=minimum_height;
@synthesize staticFlags=static_flags;
- (short)polygonIndex { return (polygon_object == nil) ? -1 : [polygon_object index]; }
@synthesize polygonObject=polygon_object;
@synthesize tag;
-(short)tag { return  (tagObject != nil) ? ([tagObject getSpecialIndex]) : (-1); }
@synthesize tagObject;

// ************************** Set Accsessors *************************

- (void)setPolygonIndex:(short)v
{
    //polygon_index = v;
    if (v == -1)
        polygon_object = nil;
    else if (/*everythingLoadedST*/ YES) // Should be ok not to check everythingIsLoadedST...
        polygon_object = [theMapPolysST objectAtIndex:v];
}

-(void)setTag:(short)v
{
    tag = v;
    tagObject = [self getTagForNumber:tag];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingTagObject
{
    return [NSSet setWithObject:@"tag"];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingPolygonObject
{
    return [NSSet setWithObject:@"polygonIndex"];
}

// ************************** Inzlizations And Class Methods *************************
#pragma mark -
#pragma mark ********* Inzlizations And Class Methods *********

//+(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }
//+(void)setTheMapPolysST:(NSArray *)theNSArray { theMapPolysST = theNSArray; }
//+(void)setThePlatformsST:(NSArray *)theNSArray { theMapPlatformsST = theNSArray; }

-(id)init
{
    if (self = [super init])
	{
		type = 0;
		speed = 60;
		delay = 30;
		maximum_height = 1024;
		minimum_height = 0;
		static_flags = 0;
		polygon_index = -1;
		polygon_object = nil;
		tag = 0;
		tagObject = nil;
	}
    return self;
}
@end
