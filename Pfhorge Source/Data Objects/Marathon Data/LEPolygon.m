//
//  LEPolygon.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jun 18 2001.
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

#include <tgmath.h>
#import "LEPolygon.h"
#import "LEMapPoint.h"
#import "LELine.h"
#import "LEMapObject.h"
#import "PhPlatform.h"
#import "LELevelData.h"

#import "PhAbstractName.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"

#import "PhLayer.h"

#import "LEExtras.h"

#import "PhData.h"
#import "PhMedia.h"
#import "PhLight.h"
#import "LESide.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@implementation LEPolygon



- (void)render
{
	if (floor_transfer_mode != 9)
	{/*
		glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
		glColor3ub(255, 255, 255);  
		glBegin(GL_POLYGON);
		switch (vertexCountForPoly)
		{
			case 8:
				glVertex3i([vertexObjects[7] xgl], floor_height/128, [vertexObjects[7] ygl]);
			case 7:
				glVertex3i([vertexObjects[6] xgl], floor_height/128, [vertexObjects[6] ygl]);
			case 6:
				glVertex3i([vertexObjects[5] xgl], floor_height/128, [vertexObjects[5] ygl]);
			case 5:
				glVertex3i([vertexObjects[4] xgl], floor_height/128, [vertexObjects[4] ygl]);
			case 4:
				glVertex3i([vertexObjects[3] xgl], floor_height/128, [vertexObjects[3] ygl]);
			case 3:
				glVertex3i([vertexObjects[2] xgl], floor_height/128, [vertexObjects[2] ygl]);
				glVertex3i([vertexObjects[1] xgl], floor_height/128, [vertexObjects[1] ygl]);
				glVertex3i([vertexObjects[0] xgl], floor_height/128, [vertexObjects[0] ygl]);
				break;
			default:
				break;
		}
		glEnd();
		
		glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);*/
		glColor3ub(0, 0, 255);  
		glBegin(GL_POLYGON);
		switch (vertexCountForPoly)
		{
			case 8:
				glVertex3i([vertexObjects[7] xgl], floor_height/128, [vertexObjects[7] ygl]);
			case 7:
				glVertex3i([vertexObjects[6] xgl], floor_height/128, [vertexObjects[6] ygl]);
			case 6:
				glVertex3i([vertexObjects[5] xgl], floor_height/128, [vertexObjects[5] ygl]);
			case 5:
				glVertex3i([vertexObjects[4] xgl], floor_height/128, [vertexObjects[4] ygl]);
			case 4:
				glVertex3i([vertexObjects[3] xgl], floor_height/128, [vertexObjects[3] ygl]);
			case 3:
				glVertex3i([vertexObjects[2] xgl], floor_height/128, [vertexObjects[2] ygl]);
				glVertex3i([vertexObjects[1] xgl], floor_height/128, [vertexObjects[1] ygl]);
				glVertex3i([vertexObjects[0] xgl], floor_height/128, [vertexObjects[0] ygl]);
				break;
			default:
				break;
		}
		glEnd();
	}
	
	if (ceiling_transfer_mode != 9) {
		/*glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
		glColor3ub(255, 255, 255);
		glBegin(GL_POLYGON);
		switch (vertexCountForPoly)
		{
			case 8:
				glVertex3i([vertexObjects[7] xgl], ceiling_height/128, [vertexObjects[7] ygl]);
			case 7:
				glVertex3i([vertexObjects[6] xgl], ceiling_height/128, [vertexObjects[6] ygl]);
			case 6:
				glVertex3i([vertexObjects[5] xgl], ceiling_height/128, [vertexObjects[5] ygl]);
			case 5:
				glVertex3i([vertexObjects[4] xgl], ceiling_height/128, [vertexObjects[4] ygl]);
			case 4:
				glVertex3i([vertexObjects[3] xgl], ceiling_height/128, [vertexObjects[3] ygl]);
			case 3:
				glVertex3i([vertexObjects[2] xgl], ceiling_height/128, [vertexObjects[2] ygl]);
				glVertex3i([vertexObjects[1] xgl], ceiling_height/128, [vertexObjects[1] ygl]);
				glVertex3i([vertexObjects[0] xgl], ceiling_height/128, [vertexObjects[0] ygl]);
				break;
			default:
				break;
		}
		glEnd();
		
		glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);*/
		glColor3ub(0, 255, 0);
		glBegin(GL_POLYGON);
		switch (vertexCountForPoly) {
			case 8:
				glVertex3i([vertexObjects[7] xgl], ceiling_height/128, [vertexObjects[7] ygl]);
			case 7:
				glVertex3i([vertexObjects[6] xgl], ceiling_height/128, [vertexObjects[6] ygl]);
			case 6:
				glVertex3i([vertexObjects[5] xgl], ceiling_height/128, [vertexObjects[5] ygl]);
			case 5:
				glVertex3i([vertexObjects[4] xgl], ceiling_height/128, [vertexObjects[4] ygl]);
			case 4:
				glVertex3i([vertexObjects[3] xgl], ceiling_height/128, [vertexObjects[3] ygl]);
			case 3:
				glVertex3i([vertexObjects[2] xgl], ceiling_height/128, [vertexObjects[2] ygl]);
				glVertex3i([vertexObjects[1] xgl], ceiling_height/128, [vertexObjects[1] ygl]);
				glVertex3i([vertexObjects[0] xgl], ceiling_height/128, [vertexObjects[0] ygl]);
				break;
			default:
				break;
		}
		glEnd();
	}
	
	
	glColor3ub(255, 0, 0);  
	glBegin(GL_QUAD_STRIP);
	switch (vertexCountForPoly)
	{
		case 8:
			glVertex3i([vertexObjects[7] xgl], ceiling_height/128, [vertexObjects[7] ygl]);
			glVertex3i([vertexObjects[7] xgl], floor_height/128, [vertexObjects[7] ygl]);
		case 7:
			glVertex3i([vertexObjects[6] xgl], ceiling_height/128, [vertexObjects[6] ygl]);
			glVertex3i([vertexObjects[6] xgl], floor_height/128, [vertexObjects[6] ygl]);
		case 6:
			glVertex3i([vertexObjects[5] xgl], ceiling_height/128, [vertexObjects[5] ygl]);
			glVertex3i([vertexObjects[5] xgl], floor_height/128, [vertexObjects[5] ygl]);
		case 5:
			glVertex3i([vertexObjects[4] xgl], ceiling_height/128, [vertexObjects[4] ygl]);
			glVertex3i([vertexObjects[4] xgl], floor_height/128, [vertexObjects[4] ygl]);
		case 4:
			glVertex3i([vertexObjects[3] xgl], ceiling_height/128, [vertexObjects[3] ygl]);
			glVertex3i([vertexObjects[3] xgl], floor_height/128, [vertexObjects[3] ygl]);
		case 3:
			glVertex3i([vertexObjects[2] xgl], ceiling_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[2] xgl], floor_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[1] xgl], ceiling_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[1] xgl], floor_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[0] xgl], ceiling_height/128, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[0] xgl], floor_height/128, [vertexObjects[0] ygl]);
			
			// Back to the begining...
			glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], ceiling_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], floor_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			break;
		default:
			break;
	}
	glEnd();
	/*
	glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
	glColor3ub(255, 255, 255);  
	glBegin(GL_QUAD_STRIP);
	switch (vertexCountForPoly)
	{
		case 8:
			glVertex3i([vertexObjects[7] xgl], ceiling_height/128, [vertexObjects[7] ygl]);
			glVertex3i([vertexObjects[7] xgl], floor_height/128, [vertexObjects[7] ygl]);
		case 7:
			glVertex3i([vertexObjects[6] xgl], ceiling_height/128, [vertexObjects[6] ygl]);
			glVertex3i([vertexObjects[6] xgl], floor_height/128, [vertexObjects[6] ygl]);
		case 6:
			glVertex3i([vertexObjects[5] xgl], ceiling_height/128, [vertexObjects[5] ygl]);
			glVertex3i([vertexObjects[5] xgl], floor_height/128, [vertexObjects[5] ygl]);
		case 5:
			glVertex3i([vertexObjects[4] xgl], ceiling_height/128, [vertexObjects[4] ygl]);
			glVertex3i([vertexObjects[4] xgl], floor_height/128, [vertexObjects[4] ygl]);
		case 4:
			glVertex3i([vertexObjects[3] xgl], ceiling_height/128, [vertexObjects[3] ygl]);
			glVertex3i([vertexObjects[3] xgl], floor_height/128, [vertexObjects[3] ygl]);
		case 3:
			glVertex3i([vertexObjects[2] xgl], ceiling_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[2] xgl], floor_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[1] xgl], ceiling_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[1] xgl], floor_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[0] xgl], ceiling_height/128, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[0] xgl], floor_height/128, [vertexObjects[0] ygl]);
			
			// Back to the begining...
			glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], ceiling_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], floor_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			break;
		default:
			break;
	}
	glEnd();
	glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);*/
	//return;
	
	glColor3ub(255, 255, 255);  
	glBegin(GL_LINES);
	switch (vertexCountForPoly)
	{
		case 8:
			glVertex3i([vertexObjects[7] xgl], ceiling_height/128, [vertexObjects[7] ygl]);
			glVertex3i([vertexObjects[7] xgl], floor_height/128, [vertexObjects[7] ygl]);
		case 7:
			glVertex3i([vertexObjects[6] xgl], ceiling_height/128, [vertexObjects[6] ygl]);
			glVertex3i([vertexObjects[6] xgl], floor_height/128, [vertexObjects[6] ygl]);
		case 6:
			glVertex3i([vertexObjects[5] xgl], ceiling_height/128, [vertexObjects[5] ygl]);
			glVertex3i([vertexObjects[5] xgl], floor_height/128, [vertexObjects[5] ygl]);
		case 5:
			glVertex3i([vertexObjects[4] xgl], ceiling_height/128, [vertexObjects[4] ygl]);
			glVertex3i([vertexObjects[4] xgl], floor_height/128, [vertexObjects[4] ygl]);
		case 4:
			glVertex3i([vertexObjects[3] xgl], ceiling_height/128, [vertexObjects[3] ygl]);
			glVertex3i([vertexObjects[3] xgl], floor_height/128, [vertexObjects[3] ygl]);
		case 3:
			glVertex3i([vertexObjects[2] xgl], ceiling_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[2] xgl], floor_height/128, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[1] xgl], ceiling_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[1] xgl], floor_height/128, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[0] xgl], ceiling_height/128, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[0] xgl], floor_height/128, [vertexObjects[0] ygl]);
			
			// Back to the begining...
			//glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], ceiling_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			//glVertex3i([vertexObjects[vertexCountForPoly-1] xgl], floor_height/128, [vertexObjects[vertexCountForPoly-1] ygl]);
			break;
		default:
			break;
	}
	glEnd(); 
}


