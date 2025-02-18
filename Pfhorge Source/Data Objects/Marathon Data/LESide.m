//
//  LESide.m
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

#import "LESide.h"
#import "LEExtras.h"
#import "LELevelData.h"
#import "LELine.h"
#import "PhTag.h"
#import "PhLight.h"

#import "PhData.h"

@interface LESideTextureDefinition : NSObject <NSSecureCoding>
@property world_distance		x0, y0;
@property shape_descriptor	texture;

// These have been added, they are not a part of the orginal structure defintion...
@property short textureCollection; //!< Obsolete... This was not in the orginal structure!
@property short textureNumber; //!< Obsolete... This was not in the orginal structure!

+ (LESideTextureDefinition*)sideTextureFromCStruct:(side_texture_definition)cTyp;
@property (readonly) side_texture_definition cStructSideTextureDefinition;

@end

@implementation LESideTextureDefinition

+ (LESideTextureDefinition *)sideTextureFromCStruct:(side_texture_definition)cTyp
{
	LESideTextureDefinition *toRet = [[LESideTextureDefinition alloc] init];
	toRet.x0 = cTyp.x0;
	toRet.y0 = cTyp.y0;
	toRet.texture = cTyp.texture;
	toRet.textureCollection = cTyp.textureCollection;
	toRet.textureNumber = cTyp.textureNumber;

	return toRet;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
	if (!coder.allowsKeyedCoding) {
		[coder failWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil]];
		return;
	}
	[coder encodeInt:_x0 forKey:@"x0"];
	[coder encodeInt:_y0 forKey:@"y0"];
	[coder encodeInt:_texture forKey:@"texture"];
	[coder encodeInt:_textureCollection forKey:@"textureCollection"];
	[coder encodeInt:_textureNumber forKey:@"textureNumber"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
	if (self = [super init]) {
		if (!coder.allowsKeyedCoding) {
			[coder failWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil]];
			return nil;
		}
		_x0 = [coder decodeIntForKey:@"x0"];
		_y0 = [coder decodeIntForKey:@"y0"];
		_texture = [coder decodeIntForKey:@"texture"];
		_textureCollection = [coder decodeIntForKey:@"textureCollection"];
		_textureNumber = [coder decodeIntForKey:@"textureNumber"];
	}
	return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (side_texture_definition)cStructSideTextureDefinition
{
	side_texture_definition toRet;
	toRet.x0 = self.x0;
	toRet.y0 = self.y0;
	toRet.texture = self.texture;
	toRet.textureCollection = self.textureCollection;
	toRet.textureNumber = self.textureNumber;
	return toRet;
}

@end

#define GET_SIDE_FLAG(b) ((flags & (b)) == (b))
#define SET_SIDE_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@implementation LESide
 // **************************  Coding/Copy Protocol Methods  *************************
