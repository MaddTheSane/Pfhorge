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

@implementation PhLight

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********


- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    NSInteger tmpLong = 0;
    NSInteger i = 0;
    
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
    ExportUnsignedShort(flags);
    
    ExportShort(phase);
    
    for (i = 0; i < 6; i++)
    {
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
    
    NSLog(@"Exporting Light: %d  -- Position: %lu --- myData: %lu", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
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
    NSLog(@"Importing Light: %d  -- Position: %lu  --- Length: %ld", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    int i;
    
    ImportShort(type);
    ImportUnsignedShort(flags);
    
    ImportShort(phase);
    
    for (i = 0; i < 6; i++)
    {
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
    encodeNumInt(coder, 0);
    
    
    encodeShort(coder, type);
    encodeUnsignedShort(coder, flags);
    
    encodeShort(coder, phase);
    
    for (i = 0; i < 6; i++)
    {
        encodeShort(coder, light_states[i].function);
        encodeShort(coder, light_states[i].period);
        encodeShort(coder, light_states[i].delta_period);
        encodeLong(coder, light_states[i].intensity);
        encodeLong(coder, light_states[i].delta_intensity);
    }
     
    encodeShort(coder, tag);
    encodeObj(coder, tagObject);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int i;
    
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    type = decodeShort(coder);
    flags = decodeUnsignedShort(coder);
    
    phase = decodeShort(coder);
    
    for (i = 0; i < 6; i++)
    {
        light_states[i].function = decodeShort(coder);
        light_states[i].period = decodeShort(coder);
        light_states[i].delta_period = decodeShort(coder);
        light_states[i].intensity = decodeInt(coder);
        light_states[i].delta_intensity = decodeInt(coder);
    }
     
    tag = decodeShort(coder);
    tagObject = decodeObj(coder);
    
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
    }
}
 
 // **************************  Overriden Standard Methods  *************************

-(short) getIndex { return [theMapLightsST indexOfObjectIdenticalTo:self]; }

-(void)update
{
    
}

// *****************   Accsessors   *****************

@synthesize type;
@synthesize flags;

@synthesize phase;

-(void)setFunction:(short)v forState:(short)i { light_states[i].function = v; }
-(void)setPeriod:(short)v forState:(short)i { light_states[i].period = v; }
-(void)setDeltaPeriod:(short)v forState:(short)i { light_states[i].delta_period = v; }
-(void)setIntensity:(int)v forState:(short)i { light_states[i].intensity = v; }
-(void)setDeltaIntensity:(int)v forState:(short)i { light_states[i].delta_intensity = v; } // used to be a fixed type :)

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

-(short)functionForState:(short)i { return  light_states[i].function; }
-(short)periodForState:(short)i { return  light_states[i].period; }
-(short)deltaPeriodForState:(short)i { return  light_states[i].delta_period; }
-(int32_t)intensityForState:(short)i { return  light_states[i].intensity; }
-(int32_t)deltaIntensityForState:(short)i { return  light_states[i].delta_intensity; } // used to be a fixed type :)

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
            if (i < 4 && i > -1)
                unused[i] = 0;
        }
    }
    return self;
}

@end

// 295 w 850 s