// This will render the polygon in OpenGL...
- (void)renderTri
{
	glColor3ub(255, 255, 0);  
	glBegin(GL_TRIANGLES);
	switch (vertexCountForPoly) {
		case 8:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[6] xgl], 0, [vertexObjects[6] ygl]);
			glVertex3i([vertexObjects[7] xgl], 0, [vertexObjects[7] ygl]);
		case 7:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[5] xgl], 0, [vertexObjects[5] ygl]);
			glVertex3i([vertexObjects[6] xgl], 0, [vertexObjects[6] ygl]);
		case 6:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[4] xgl], 0, [vertexObjects[4] ygl]);
			glVertex3i([vertexObjects[5] xgl], 0, [vertexObjects[5] ygl]);
		case 5:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[3] xgl], 0, [vertexObjects[3] ygl]);
			glVertex3i([vertexObjects[4] xgl], 0, [vertexObjects[4] ygl]);
		case 4:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[2] xgl], 0, [vertexObjects[2] ygl]);
			glVertex3i([vertexObjects[3] xgl], 0, [vertexObjects[3] ygl]);
		case 3:
			glVertex3i([vertexObjects[0] xgl], 0, [vertexObjects[0] ygl]);
			glVertex3i([vertexObjects[1] xgl], 0, [vertexObjects[1] ygl]);
			glVertex3i([vertexObjects[2] xgl], 0, [vertexObjects[2] ygl]);
		break;
		default:
			break;
	}
	glEnd(); 
}


