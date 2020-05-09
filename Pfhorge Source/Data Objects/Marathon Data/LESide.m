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
#import "PhTag.h"

#import "PhData.h"

#define GET_SIDE_FLAG(b) (flags & (b))
#define SET_SIDE_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@implementation LESide
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
    
    int myPosition = [index count];
    
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
    
    if (control_panel_permutation_object != nil && [mainObjs containsObject:control_panel_permutation_object])
    {
        ExportObj(control_panel_permutation_object);
    }
    else
    {
        ExportNil();
    }
    
    ExportLong(permutationEffects);
    
    ExportShort(primary_transfer_mode);
    ExportShort(secondary_transfer_mode);
    ExportShort(transparent_transfer_mode);
    
    if (polygon_object != nil && [mainObjs containsObject:polygon_object])
    {
        ExportObj(polygon_object);
    }
    else
    {
        ExportNil();
    }
    
    if (line_object != nil && [mainObjs containsObject:line_object])
    {
        ExportObj(line_object);
    }
    else
    {
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
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    

	NSLog(@"Exporting Side: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %d", [self index], myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
	NSLog(@"Importing Side: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
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
    
    if (useIndexNumbersInstead)
    {
        tmpShort = GetIndexAdv(primary_lightsource_object);
        encodeShort(coder, tmpShort);
        tmpShort = GetIndexAdv(secondary_lightsource_object);
        encodeShort(coder, tmpShort);
        tmpShort = GetIndexAdv(transparent_lightsource_object);
        encodeShort(coder, tmpShort);
    }
    else
    {
        encodeObj(coder, primary_lightsource_object);
        encodeObj(coder, secondary_lightsource_object);
        encodeObj(coder, transparent_lightsource_object);
        encodeObj(coder, control_panel_permutation_object);
    }
    
    encodeLong(coder, ambient_delta);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    
    //NSLog(@"Side");
    
    self = [super initWithCoder:coder];
    
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
    
    if (useIndexNumbersInstead)
    {
        primary_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
        secondary_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
        transparent_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
    }
    else
    {
        primary_lightsource_object = decodeObj(coder);
        secondary_lightsource_object = decodeObj(coder);
        transparent_lightsource_object = decodeObj(coder);
        control_panel_permutation_object = decodeObj(coder);
    }
    
    ambient_delta = decodeLong(coder);
    
    if (polygon_object == nil || line_object == nil)
    {
            if (self == nil)
        NSLog(@"************************************ Side - nil - 2...");
        //return nil;
    }
    
    if (useIndexNumbersInstead)
        [theLELevelDataST addObjects:self];
    
    useIndexNumbersInstead = NO;
    
    return self;
}


-(void)dealloc
{
    [super dealloc];
}

// ****************** Utilites ********************
#pragma mark -
#pragma mark ********* Utilites *********

-(void)setLightsThatAre:(id)theLightInQuestion to:(id)setToLight
{
    if (transparent_lightsource_object == theLightInQuestion)
        transparent_lightsource_object = setToLight;
    
    if (secondary_lightsource_object == theLightInQuestion)
        secondary_lightsource_object = setToLight;
    
    if (primary_lightsource_object == theLightInQuestion)
        primary_lightsource_object = setToLight;
}


// ***************** Copy Methods *****************
#pragma mark -
#pragma mark ********* Copy Methods *********
-(void)copySettingsTo:(id)target
{
    LESide *theTarget = (LESide *)target;
    
    if (primary_texture.texture != -1) // define NONE and use NONE here
    {
        [theTarget setPrimary_texture:primary_texture];
        [theTarget setPrimary_transfer_mode:primary_transfer_mode];
        [theTarget setPrimary_lightsource_object:primary_lightsource_object];
    }
    
    if (secondary_texture.texture != -1) // define NONE and use NONE here
    {
        [theTarget setSecondary_texture:secondary_texture];
        [theTarget setSecondary_transfer_mode:secondary_transfer_mode];
        [theTarget setSecondary_lightsource_object:secondary_lightsource_object];
    }
    
    if (transparent_texture.texture != -1) // define NONE and use NONE here
    {
        [theTarget setTransparent_texture:transparent_texture];
        [theTarget setTransparent_transfer_mode:transparent_transfer_mode];
        [theTarget setTransparent_lightsource_object:transparent_lightsource_object];
    }
    
    // Should I? Proably, I will see what happens (the dragon, me)...
    [theTarget setFlags:flags];
    
    // Should I also inlucd control panel settings? We will se waht happens...
    if (flags & _side_is_control_panel)
    {
        [theTarget setControl_panel_type:control_panel_type];
        [theTarget setControl_panel_permutation:control_panel_permutation];
    }
    else
    {
        [theTarget setControl_panel_type:0];
        [theTarget setControl_panel_permutation:0];
    }
    
    [theTarget setExclusion_zone:exclusion_zone];
    [theTarget setAmbient_delta:ambient_delta];
    
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
            
    [copy setPrimary_texture:primary_texture];
    [copy setSecondary_texture:secondary_texture];
    [copy setTransparent_texture:transparent_texture];
    
    [copy setExclusion_zone:exclusion_zone];
            
    [copy setControl_panel_type:control_panel_type];
    [copy setControl_panel_permutation:control_panel_permutation];
            
    [copy setPrimary_transfer_mode:primary_transfer_mode];
    [copy setSecondary_transfer_mode:secondary_transfer_mode];
    [copy setTransparent_transfer_mode:transparent_transfer_mode];
            
    
    [copy setPolygon_object:polygon_object];
    [copy setLine_object:line_object];
            
    
    [copy setPrimary_lightsource_object:primary_lightsource_object];
    [copy setSecondary_lightsource_object:secondary_lightsource_object];
    [copy setTransparent_lightsource_object:transparent_lightsource_object];
            
    [copy setAmbient_delta:ambient_delta];
    
    return copy;
}

// **************************  Flag Methods  *************************
#pragma mark -
#pragma mark ********* Flag Methods *********

-(BOOL)getFlagS:(short)theFlag;
{
    switch (theFlag)
    {
        case 1:
            return GET_SIDE_FLAG(_control_panel_status);
            break;
        case 2:
            return GET_SIDE_FLAG(_side_is_control_panel);
            break;
        case 3:
            return GET_SIDE_FLAG(_side_is_repair_switch);
            break;
        case 4:
            return GET_SIDE_FLAG(_side_is_destructive_switch);
            break;
        case 5:
            return GET_SIDE_FLAG(_side_is_lighted_switch);
            break;
        case 6:
            return GET_SIDE_FLAG(_side_switch_can_be_destroyed);
            break;
        case 7:
            return GET_SIDE_FLAG(_side_switch_can_only_be_hit_by_projectiles);
            break;
        case 8:
            return GET_SIDE_FLAG(_editor_dirty_bit);
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
        case _control_panel_status:
            SET_SIDE_FLAG(_control_panel_status, v);
            break;
        case _side_is_control_panel:
            SET_SIDE_FLAG(_side_is_control_panel, v);
            break;
        case _side_is_repair_switch:
            SET_SIDE_FLAG(_side_is_repair_switch, v);
            break;
        case _side_is_destructive_switch:
            SET_SIDE_FLAG(_side_is_destructive_switch, v);
            break;
        case _side_is_lighted_switch:
            SET_SIDE_FLAG(_side_is_lighted_switch, v);
            break;
        case _side_switch_can_be_destroyed:
            SET_SIDE_FLAG(_side_switch_can_be_destroyed, v);
            break;
        case _side_switch_can_only_be_hit_by_projectiles:
            SET_SIDE_FLAG(_side_switch_can_only_be_hit_by_projectiles, v);
            break;
        case _editor_dirty_bit:
            SET_SIDE_FLAG(_editor_dirty_bit, v);
            break;
    }
 }
 
 // **************************  Overriden Standard Methods  *************************
 #pragma mark -
#pragma mark ********* Overriden Standard Methods  *********
 
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
 #pragma mark -
#pragma mark ********* Set Accsessors *********

-(void)setPrimaryTexture:(char)number
{ 
    char *theTexChar = (char *)&primary_texture.texture;
    (theTexChar)[1] = number;
}

-(void)setSecondaryTexture:(char)number
{ 
    char *theTexChar = (char *)&secondary_texture.texture;
    (theTexChar)[1] = number;
}

-(void)setTransparentTexture:(char)number
{ 
    char *theTexChar = (char *)&transparent_texture.texture;
    (theTexChar)[1] = number;
}

-(void)setPrimaryTextureCollection:(char)number
{ 
    char *theTexChar = (char *)&primary_texture.texture;
    (theTexChar)[0] = 0x11 + number;
}

-(void)setSecondaryTextureCollection:(char)number
{ 
    char *theTexChar = (char *)&secondary_texture.texture;
    (theTexChar)[0] = 0x11 + number;
}

-(void)setTransparentTextureCollection:(char)number
{ 
    char *theTexChar = (char *)&transparent_texture.texture;
    (theTexChar)[0] = 0x11 + number;
}

-(void)resetTextureCollection
{ 
    // For right now it just sets it to the current levels
    // collection.
    char *thePTexChar = (char *)&primary_texture.texture;
    char *theSTexChar = (char *)&secondary_texture.texture;
    char *theTTexChar = (char *)&transparent_texture.texture;
    short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (thePTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theSTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theTTexChar)[0] = (0x11 + theCurrentEnviroCode);
}

-(void)setTextureCollection:(char)number
{ 
    char *thePTexChar = (char *)&primary_texture.texture;
    char *theSTexChar = (char *)&secondary_texture.texture;
    char *theTTexChar = (char *)&transparent_texture.texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (thePTexChar)[0] = (0x11 + number);
    (theSTexChar)[0] = (0x11 + number);
    (theTTexChar)[0] = (0x11 + number);
}

-(void)setType:(short)v { type = v; }
-(void)setFlags:(LESideFlags)v { flags = v; }
        
-(void)setPrimary_texture:(struct side_texture_definition)v { primary_texture = v; }
-(void)setSecondary_texture:(struct side_texture_definition)v { secondary_texture = v; }
-(void)setTransparent_texture:(struct side_texture_definition)v { transparent_texture = v; }

-(void)setExclusion_zone:(struct side_exclusion_zone)v { exclusion_zone = v; }
        
-(void)setControl_panel_type:(short)v
{
    int enviroCode = [theLELevelDataST environmentCode];
    int modfiedControlPanelType = -1;
    permutationEffects = 0;
    control_panel_type = v;
    
    switch (enviroCode)
    {
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
        
    if (enviroCode == _water)
    {
        switch(modfiedControlPanelType)
        {
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
    }
    else
    {
        switch(modfiedControlPanelType)
        {
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

-(void)setControl_panel_permutation:(short)v
{
    NSArray *theObjectArray = nil;
    control_panel_permutation = v;
    
    switch(permutationEffects)
    {
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
    
    if (theObjectArray != nil && (int)[theObjectArray count] > v)
   	control_panel_permutation_object = [theObjectArray objectAtIndex:control_panel_permutation];
    else
        control_panel_permutation_object = nil;
    
    return;
}

-(void)setControl_panel_permutation_object:(id)v { control_panel_permutation_object = v; }

        
-(void)setPrimary_transfer_mode:(short)v { primary_transfer_mode = v; }
-(void)setSecondary_transfer_mode:(short)v { secondary_transfer_mode = v; }
-(void)setTransparent_transfer_mode:(short)v { transparent_transfer_mode = v; }

//	--- --- ---

-(void)setPolygon_index:(short)v {
    //polygon_index = v;
    if (v == -1)
        polygon_object = nil;
    else if (everythingLoadedST)
        polygon_object = [theMapLightsST objectAtIndex:v];
}
-(void)setLine_index:(short)v {
    //line_index = v; 
    if (v == -1)
        line_object = nil;
    else if (everythingLoadedST)
        line_object = [theMapLightsST objectAtIndex:v];
}

//	*** *** ***

-(void)setPolygon_object:(id)v { polygon_object = v; }
-(void)setLine_object:(id)v { line_object = v; }

// 	--- --- ---

-(void)setPrimary_lightsource_index:(short)v {
    //primary_lightsource_index = v;
    if (v == -1)
        primary_lightsource_object = nil;
    else if (everythingLoadedST)
        primary_lightsource_object = [theMapLightsST objectAtIndex:v];
}
-(void)setSecondary_lightsource_index:(short)v {
    //secondary_lightsource_index = v;
    
    if (v == -1)
        secondary_lightsource_object = nil;
    else if (everythingLoadedST)
        secondary_lightsource_object = [theMapLightsST objectAtIndex:v];
    
    NSLog(@"setSecondary_lightsource_index Set To: %d   The Object Index: %d", v, [secondary_lightsource_object index]);
}
-(void)setTransparent_lightsource_index:(short)v {
    //transparent_lightsource_index = v;
    if (v == -1)
        transparent_lightsource_object = nil;
    else if (everythingLoadedST)
        transparent_lightsource_object = [theMapLightsST objectAtIndex:v];
}

//		 *** *** ***

-(void)setPrimary_lightsource_object:(id)v {
    primary_lightsource_object = v;
}
-(void)setSecondary_lightsource_object:(id)v {
    secondary_lightsource_object = v;
}
-(void)setTransparent_lightsource_object:(id)v {
    transparent_lightsource_object = v;
}

//	--- --- ---
        
-(void)setAmbient_delta:(long)v { ambient_delta = v; }

// *****************   Get Accsessors   *****************
 #pragma mark -
#pragma mark ********* Get Accsessors *********

-(char)primaryTexture
{ 
    char *theTexChar = (char *)&primary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1];
}

-(char)secondaryTexture
{ 
    char *theTexChar = (char *)&secondary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1];
}

-(char)transparentTexture
{ 
    char *theTexChar = (char *)&transparent_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[1];
}

-(char)primaryTextureCollection
{ 
    char *theTexChar = (char *)&primary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0] - 0x11;
}

-(char)secondaryTextureCollection
{ 
    char *theTexChar = (char *)&secondary_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0] - 0x11;
}

-(char)transparentTextureCollection
{ 
    char *theTexChar = (char *)&transparent_texture.texture;
    //(theTexChar)[0]
    return (theTexChar)[0] - 0x11;
}

-(char)textureCollection
{ 
    return [self primaryTextureCollection];
}

-(short)type { return type; }
-(LESideFlags)flags { return flags; }
        
-(struct side_texture_definition)getPrimary_texture { return primary_texture; }
-(struct side_texture_definition)getSecondary_texture { return secondary_texture; }
-(struct side_texture_definition)getTransparent_texture { return transparent_texture; }

-(struct side_exclusion_zone)getExclusion_zone { return exclusion_zone; }

-(int)getPermutationEffects
{
    return permutationEffects;
}
  
-(short)getControl_panel_type { return control_panel_type; }
-(short)getControl_panel_permutation
{
    /*if (control_panel_permutation_object != nil)
        NSLog(@"polygonPermutationNumber: %d", [control_panel_permutation_object index]);*/
    
    return (control_panel_permutation_object != nil) ? ([control_panel_permutation_object getSpecialIndex]) : (0);
}

-(id)getControl_panel_permutation_object { return control_panel_permutation_object; }

        
-(short)getPrimary_transfer_mode { return primary_transfer_mode; }
-(short)getSecondary_transfer_mode { return secondary_transfer_mode; }
-(short)getTransparent_transfer_mode { return transparent_transfer_mode; }
        
-(short)getPolygon_index { return (polygon_object == nil) ? -1 : [polygon_object index]; }
-(short)getLine_index { return (line_object == nil) ? -1 : [line_object index]; }

-(id)getpolygon_object { return polygon_object; }
-(id)getline_object { return line_object; }
        
-(short)getPrimary_lightsource_index { return (primary_lightsource_object == nil) ? -1 : [primary_lightsource_object index]; }
-(short)getSecondary_lightsource_index { return (secondary_lightsource_object == nil) ? -1 : [secondary_lightsource_object index]; }
-(short)getTransparent_lightsource_index { return (transparent_lightsource_object == nil) ? -1 : [transparent_lightsource_object index]; }
                
-(id)getprimary_lightsource_object { return primary_lightsource_object; }
-(id)getsecondary_lightsource_object { return secondary_lightsource_object; }
-(id)gettransparent_lightsource_object { return transparent_lightsource_object; }

-(int)getAmbient_delta { return ambient_delta; }

//  ************************** Other Useful Methods *************************
#pragma mark -
#pragma mark ********* Other Useful Methods *********

-(short)getAdjustedControlPanelType
{
    if ([self getFlagS:2] == NO)
        return -1; // This Side Is Noit A Control Panel
    
    if (control_panel_type < 10 && control_panel_type >= 0) // water
    {
        switch (control_panel_type)
        {
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
                SEND_ERROR_MSG(@"Water control panel type not found in LESide->adjustedControlPanelType 1");
                return -1;
                break;
        }
    }
    else if (control_panel_type < 21 && control_panel_type >= 10) // lava
        return control_panel_type - lavaOffset;
    else if (control_panel_type < 32 && control_panel_type >= 21) // sewage
        return control_panel_type - sewageOffset;
    else if (control_panel_type < 43 && control_panel_type >= 32) // pfhor
        return control_panel_type - pfhorOffset;
    else if (control_panel_type < 54 && control_panel_type >= 43) // jjaro
        return control_panel_type - jjaroOffset;
    else if (control_panel_type >= 54) // to great
    {
        SEND_ERROR_MSG(@"Water control panel type not found in LESide->adjustedControlPanelType 2");
        return -1;
    }
    else if (control_panel_type < 0) // to low
    {
        SEND_ERROR_MSG(@"Water control panel type not found in LESide->adjustedControlPanelType 3");
        return -1;
    }
    
    SEND_ERROR_MSG(@"Water control panel type not found in LESide->adjustedControlPanelType 4, This could be a logic error!!!");
    return -1;
}

// ************************** Inzlizations And Class Methods *************************
#pragma mark -
#pragma mark ********* Inzlizations And Class Methods *********

-(id)initWithSide:(LESide *)theSideToImitate
{
    self = [self init];
    [theSideToImitate copySettingsTo:self];
    
    return self;
}

-(id)init
{
    self = [super init];
    if (self == nil)
	return nil;
    
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
    
    control_panel_type = 0; // only valid if side->flags & _side_is_control_panel
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
    
    return self;
}

@end