#pragma mark - Coding/Copy Protocol Methods


 - (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    int tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound) {
        return theNumber;
    }
    
    NSInteger myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    ExportShort(type);
    ExportUnsignedShort(flags);
    
    ExportShort(primary_texture.x0);
    ExportShort(primary_texture.y0);
    ExportShort(primary_texture.texture);
    ExportShort(primary_texture.textureCollection);
    ExportShort(primary_texture.textureNumber);
    
    ExportShort(secondary_texture.x0);
    ExportShort(secondary_texture.y0);
    ExportShort(secondary_texture.texture);
    ExportShort(secondary_texture.textureCollection);
    ExportShort(secondary_texture.textureNumber);
    
    ExportShort(transparent_texture.x0);
    ExportShort(transparent_texture.y0);
    ExportShort(transparent_texture.texture);
    ExportShort(transparent_texture.textureCollection);
    ExportShort(transparent_texture.textureNumber);
    
    ExportShort(control_panel_type);
    
    // 	In the future, might want to encode an addtional short that
    // tells wether, when importing, it should refer to an imported object
    // or an already exsisting object... (for example, a teleport destination
    // that is not going to be exported)...
    
    if (control_panel_permutation_object != nil && [mainObjs containsObject:control_panel_permutation_object]) {
        ExportObj(control_panel_permutation_object);
    } else {
        ExportNil();
    }
    
    ExportLong(permutationEffects);
    
    ExportShort(primary_transfer_mode);
    ExportShort(secondary_transfer_mode);
    ExportShort(transparent_transfer_mode);
    
    if (polygon_object != nil && [mainObjs containsObject:polygon_object]) {
        ExportObj(polygon_object);
    } else {
        ExportNil();
    }
    
    if (line_object != nil && [mainObjs containsObject:line_object]) {
        ExportObj(line_object);
    } else {
        ExportNil();
    }
    
    
    // 	In the future, you should also encode the current index
    // then the user has a choice, when importing this object, wether
    // to use lights at the same index, or to use the exported lights...
    
    //if (primary_lightsource_object != nil && [mainObjs containsObject:primary_lightsource_object])
        //ExportObj(primary_lightsource_object);
        ExportObjPos(primary_lightsource_object);
    //else
    //    ExportObj(nil);

    //if (secondary_lightsource_object != nil && [mainObjs containsObject:secondary_lightsource_object])
        //ExportObj(secondary_lightsource_object);
        ExportObjPos(secondary_lightsource_object);
    // else
    //     ExportObj(nil);

    //if (transparent_lightsource_object != nil && [mainObjs containsObject:transparent_lightsource_object])
        //ExportObj(transparent_lightsource_object);
        ExportObjPos(transparent_lightsource_object);
    //else
    //    ExportObj(nil);
    
    
    ExportLong(ambient_delta);
    
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = (int)[myData length];
    saveIntToNSData(tmpLong, theData);
    [theData appendData:myData];
    [theData appendData:futureData];
    

    NSLog(@"Exporting Side: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    if ([index indexOfObjectIdenticalTo:self] != myPosition) {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Side: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    ImportShort(type);
    ImportUnsignedShort(flags);
    
    ImportShort(primary_texture.x0);
    ImportShort(primary_texture.y0);
    ImportShort(primary_texture.texture);
    ImportShort(primary_texture.textureCollection);
    ImportShort(primary_texture.textureNumber);
    
    ImportShort(secondary_texture.x0);
    ImportShort(secondary_texture.y0);
    ImportShort(secondary_texture.texture);
    ImportShort(secondary_texture.textureCollection);
    ImportShort(secondary_texture.textureNumber);
    
    ImportShort(transparent_texture.x0);
    ImportShort(transparent_texture.y0);
    ImportShort(transparent_texture.texture);
    ImportShort(transparent_texture.textureCollection);
    ImportShort(transparent_texture.textureNumber);
    
    ImportShort(control_panel_type);
    
    // 	In the future, might want to encode an addtional short that
    // tells wether, when importing, it should refer to an imported object
    // or an already exsisting object... (for example, a teleport destination
    // that is not going to be exported)...
    
    ImportObj(control_panel_permutation_object);
    
    ImportInt(permutationEffects);
    
    ImportShort(primary_transfer_mode);
    ImportShort(secondary_transfer_mode);
    ImportShort(transparent_transfer_mode);
    
    ImportObj(polygon_object);
    ImportObj(line_object);
    
    
    // 	In the future, you should also encode the current index
    // then the user has a choice, when importing this object, wether
    // to use lights at the same index, or to use the exported lights...
    
    //if (primary_lightsource_object != nil && [mainObjs containsObject:primary_lightsource_object])
        ImportObjIndexPos(primary_lightsource_object, theMapLightsST);
        //ImportObj(primary_lightsource_object);
    //else
    //    ExportObj(nil);

    //if (secondary_lightsource_object != nil && [mainObjs containsObject:secondary_lightsource_object])
        ImportObjIndexPos(secondary_lightsource_object, theMapLightsST);
        //ImportObj(secondary_lightsource_object);
    // else
    //     ExportObj(nil);

    //if (transparent_lightsource_object != nil && [mainObjs containsObject:transparent_lightsource_object])
        ImportObjIndexPos(transparent_lightsource_object, theMapLightsST);
        //ImportObj(transparent_lightsource_object);
    //else
    //    ExportObj(nil);
    
    
    ImportInt(ambient_delta);
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    short tmpShort;
    
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:type forKey:@"type"];
        [coder encodeInt:flags forKey:@"flags"];
        
        [coder encodeConditionalObject:polygon_object forKey:@"polygon_object"];
        [coder encodeConditionalObject:line_object forKey:@"line_object"];
        [coder encodeObject:[LESideTextureDefinition sideTextureFromCStruct:primary_texture] forKey:@"primary_texture"];
        [coder encodeObject:[LESideTextureDefinition sideTextureFromCStruct:secondary_texture] forKey:@"secondary_texture"];
        [coder encodeObject:[LESideTextureDefinition sideTextureFromCStruct:transparent_texture] forKey:@"transparent_texture"];
        [coder encodePoint:exclusion_zone.e0 forKey:@"exclusion_zone.e0"];
        [coder encodePoint:exclusion_zone.e1 forKey:@"exclusion_zone.e1"];
        [coder encodePoint:exclusion_zone.e2 forKey:@"exclusion_zone.e2"];
        [coder encodePoint:exclusion_zone.e3 forKey:@"exclusion_zone.e3"];
        
        [coder encodeInt:control_panel_type forKey:@"control_panel_type"];
        [coder encodeInt:control_panel_permutation forKey:@"control_panel_permutation"];
        
        [coder encodeInt:primary_transfer_mode forKey:@"primary_transfer_mode"];
        [coder encodeInt:secondary_transfer_mode forKey:@"secondary_transfer_mode"];
        [coder encodeInt:transparent_transfer_mode forKey:@"transparent_transfer_mode"];
        
        // If So, Should Already Have This On:
        // setEncodeIndexNumbersInstead:YES];
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(primary_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"primary_lightsource_object index"];
            tmpShort = GetIndexAdv(secondary_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"secondary_lightsource_object index"];
            tmpShort = GetIndexAdv(transparent_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"transparent_lightsource_object index"];
        } else {
            [coder encodeObject:primary_lightsource_object forKey:@"primary_lightsource_object"];
            [coder encodeObject:secondary_lightsource_object forKey:@"secondary_lightsource_object"];
            [coder encodeObject:transparent_lightsource_object forKey:@"transparent_lightsource_object"];
            [coder encodeObject:control_panel_permutation_object forKey:@"control_panel_permutation_object"];
        }
        
        [coder encodeInt:ambient_delta forKey:@"ambient_delta"];
    } else {
        encodeNumInt(coder, 0);
        
        encodeShort(coder, type);
        encodeUnsignedShort(coder, flags);
        
        encodeShort(coder, primary_texture.x0);
        encodeShort(coder, primary_texture.y0);
        encodeShort(coder, primary_texture.texture);
        encodeShort(coder, primary_texture.textureCollection);
        encodeShort(coder, primary_texture.textureNumber);
        
        encodeShort(coder, secondary_texture.x0);
        encodeShort(coder, secondary_texture.y0);
        encodeShort(coder, secondary_texture.texture);// Seperate this into two chars
        encodeShort(coder, secondary_texture.textureCollection);
        encodeShort(coder, secondary_texture.textureNumber);
        
        encodeShort(coder, transparent_texture.x0);
        encodeShort(coder, transparent_texture.y0);
        encodeShort(coder, transparent_texture.texture);
        encodeShort(coder, transparent_texture.textureCollection);
        encodeShort(coder, transparent_texture.textureNumber);
        
        
        [coder encodePoint:exclusion_zone.e0];
        [coder encodePoint:exclusion_zone.e1];
        [coder encodePoint:exclusion_zone.e2];
        [coder encodePoint:exclusion_zone.e3];
        
        encodeShort(coder, control_panel_type);
        encodeShort(coder, control_panel_permutation);
        
        encodeShort(coder, primary_transfer_mode);
        encodeShort(coder, secondary_transfer_mode);
        encodeShort(coder, transparent_transfer_mode);
        
        // If So, Should Already Have This On:
        // setEncodeIndexNumbersInstead:YES];
        encodeConditionalObject(coder, polygon_object);
        encodeConditionalObject(coder, line_object);
        
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(primary_lightsource_object);
            encodeShort(coder, tmpShort);
            tmpShort = GetIndexAdv(secondary_lightsource_object);
            encodeShort(coder, tmpShort);
            tmpShort = GetIndexAdv(transparent_lightsource_object);
            encodeShort(coder, tmpShort);
        } else {
            encodeObj(coder, primary_lightsource_object);
            encodeObj(coder, secondary_lightsource_object);
            encodeObj(coder, transparent_lightsource_object);
            encodeObj(coder, control_panel_permutation_object);
        }
        
        encodeLong(coder, ambient_delta);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    
    //NSLog(@"Side");
    
    if (self = [super initWithCoder:coder]) {
        if (coder.allowsKeyedCoding) {
            type = [coder decodeIntForKey:@"type"];
            flags = [coder decodeIntForKey:@"flags"];
            
            primary_texture = [[coder decodeObjectOfClass:[LESideTextureDefinition class] forKey:@"primary_texture"] cStructSideTextureDefinition];
            secondary_texture = [[coder decodeObjectOfClass:[LESideTextureDefinition class] forKey:@"secondary_texture"] cStructSideTextureDefinition];
            transparent_texture = [[coder decodeObjectOfClass:[LESideTextureDefinition class] forKey:@"transparent_texture"] cStructSideTextureDefinition];
            
            exclusion_zone.e0 = [coder decodePointForKey:@"exclusion_zone.e0"];
            exclusion_zone.e1 = [coder decodePointForKey:@"exclusion_zone.e1"];
            exclusion_zone.e2 = [coder decodePointForKey:@"exclusion_zone.e2"];
            exclusion_zone.e3 = [coder decodePointForKey:@"exclusion_zone.e3"];
            
            control_panel_type = [coder decodeIntForKey:@"control_panel_type"];
            control_panel_permutation = [coder decodeIntForKey:@"control_panel_permutation"];
            
            primary_transfer_mode = [coder decodeIntForKey:@"primary_transfer_mode"];
            secondary_transfer_mode = [coder decodeIntForKey:@"secondary_transfer_mode"];
            transparent_transfer_mode = [coder decodeIntForKey:@"transparent_transfer_mode"];
            
            polygon_object = [coder decodeObjectOfClass:[LEPolygon class] forKey:@"polygon_object"];
            line_object = [coder decodeObjectOfClass:[LELine class] forKey:@"line_object"];
            
            if (useIndexNumbersInstead) {
                short tmpShort;
                tmpShort = [coder decodeIntForKey:@"primary_lightsource_object index"];
                primary_lightsource_object = [self getLightFromIndex:tmpShort];
                tmpShort = [coder decodeIntForKey:@"secondary_lightsource_object index"];
                secondary_lightsource_object = [self getLightFromIndex:tmpShort];
                tmpShort = [coder decodeIntForKey:@"transparent_lightsource_object index"];
                transparent_lightsource_object = [self getLightFromIndex:tmpShort];
            } else {
                primary_lightsource_object = [coder decodeObjectOfClass:[PhLight class] forKey:@"primary_lightsource_object"];
                secondary_lightsource_object = [coder decodeObjectOfClass:[PhLight class] forKey:@"secondary_lightsource_object"];
                transparent_lightsource_object = [coder decodeObjectOfClass:[PhLight class] forKey:@"transparent_lightsource_object"];
                control_panel_permutation_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"control_panel_permutation_object"];
            }
            
            ambient_delta = [coder decodeIntForKey:@"ambient_delta"];
            
        } else {
            if (self == nil)
                NSLog(@"************************************ Side - nil - 1...");
            
            versionNum = decodeNumInt(coder);
            
            type = decodeShort(coder);
            flags = decodeUnsignedShort(coder);
            
            primary_texture.x0 = decodeShort(coder);
            primary_texture.y0 = decodeShort(coder);
            primary_texture.texture = decodeShort(coder);
            primary_texture.textureCollection = decodeShort(coder);
            primary_texture.textureNumber = decodeShort(coder);
            
            secondary_texture.x0 = decodeShort(coder);
            secondary_texture.y0 = decodeShort(coder);
            secondary_texture.texture = decodeShort(coder);
            secondary_texture.textureCollection = decodeShort(coder);
            secondary_texture.textureNumber = decodeShort(coder);
            
            transparent_texture.x0 = decodeShort(coder);
            transparent_texture.y0 = decodeShort(coder);
            transparent_texture.texture = decodeShort(coder);
            transparent_texture.textureCollection = decodeShort(coder);
            transparent_texture.textureNumber = decodeShort(coder);
            
            
            exclusion_zone.e0 = [coder decodePoint];
            exclusion_zone.e1 = [coder decodePoint];
            exclusion_zone.e2 = [coder decodePoint];
            exclusion_zone.e3 = [coder decodePoint];
            
            control_panel_type = decodeShort(coder);
            control_panel_permutation = decodeShort(coder);
            
            primary_transfer_mode = decodeShort(coder);
            secondary_transfer_mode = decodeShort(coder);
            transparent_transfer_mode = decodeShort(coder);
            
            polygon_object = decodeObj(coder);
            line_object = decodeObj(coder);
            
            if (useIndexNumbersInstead) {
                primary_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
                secondary_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
                transparent_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
            } else {
                primary_lightsource_object = decodeObj(coder);
                secondary_lightsource_object = decodeObj(coder);
                transparent_lightsource_object = decodeObj(coder);
                control_panel_permutation_object = decodeObj(coder);
            }
            
            ambient_delta = decodeLong(coder);
            
            if (polygon_object == nil || line_object == nil) {
                if (self == nil) {
                    NSLog(@"************************************ Side - nil - 2...");
                }
                //return nil;
            }
        }
        
        if (useIndexNumbersInstead)
            [theLELevelDataST addObjects:self];
        
        useIndexNumbersInstead = NO;
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