- (void)displayInfo
{
    if (type == _polygon_is_platform) {
        [permutationObject displayInfo];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"Detailed Polygon Info", @"Detailed Polygon Info");
        alert.informativeText = NSLocalizedString(@"Only platform polygons support this for right now…", @"Only platform polygons support this for right now…");
        alert.alertStyle = NSAlertStyleInformational;
        [alert runModal];
    }
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Polygon Index: %d   Layer: %@", [self index], [polyLayer phName], nil];
}



 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

 - (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    long tmpLong = 0;
    int i = 0;
    short tmpShort;
    
    if (theNumber != NSNotFound) {
        return theNumber;
    }
    
    NSInteger myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    ExportShort(type);
    ExportUnsignedShort(flags);
    
    // *** Only for a plaform for right now... ***
    //ExportObj(permutationObject);
    
    switch (type) {
        case _polygon_is_base:
        case _polygon_is_minor_ouch:
        case _polygon_is_major_ouch:
        case _polygon_is_glue:
        case _polygon_is_glue_trigger:
        case _polygon_is_superglue:
        case _polygon_is_goal:
        case _polygon_is_visible_monster_trigger:
        case _polygon_is_invisible_monster_trigger:
        case _polygon_is_dual_monster_trigger:
        case _polygon_is_item_trigger:
        case _polygon_must_be_explored:
        case _polygon_is_zone_border:
        case _polygon_is_normal:
        case _polygon_is_item_impassable:
        case _polygon_is_monster_impassable:
        case _polygon_is_hill:
            permutationObject = nil;
            break;
		default:
			break;
    }
    
    switch (type) {
        /*case _polygon_is_base:
            tmpShort = 0;
            encodeShort(coder, tmpShort);
            break;*/
        case _polygon_is_light_on_trigger:
        case _polygon_is_platform_on_trigger:
        case _polygon_is_light_off_trigger:
        case _polygon_is_platform_off_trigger:
        case _polygon_is_teleporter:
            ExportObjPos(((LEMapStuffParent*)permutationObject));
            break;
        case _polygon_is_automatic_exit:
            tmpShort = [permutationObject shortValue];
            ExportShort(tmpShort);
            break;
        case _polygon_is_platform:
            //ExportObjPos(permutationObject);
            ExportObj(permutationObject);
            break;
		default:
			break;
    }
        
    ExportShort(vertexCountForPoly);
    
    for (i = 0; i < 8; i++)
    {
        ExportObj(vertexObjects[i]);
    }
    
    for (i = 0; i < 8; i++)
    {
        ExportObj(lineObjects[i]);
    }
    
    ExportShort(floor_texture);
    ExportShort(ceiling_texture);
    ExportShort(floor_height);
    ExportShort(ceiling_height);
    
    // ImportObjIndexPos
    // ExportObjPos(); // --- --- ---
    
    ExportObjPos(floor_lightsource_object); // --- --- ---
    ExportObjPos(ceiling_lightsource_object); // --- --- ---
    ExportObj(floor_lightsource_object);
    ExportObj(ceiling_lightsource_object);
    
    ExportLong(area);
    
    ExportShort(floor_transfer_mode);
    ExportShort(ceiling_transfer_mode);
    
    short x = center.x;
    short y = center.y;
    
    ExportShort(x);
    ExportShort(y);
    
    for (i = 0; i < 8; i++) {
        ExportObj(side_objects[i]);
    }
    
    x = floor_origin.x;
    y = floor_origin.y;
    
    ExportShort(x);
    ExportShort(y);
    
    x = ceiling_origin.x;
    y = ceiling_origin.y;
    
    ExportShort(x);
    ExportShort(y);
    
    ExportObjPos(media_object); // --- --- ---
    ExportObjPos(media_lightsource_object); // --- --- ---
    ExportObj(media_object);
    ExportObj(media_lightsource_object);
    
    ExportObjPos(ambient_sound_image_object); // --- --- ---
    ExportObjPos(random_sound_image_object); // --- --- ---
    ExportObj(ambient_sound_image_object);
    ExportObj(random_sound_image_object);
    
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
    
    // *** *** **** Add Self... *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];

    
    //
    
    NSLog(@"Exporting Polygon: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    if ([index indexOfObjectIdenticalTo:self] != myPosition) {
        NSLog(@"BIG EXPORT ERROR: polygon %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

 - (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    //long theNumber = [index indexOfObjectIdenticalTo:self];
    //long tmpLong = 0;
    int i = 0;
    short tmpShort;
    
    NSLog(@"Importing Polygon: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    /*
    if (theNumber != NSNotFound)
    {
        return theNumber;
    }
    */
    
    //NSMutableData *myData = [[NSMutableData alloc] init];
    
    
    // getBytes:range:
    
    
    ImportShort(type);
    ImportUnsignedShort(flags);
    
    // *** only if this is a platform... ***
    //ImportObj(permutationObject);
    

    switch (type) {
        /*case _polygon_is_base:
            tmpShort = 0;
            encodeShort(coder, tmpShort);
            break;*/
        case _polygon_is_light_on_trigger:
        case _polygon_is_light_off_trigger:
            ImportObjIndexPos(permutationObject, theMapLightsST);
            break;
        case _polygon_is_platform_on_trigger:
        case _polygon_is_platform_off_trigger:
        case _polygon_is_teleporter:
            ImportObjIndexPos(permutationObject, theMapPolysST);
            break;
        case _polygon_is_automatic_exit:
            ImportShort(tmpShort);
            permutationObject = numShort(tmpShort);
            break;
        case _polygon_is_platform:
            ImportObj(permutationObject);
            break;
		default:
			break;
    }
    
    
    ImportShort(vertexCountForPoly);
    
    for (i = 0; i < 8; i++)
    {
        ImportObj(vertexObjects[i]);
    }
    
    for (i = 0; i < 8; i++)
    {
        ImportObj(lineObjects[i]);
    }
    
    ImportShort(floor_texture);
    ImportShort(ceiling_texture);
    ImportShort(floor_height);
    ImportShort(ceiling_height);
    
    if (useOrg != YES)
    {
        ImportObjIndexPos(floor_lightsource_object, theMapLightsST);
        ImportObjIndexPos(ceiling_lightsource_object, theMapLightsST);
        SkipObj();
        SkipObj();
    }
    else
    {
        SkipObj();
        SkipObj();
        ImportObj(ceiling_lightsource_object);
        ImportObj(ceiling_lightsource_object);
    }
    
    //getObjectFromIndexUsingLast
    
    ImportInt(area);
    
    ImportShort(floor_transfer_mode);
    ImportShort(ceiling_transfer_mode);
    
    ImportShort(center.x);
    ImportShort(center.y);
    
    for (i = 0; i < 8; i++)
    {
        ImportObj(side_objects[i]);
    }
    
    ImportShort(floor_origin.x);
    ImportShort(floor_origin.y);
    
    ImportShort(ceiling_origin.x);
    ImportShort(ceiling_origin.y);
    
    if (useOrg != YES)
    {
        ImportObjIndexPos(media_object, theMediaST);
        ImportObjIndexPos(media_lightsource_object, theMapLightsST);
        SkipObj();
        SkipObj();
    }
    else
    {
        SkipObj();
        SkipObj();
        ImportObj(media_object);
        ImportObj(media_lightsource_object);
    }
    
    
    if (useOrg != YES)
    {
        ImportObjIndexPos(ambient_sound_image_object, theAmbientSoundsST);
        ImportObjIndexPos(random_sound_image_object, theRandomSoundsST);
        SkipObj();
        SkipObj();
    }
    else
    {
        SkipObj();
        SkipObj();
        ImportObj(ambient_sound_image_object);
        ImportObj(random_sound_image_object);
    }
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    int i, tempInt;
    short tmpShort;
    
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        if (!useIndexNumbersInstead) {
            [coder encodeObject:polyLayer forKey:@"polyLayer"];
        }
        
        [coder encodeBool:polygonConcave forKey:@"polygonConcave"];
        
        [coder encodeInt:type forKey:@"type"];
        [coder encodeInt:flags forKey:@"flags"];
        
        switch (type) {
            case _polygon_is_base:
            case _polygon_is_minor_ouch:
            case _polygon_is_major_ouch:
            case _polygon_is_glue:
            case _polygon_is_glue_trigger:
            case _polygon_is_superglue:
            case _polygon_is_goal:
            case _polygon_is_visible_monster_trigger:
            case _polygon_is_invisible_monster_trigger:
            case _polygon_is_dual_monster_trigger:
            case _polygon_is_item_trigger:
            case _polygon_must_be_explored:
            case _polygon_is_zone_border:
            case _polygon_is_normal:
            case _polygon_is_item_impassable:
            case _polygon_is_monster_impassable:
            case _polygon_is_hill:
                permutationObject = nil;
                break;
            default:
                break;
        }
        
        if (useIndexNumbersInstead) {
            switch (type) {
                case _polygon_is_base:
                    //tmpShort = 0;
                    [coder encodeInt:0 forKey:@"permutationObject index"];
                    break;
                case _polygon_is_light_on_trigger:
                case _polygon_is_platform_on_trigger:
                case _polygon_is_light_off_trigger:
                case _polygon_is_platform_off_trigger:
                case _polygon_is_teleporter:
                    tmpShort = GetIndexAdv(permutationObject);
                    [coder encodeInt:tmpShort forKey:@"permutationObject index"];
                    break;
                case _polygon_is_automatic_exit:
                    //tmpShort = 0;
                    [coder encodeInt:0 forKey:@"permutationObject index"];
                    break;
                case _polygon_is_platform:
                    [permutationObject setEncodeIndexNumbersInstead:YES];
                    [coder encodeObject:permutationObject forKey:@"permutationObject"];
                    [permutationObject setEncodeIndexNumbersInstead:NO];
                    break;
                default:
                    break;
            }
        } else {
            [coder encodeObject:permutationObject forKey:@"permutationObject"];
        }
        
        @autoreleasepool {
            NSArray *tmpVertex = [NSArray arrayWithObjects:vertexObjects count:vertexCountForPoly];
            NSArray *tmpLine = [NSArray arrayWithObjects:lineObjects count:vertexCountForPoly];
            if (useIndexNumbersInstead) {
                [tmpVertex makeObjectsPerformSelector:@selector(setEncodeIndexNumbersInstead:) withObject:@YES];
                [tmpLine makeObjectsPerformSelector:@selector(setEncodeIndexNumbersInstead:) withObject:@YES];
            }
            
            [coder encodeObject:tmpVertex forKey:@"vertexObjects"];
            [coder encodeObject:tmpLine forKey:@"lineObjects"];
            
            if (!useIndexNumbersInstead) {
                NSMutableDictionary *tmpAdj = [NSMutableDictionary dictionary];
                NSMutableDictionary *tmpSide = [NSMutableDictionary dictionary];
                for (int i = 0; i < vertexCountForPoly; i++) {
                    if (adjacent_polygon_objects[i]) {
                        [tmpAdj setObject:adjacent_polygon_objects[i] forKey:@(i)];
                    }
                    if (side_objects[i]) {
                        [tmpSide setObject:side_objects[i] forKey:@(i)];
                    }
                }
                [coder encodeObject:tmpAdj forKey:@"adjacent_polygon_objects"];
                [coder encodeObject:tmpSide forKey:@"side_objects"];
            }
            
            if (useIndexNumbersInstead) {
                [tmpVertex makeObjectsPerformSelector:@selector(setEncodeIndexNumbersInstead:) withObject:@NO];
                [tmpLine makeObjectsPerformSelector:@selector(setEncodeIndexNumbersInstead:) withObject:@NO];
            }
        }
        
        [coder encodeInt:floor_texture forKey:@"floor_texture"];
        [coder encodeInt:ceiling_texture forKey:@"ceiling_texture"];
        [coder encodeInt:floor_height forKey:@"floor_height"];
        [coder encodeInt:ceiling_height forKey:@"ceiling_height"];
        
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(floor_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"floor_lightsource_object index"];
            tmpShort = GetIndexAdv(ceiling_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"ceiling_lightsource_object index"];
        } else {
            [coder encodeObject:floor_lightsource_object forKey:@"floor_lightsource_object"];
            [coder encodeObject:ceiling_lightsource_object forKey:@"ceiling_lightsource_object"];
        }
        
        [coder encodeInt:area forKey:@"area"];
        
        if (!useIndexNumbersInstead) {
            [coder encodeObject:first_object_pointer forKey:@"first_object_pointer"];
            
            [coder encodeObject:first_exclusion_zone_object forKey:@"first_exclusion_zone_object"];
            [coder encodeInt:line_exclusion_zone_count forKey:@"line_exclusion_zone_count"];
            [coder encodeInt:point_exclusion_zone_count forKey:@"point_exclusion_zone_count"];
        }
        
        [coder encodeInt:floor_transfer_mode forKey:@"floor_transfer_mode"];
        [coder encodeInt:ceiling_transfer_mode forKey:@"ceiling_transfer_mode"];
        
        if (!useIndexNumbersInstead) {
            [coder encodeObject:first_neighbor_object forKey:@"first_neighbor_object"];
            [coder encodeInt:neighbor_count forKey:@"neighbor_count"];
        }
        
        [coder encodePoint:center forKey:@"center"];
        [coder encodePoint:floor_origin forKey:@"floor_origin"];
        [coder encodePoint:ceiling_origin forKey:@"ceiling_origin"];
        
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(media_object);
            [coder encodeInt:tmpShort forKey:@"media_object index"];
            tmpShort = GetIndexAdv(media_lightsource_object);
            [coder encodeInt:tmpShort forKey:@"media_lightsource_object index"];
        } else {
            [coder encodeObject:media_object forKey:@"media_object"];
            [coder encodeObject:media_lightsource_object forKey:@"media_lightsource_object"];
            
            [coder encodeObject:sound_source_objects forKey:@"sound_source_objects"];
        }
        
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(ambient_sound_image_object);
            [coder encodeInt:tmpShort forKey:@"random_sound_image_object index"];
            tmpShort = GetIndexAdv(random_sound_image_object);
            [coder encodeInt:tmpShort forKey:@"random_sound_image_object index"];
        } else {
            [coder encodeObject:ambient_sound_image_object forKey:@"ambient_sound_image_object"];
            [coder encodeObject:random_sound_image_object forKey:@"random_sound_image_object"];
        }
    } else {
        encodeNumInt(coder, 1);
        
        
        if (!useIndexNumbersInstead)
            encodeObj(coder, polyLayer);
        
        encodeBOOL(coder, polygonConcave);
        
        encodeShort(coder, type);
        encodeUnsignedShort(coder, flags);
        
        switch (type) {
            case _polygon_is_base:
            case _polygon_is_minor_ouch:
            case _polygon_is_major_ouch:
            case _polygon_is_glue:
            case _polygon_is_glue_trigger:
            case _polygon_is_superglue:
            case _polygon_is_goal:
            case _polygon_is_visible_monster_trigger:
            case _polygon_is_invisible_monster_trigger:
            case _polygon_is_dual_monster_trigger:
            case _polygon_is_item_trigger:
            case _polygon_must_be_explored:
            case _polygon_is_zone_border:
            case _polygon_is_normal:
            case _polygon_is_item_impassable:
            case _polygon_is_monster_impassable:
            case _polygon_is_hill:
                permutationObject = nil;
                break;
            default:
                break;
        }
        
        if (useIndexNumbersInstead) {
            switch (type) {
                case _polygon_is_base:
                    tmpShort = 0;
                    encodeShort(coder, tmpShort);
                    break;
                case _polygon_is_light_on_trigger:
                case _polygon_is_platform_on_trigger:
                case _polygon_is_light_off_trigger:
                case _polygon_is_platform_off_trigger:
                case _polygon_is_teleporter:
                    tmpShort = GetIndexAdv(permutationObject);
                    encodeShort(coder, tmpShort);
                    break;
                case _polygon_is_automatic_exit:
                    tmpShort = 0;
                    encodeShort(coder, tmpShort);
                    break;
                case _polygon_is_platform:
                    [permutationObject setEncodeIndexNumbersInstead:YES];
                    encodeObj(coder, permutationObject);
                    [permutationObject setEncodeIndexNumbersInstead:NO];
                    break;
                default:
                    break;
            }
        } else {
            if (type != _polygon_is_automatic_exit/* || type != _polygon_is_base*/) {
                encodeObj(coder, permutationObject);
            } else {
                short tmpn = [permutationObject shortValue];
                encodeShort(coder, tmpn);
            }
        }
        
        
        encodeShort(coder, vertexCountForPoly);
        
        for (i = 0; i < vertexCountForPoly; i++) {
            if (useIndexNumbersInstead) {
                NSLog(@"POLYGON: vertexObjects[%d]: %d", i, [vertexObjects[i] index]);
                [vertexObjects[i] setEncodeIndexNumbersInstead:YES];
                [lineObjects[i] setEncodeIndexNumbersInstead:YES];
                //[side_objects[i] setEncodeIndexNumbersInstead:YES];
            }
            
            encodeObj(coder, vertexObjects[i]);
            encodeObj(coder, lineObjects[i]);
            
            if (!useIndexNumbersInstead)
                encodeObj(coder, adjacent_polygon_objects[i]);
            
            if (!useIndexNumbersInstead)
                encodeObj(coder, side_objects[i]);
            
            if (useIndexNumbersInstead) {
                [vertexObjects[i] setEncodeIndexNumbersInstead:NO];
                [lineObjects[i] setEncodeIndexNumbersInstead:NO];
                //[side_objects[i] setEncodeIndexNumbersInstead:NO];
            }
            else
                side_objects[i] = nil;
        }
        
        encodeShort(coder, floor_texture);
        encodeShort(coder, ceiling_texture);
        encodeShort(coder, floor_height);
        encodeShort(coder, ceiling_height);
        
        if (useIndexNumbersInstead) {
            tmpShort = GetIndexAdv(floor_lightsource_object);
            encodeShort(coder, tmpShort);
            tmpShort = GetIndexAdv(ceiling_lightsource_object);
            encodeShort(coder, tmpShort);
        } else {
            encodeObj(coder, floor_lightsource_object);
            encodeObj(coder, ceiling_lightsource_object);
        }
        
        encodeLong(coder, area);
        
        if (!useIndexNumbersInstead) {
            encodeObj(coder, first_object_pointer);
            
            encodeObj(coder, first_exclusion_zone_object);
            encodeShort(coder, line_exclusion_zone_count);
            encodeShort(coder, point_exclusion_zone_count);
        }
        
        encodeShort(coder, floor_transfer_mode);
        encodeShort(coder, ceiling_transfer_mode);
        
        if (!useIndexNumbersInstead) {
            encodeObj(coder, first_neighbor_object);
            encodeShort(coder, neighbor_count);
        }
        
        tempInt = center.x;
        encodeInt(coder, tempInt);
        tempInt = center.y;
        encodeInt(coder, tempInt);
        
        tempInt = floor_origin.x;
        encodeInt(coder, tempInt);
        tempInt = floor_origin.y;
        encodeInt(coder, tempInt);
        
        tempInt = ceiling_origin.x;
        encodeInt(coder, tempInt);
        tempInt = ceiling_origin.y;
        encodeInt(coder, tempInt);
        
        if (useIndexNumbersInstead)
        {
            tmpShort = GetIndexAdv(media_object);
            encodeShort(coder, tmpShort);
            tmpShort = GetIndexAdv(media_lightsource_object);
            encodeShort(coder, tmpShort);
        }
        else
        {
            encodeObj(coder, media_object);
            encodeObj(coder, media_lightsource_object);
            
            encodeObj(coder, sound_source_objects);
        }
        
        if (useIndexNumbersInstead)
        {
            tmpShort = GetIndexAdv(ambient_sound_image_object);
            encodeShort(coder, tmpShort);
            tmpShort = GetIndexAdv(random_sound_image_object);
            encodeShort(coder, tmpShort);
        }
        else
        {
            encodeObj(coder, ambient_sound_image_object);
            encodeObj(coder, random_sound_image_object);
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    int i;
    
    int versionNum = 0;
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        if (!useIndexNumbersInstead) {
            polyLayer = [coder decodeObjectOfClass:[PhLayer class] forKey:@"polyLayer"];
        }
        
        polygonConcave = [coder decodeBoolForKey:@"polygonConcave"];
        
        type = [coder decodeIntForKey:@"type"];
        flags = [coder decodeIntForKey:@"flags"];
        
        if (useIndexNumbersInstead) {
            short tmpShort;
            switch (type) {
                case _polygon_is_base:
                    ///tmpShort = 0;
                    //decodeShort(coder);
                    break;
                case _polygon_is_light_on_trigger:
                case _polygon_is_light_off_trigger:
                    tmpShort = [coder decodeIntForKey:@"permutationObject index"];
                    permutationObject = [self getLightFromIndex:tmpShort];
                    break;
                case _polygon_is_platform_on_trigger:
                case _polygon_is_platform_off_trigger:
                case _polygon_is_teleporter:
                    tmpShort = [coder decodeIntForKey:@"permutationObject index"];
                    permutationObject = [self getPolygonFromIndex:tmpShort];
                    break;
                case _polygon_is_automatic_exit:
                    ///tmpShort = 0;
                    //decodeShort(coder);
                    break;
                case _polygon_is_platform:
                    permutationObject = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class], [LEMapStuffParent class], nil] forKey:@"permutationObject"];
                    break;
                default:
                    break;
            }
        } else {
            permutationObject = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class], [LEMapStuffParent class], nil] forKey:@"permutationObject"];
        }
        
        @autoreleasepool {
            NSArray *tmpVertex = [coder decodeObjectOfClasses:[NSSet setWithObjects:[LEMapPoint class], [NSArray class], nil] forKey:@"vertexObjects"];
            NSArray *tmpLine = [coder decodeObjectOfClasses:[NSSet setWithObjects:[LELine class], [NSArray class], nil] forKey:@"lineObjects"];
            vertexCountForPoly = tmpVertex.count;
            
            for (int i = 0; i<vertexCountForPoly; i++) {
                vertexObjects[i]=tmpVertex[i];
                lineObjects[i]=tmpLine[i];
            }
            
            if (!useIndexNumbersInstead) {
                NSDictionary *tmpAdj = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class], [NSDictionary class], [LEMapStuffParent class], nil] forKey:@"adjacent_polygon_objects"];
                NSDictionary *tmpSide = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class], [NSDictionary class], [LESide class], nil] forKey:@"side_objects"];
                for (int i = 0; i<vertexCountForPoly; i++) {
                    adjacent_polygon_objects[i]=tmpAdj[@(i)];
                    side_objects[i]=tmpSide[@(i)];
                }
            }
        }
        
        floor_texture = [coder decodeIntForKey:@"floor_texture"];
        ceiling_texture = [coder decodeIntForKey:@"ceiling_texture"];
        floor_height = [coder decodeIntForKey:@"floor_height"];
        ceiling_height = [coder decodeIntForKey:@"ceiling_height"];
        
        if (useIndexNumbersInstead) {
            short tmpShort;
            tmpShort = [coder decodeIntForKey:@"floor_lightsource_object index"];
            floor_lightsource_object = [self getLightFromIndex:tmpShort];
            tmpShort = [coder decodeIntForKey:@"floor_lightsource_object index"];
            ceiling_lightsource_object = [self getLightFromIndex:tmpShort];
        } else {
            floor_lightsource_object = [coder decodeObjectOfClass:[PhLight class] forKey:@"floor_lightsource_object"];
            ceiling_lightsource_object = [coder decodeObjectOfClass:[PhLight class] forKey:@"ceiling_lightsource_object"];
        }
        
        area = [coder decodeIntForKey:@"area"];
        
        if (!useIndexNumbersInstead) {
            first_object_pointer = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"first_object_pointer"];
            
            first_exclusion_zone_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"first_exclusion_zone_object"];
            line_exclusion_zone_count = [coder decodeIntForKey:@"line_exclusion_zone_count"];
            point_exclusion_zone_count = [coder decodeIntForKey:@"point_exclusion_zone_count"];
        }
        
        floor_transfer_mode = [coder decodeIntForKey:@"floor_transfer_mode"];
        ceiling_transfer_mode = [coder decodeIntForKey:@"ceiling_transfer_mode"];
        
        if (!useIndexNumbersInstead) {
            first_neighbor_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"first_neighbor_object"];
            neighbor_count = [coder decodeIntForKey:@"neighbor_count"];
        }
        
        center = [coder decodePointForKey:@"center"];
        floor_origin = [coder decodePointForKey:@"floor_origin"];
        ceiling_origin = [coder decodePointForKey:@"ceiling_origin"];
        
        if (useIndexNumbersInstead) {
            short tmpShort;
            tmpShort = [coder decodeIntForKey:@"media_object index"];
            media_object = [self getMediaFromIndex:tmpShort];
            tmpShort = [coder decodeIntForKey:@"media_lightsource_object index"];
            media_lightsource_object = [self getLightFromIndex:tmpShort];
        } else {
            media_object = [coder decodeObjectOfClass:[PhMedia class] forKey:@"media_object"];
            media_lightsource_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"media_lightsource_object"];
            
            sound_source_objects = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"sound_source_objects"];
        }
        
        if (useIndexNumbersInstead) {
            short tmpShort;
            tmpShort = [coder decodeIntForKey:@"ambient_sound_image_object index"];
            ambient_sound_image_object = [self getAmbientSoundFromIndex:tmpShort];
            tmpShort = [coder decodeIntForKey:@"random_sound_image_object index"];
            random_sound_image_object = [self getRandomSoundFromIndex:tmpShort];
        } else {
            ambient_sound_image_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"ambient_sound_image_object"];
            random_sound_image_object = [coder decodeObjectOfClass:[LEMapStuffParent class] forKey:@"random_sound_image_object"];
        }
        
        //if (useIndexNumbersInstead)
        //    [theLELevelDataST addPolygonDirectly:self];
        
        //useIndexNumbersInstead = NO;
        
        
        switch (type) {
            case _polygon_is_base:
            case _polygon_is_minor_ouch:
            case _polygon_is_major_ouch:
            case _polygon_is_glue:
            case _polygon_is_glue_trigger:
            case _polygon_is_superglue:
            case _polygon_is_goal:
            case _polygon_is_visible_monster_trigger:
            case _polygon_is_invisible_monster_trigger:
            case _polygon_is_dual_monster_trigger:
            case _polygon_is_item_trigger:
            case _polygon_must_be_explored:
            case _polygon_is_zone_border:
            case _polygon_is_normal:
            case _polygon_is_item_impassable:
            case _polygon_is_monster_impassable:
            case _polygon_is_hill:
                permutationObject = nil;
                break;
            default:
                break;
        }
    } else {
        versionNum = decodeNumInt(coder);
        
        if (!useIndexNumbersInstead)
            polyLayer = decodeObj(coder);
        
        polygonConcave = decodeBOOL(coder);
        
        type = decodeShort(coder);
        flags = decodeUnsignedShort(coder);
/*
-(id)getLightFromIndex:(short)theIndex;
-(id)getMediaFromIndex:(short)theIndex;
-(id)getAmbientSoundFromIndex:(short)theIndex;
-(id)getRandomSoundFromIndex:(short)theIndex;
-(id)getPolygonFromIndex:(short)theIndex;
*/



        if (useIndexNumbersInstead) {
            switch (type) {
                case _polygon_is_base:
                    ///tmpShort = 0;
                    decodeShort(coder);
                    break;
                case _polygon_is_light_on_trigger:
                case _polygon_is_light_off_trigger:
                    permutationObject = [self getLightFromIndex:decodeShort(coder)];
                    break;
                case _polygon_is_platform_on_trigger:
                case _polygon_is_platform_off_trigger:
                case _polygon_is_teleporter:
                    ///tmpShort = [permutationObject getIndex];
                    permutationObject = [self getPolygonFromIndex:decodeShort(coder)];
                    break;
                case _polygon_is_automatic_exit:
                    ///tmpShort = 0;
                    decodeShort(coder);
                    break;
                case _polygon_is_platform:
                    permutationObject = decodeObj(coder);
                    break;
                default:
                    break;
            }
        } else {
            if (_polygon_is_automatic_exit == type /*[permutationObject isKindOfClass:[NSNumber class]]*/) {
                if (versionNum < 1) {
                    decodeObj(coder);
                    permutationObject = [numShort(256) copy];
                } else
                    permutationObject = [numShort(decodeShort(coder)) copy];
            }
            else
                permutationObject = decodeObj(coder);
        }
        vertexCountForPoly = decodeShort(coder);
        //NSLog(@"decode vertexCountForPoly: %d", vertexCountForPoly);
        for (i = 0; i < vertexCountForPoly; i++) {
            vertexObjects[i] = decodeObj(coder);
            lineObjects[i] = decodeObj(coder);
            
            if (!useIndexNumbersInstead)
                adjacent_polygon_objects[i] = decodeObj(coder);
            
            if (!useIndexNumbersInstead)
                side_objects[i] = decodeObj(coder);
        }
        
        floor_texture = decodeShort(coder);
        ceiling_texture = decodeShort(coder);
        floor_height = decodeShort(coder);
        ceiling_height = decodeShort(coder);
        
        if (useIndexNumbersInstead) {
            floor_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
            ceiling_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
        } else {
            floor_lightsource_object = decodeObj(coder);
            ceiling_lightsource_object = decodeObj(coder);
        }
        
        area = decodeLong(coder);
        
        if (!useIndexNumbersInstead) {
            first_object_pointer = decodeObj(coder);
            
            first_exclusion_zone_object = decodeObj(coder);
            line_exclusion_zone_count = decodeShort(coder);
            point_exclusion_zone_count = decodeShort(coder);
        }
        
        floor_transfer_mode = decodeShort(coder);
        ceiling_transfer_mode = decodeShort(coder);
        
        if (!useIndexNumbersInstead) {
            first_neighbor_object = decodeObj(coder);
            neighbor_count = decodeShort(coder);
        }
        
        center.x = decodeInt(coder);
        center.y = decodeInt(coder);
        
        floor_origin.x = decodeInt(coder);
        floor_origin.y = decodeInt(coder);
        
        ceiling_origin.x = decodeInt(coder);
        ceiling_origin.y = decodeInt(coder);
        
        if (useIndexNumbersInstead) {
            media_object = [self getMediaFromIndex:decodeShort(coder)];
            media_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
        } else {
            media_object = decodeObj(coder);
            media_lightsource_object = decodeObj(coder);
            
            sound_source_objects = decodeObj(coder);
        }
        
        if (useIndexNumbersInstead) {
            ambient_sound_image_object = [self getAmbientSoundFromIndex:decodeShort(coder)];
            random_sound_image_object = [self getRandomSoundFromIndex:decodeShort(coder)];
        } else {
            ambient_sound_image_object = decodeObj(coder);
            random_sound_image_object = decodeObj(coder);
        }
        
        //if (useIndexNumbersInstead)
        //    [theLELevelDataST addPolygonDirectly:self];
        
        //useIndexNumbersInstead = NO;
        
        
        switch (type) {
            case _polygon_is_base:
            case _polygon_is_minor_ouch:
            case _polygon_is_major_ouch:
            case _polygon_is_glue:
            case _polygon_is_glue_trigger:
            case _polygon_is_superglue:
            case _polygon_is_goal:
            case _polygon_is_visible_monster_trigger:
            case _polygon_is_invisible_monster_trigger:
            case _polygon_is_dual_monster_trigger:
            case _polygon_is_item_trigger:
            case _polygon_must_be_explored:
            case _polygon_is_zone_border:
            case _polygon_is_normal:
            case _polygon_is_item_impassable:
            case _polygon_is_monster_impassable:
            case _polygon_is_hill:
                permutationObject = nil;
                break;
            default:
                break;
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    LEPolygon *copy = [[LEPolygon allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

-(id)initWithPolygon:(LEPolygon *)thePolygonToImitate
{
    self = [self init];
    [thePolygonToImitate copySettingsTo:self];
    
    return self;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        useIndexNumbersInstead = NO;
        
        [self setVertextCount:0];
        for(int i = 0; i < 8; i++) {
            lineIndexes[i] = -1;
            vertexIndexes[i] = -1;
            lineObjects[i] = nil;
            vertexObjects[i] = nil;
            side_indexes[i] = -1;
            side_objects[i] = nil;
            adjacent_polygon_indexes[i] = -1;
            adjacent_polygon_objects[i] = nil;
        }
        
        floor_height = 0;
        ceiling_height = 1024;
        floor_lightsource_index = 0;
        ceiling_lightsource_index = 0;
        floor_lightsource_object = nil;
        ceiling_lightsource_object = nil;
        flags = 0;
        permutation = 0;
        ambient_sound_image_index = -1;
        random_sound_image_index = -1;
        media_index = -1;
        media_lightsource_index = 0;
        polygonConcave = YES;
        
        floor_transfer_mode = 0;
        ceiling_transfer_mode = 0;
        floor_texture = 4358; // 0x1106 17-6
        ceiling_texture = 4359; // 0x1107 17-7
        
        ambient_sound_image_object = nil;
        random_sound_image_object = nil;
        media_object = nil;
        
        polyLayer = nil;
        
        permutationObject = nil;
    }
    return self;
}

-(void)dealloc
{
    // / CHECK THIS OUT, CRRASHED HERE After switching to a layer and saving and closing: if ([permutationObject isKindOfClass:[NSNumber class]])
    // /    [permutationObject release];
    
    permutationObject = nil;
}

-(BOOL)uses:(id)theObj
{
    if ([theObj isKindOfClass:[LEMapPoint class]]) {
        for (int i = 0; i < vertexCountForPoly; i++) {
            if (vertexObjects[i] == theObj) {
                return YES;
            }
        }
    } else if ([theObj isKindOfClass:[LELine class]]) {
        for(int i = 0; i < vertexCountForPoly; i++) {
            if (lineObjects[i] == theObj) {
                return YES;
            }
        }
    } else if ([theObj isKindOfClass:[LEPolygon class]]) {
        return NO; // might want to check clockwise/counterclockwise stuff...
    } else if ([theObj isKindOfClass:[LEMapObject class]]) {
        return NO; // check if object in this polygon?
    }
    return NO;      
}

-(short) index { return [theMapPolysST indexOfObjectIdenticalTo:self]; }

// ****************** Texture Methods ********************
#pragma mark -
#pragma mark ********* Texture Methods *********

-(void)setCeilingTextureOnly:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&ceiling_texture;
    (theTexChar)[0] = number;
}

-(void)setFloorTextureOnly:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&floor_texture;
    (theTexChar)[0] = number;
}

-(void)setCeilingTextureCollectionOnly:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&ceiling_texture;
    (theTexChar)[1] = number + 0x11;
}

