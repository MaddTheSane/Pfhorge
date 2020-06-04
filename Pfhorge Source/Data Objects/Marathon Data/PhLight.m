//
//  LELight.m
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

#import "PhLight.h"
#import "LEExtras.h"
#import "PhTag.h"

#define GET_LIGHT_FLAG(b) (flags & (b))
#define SET_LIGHT_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@interface PhLightingFunctionSpecificationObject: NSObject <NSSecureCoding>
{
	PhLightFunction function;

	short period, delta_period;
	int32_t	intensity, delta_intensity; // used to be a fixed type :)
}
@property PhLightFunction function;

@property short period, deltaPeriod;
@property int32_t	intensity, deltaIntensity;

- (instancetype)initWithCStruct:(struct lighting_function_specification)cStruct;
@property (readonly) struct lighting_function_specification cStruct;
@end

@implementation PhLightingFunctionSpecificationObject
@synthesize function;
@synthesize period;
@synthesize deltaPeriod=delta_period;
@synthesize intensity;
@synthesize deltaIntensity=delta_intensity;

-(instancetype)initWithCStruct:(struct lighting_function_specification)cStruct
{
	if (self = [super init]) {
		function = cStruct.function;
		period = cStruct.period;
		delta_period = cStruct.delta_period;
		intensity = cStruct.intensity;
		delta_intensity = cStruct.delta_intensity;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if (!coder.allowsKeyedCoding) {
		[coder failWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil]];
		return;
	}
	[coder encodeInt:function forKey:@"function"];
	[coder encodeInt:period forKey:@"period"];
	[coder encodeInt:delta_period forKey:@"deltaPeriod"];
	[coder encodeInt:intensity forKey:@"intensity"];
	[coder encodeInt:delta_intensity forKey:@"deltaIntensity"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		if (!coder.allowsKeyedCoding) {
			[coder failWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil]];
			[self release];
			return nil;
		}
		function = [coder decodeIntForKey:@"function"];
		period = [coder decodeIntForKey:@"period"];
		delta_period = [coder decodeIntForKey:@"deltaPeriod"];
		intensity = [coder decodeIntForKey:@"intensity"];
		delta_intensity = [coder decodeIntForKey:@"deltaIntensity"];
	}
	return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (struct lighting_function_specification)cStruct
{
	struct lighting_function_specification toRet;
	toRet.function = function;
	toRet.period = period;
	toRet.delta_period = delta_period;
	toRet.intensity = intensity;
	toRet.delta_intensity = delta_intensity;
	return toRet;
}

@end

@implementation PhLight

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********


- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    NSInteger tmpLong = 0;
    NSInteger i = 0;
    
    if (theNumber != NSNotFound) {
        return theNumber;
    }
    
    NSInteger myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    // *** Start Exporting ***
    
    
    ExportShort(type);
    ExportUnsignedShort(flags);
    
    ExportShort(phase);
    
    for (i = 0; i < 6; i++) {
        ExportShort(light_states[i].function);
        ExportShort(light_states[i].period);
        ExportShort(light_states[i].delta_period);
        ExportLong(light_states[i].intensity);
        ExportLong(light_states[i].delta_intensity);
    }
    
    ExportTag(tagObject);
    
    
    // *** End Exporting ***
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
    NSLog(@"Exporting Light: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ([index indexOfObjectIdenticalTo:self] != myPosition) {
		NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Light: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    int i;
    
    ImportShort(type);
    ImportUnsignedShort(flags);
    
    ImportShort(phase);
    
    for (i = 0; i < 6; i++) {
        ImportShort(light_states[i].function);
        ImportShort(light_states[i].period);
        ImportShort(light_states[i].delta_period);
        ImportInt(light_states[i].intensity);
        ImportInt(light_states[i].delta_intensity);
    }
    
    ImportTag(tagObject);
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    int i;
    
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:type forKey:@"type"];
        [coder encodeInt:flags forKey:@"flags"];
        
        [coder encodeInt:phase forKey:@"phase"];
        
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:6];
        for (i = 0; i < 6; i++) {
            [tmp addObject:[[[PhLightingFunctionSpecificationObject alloc] initWithCStruct:light_states[i]] autorelease]];
        }
        [coder encodeObject:tmp forKey:@"light_states"];
        
        [coder encodeInt:tag forKey:@"tag"];
        [coder encodeObject:tagObject forKey:@"tagObject"];
    } else {
        encodeNumInt(coder, 0);
        
        
        encodeShort(coder, type);
        encodeUnsignedShort(coder, flags);
        
        encodeShort(coder, phase);
        
        for (i = 0; i < 6; i++) {
            encodeShort(coder, light_states[i].function);
            encodeShort(coder, light_states[i].period);
            encodeShort(coder, light_states[i].delta_period);
            encodeLong(coder, light_states[i].intensity);
            encodeLong(coder, light_states[i].delta_intensity);
        }
        
        encodeShort(coder, tag);
        encodeObj(coder, tagObject);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    int i;
    
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        type = [coder decodeIntForKey:@"type"];
        flags = [coder decodeIntForKey:@"flags"];
        
        phase = [coder decodeIntForKey:@"phase"];
        NSArray *tmp = [coder decodeObjectOfClasses:[NSSet setWithObjects:[PhLightingFunctionSpecificationObject class], [NSArray class], nil] forKey:@"light_states"];
        for (i = 0; i < 6; i++) {
            PhLightingFunctionSpecificationObject *obj = tmp[i];
            light_states[i] = obj.cStruct;
        }
        
        tag = [coder decodeIntForKey:@"tag"];
        tagObject = [coder decodeObjectOfClass:[PhTag class] forKey:@"tagObject"];
    } else {
        /*int versionNum = */decodeNumInt(coder);
        
        type = decodeShort(coder);
        flags = decodeUnsignedShort(coder);
        
        phase = decodeShort(coder);
        
        for (i = 0; i < 6; i++) {
            light_states[i].function = decodeShort(coder);
            light_states[i].period = decodeShort(coder);
            light_states[i].delta_period = decodeShort(coder);
            light_states[i].intensity = decodeInt(coder);
            light_states[i].delta_intensity = decodeInt(coder);
        }
        
        tag = decodeShort(coder);
        tagObject = decodeObj(coder);
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhLight *copy = [[PhLight allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// **************************  Flag Methods  *************************

-(BOOL)getFlag:(PhLightStaticFlags)theFlag;
{
    switch (theFlag)
    {
        case PhLightStaticFlagIsInitiallyActive:
            return GET_LIGHT_FLAG(PhLightStaticFlagIsInitiallyActive);
            break;
        case PhLightStaticFlagIsStateless:
            return GET_LIGHT_FLAG(PhLightStaticFlagIsStateless);
            break;
        default:
            break;
    }
    return NO;
}

-(void)setFlag:(PhLightStaticFlags)theFlag to:(BOOL)v
{
    switch (theFlag)
    {
        case PhLightStaticFlagIsInitiallyActive:
            SET_LIGHT_FLAG(PhLightStaticFlagIsInitiallyActive, v);
            break;
        case PhLightStaticFlagIsStateless:
            SET_LIGHT_FLAG(PhLightStaticFlagIsStateless, v);
            break;
        default:
            break;
    }
}
 
 // **************************  Overriden Standard Methods  *************************

-(short) index { return [theMapLightsST indexOfObjectIdenticalTo:self]; }

-(void)update
{
    
}

// *****************   Accsessors   *****************

@synthesize type;
@synthesize flags;

@synthesize phase;

-(void)setFunction:(PhLightFunction)v forState:(PhLightState)i { light_states[i].function = v; }
-(void)setPeriod:(short)v forState:(PhLightState)i { light_states[i].period = v; }
-(void)setDeltaPeriod:(short)v forState:(PhLightState)i { light_states[i].delta_period = v; }
-(void)setIntensity:(int)v forState:(PhLightState)i { light_states[i].intensity = v; }
-(void)setDeltaIntensity:(int)v forState:(PhLightState)i { light_states[i].delta_intensity = v; } // used to be a fixed type :)

@synthesize tag;
-(void)setTag:(short)v
{
    tag = v;
    tagObject = [self getTagForNumber:tag];
}

@synthesize tagObject;

+(NSSet<NSString *> *)keyPathsForValuesAffectingTag
{
    return [NSSet setWithObject:@"tagObject"];
}

+(NSSet<NSString *> *)keyPathsForValuesAffectingTagObject
{
    return [NSSet setWithObject:@"tag"];
}

-(PhLightFunction)functionForState:(PhLightState)i { return  light_states[i].function; }
-(short)periodForState:(PhLightState)i { return  light_states[i].period; }
-(short)deltaPeriodForState:(PhLightState)i { return  light_states[i].delta_period; }
-(int32_t)intensityForState:(PhLightState)i { return  light_states[i].intensity; }
-(int32_t)deltaIntensityForState:(PhLightState)i { return  light_states[i].delta_intensity; } // used to be a fixed type :)

-(short)tag { return (tagObject != nil) ? ([tagObject getSpecialIndex]) : (-1); }

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }

-(id)init
{
    if (self = [super init]) {
        int i;
        
        type = 0;
        flags = 0;
        phase = 0;
        tag = 0;
        tagObject = nil;
        
        for (i = 0; i < 6; i++)
        {
            NSParameterAssert(i >= 0 && i < 6);
            
            light_states[i].function = 0;
            light_states[i].function = 0;
            light_states[i].period = 0;
            light_states[i].delta_period = 0;
            light_states[i].intensity = 0;
            light_states[i].delta_intensity = 0;
        }
    }
    return self;
}

@end

// 295 w 850 s