-(void)dealloc
{
}

// ****************** Utilites ********************
#pragma mark - Utilites

-(void)setLightsThatAre:(PhLight*)theLightInQuestion to:(PhLight*)setToLight
{
    if (transparent_lightsource_object == theLightInQuestion)
        transparent_lightsource_object = setToLight;
    
    if (secondary_lightsource_object == theLightInQuestion)
        secondary_lightsource_object = setToLight;
    
    if (primary_lightsource_object == theLightInQuestion)
        primary_lightsource_object = setToLight;
}


// ***************** Copy Methods *****************
#pragma mark - Copy Methods

-(void)copySettingsTo:(id)target
{
    LESide *theTarget = (LESide *)target;
    
    if (primary_texture.texture != NONE) {
        [theTarget setPrimaryTextureStruct:primary_texture];
        [theTarget setPrimaryTransferMode:primary_transfer_mode];
        [theTarget setPrimaryLightsourceObject:primary_lightsource_object];
    }
    
    if (secondary_texture.texture != NONE) {
        [theTarget setSecondaryTextureStruct:secondary_texture];
        [theTarget setSecondaryTransferMode:secondary_transfer_mode];
        [theTarget setSecondaryLightsourceObject:secondary_lightsource_object];
    }
    
    if (transparent_texture.texture != NONE) {
        [theTarget setTransparentTextureStruct:transparent_texture];
        [theTarget setTransparentTransferMode:transparent_transfer_mode];
        [theTarget setTransparentLightsourceObject:transparent_lightsource_object];
    }
    
    // Should I? Proably, I will see what happens (the dragon, me)...
    [theTarget setFlags:flags];
    
    // Should I also inlucd control panel settings? We will see what happens...
    if (flags & LESideIsControlPanel) {
        [theTarget setControlPanelType:control_panel_type];
        [theTarget setControlPanelPermutation:control_panel_permutation];
    } else {
        [theTarget setControlPanelType:0];
        [theTarget setControlPanelPermutation:0];
    }
    
    [theTarget setExclusionZone:exclusion_zone];
    [theTarget setAmbientDelta:ambient_delta];
    
    // Added this on 1/25/2003, why was it not included
    // a long time before? 
    // Decided to leave it commented out becuase
    // the type should not have to be copyed over...
    //[theTarget setType:type];
}