-(void)setFloorTextureCollectionOnly:(char)number
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&floor_texture;
    (theTexChar)[1] = number + 0x11;
}

-(void)resetTextureCollectionOnly
{
    //TODO: make endian-safe
    // For right now it just sets it to the current levels
    // collection.
    char *theFTexChar = (char *)&floor_texture;
    char *theCTexChar = (char *)&ceiling_texture;
    short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (theFTexChar)[1] = (0x11 + theCurrentEnviroCode);
    (theCTexChar)[1] = (0x11 + theCurrentEnviroCode);
}

-(void)setTextureCollectionOnly:(char)number
{
    //TODO: make endian-safe
    char *theFTexChar = (char *)&floor_texture;
    char *theCTexChar = (char *)&ceiling_texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (theFTexChar)[1] = (0x11 + number);
    (theCTexChar)[1] = (0x11 + number);
}

-(char)ceilingTextureOnly
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&ceiling_texture;
    return (theTexChar)[0];
}

-(char)floorTextureOnly
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&floor_texture;
    return (theTexChar)[0];
}

-(char)ceilingTextureCollectionOnly
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&ceiling_texture;
    return (theTexChar)[1] - 0x11;
}

-(char)floorTextureCollectionOnly
{
    //TODO: make endian-safe
    char *theTexChar = (char *)&floor_texture;
    return (theTexChar)[1] - 0x11;
}

