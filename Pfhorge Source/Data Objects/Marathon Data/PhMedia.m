//
//  PhMedia.m
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

#import "PhMedia.h"
#import "LEExtras.h"

#define GET_MEDIA_FLAG(b) (flags & (b))
#define SET_MEDIA_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@implementation PhMedia

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
    
    ExportShort(type);
    ExportUnsignedShort(flags);
    
    ExportObjPos(light_object);
    ExportObj(light_object);
    
    ExportShort(current_direction);
    ExportShort(current_magnitude);
    ExportShort(low);
    ExportShort(high);
    ExportShort(origin.x);
    ExportShort(origin.y);
    ExportShort(height);
    ExportLong(minimum_light_intensity);
    ExportShort(texture);
    ExportShort(transfer_mode);
    
    // *** End Exporting ***
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
     NSLog(@"Exporting Media: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
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
    NSLog(@"Importing Media: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    ImportShort(type);
    ImportUnsignedShort(flags);
    
    if (useOrg != YES)
    {
        ImportObjIndexPos(light_object, theMapLightsST);
        SkipObj();
    }
    else
    {
        SkipObj();
        ImportObj(light_object);
    }
    
    ImportShort(current_direction);
    ImportShort(current_magnitude);
    ImportShort(low);
    ImportShort(high);
    ImportShort(origin.x);
    ImportShort(origin.y);
    ImportShort(height);
    ImportInt(minimum_light_intensity);
    ImportShort(texture);
    ImportShort(transfer_mode);
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    int tempInt;
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeShort(coder, type);
    encodeUnsignedShort(coder, flags);
    
    encodeObj(coder, light_object);
    
    encodeShort(coder, current_direction);
    encodeShort(coder, current_magnitude);
    
    encodeShort(coder, low);
    encodeShort(coder, high);
    
    tempInt = origin.x;
    encodeInt(coder, tempInt);
    tempInt = origin.y;
    encodeInt(coder, tempInt);
    encodeShort(coder, height);
    
    encodeLong(coder, minimum_light_intensity);
    encodeShort(coder, texture);
    encodeShort(coder, transfer_mode);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    type = decodeShort(coder);
    flags = decodeUnsignedShort(coder);
    
    light_object = decodeObj(coder);
    
    current_direction = decodeShort(coder);
    current_magnitude = decodeShort(coder);
    
    low = decodeShort(coder);
    high = decodeShort(coder);
    
    origin.x = decodeInt(coder);
    origin.y = decodeInt(coder);
    height = decodeShort(coder);
    
    minimum_light_intensity = decodeInt(coder);
    texture = decodeShort(coder);
    transfer_mode = decodeShort(coder);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhMedia *copy = [[PhMedia allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// ****************** Utilites ********************
#pragma mark -
#pragma mark ********* Utilites *********

-(void)setLightsThatAre:(id)theLightInQuestion to:(id)setToLight
{
    if (light_object == theLightInQuestion)
        [self setLightObject:setToLight];
}


// **************************  Flag Methods  *************************
#pragma mark -
#pragma mark ********* Flag Methods *********

-(BOOL)getFlag:(unsigned short)theFlag;
{
    switch (theFlag)
    {
        case _media_sound_obstructed_by_floor:
            return GET_MEDIA_FLAG(_media_sound_obstructed_by_floor);
            break;
    }
    return NO;
}

-(void)setFlag:(unsigned short)theFlag to:(BOOL)v
{
    switch (theFlag)
    {
        case _media_sound_obstructed_by_floor:
            SET_MEDIA_FLAG(_media_sound_obstructed_by_floor, v);
            break;
    }
}
 
 // **************************  Overriden Standard Methods  *************************
#pragma mark -
#pragma mark ********* Overriden Standard Methods *********

-(short) index { return [theMediaST indexOfObjectIdenticalTo:self]; }

-(void) updateObjectsFromIndexes
{
    //[self setLightIndex:[self lightIndex]];
}

-(void)update
{

}

// *****************   Accsessors   *****************
#pragma mark -
#pragma mark ********* Accsessors *********

@synthesize type;
@synthesize flags;

+(NSSet<NSString *> *)keyPathsForValuesAffectingLightIndex
{
    return [NSSet setWithObject:@"lightObject"];
}

+(NSSet<NSString *> *)keyPathsForValuesAffectingLightObject
{
    return [NSSet setWithObject:@"lightIndex"];
}

@dynamic lightIndex;
-(void)setLightIndex:(short)v
{
    //light_index = v;
    if (v == -1)
        light_object = nil;
    else if (everythingLoadedST)
        light_object = [theMapLightsST objectAtIndex:v];
}
@synthesize lightObject=light_object;

@synthesize currentDirection=current_direction;
@synthesize currentMagnitude=current_magnitude;

@synthesize low;
@synthesize high;

@synthesize origin;
@synthesize height;

@synthesize minimumLightIntensity=minimum_light_intensity; // ??? Object ???
@synthesize texture;
@synthesize transferMode=transfer_mode;

// *****************   Get Accsessors   *****************
#pragma mark -
#pragma mark ********* Get Accsessors *********


-(short)lightIndex { return (light_object == nil) ? -1 : [light_object index]; }

// ************************** Inzlizations And Class Methods *************************
#pragma mark -
#pragma mark ********* Inzlizations And Class Methods *********

//+(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }
//+(void)setTheMapLightsST:(NSArray *)theNSArray { theMapLightsST = theNSArray; }

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