- (id)copyWithZone:(NSZone *)zone
{
    LESide *copy = [[LESide allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
        
    [copy setType:type];
    [copy setFlags:flags];
            
    [copy setPrimaryTextureStruct:primary_texture];
    [copy setSecondaryTextureStruct:secondary_texture];
    [copy setTransparentTextureStruct:transparent_texture];
    
    [copy setExclusionZone:exclusion_zone];
            
    [copy setControlPanelType:control_panel_type];
    [copy setControlPanelPermutation:control_panel_permutation];
            
    [copy setPrimaryTransferMode:primary_transfer_mode];
    [copy setSecondaryTransferMode:secondary_transfer_mode];
    [copy setTransparentTransferMode:transparent_transfer_mode];
            
    
    [copy setPolygonObject:polygon_object];
    [copy setLineObject:line_object];
            
    
    [copy setPrimaryLightsourceObject:primary_lightsource_object];
    [copy setSecondaryLightsourceObject:secondary_lightsource_object];
    [copy setTransparentLightsourceObject:transparent_lightsource_object];
            
    [copy setAmbientDelta:ambient_delta];
    
    return copy;
}

// **************************  Flag Methods  *************************
#pragma mark - Flag Methods

-(BOOL)getFlagS:(short)theFlag;
{
    switch (theFlag) {
        case 1:
            return GET_SIDE_FLAG(LESideControlPanelStatus);
            break;
        case 2:
            return GET_SIDE_FLAG(LESideIsControlPanel);
            break;
        case 3:
            return GET_SIDE_FLAG(LESideIsRepairSwitch);
            break;
        case 4:
            return GET_SIDE_FLAG(LESideIsDestructiveSwitch);
            break;
        case 5:
            return GET_SIDE_FLAG(LESideIsLightedSwitch);
            break;
        case 6:
            return GET_SIDE_FLAG(LESideSwitchCanBeDestroyed);
            break;
        case 7:
            return GET_SIDE_FLAG(LESideSwitchCanOnlyBeByProjectiles);
            break;
        case 8:
            return GET_SIDE_FLAG(LESideEditorDirtyBit);
            break;
        default:
            NSLog(@"DEFAULT");
            break;
    }
    return NO;
}

-(void)setFlag:(unsigned short)theFlag to:(BOOL)v
 {
    switch (theFlag)
    {
        case LESideControlPanelStatus:
            SET_SIDE_FLAG(LESideControlPanelStatus, v);
            break;
        case LESideIsControlPanel:
            SET_SIDE_FLAG(LESideIsControlPanel, v);
            break;
        case LESideIsRepairSwitch:
            SET_SIDE_FLAG(LESideIsRepairSwitch, v);
            break;
        case LESideIsDestructiveSwitch:
            SET_SIDE_FLAG(LESideIsDestructiveSwitch, v);
            break;
        case LESideIsLightedSwitch:
            SET_SIDE_FLAG(LESideIsLightedSwitch, v);
            break;
        case LESideSwitchCanBeDestroyed:
            SET_SIDE_FLAG(LESideSwitchCanBeDestroyed, v);
            break;
        case LESideSwitchCanOnlyBeByProjectiles:
            SET_SIDE_FLAG(LESideSwitchCanOnlyBeByProjectiles, v);
            break;
        case LESideEditorDirtyBit:
            SET_SIDE_FLAG(LESideEditorDirtyBit, v);
            break;
    }
 }
 
 // **************************  Overriden Standard Methods  *************************
#pragma mark - Overriden Standard Methods
 
-(void)update
{

}

-(void) updateIndexesNumbersFromObjects
{

}

-(void) updateObjectsFromIndexes
{

}

-(short) index
{
    return [theMapSidesST indexOfObjectIdenticalTo:self];
}

// *****************   Set Accsessors   *****************
#pragma mark - Set Accsessors

-(void)setPrimaryTexture:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&primary_texture.texture;
    (theTexChar)[0] = number;
}

-(void)setSecondaryTexture:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&secondary_texture.texture;
    (theTexChar)[0] = number;
}