// I would not reccemend using this function any more, since the ceiling could be diffrent.
// Before it was assumed that the floor and ceiling would be in the same colleciton,
// that assumtion can not be made anymore...
-(char)textureCollectionOnly
{
    //TODO: make endian-safe
    char *theFTexChar = (char *)&floor_texture;
    //char *theCTexChar = (char *)&ceiling_texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    return (theFTexChar)[1] - 0x11;
    //(theCTexChar)[0] = (0x11 + number);
}

// ****************** Utilites ********************
#pragma mark -
#pragma mark ********* Utilites *********

- (void)releasePlatform
{
	
}

-(void)calculateSidesForAllLines
{
    for (int i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}

-(void)copySettingsTo:(id)target
{
    LEPolygon *theTarget = (LEPolygon *)target;
    id tempPermutationObj = nil;
    int thePreviousType = [theTarget type];
    
    [theTarget setMediaObject:media_object];
    [theTarget setMediaLightsourceObject:media_lightsource_object];
    [theTarget setAmbientSoundObject:ambient_sound_image_object];
    [theTarget setRandomSoundObject:random_sound_image_object];
    
    [theTarget setFloorOrigin:floor_origin];
    [theTarget setCeilingOrigin:ceiling_origin];
    
    [theTarget setType:type];
    [theTarget setFlags:flags];
    
	// NEED: to add and rememove the platform from the level also...
	
	
    if (thePreviousType == _polygon_is_platform && type != _polygon_is_platform) {
        [theTarget releasePlatform];
    }
    
    switch (type) {
        case _polygon_is_platform:
            if ([permutationObject class] == [PhPlatform class]) {
				if ([theTarget permutationObject] != nil) {
					if ([[theTarget permutationObject] class] == [PhPlatform class]) {
						tempPermutationObj = [theTarget permutationObject];
						[permutationObject copySettingsTo:tempPermutationObj];
					} else {
						tempPermutationObj = [permutationObject copy];
							/* copy method should automatically do this */
						//[permutationObject copySettingsTo:tempPermutationObj];
						[tempPermutationObj setPolygonObject:theTarget];
					}
				} else {
					tempPermutationObj = [permutationObject copy];
						/* copy method should automatically do this */
					//[permutationObject copySettingsTo:tempPermutationObj];
					[tempPermutationObj setPolygonObject:theTarget];
				}
            } else {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
                alert.informativeText = NSLocalizedString(@"When copying settings to a new platform, the orginal platfrom was nil, Default Polygon Subroutine Error!!!", @"When copying settings to a new platform, the orginal platfrom was nil, Default Polygon Subroutine Error!!!");
                alert.alertStyle = NSAlertStyleInformational;
                [alert runModal];
                tempPermutationObj = nil;
            }
            break;
        case _polygon_is_light_on_trigger:
            tempPermutationObj = permutationObject;
            break;
        case _polygon_is_platform_on_trigger:
            tempPermutationObj = permutationObject;
            break;
        case _polygon_is_light_off_trigger:
            tempPermutationObj = permutationObject;
            break;
        case _polygon_is_platform_off_trigger:
            tempPermutationObj = permutationObject;
            break;
        case _polygon_is_teleporter:
            tempPermutationObj = permutationObject;
            break;
        case _polygon_is_base: // For Now, I am not sure about this yet??? 
        case _polygon_is_automatic_exit:
            //NSLog(@"AUTOMATIC EXIT: %d", thePermutation);
        default:
            tempPermutationObj = nil;
            break;
    }
    
    [theTarget setPermutationObject:tempPermutationObj];
    [theTarget setFloorTexture:floor_texture];
    [theTarget setCeilingTexture:ceiling_texture];
    
    [theTarget setFloorHeightNoSides:floor_height];
    [theTarget setCeilingHeight:ceiling_height];
    
    [theTarget setFloorLightsourceObject:floor_lightsource_object];
    [theTarget setCeilingLightsourceObject:ceiling_lightsource_object];
    [theTarget setArea:area];
    [theTarget setFirstObjectObject:first_object_pointer];
    [theTarget setFloorTransferMode:floor_transfer_mode];
    [theTarget setCeilingTransferMode:ceiling_transfer_mode];
    [theTarget setCenter:center];
}

-(int)getLineNumberFor:(LELine *)theLine
{
    for (int i = 0; i < vertexCountForPoly; i++) {
        if (lineObjects[i] == theLine)
            return i;
    }
    return -1;
}

-(void)setLightsThatAre:(PhLight*)theLightInQuestion to:(PhLight*)setToLight
{
    if (floor_lightsource_object == theLightInQuestion)
        floor_lightsource_object = setToLight;
    
    if (ceiling_lightsource_object == theLightInQuestion)
        ceiling_lightsource_object = setToLight;
}

-(void)thePolyMap:(NSBezierPath *)poly
{
    //If there is not at least 3 points, there can be no polygon as far as Marathon is concerned (in theory) :)
    if (vertexCountForPoly > 2)  {
        [poly moveToPoint:[vertexObjects[0] as32Point]];
        for (short i = 1; i < vertexCountForPoly; i++) {
            [poly lineToPoint:[vertexObjects[i] as32Point]];
        }
        [poly closePath];
        return;
    }
    return;
}

-(void)removeLineAssotication:(LELine *)theLine
{
    int i;
    for(i = 0; i < vertexCountForPoly; i++) {
        if (lineObjects[i] == theLine) {
            lineObjects[i] = nil;
        }
    }
}

-(void)removePointAssotication:(LEMapPoint *)theLine
{
    int i;
    for(i = 0; i < vertexCountForPoly; i++) {
        if (vertexObjects[i] == theLine) {
            vertexObjects[i] = nil;
        }
    }
}

-(void)removeAssociationOfObject:(id)theObj
{
    int i;
    
    if ([theObj isKindOfClass:[LEPolygon class]]) {
        for(i = 0; i < 8; i++) {
            if (adjacent_polygon_objects[i] == theObj)
                adjacent_polygon_objects[i] = nil;
        }
    } else if ([theObj isKindOfClass:[LELine class]]) {
        for(i = 0; i < vertexCountForPoly; i++) {
            if (lineObjects[i] == theObj)
                lineObjects[i] = nil;
        }
    } else if ([theObj isKindOfClass:[LEMapPoint class]]) {
        for(i = 0; i < vertexCountForPoly; i++) {
            if (vertexObjects[i] == theObj) {
                vertexObjects[i] = nil;
            }
        }
    }
    
    return;
}

-(void)setAllAdjacentPolygonPointersToNil
{
    for (int i = 0; i < 8; i++) {
        adjacent_polygon_objects[i] = nil;
    }
}

// ****************** Polygon Layer *********************
#pragma mark -
#pragma mark ********* Polygon Layer *********
@synthesize polyLayer;
-(void)setPolyLayer:(PhLayer *)theLayer
{
    if (polyLayer != nil)
        [polyLayer removeObjectFromLayer:self];
        
    polyLayer = theLayer;
    
    if (polyLayer != nil)
        [polyLayer addObjectToLayer:self];
}


// ****************** Moving/Bounds *********************
#pragma mark -
#pragma mark ********* Moving/Bounds *********
-(NSRect)drawingBounds
{ 
    //NSBezierPath *poly = [NSBezierPath bezierPath];
    //[self thePolyMap:poly];
    //return [poly bounds];
    
    int i;
    
    int maxX = [vertexObjects[0] x32];
    int minX = maxX;
    int minY = [vertexObjects[0] y32];
    int maxY = minY;
    
    for (i = 1; i < vertexCountForPoly; i++) {
        int dpX = [vertexObjects[i] x32];
        int dpY = [vertexObjects[i] y32];
        
        if (dpX > maxX)
            maxX = dpX;
        else if (dpX < minX)
            minX = dpX;
        
        if (dpY < minY)
            minY = dpY;
        else if (dpY > maxY)
            maxY = dpY;
    }
    
    return NSMakeRect(minX, minY, (maxX - minX), (maxY - minY));
}

-(void)moveBy32Point:(NSPoint)theOffset
{
    short i;
    
    //If there is not at least 3 points, there can be no polygon as far as Marathon is concerned (in thory) :)
    if (vertexCountForPoly > 2)  {
        for (i = 0; i < vertexCountForPoly; i++) {
            [vertexObjects[i] moveBy32Point:theOffset];
        }
        return;
    }
}

-(void)moveBy32Point:(NSPoint)theOffset pointsAlreadyMoved:(NSMutableSet *)pointsAlreadyMoved
{
    short i;
    
    //If there is not at least 3 points, there can be no polygon as far as marathon is concerned (in thory) :)
    if (vertexCountForPoly > 2) 
    {
        for (i = 0; i < vertexCountForPoly; i++)
        {
            if (![pointsAlreadyMoved containsObject:(vertexObjects[i])])
            {
                [vertexObjects[i] moveBy32Point:theOffset];
                [pointsAlreadyMoved addObject:vertexObjects[i]];
            }
        }
        return;
    }
}

- (BOOL)LEhitTest:(NSPoint)point {
    NSBezierPath *poly = [NSBezierPath bezierPath];
    //NSLog(@"About to self create poly map...");
    [self thePolyMap:poly];
    //NSLog(@"About to self create poly map...[DONE]");
    if ([poly containsPoint:point]) { return YES; }
    return NO;
}


// ******************************** Set Accsessors **********************************

-(void)setType:(LEPolygonType)v
{
    int i;
    
    if (type != v)
    {
        type = v;
        
        [self setPermutationObject:nil];
        
        for (i = 0; i < vertexCountForPoly; i++)
            [lineObjects[i] caculateSides];
    }
}

-(void)setPermutation:(short)v
{
    /*if (type == _polygon_is_platform)
    {
        
    }
    else*/
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
    alert.informativeText = NSLocalizedString(@"An obsolete method setPermutation:(short)v was called in a polygon object, this is a possible error!", @"An obsolete method setPermutation:(short)v was called in a polygon object, this is a possible error!");
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
    //permutation = v;
}

-(void)setPermutationObject:(id)theObject
{
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        permutationObject = nil;
    }
    else if ([permutationObject isKindOfClass:[PhPlatform class]])
    {
        [theObject setPolygonObject:nil];
        permutationObject = nil;
    }
    
    if (theObject == nil)
    {
        permutationObject = nil;
        return;
    }
    
    permutationObject = nil;
    
    if ([theObject isKindOfClass:[NSNumber class]])
    {
        NSLog(@"*** SETING POLY PERMUTATION WITH NSNumber: %d ***", [theObject intValue]);
        permutationObject = [theObject copy];
    }
    else if ([theObject isKindOfClass:[PhPlatform class]])
    {
        permutationObject = theObject;
        [theObject setPolygonObject:self];
    }
    else
    {
        permutationObject = theObject;
    }
    
    /*if ([theObject isKindOfClass:[PhPlatform class]])
    {
        permutationObject = theObject;
        if (permutationObject == nil)
        {
            permutation = -1;
            type = _polygon_is_normal;
        }
        else
        {
            permutation = [theMapPlatformsST indexOfObjectIdenticalTo:permutationObject];
            type = _polygon_is_platform;
        }
    }*/
    /*
    else if ([objectToAdd isKindOfClass:[LELine class]])
        [self addLine:objectToAdd];
    
    else if ([objectToAdd isKindOfClass:[LEPolygon class]])
        [self addPolygon:objectToAdd];
        
    else if ([objectToAdd isKindOfClass:[LEMapObject class]])
    */
}