-(void)setTransparentTexture:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&transparent_texture.texture;
    (theTexChar)[0] = number;
}

-(void)setPrimaryTextureCollection:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&primary_texture.texture;
    (theTexChar)[1] = 0x11 + number;
}

-(void)setSecondaryTextureCollection:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&secondary_texture.texture;
    (theTexChar)[1] = 0x11 + number;
}

-(void)setTransparentTextureCollection:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&transparent_texture.texture;
    (theTexChar)[1] = 0x11 + number;
}

-(void)resetTextureCollection
{
    //TODO: make endian-safe
    // For right now it just sets it to the current levels
    // collection.
    char *thePTexChar = (char *)&primary_texture.texture;
    char *theSTexChar = (char *)&secondary_texture.texture;
    char *theTTexChar = (char *)&transparent_texture.texture;
    short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (thePTexChar)[1] = (0x11 + theCurrentEnviroCode);
    (theSTexChar)[1] = (0x11 + theCurrentEnviroCode);
    (theTTexChar)[1] = (0x11 + theCurrentEnviroCode);
}

-(void)setTextureCollection:(char)number
{
    //TODO: make endian-safe
    char *thePTexChar = (char *)&primary_texture.texture;
    char *theSTexChar = (char *)&secondary_texture.texture;
    char *theTTexChar = (char *)&transparent_texture.texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (thePTexChar)[1] = (0x11 + number);
    (theSTexChar)[1] = (0x11 + number);
    (theTTexChar)[1] = (0x11 + number);
}
        
-(void)setControlPanelType:(short)v
{
    int enviroCode = [theLELevelDataST environmentCode];
    int modfiedControlPanelType = -1;
    permutationEffects = 0;
    control_panel_type = v;
    
    switch (enviroCode) {
        case _water:
            modfiedControlPanelType = (control_panel_type - waterOffset);
            break;
        case _lava:
            modfiedControlPanelType = (control_panel_type - lavaOffset);
            break;
        case _sewage:
            modfiedControlPanelType = (control_panel_type - sewageOffset);
            break;
        case _jjaro:
            modfiedControlPanelType = (control_panel_type - jjaroOffset);
            break;
        case _pfhor:
            modfiedControlPanelType = (control_panel_type - pfhorOffset);
            break;
        default:
            NSLog(@"When setting side#%d control_panel_type, encountered an unknown enviromental code...", [self index]);
            return;
            break;
    }
        
    if (enviroCode == _water) {
        switch(modfiedControlPanelType) {
            case 3:
            case 6:
            case 9:
                permutationEffects = _cpanel_effects_tag;
                break;
            case 4:
                permutationEffects = _cpanel_effects_light;      
                break;
            case 5:
                permutationEffects = _cpanel_effects_polygon;
                break;
            case 8:
                permutationEffects = _cpanel_effects_terminal;
                break;
        }
    } else {
        switch(modfiedControlPanelType) {
            case 5:
            case 9:
            case 10:
                permutationEffects = _cpanel_effects_tag;
                break;
            case 3:
                permutationEffects = _cpanel_effects_light;      
                break;
            case 4:
                permutationEffects = _cpanel_effects_polygon;
                break;
            case 7:
                permutationEffects = _cpanel_effects_terminal;
                break;
        }
    }
    
   ///  NSLog(@"LESide#%d  effect: %d modPanelType: %d  orginalType: %d", [self index], permutationEffects, modfiedControlPanelType, control_panel_type);
    
    // Might want to point to the first object of whatever
    //  the permutation needs to point to?
    control_panel_permutation_object = nil;
    control_panel_permutation = -1;
}