-(void)setVertextCount:(short)vCount { vertexCountForPoly = vCount;}

-(void)setV1:(short)v { [self setVertexWith:v toIndex:0];  } //
-(void)setV2:(short)v { [self setVertexWith:v toIndex:1];  } //
-(void)setV3:(short)v { [self setVertexWith:v toIndex:2];  } //
-(void)setV4:(short)v { [self setVertexWith:v toIndex:3];  } //
-(void)setV5:(short)v { [self setVertexWith:v toIndex:4];  } //
-(void)setV6:(short)v { [self setVertexWith:v toIndex:5];  } //
-(void)setV7:(short)v { [self setVertexWith:v toIndex:6];  } //
-(void)setV8:(short)v { [self setVertexWith:v toIndex:7];  } //


-(void)setVertexWith:(short)v toIndex:(short)i
{
    //vertexIndexes[i] = v;
    if (v == -1)
        vertexObjects[i] = nil;
    else if (everythingLoadedST)
        vertexObjects[i] = [theMapPointsST objectAtIndex:v];
} //

-(void)setVertexWithObject:(id)v toIndex:(short)i
{
    vertexObjects[i] = v;
} //

-(void)setLines:(short)v toIndex:(short)i 
{
    //lineIndexes[i] = v;
    
    if (v == -1)
        lineObjects[i] = nil;
    else if (everythingLoadedST)
        lineObjects[i] = [theMapLinesST objectAtIndex:v];
} //
-(void)setLinesObject:(id)v toIndex:(short)i 
{
    
    lineObjects[i] = v;
} //

-(void)setFloorHeightNoSides:(short)v { floor_height = v; }
-(void)setCeilingHeightNoSides:(short)v { ceiling_height = v; }

-(void)setFloorHeight:(short)v
{
    int i;
    floor_height = v;
    for (i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}
-(void)setCeilingHeight:(short)v
{
    int i;
    ceiling_height = v;
    for (i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}

-(void)setFloorLightsource:(short)v 
{
    //floor_lightsource_index = v;
    if (v == -1)
        floor_lightsource_object = nil;
    else if (everythingLoadedST)
        floor_lightsource_object = [theMapLightsST objectAtIndex:v];
} //

-(void)setCeilingLightsource:(short)v
{
    //ceiling_lightsource_index = v;
    if (v == -1)
        ceiling_lightsource_object = nil;
    else if (everythingLoadedST)
        ceiling_lightsource_object = [theMapLightsST objectAtIndex:v];
} //

-(void)setFirstObject:(short)v 
{
    //first_object_index = v;
    if (v == -1)
        first_object_pointer = nil;
    else if (everythingLoadedST)
        first_object_pointer = [theMapObjectsST objectAtIndex:v];
} //
-(void)setFirstObjectObject:(id)v 
{
    first_object_pointer = v; 
} //

-(void)setAdjacentPolygon:(short)v toIndex:(short)i 
{
    //adjacent_polygon_indexes[i] = v; 
    if (v == -1)
        adjacent_polygon_objects[i] = nil;
    else if (everythingLoadedST)
        adjacent_polygon_objects[i] = [theMapPolysST objectAtIndex:v];
} //
-(void)setAdjacentPolygonObject:(id)v toIndex:(short)i 
{
    adjacent_polygon_objects[i] = v; 
} //

-(void)setFirstNeighbor:(short)v 
{
    //first_neighbor_index = v; 
    if (v == -1)
        first_neighbor_object = nil;
    else if (everythingLoadedST)
        first_neighbor_object = [theMapPolysST objectAtIndex:v];
} //
-(void)setFirstNeighborObject:(id)v 
{
    first_neighbor_object = v;
} //

-(void)setSides:(short)v toIndex:(short)i 
{
    if (v == -1)
        side_objects[i] = nil;
    else if (everythingLoadedST)
        side_objects[i] = [theMapSidesST objectAtIndex:v];
} //
-(void)setSidesObject:(id)v toIndex:(short)i 
{
    side_objects[i] = v;
} //

-(void)setMedia:(short)v { [self setMediaIndex:v]; }
-(void)setMediaIndex:(short)v 
{
    //media_index = v;
    if (v == -1)
        media_object = nil;
    else if (everythingLoadedST)
        media_object = [theMediaST objectAtIndex:v];
} //
@synthesize mediaObject=media_object;

-(void)setMediaLightsource:(short)v 
{ 
    //media_lightsource_index = v; 
    if (v == -1)
        media_lightsource_object = nil;
    else if (everythingLoadedST)
        media_lightsource_object = [theMapLightsST objectAtIndex:v];
} //
@synthesize mediaLightsourceObject=media_lightsource_object;

-(void)setSoundSources:(short)v 
{ 
    sound_source_indexes = v;   //TODO: FIRGURE THIS OUT SOMETIME
} //
@synthesize soundSourcesObject=sound_source_objects;

-(void)setAmbientSound:(short)v 
{ 
    //ambient_sound_image_index = v; 
    if (v == -1)
        ambient_sound_image_object = nil;
    else if (everythingLoadedST)
        ambient_sound_image_object = [theAmbientSoundsST objectAtIndex:v];
} //
@synthesize ambientSoundObject=ambient_sound_image_object;

-(void)setRandomSound:(short)v 
{ 
    //random_sound_image_index = v; 
    if (v == -1)
        random_sound_image_object = nil;
    else if (everythingLoadedST)
        random_sound_image_object = [theRandomSoundsST objectAtIndex:v];
} //
@synthesize randomSoundObject=random_sound_image_object;


// ************************************* Get Accsessors ********************************************************
@synthesize polygonConcaveFlag=polygonConcave;
@synthesize type;
@synthesize flags;

-(short)permutation
{
    ///SEND_ERROR_MSG(@"An obsolet method -(short)permutation was called in a polygon object, this is a possible error!");
    
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        /*NSLog(@"polygonPermutation NSNumber value: %d", [permutationObject shortValue]);*/
        return [permutationObject shortValue];
    }
    
    /*if (permutationObject != nil)
        NSLog(@"polygonPermutation index number: %d", [permutationObject index]);*/
    
    return (permutationObject == nil) ? (-1) : ([(LEMapStuffParent*)permutationObject index]);
}
-(short)getPermutationZero { return (permutationObject == nil) ? (0) : ([self permutation]); } // ***

-(id)permutationObject
{
    if (permutationObject == nil)
        return nil;
    
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        return [permutationObject copy];
    }
    
    return permutationObject;
}

-(short *)getTheVertexes // ********** <-- NEED TO FIX THIS UP FOR NEW OBJECT MODULE!!! *********
{
    int i;
    
    for (i = 0; i < 8; i++)
        vertexIndexes[i] = [self vertexIndexesAtIndex:i];
    
    return vertexIndexes;
}

-(short)getTheVertexCount { // NSLog(@"RETURNING The Poly Vertex Count (poly): %d", vertexCount);
                            return vertexCountForPoly; }

-(short)vertexIndexesAtIndex:(short)i { return (vertexObjects[i] == nil) ? -1 : [vertexObjects[i] index]; }
-(short)lineIndexesAtIndex:(short)i { return (lineObjects[i] == nil) ? -1 : [lineObjects[i] index]; }

-(short)getVertexIndexesZero:(short)i { return (vertexObjects[i] == nil) ? 0 : [vertexObjects[i] index]; }  // ***
-(short)getLineIndexesZero:(short)i { return (lineObjects[i] == nil) ? 0 : [lineObjects[i] index]; }  // ***

-(NSArray *)vertexArray
{
    return [NSArray arrayWithObjects:vertexObjects count:vertexCountForPoly];
}
-(id)vertexObjectAtIndex:(short)i { return vertexObjects[i]; }