-(void)setControlPanelPermutation:(short)v
{
    NSArray *theObjectArray = nil;
    control_panel_permutation = v;
    
    switch (permutationEffects) {
        case 0:
            control_panel_permutation_object = nil;
            return;
        case _cpanel_effects_tag: //g
            control_panel_permutation_object = [self getTagForNumber:control_panel_permutation];
            return;
        case _cpanel_effects_light: 
            theObjectArray = theMapLightsST;
            break;
        case _cpanel_effects_polygon:
            theObjectArray = theMapPolysST;
            break;
        case _cpanel_effects_terminal:
            // NSLog(@"Terminal Count: %d", [theTerminalsST count]);
            theObjectArray = theTerminalsST;
            break;
        default:
            
            break;
    }
    
    if (theObjectArray != nil && [theObjectArray count] > v)
   	control_panel_permutation_object = [theObjectArray objectAtIndex:control_panel_permutation];
    else
        control_panel_permutation_object = nil;
    
    return;
}

@synthesize controlPanelPermutationObject=control_panel_permutation_object;
        

//	--- --- ---

-(void)setPolygonIndex:(short)v {
    //polygon_index = v;
    if (v == -1)
        polygon_object = nil;
    else if (everythingLoadedST)
        polygon_object = [theMapPolysST objectAtIndex:v];
}
-(void)setLineIndex:(short)v {
    //line_index = v; 
    if (v == -1)
        line_object = nil;
    else if (everythingLoadedST)
        line_object = [theMapLinesST objectAtIndex:v];
}

//	*** *** ***

@synthesize polygonObject=polygon_object;
@synthesize lineObject=line_object;

// 	--- --- ---

-(void)setPrimaryLightsourceIndex:(short)v {
    //primary_lightsource_index = v;
    if (v == -1)
        primary_lightsource_object = nil;
    else if (everythingLoadedST)
        primary_lightsource_object = [theMapLightsST objectAtIndex:v];
}
-(void)setSecondaryLightsourceIndex:(short)v {
    //secondary_lightsource_index = v;
    
    if (v == -1)
        secondary_lightsource_object = nil;
    else if (everythingLoadedST)
        secondary_lightsource_object = [theMapLightsST objectAtIndex:v];
    
    NSLog(@"setSecondary_lightsource_index Set To: %d   The Object Index: %d", v, [secondary_lightsource_object index]);
}
-(void)setTransparentLightsourceIndex:(short)v {
    //transparent_lightsource_index = v;
    if (v == -1)
        transparent_lightsource_object = nil;
    else if (everythingLoadedST)
        transparent_lightsource_object = [theMapLightsST objectAtIndex:v];
}

//	--- --- ---
        
@synthesize ambientDelta=ambient_delta;

// *****************   Get Accsessors   *****************
#pragma mark - Get Accessors

-(char)primaryTexture
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&primary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0];
}

-(char)secondaryTexture
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&secondary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0];
}

-(char)transparentTexture
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&transparent_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0];
}

-(char)primaryTextureCollection
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&primary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1] - 0x11;
}

-(char)secondaryTextureCollection
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&secondary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1] - 0x11;
}

-(char)transparentTextureCollection
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&transparent_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1] - 0x11;
}

-(char)textureCollection
{ 
    return [self primaryTextureCollection];
}

@synthesize type;
@synthesize flags;
        
@synthesize primaryTextureStruct=primary_texture;
@synthesize secondaryTextureStruct=secondary_texture;
@synthesize transparentTextureStruct=transparent_texture;

@synthesize exclusionZone=exclusion_zone;

-(int)permutationEffects
{
    return permutationEffects;
}

@synthesize controlPanelType=control_panel_type;
-(short)controlPanelPermutation
{
    /*if (control_panel_permutation_object != nil)
        NSLog(@"polygonPermutationNumber: %d", [control_panel_permutation_object index]);*/
    
    return (control_panel_permutation_object != nil) ? ([control_panel_permutation_object getSpecialIndex]) : (0);
}

        
@synthesize primaryTransferMode=primary_transfer_mode;
@synthesize secondaryTransferMode=secondary_transfer_mode;
@synthesize transparentTransferMode=transparent_transfer_mode;
        
-(short)polygonIndex { return (polygon_object == nil) ? -1 : [polygon_object index]; }
-(short)lineIndex { return (line_object == nil) ? -1 : [line_object index]; }
        
-(short)primaryLightsourceIndex { return (primary_lightsource_object == nil) ? -1 : [primary_lightsource_object index]; }
-(short)secondaryLightsourceIndex { return (secondary_lightsource_object == nil) ? -1 : [secondary_lightsource_object index]; }
-(short)transparentLightsourceIndex { return (transparent_lightsource_object == nil) ? -1 : [transparent_lightsource_object index]; }
                
@synthesize primaryLightsourceObject=primary_lightsource_object;
@synthesize secondaryLightsourceObject=secondary_lightsource_object;
@synthesize transparentLightsourceObject=transparent_lightsource_object;

//  ************************** Other Useful Methods *************************
#pragma mark - Other Useful Methods

-(short)adjustedControlPanelType
{
    if ([self getFlagS:2] == NO)
        return -1; // This Side Is Not A Control Panel
    
    if (control_panel_type < 10 && control_panel_type >= 0) { // water
        switch (control_panel_type) {
            case 0:
                return _panel_oxygen;
                break;
            case 1:
                return _panel_singleShield;
                break;
            case 2:
                return _panel_doubleShield;
                break;
            case 3:
                return _panel_chipInserton;
                break;
            case 4:
                return _panel_lightSwitch;
                break;
            case 5:
                return _panel_platformSwitch;
                break;
            case 6:
                return _panel_tagSwitch;
                break;
            case 7:
                return _panel_patternBuffer;
                break;
            case 8:
                return _panel_computerTerminal;
                break;
            case 9:
                return _panel_wires;
                break;
            default:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Generic Error";
                alert.informativeText = @"Water control panel type not found in LESide->adjustedControlPanelType 1";
                alert.alertStyle = NSAlertStyleCritical;
                [alert runModal];
            }
                return -1;
                break;
        }
    } else if (control_panel_type < 21 && control_panel_type >= 10) { // lava
        return control_panel_type - lavaOffset;
    } else if (control_panel_type < 32 && control_panel_type >= 21) { // sewage
        return control_panel_type - sewageOffset;
    } else if (control_panel_type < 43 && control_panel_type >= 32) { // pfhor
        return control_panel_type - pfhorOffset;
    } else if (control_panel_type < 54 && control_panel_type >= 43) { // jjaro
        return control_panel_type - jjaroOffset;
    } else if (control_panel_type >= 54) { // too great
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
        alert.informativeText = NSLocalizedString(@"Water control panel type not found in LESide->adjustedControlPanelType 2", @"Water control panel type not found in LESide->adjustedControlPanelType 2");
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
        return -1;
    } else if (control_panel_type < 0) { // too low
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
        alert.informativeText = NSLocalizedString(@"Water control panel type not found in LESide->adjustedControlPanelType 3", @"Water control panel type not found in LESide->adjustedControlPanelType 3");
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
        return -1;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
    alert.informativeText = NSLocalizedString(@"Water control panel type not found in LESide->adjustedControlPanelType 4, This could be a logic error!!!", @"Water control panel type not found in LESide->adjustedControlPanelType 4, This could be a logic error!!!");
    alert.alertStyle = NSAlertStyleCritical;
    [alert runModal];
    return -1;
}

// ************************** Inzlizations And Class Methods *************************
#pragma mark - Inzlizations And Class Methods

-(id)initWithSide:(LESide *)theSideToImitate
{
    if (self = [self init]) {
        [theSideToImitate copySettingsTo:self];
    }
    return self;
}

-(id)init
{
    if (self = [super init]) {
        type = 0;
        flags = 0;
        primary_texture.x0 = 0;
        primary_texture.y0 = 0;
        primary_texture.texture = 4357;
        primary_texture.textureCollection = 17; // Set to to the texture the level is using!
        primary_texture.textureNumber = 5;
        secondary_texture.x0 = 0;
        secondary_texture.y0 = 0;
        secondary_texture.texture = -1;
        secondary_texture.textureCollection = -1; // Set to to the texture the level is using!
        secondary_texture.textureNumber = -1;
        transparent_texture.x0 = 0;
        transparent_texture.y0 = 0;
        
        // I don't think having two parts of it negitve will result in a negitive number?
        // Check this out!!!
        transparent_texture.texture = -1; // NONE
        transparent_texture.textureCollection = -1; // Set to to the texture the level is using!
        transparent_texture.textureNumber = -1;
        
        exclusion_zone.e0 = NSMakePoint(0,0);
        exclusion_zone.e1 = NSMakePoint(0,0);
        exclusion_zone.e2 = NSMakePoint(0,0);
        exclusion_zone.e3 = NSMakePoint(0,0);
        
        control_panel_type = 0; // only valid if side->flags & LESideIsControlPanel
        control_panel_permutation = 0; // platform index, light source index, etc...
        control_panel_permutation_object = nil; // platform object, light source object, etc...
        permutationEffects = 0;
        
        primary_transfer_mode = 0;
        secondary_transfer_mode = 0;
        transparent_transfer_mode = 0;
        
        polygon_index = -1;
        line_index = -1;
        polygon_object = nil;
        line_object = nil;
        
        primary_lightsource_index = 0;
        secondary_lightsource_index = 0;
        transparent_lightsource_index = 0;
        
        primary_lightsource_object = nil;
        secondary_lightsource_object = nil;
        transparent_lightsource_object = nil;
        
        ambient_delta = 0;
    }
    return self;
}

@end