-(NSArray *)lineArray
{
    return [NSArray arrayWithObjects:lineObjects count:vertexCountForPoly];
}
-(id)lineObjectAtIndex:(short)i { return lineObjects[i]; }
//-(id)getLineObjects { return lineObjects; }
 
@synthesize floorTexture=floor_texture;
@synthesize ceilingTexture=ceiling_texture;

@synthesize floorHeight=floor_height;
@synthesize ceilingHeight=ceiling_height; 

-(NSDecimalNumber *)floorHeightAsDecimal { return [self divideAndRound:floor_height by:1024]; }
-(NSDecimalNumber *)ceilingHeightAsDecimal { return [self divideAndRound:ceiling_height by:1024]; }

-(NSString *)floorHeightAsDecimalString { return [[self floorHeightAsDecimal] stringValue]; }
-(NSString *)ceilingHeightAsDecimalString { return [[self ceilingHeightAsDecimal] stringValue]; }

-(short)floorLightsourceIndex { return (floor_lightsource_object == nil) ? -1 : [floor_lightsource_object index]; }
-(short)ceilingLightsourceIndex { return (ceiling_lightsource_object == nil) ? -1 : [ceiling_lightsource_object index]; }

-(short)getFloor_lightsource_index_zero { return (floor_lightsource_object == nil) ? 0 : [floor_lightsource_object index]; }  // ***
-(short)getCeiling_lightsource_index_zero { return (ceiling_lightsource_object == nil) ? 0 : [ceiling_lightsource_object index]; }  // ***

@synthesize floorLightsourceObject=floor_lightsource_object;
@synthesize ceilingLightsourceObject=ceiling_lightsource_object;

@synthesize area;
@synthesize firstObjectIndex=first_object_index;
@synthesize firstExclusionZoneIndex=first_exclusion_zone_index;
@synthesize lineExclusionZoneCount=line_exclusion_zone_count;
@synthesize pointExclusionZoneCount=point_exclusion_zone_count;
@synthesize floorTransferMode=floor_transfer_mode;
@synthesize ceilingTransferMode=ceiling_transfer_mode;

-(short)adjacentPolygonIndexesAtIndex:(short)i { return (adjacent_polygon_objects[i] == nil) ? 0 : [adjacent_polygon_objects[i] index]; }  // ***
-(id)adjacentPolygonObjectAtIndex:(short)i { return adjacent_polygon_objects[i]; } //

-(short)firstNeighborIndex { return (first_neighbor_object == nil) ? -1 : [first_neighbor_object index]; } //
-(id)firstNeighborObject { return first_neighbor_object; } // ---

@synthesize neighborCount=neighbor_count;
@synthesize center;

-(short)sideIndexesAtIndex:(short)i { return (side_objects[i] == nil) ? 0 : [side_objects[i] index]; }  // ***
-(id)sideObjectAtIndex:(short)i { return side_objects[i]; } //

@synthesize floorOrigin=floor_origin;
@synthesize ceilingOrigin=ceiling_origin;

-(short)mediaIndex { return (media_object == nil) ? -1 : [media_object index]; } //
-(short)mediaLightsourceIndex { return (media_lightsource_object == nil) ? 0 : [media_lightsource_object index]; }  // ***
-(short)soundSourceIndexes { return sound_source_indexes; } // *** WORK ON THIS ONE ***
-(short)ambientSoundImageIndex { return (ambient_sound_image_object == nil) ? -1 : [ambient_sound_image_object index]; } //
-(short)randomSoundImageIndex { return (random_sound_image_object == nil) ? -1 : [random_sound_image_object index]; } //

// **************************** Polygon Concave Verification ***********************************

-(BOOL)isPolygonConcave
{
    NSEnumerator *numer;
    BOOL /*keepPolyFinding = YES,*/ foundTheLine = NO;
    //BOOL foundSelection = NO
    //BOOL keepFollowingTheLines = YES;
    BOOL lastLineToTest = NO;
    NSInteger indexOfLineFound;
    //int dis1, dis2;
    //NSMutableArray *theMapObjects, *thePolys;
    LEMapPoint *currentLineMainPoint, *currentLineSecondaryPoint;
    //LEMapPoint *curPoint;
    LELine *thisMapLine = nil, *currentLine = nil, *previousLine = nil;
    NSPoint point1, point2;
    
    //New Variables...
    float leftMostX, greatestY, leastY;
    LEMapPoint 	*leftMostPoint/*, *secondLeftMostPoint*/;
    LELine 	*leftMostLine = nil, *thePrevLine = nil;
    BOOL	pointOneGotten = NO, bottomMost = NO, gettingSlope = NO, topMost = NO;
    NSMutableArray *polyLines = [NSMutableArray arrayWithCapacity:8];
    int i;
    double thePrevPointX = 0,thePrevPointY = 0, theMainPointX = 0, theMainPointY = 0;
    
    // Prepeare The Stuff... :)   Draconic... --:=>
    
    ////NSLog(@"Got Thought With Preperations...");
    
    // Find the left most line...
    /*if (theCurPoint.x < -1023)
    {
        keepPolyFinding = NO;
        foundTheLine = NO;
        indexOfLineFound = -1;
        return NO;
    }*/
    
	leftMostX = [vertexObjects[0] x];
	greatestY = [vertexObjects[0] y];
	leastY = [vertexObjects[0] y];
    leftMostPoint = vertexObjects[0];
    for (i = 1; i < vertexCountForPoly; i++) {
        if (vertexObjects[i] != nil) {
            if ([vertexObjects[i] x] < leftMostX) {
                leftMostX = [vertexObjects[i] x];
                leftMostPoint = vertexObjects[i];
                //NSLog(@"Less Then to leftMostX, point index: %d",
                //[theMapPointsST indexOfObjectIdenticalTo:vertexObjects[i]]);
                ////NSLog(@"leftMostX: %d", leftMostX);
            } else if ([vertexObjects[i] x] == leftMostX) {
                leftMostX = [vertexObjects[i] x];
                leftMostPoint = vertexObjects[i];
                //NSLog(@"Equal to leftMostX, point index: %d",
                //[theMapPointsST indexOfObjectIdenticalTo:vertexObjects[i]]);
                /*if ([vertexObjects[i] y] != [leftMostPoint y])
                {
                    // Found It!!!
                    secondLeftMostPoint = vertexObjects[i];
                }
                else// if ([vertexObjects[i] y] == [leftMostPoint y])
                {
                    //This may be illegal, ???
                    [self setPolygonConcaveFlag:NO];
                    return NO;
                }*/
            }
            
			if ([vertexObjects[i] y] > greatestY) // Get The Bottom Most Point...
				greatestY = [vertexObjects[i] y];
            
			if ([vertexObjects[i] y] < leastY) // Get The Top Most Point...
				leastY = [vertexObjects[i] y];
        } else if (vertexObjects[i] == nil) {
            //   not suposed to be nil, error!!!
            // ****************** Somthing Wrong With Polgonal Data!!! **********************
            // Invalidate the polygon here!!!
            // Data inregertiy for this polygon is corupted!!!
            NSLog(@"vertextObject nil when it was not suposed to be...?");
            [self setPolygonConcaveFlag:NO];
            return NO;
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Generic Error";
            alert.informativeText = @"Somthing wrong with program logic!!! MAJOR, proably even FATEL error!!!";
            alert.alertStyle = NSAlertStyleInformational;
            [alert runModal];
            [self setPolygonConcaveFlag:NO];
            return NO; // What would bring it here?
        }
    } // END FOR
    
    if (leftMostPoint == nil)
      NSLog(@"Polygon %d had No Left Most Point???", [self index]);
        
  // NSLog(@"It's Point Indexes for leftMostPointIndex: %d", [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]);
    
	bottomMost = (BOOL)(greatestY == [leftMostPoint y]);
	topMost =  (BOOL)(leastY == [leftMostPoint y]);
    
    //   See if the Left Point Object is the same object
    //   as one of the point objects for this line...
    for (i = 0; i < vertexCountForPoly; i++)
    {
        BOOL foundTheLine = NO;
      // NSLog(@"Tesing Line %d", [lineObjects[i] index]);
      // NSLog(@"It's Point Indexes are p1: %d p2: %d leftMostPointIndex: %d", [theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] mapPoint1]], [theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] mapPoint2]], [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]);
        
        if (([theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] mapPoint1]] == [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]) || ([theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] mapPoint2]] == [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]))
        {
            //NSLog(@"Line %d passed", [lineObjects[i] index]);
            
            
			if ([[lineObjects[i] mapPoint1] y] != [[lineObjects[i] mapPoint2] y])
            {
                id theCurSecPoint;
                
                if (pointOneGotten && !gettingSlope)
                {
                    foundTheLine = YES;
                  // NSLog(@"foundTheLine set to YES at Begining");
                }
                // *** See which point is the secondary point ***
                if (leftMostPoint == [lineObjects[i] mapPoint2])
                {
                    theCurSecPoint = [lineObjects[i] mapPoint1];
                }
                else if  (leftMostPoint == [lineObjects[i] mapPoint1])
                {
                    theCurSecPoint = [lineObjects[i] mapPoint2];
                }
                else
                {
                    NSLog(@"ERROR, polygon %d is not concave due to programming logic mistake!", [self index]);
                    [self setPolygonConcaveFlag:NO];
                    return NO;
                }
                
                // *** do the slope checking, etc... ***
                
                if ((topMost || bottomMost) && !pointOneGotten && !gettingSlope) {
					thePrevPointY = [theCurSecPoint y];
					thePrevPointX = [theCurSecPoint x];
					theMainPointX = [leftMostPoint x];
					theMainPointY = [leftMostPoint y];
                    gettingSlope = YES;
                    thePrevLine = lineObjects[i];
                  // NSLog(@"Found a line 1 for slop check, line %d", [lineObjects[i] index]);
                } else if ((topMost || bottomMost) && pointOneGotten && gettingSlope) {
                    double previousX = thePrevPointX - theMainPointX; //
                    double previousY = thePrevPointY - theMainPointY; //
					double thisX = [theCurSecPoint x] - theMainPointX;
					double thisY = [theCurSecPoint y] - theMainPointY; //
                    
                    double slope = previousY / previousX;
                    double theXfromSlope = thisY / slope;
                  // NSLog(@"F previousY: %g previousX: %g", previousY, previousX);
                  // NSLog(@"F slope: %g theY: %g", slope, thisY);
                  // NSLog(@"F theXfromSlop: %g", theXfromSlope);

                    if (thisX < theXfromSlope) { // other one ok
                        foundTheLine = YES;
                    } else if (thisX > theXfromSlope) { //this one ok
                        //Found A Qualified Left Most Line!!!
                        leftMostLine = thePrevLine;
                        indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                        currentLine = leftMostLine;
                        //foundTheLine = YES;
                      // NSLog(@"1-1 Found a line, line %d", [leftMostLine index]);
                        break;
                    } else { // if (thisX == theXfromSlope)
                        // ???
                      // NSLog(@"???, the First Slope Check Equal Each Other (thisX == theXfromSlope)");
                        foundTheLine = YES;
                    }
                }
                
                if (pointOneGotten || !(topMost || bottomMost) /* || (slope check thingy) */ ) {
                    foundTheLine = YES;
                  // NSLog(@"foundTheLine set to YES at END");
                }
            } else if ((topMost || bottomMost) && pointOneGotten) {
                //Found A Qualified Left Most Line!!!
                leftMostLine = thePrevLine;
                indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                currentLine = leftMostLine;
                //foundTheLine = YES;
              // NSLog(@"1-1 Found a line, line %d", [leftMostLine index]);
                break;
            }
            
            if (foundTheLine) {
                    //Found A Qualified Left Most Line!!!
                    leftMostLine = lineObjects[i];
                    indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                    currentLine = leftMostLine;
                  // NSLog(@"2 Found a line(*), line %d", [leftMostLine index]);
                    break;
            } else if (pointOneGotten) {
                //of the two lines from that point
                //both are not qualified?
                NSLog(@"Sorry, but could not determin if polygon %d was concave, the left most points lines were not qualified?", [self index]);
                //[self setPolygonConcaveFlag:NO];
                //return NO;
                leftMostLine = lineObjects[i];
                indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                currentLine = leftMostLine;
                foundTheLine = YES;
                // NSLog(@"Found a line, line %d", [leftMostLine index]);
                break;
            }
            
            pointOneGotten = YES;
        } else { //previouse if was the one checking to see if points belong to the line...
            
        }
    }
    
    for (i = 0; i < vertexCountForPoly; i++) {
        if (lineObjects[i] == nil)
            NSLog(@"A line in the polgon line object array is NILL, This hsould of never have happened, Major Error!!!");
        else
            [polyLines addObject:lineObjects[i]];
    }
    
    ////NSLog(@"Got Thought With Line Finding...");
     
    // If the line was not found, return NO...
    if (!foundTheLine && currentLine == nil)
    {
        NSLog(@"Left Most Line Was Not Found To Begin Concave Checking With");
        [self setPolygonConcaveFlag:NO];
        return NO;
    }
    
    // If line was found, follow it around, always choosing
    // the inner most line, to see if it completes a polygon...
    
    //get The line disteance in world_units/32 from upper left corner of grid
    
    point1 = [[theMapPointsST objectAtIndex:[currentLine pointIndex1]] asPoint];
    point2 = [[theMapPointsST objectAtIndex:[currentLine pointIndex2]] asPoint];
    
    if (point1.y < point2.y) {
        currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
        currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
    } else if (point1.y > point2.y) {
        currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
        currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
    } else {
        if (point1.x > point2.x) {
            currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
            currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
        } else {
            currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
            currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
        }
    }
    
    // NSLog(@"currentLineMainPoint index: %d",
            // [theMapPointsST indexOfObjectIdenticalTo:currentLineMainPoint]);
    // NSLog(@"currentLineSecondaryPoint index: %d",
            // [theMapPointsST indexOfObjectIdenticalTo:currentLineSecondaryPoint]);
    // NSLog(@"currentLine: %d", [currentLine index]);
    
    //while (keepFollowingTheLines)
    for (i = 0; i < vertexCountForPoly; i++) {
        LELine *smallestLine, *tmpLine;
        LEMapPoint *nextMainPoint;
        NSInteger smallestLineIndex = -1, nextMainPointIndex = -1;
        double smallestAngle = 181.0;
        LEMapPoint *theCurPoint1;
        LEMapPoint *theCurPoint2;
        LEMapPoint *theCurPoint;
        
        smallestLine = nil;
        nextMainPoint = nil;
        
        //theConnectedLines = [currentLineMainPoint getLinesAttachedToMe];
        
        numer = [polyLines objectEnumerator];
        for (tmpLine in numer) {
            if ((([tmpLine mapPoint1] == currentLineMainPoint) || //Used to be [currentLine getMapPoint1]
                ([tmpLine mapPoint2] == currentLineMainPoint)) && //Used to be [currentLine mapPoint2]
                    (tmpLine != currentLine)) {
                thisMapLine = tmpLine;
                break;
            }
        }
        

        ////NSLog(@"Found connected lines, processesing them now...");
        
        previousLine = nil; // Just to make sure...
            
        theCurPoint1 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex1]];
        theCurPoint2 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex2]];
        
        if (theCurPoint1 == currentLineMainPoint)
        {
            theCurPoint = theCurPoint2;
        }
        else
        {
            theCurPoint = theCurPoint1;
        }
        
      // NSLog(@"Analyzing line: %d", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine]);
        
        if (thisMapLine != currentLine) // Just to make sure...
        {
            if (theCurPoint != nil) // Just to make sure...
            {
                double previousX, previousY, thisX, thisY;
                double prevX, prevY, theX, theY;
                double prevLength, theLength;
                double theta, alpha, thetaRad, tango;
                double xrot, yrot;
                double slope, theXfromSlop;
                short newX, newY, newPrevX, newPrevY;
                BOOL slopeChecksOut = NO;

				previousX = [currentLineSecondaryPoint x] - [currentLineMainPoint x];
				previousY = [currentLineSecondaryPoint y] - [currentLineMainPoint y];
				thisX = [theCurPoint x] - [currentLineMainPoint x];
				thisY = [theCurPoint y] - [currentLineMainPoint y];
                prevX = previousX;
                prevY = previousY;
                theX = thisX;
                theY = thisY;
                
              // NSLog(@"previousY: %g previousX: %g", previousY, previousX);
                slope = previousY / previousX;
              // NSLog(@"slope: %g theY: %g", slope, theY);
                theXfromSlop = theY / slope;
              // NSLog(@"theXfromSlop: %g", theXfromSlop);
                
                prevLength = sqrt( previousX * previousX + previousY * previousY );
                previousX /= prevLength;
                previousY /= prevLength;

                theLength = sqrt( thisX * thisX + thisY * thisY );
                thisX /= theLength;
                thisY /= theLength;

                theta = (double)previousX * (double)thisX + (double)previousY * (double)thisY;
              // NSLog(@"Angleized Line Index: %d  theta: %g", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine], theta);
                alpha = theta;
                tango = theta;
                theta = acos(theta);
                thetaRad = theta;
                theta = theta * 180.0 / M_PI;
                alpha = asin(alpha);
                alpha = alpha * 180.0 / M_PI;
                tango = atan(tango);
                tango = tango * 180.0 / M_PI;
                // NSLog(@"Angleized Line Index: %d  Alpha: %g Tango: %g", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine], alpha, tango);
                xrot = theX * cos(thetaRad) - theY * sin(thetaRad);
                yrot = theX * sin(thetaRad) + theY * cos(thetaRad);
                // NSLog(@"Angleized Line Index: %d  with BEFORE rot ( %f, %f)", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine], xrot, yrot);

                newX = (short) xrot;
                newY = (short) yrot;
                newPrevX = (short)prevX;
                newPrevY = (short)prevY;
                xrot = (double)newX / theLength;
                yrot = (double)newY / theLength;
                // NSLog(@"Angleized Line Index: %d  With Angle Of: %g with rot ( %f, %f)",
                    // [theMapLinesST indexOfObjectIdenticalTo:thisMapLine], theta, xrot, yrot);
                
                
                if (theta != 180.0) {
                      // NSLog(@"For Line %d  theX: %g theY: %g", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine], theX, theY);
                        if (0 < prevY) // Main Point Lower
                        {
                            if (theX >= theXfromSlop) //ok
                            {
                                // NSLog(@"For Line %d  (1) ", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine]);
                                slopeChecksOut = YES;
                            }
                        }
                        else if (0 > prevY) // Main Point Higher
                        {
                            if (theX <= theXfromSlop) //ok
                            {
                                // NSLog(@"For Line %d  (2) ", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine]);
                                slopeChecksOut = YES;
                            }
                        }
                        else // equals
                        {
                            if (0 > prevX) // Main Point Higher
                            {
                                if (theY >= prevY) //ok
                                {
                                    // NSLog(@"For Line %d  (3) ", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine]);
                                    slopeChecksOut = YES;
                                }
                            }
                            else if (prevX > 0) // Main Point Higher
                            {
                                if (theY <= prevY) //ok
                                {
                                    // NSLog(@"For Line %d  (4) ", [theMapLinesST indexOfObjectIdenticalTo:thisMapLine]);
                                    slopeChecksOut = YES;
                                }
                            }
                        }
                }
                else if (theta == 180.0)
                {
                    slopeChecksOut = YES;
                }
                
                if ( theta <= 180.0 /*&& theta < smallestAngle*/ && slopeChecksOut)
                {
                    smallestLine = thisMapLine;
                    smallestLineIndex = [theMapLinesST indexOfObjectIdenticalTo:thisMapLine];
                    smallestAngle = theta;
                    nextMainPoint = theCurPoint;
                    nextMainPointIndex = [theMapPointsST indexOfObjectIdenticalTo:theCurPoint];
                        
                    // NSLog(@"Lowest Line Index: %d  With Angle Of: %g", smallestLineIndex, smallestAngle);
                }// End if ( theta <= 180.0 && theta < smallestAngle && [theCurPoint x] >= [firstPoint x])
                else
                {
                    /*if (slopeChecksOut)
                        NSLog(@"For polygon %d, line %d angle was not correct, not concave, theta: %f  slopeChecksOut TRUE",
                            [self index], [thisMapLine index], theta);
                    else
                        NSLog(@"For polygon %d, line %d angle was not correct, not concave, theta: %f  slopeChecksOut FALSE",
                            [self index], [thisMapLine index], theta);*/
                    [self setPolygonConcaveFlag:NO];
                    return NO; // It is not concave!!!
                }
            } // End if (theCurPoint != nil)
        } // End if (currentLine != thisMapLine)
        
        if (smallestLine == nil)
        {
            NSLog(@"Major Error, smallestLine == nil, but already tested for that, polygon not conave just in case...");
            [self setPolygonConcaveFlag:NO];
            return NO; // Should of never reached this point, but just in case...
        }
        
        // NSLog(@"After a angle finding session");
        
        if (lastLineToTest)
        {
            // Test to see and confirm that the line it choose is the same
            // as the first line that was found... 
            ////NSLog(@"Second Phase Almost Complete...");
            if (smallestLine != leftMostLine)
            {
                NSLog(@"Line was not qulified becuase I could not confirm that last line is the same line as the first one...");
                [self setPolygonConcaveFlag:NO];
                return NO;
            }
            
            // *** the polygon is as far as I know concave! ***
          // NSLog(@"Poly %d Concave M1", [self index]);
            [self setPolygonConcaveFlag:YES];
            return YES;
        }
        else
        {                
            // Need to see if the next main point is the same point as the first one...
            if (leftMostPoint == nextMainPoint)
            {                
                // Make the current main vector secondary, make new vector the main vector...
                currentLineSecondaryPoint = currentLineMainPoint;
                currentLineMainPoint = nextMainPoint;
                //Make The Next Current Line the one just found...
                currentLine = smallestLine;
                lastLineToTest = YES;
            }
            else
            { // Polygon Not Yet Completed...                
                // Make the current main vector secondary, make new vector the main vector...
                currentLineSecondaryPoint = currentLineMainPoint;
                currentLineMainPoint = nextMainPoint;
                //Make The Next Current Line the one just found...
                currentLine = smallestLine;
            }
        } // End if (lastLineToTest) else
    } // End while (keepFollowingTheLines)
    
    // *** the polygon is as far as I know concave! ***
  // NSLog(@"Poly %d Concave M2", [self index]);
    [self setPolygonConcaveFlag:YES];
    return YES;
    
} // End -(BOOL)isPolygonConcave


@end
