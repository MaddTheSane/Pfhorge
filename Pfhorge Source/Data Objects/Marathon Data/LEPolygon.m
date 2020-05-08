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

#import "LEPolygon.h"
#import "LEMapPoint.h"
#import "LELine.h"
#import "LEMapObject.h"
#import "PhPlatform.h"
#import "LELevelData.h"

#import "PhAbstractName.h"

#import "PhLayer.h"

#import "LEExtras.h"

#import "PhData.h"

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
	
	if (ceiling_transfer_mode != 9)
	{
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
    if (type == _polygon_is_platform)
    {
        [permutationObject displayInfo];
    }
    else
    {
        SEND_INFO_MSG_TITLE(@"Only platform polygons support this for right now...", @"Detailed Polygon Info");
    }
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Polygon Index: %d   Layer: %@", [self getIndex], [polyLayer getPhName], nil];
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
    
    if (theNumber != NSNotFound)
    {
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
    
    switch (type)
    {
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
    }
    
    switch (type)
    {
        /*case _polygon_is_base:
            tmpShort = 0;
            encodeShort(coder, tmpShort);
            break;*/
        case _polygon_is_light_on_trigger:
        case _polygon_is_platform_on_trigger:
        case _polygon_is_light_off_trigger:
        case _polygon_is_platform_off_trigger:
        case _polygon_is_teleporter:
            ExportObjPos(permutationObject);
            break;
        case _polygon_is_automatic_exit:
            tmpShort = [permutationObject shortValue];
            ExportShort(tmpShort);
            break;
        case _polygon_is_platform:
            //ExportObjPos(permutationObject);
            ExportObj(permutationObject);
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
    
    for (i = 0; i < 8; i++)
    {
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
    
    NSLog(@"Exporting Polygon: %d  -- Position: %lu --- myData: %lu", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: polygon %d was not at the end of the index... myPosition = %ld", [self getIndex], (long)myPosition);
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
    
    NSLog(@"Importing Polygon: %d  -- Position: %lu  --- Length: %ld", [self getIndex], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
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
    

    switch (type)
    {
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
            [permutationObject retain];
            break;
        case _polygon_is_platform:
            ImportObj(permutationObject);
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
    int tmpShort;
    
    [super encodeWithCoder:coder];
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
        }
    }
    else
    {
		if (type != _polygon_is_automatic_exit/* || type != _polygon_is_base*/) {
            encodeObj(coder, permutationObject);
		} else
        {
            short tmpn = [permutationObject shortValue];
            encodeShort(coder, tmpn);
        }
    }
    
    
    encodeShort(coder, vertexCountForPoly);
    
    for (i = 0; i < vertexCountForPoly; i++)
    {
        if (useIndexNumbersInstead)
        {
            NSLog(@"POLYGON: vertexObjects[%d]: %d", i, [vertexObjects[i] getIndex]);
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
        
        if (useIndexNumbersInstead)
        {
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
    
    if (useIndexNumbersInstead)
    {
        tmpShort = GetIndexAdv(floor_lightsource_object);
        encodeShort(coder, tmpShort);
        tmpShort = GetIndexAdv(ceiling_lightsource_object);
        encodeShort(coder, tmpShort);
    }
    else
    {
        encodeObj(coder, floor_lightsource_object);
        encodeObj(coder, ceiling_lightsource_object);
    }
    
    encodeLong(coder, area);
    
    if (!useIndexNumbersInstead)
    {
        encodeObj(coder, first_object_pointer);
        
        encodeObj(coder, first_exclusion_zone_object);
        encodeShort(coder, line_exclusion_zone_count);
        encodeShort(coder, point_exclusion_zone_count);
    }
    
    encodeShort(coder, floor_transfer_mode);
    encodeShort(coder, ceiling_transfer_mode);
    
    if (!useIndexNumbersInstead)
    { 
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

- (id)initWithCoder:(NSCoder *)coder
{
    int i;
    
    int versionNum = 0;
    self = [super initWithCoder:coder];
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
        }
    }
    else
    {
        if (_polygon_is_automatic_exit == type   /*[permutationObject isKindOfClass:[NSNumber class]]*/)
        {
            if (versionNum < 1)
            {
                decodeObj(coder);
                permutationObject = [numShort(256) copy];
            }
            else
                permutationObject = [numShort(decodeShort(coder)) copy];
        }
        else
            permutationObject = decodeObj(coder);
    }
    vertexCountForPoly = decodeShort(coder);
    //NSLog(@"decode vertexCountForPoly: %d", vertexCountForPoly);
    for (i = 0; i < vertexCountForPoly; i++)
    {
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
    
    if (useIndexNumbersInstead)
    {
        floor_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
        ceiling_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
    }
    else
    {
        floor_lightsource_object = decodeObj(coder);
        ceiling_lightsource_object = decodeObj(coder);
    }
    
    area = decodeLong(coder);
    
    if (!useIndexNumbersInstead)
    {
        first_object_pointer = decodeObj(coder);
        
        first_exclusion_zone_object = decodeObj(coder);
        line_exclusion_zone_count = decodeShort(coder);
        point_exclusion_zone_count = decodeShort(coder);
    }
    
    floor_transfer_mode = decodeShort(coder);
    ceiling_transfer_mode = decodeShort(coder);
    
    if (!useIndexNumbersInstead)
    {
        first_neighbor_object = decodeObj(coder);
        neighbor_count = decodeShort(coder);
    }
    
    center.x = decodeInt(coder);
    center.y = decodeInt(coder);
    
    floor_origin.x = decodeInt(coder);
    floor_origin.y = decodeInt(coder);
    
    ceiling_origin.x = decodeInt(coder);
    ceiling_origin.y = decodeInt(coder);
    
    if (useIndexNumbersInstead)
    {
        media_object = [self getMediaFromIndex:decodeShort(coder)];
        media_lightsource_object = [self getLightFromIndex:decodeShort(coder)];
    }
    else
    {
        media_object = decodeObj(coder);
        media_lightsource_object = decodeObj(coder);
        
        sound_source_objects = decodeObj(coder);
    }
    
    if (useIndexNumbersInstead)
    {
        ambient_sound_image_object = [self getAmbientSoundFromIndex:decodeShort(coder)];
        random_sound_image_object = [self getRandomSoundFromIndex:decodeShort(coder)];
    }
    else
    {
        ambient_sound_image_object = decodeObj(coder);
        random_sound_image_object = decodeObj(coder);
    }
    
    //if (useIndexNumbersInstead)
    //    [theLELevelDataST addPolygonDirectly:self];
    
    //useIndexNumbersInstead = NO;
    
    
        switch (type)
        {
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
        }
    
    return self;
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
    if (self != nil)
    {
        int i;
        
        useIndexNumbersInstead = NO;
        
        [self setVertextCount:0];
        for(i = 0; i < 8; i++)
        {
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
    
    [super dealloc];
}

-(BOOL)uses:(id)theObj
{
    if ([theObj isKindOfClass:[LEMapPoint class]])
    {
        int i;
        for(i = 0; i < vertexCountForPoly; i++)
            if (vertexObjects[i] == theObj) return YES;
    }
    else if ([theObj isKindOfClass:[LELine class]])
    {
        int i;
        for(i = 0; i < vertexCountForPoly; i++)
            if (lineObjects[i] == theObj) return YES;
    }
    else if ([theObj isKindOfClass:[LEPolygon class]])
    {
        return NO; // might want to check clockwise/counterclockwise stuff...
    }
    else if ([theObj isKindOfClass:[LEMapObject class]])
    {
        return NO; // check if object in this polygon?
    }
    return NO;      
}

-(short) getIndex { return [theMapPolysST indexOfObjectIdenticalTo:self]; }

// ****************** Texture Methods ********************
#pragma mark -
#pragma mark ********* Texture Methods *********

-(void)setCeilingTextureOnly:(char)number
{
    char *theTexChar = (char *)&ceiling_texture;
    (theTexChar)[1] = number;
}

-(void)setFloorTextureOnly:(char)number
{ 
    char *theTexChar = (char *)&floor_texture;
    (theTexChar)[1] = number;
}

-(void)setCeilingTextureCollectionOnly:(char)number
{
    char *theTexChar = (char *)&ceiling_texture;
    (theTexChar)[0] = number + 0x11;
}

-(void)setFloorTextureCollectionOnly:(char)number
{ 
    char *theTexChar = (char *)&floor_texture;
    (theTexChar)[0] = number + 0x11;
}

-(void)resetTextureCollectionOnly
{ 
    // For right now it just sets it to the current levels
    // collection.
    char *theFTexChar = (char *)&floor_texture;
    char *theCTexChar = (char *)&ceiling_texture;
    short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (theFTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theCTexChar)[0] = (0x11 + theCurrentEnviroCode);
}

-(void)setTextureCollectionOnly:(char)number
{ 
    char *theFTexChar = (char *)&floor_texture;
    char *theCTexChar = (char *)&ceiling_texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    (theFTexChar)[0] = (0x11 + number);
    (theCTexChar)[0] = (0x11 + number);
}

-(char)ceilingTextureOnly
{
    char *theTexChar = (char *)&ceiling_texture;
    return (theTexChar)[1];
}

-(char)floorTextureOnly
{ 
    char *theTexChar = (char *)&floor_texture;
    return (theTexChar)[1];
}

-(char)ceilingTextureCollectionOnly
{
    char *theTexChar = (char *)&ceiling_texture;
    return (theTexChar)[0] - 0x11;
}

-(char)floorTextureCollectionOnly
{ 
    char *theTexChar = (char *)&floor_texture;
    return (theTexChar)[0] - 0x11;
}

// I would not reccemend using this function any more, since the ceiling could be diffrent.
// Before it was assumed that the floor and ceiling would be in the same colleciton,
// that assumtion can not be made anymore...
-(char)textureCollectionOnly
{ 
    char *theFTexChar = (char *)&floor_texture;
    //char *theCTexChar = (char *)&ceiling_texture;
    //short theCurrentEnviroCode = [theLELevelDataST environmentCode];
    return (theFTexChar)[0] - 0x11;
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
    int i;
    for (i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}

-(void)copySettingsTo:(id)target
{
    LEPolygon *theTarget = (LEPolygon *)target;
    id tempPermutationObj = nil;
    int thePreviousType = [theTarget getType];
    
    [theTarget setMediaObject:media_object];
    [theTarget setMedia_lightsourceObject:media_lightsource_object];
    [theTarget setAmbient_soundObject:ambient_sound_image_object];
    [theTarget setRandom_soundObject:random_sound_image_object];
    
    [theTarget setFloor_origin:floor_origin];
    [theTarget setCeiling_origin:ceiling_origin];
    
    [theTarget setType:type];
    [theTarget setFlags:flags];
    
	// NEED: to add and rememove the platform from the level also...
	
	
    if (thePreviousType == _polygon_is_platform && type != _polygon_is_platform)
    {
        [theTarget releasePlatform];
    }
    
    switch (type)
    {
        case _polygon_is_platform:
            if ([permutationObject class] == [PhPlatform class])
            {
				if ([theTarget getPermutationObject] != nil)
				{
					if ([[theTarget getPermutationObject] class] == [PhPlatform class])
					{
						tempPermutationObj = [theTarget getPermutationObject];
						[permutationObject copySettingsTo:tempPermutationObj];
					}
					else
					{
						tempPermutationObj = [permutationObject copy];
							/* copy method should automatically do this */
						//[permutationObject copySettingsTo:tempPermutationObj];
						[tempPermutationObj setPolygonObject:theTarget];
					}
				}
				else
				{
					tempPermutationObj = [permutationObject copy];
						/* copy method should automatically do this */
					//[permutationObject copySettingsTo:tempPermutationObj];
					[tempPermutationObj setPolygonObject:theTarget];
				}
            }
            else
            {
                SEND_ERROR_MSG(@"When copying settings to a new platform, the orginal platfrom was nil, Default Polygon Subroutine Error!!!");
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
    
    [theTarget setFloor_height_no_sides:floor_height];
    [theTarget setCeiling_height:ceiling_height];
    
    [theTarget setFloor_lightsourceObject:floor_lightsource_object];
    [theTarget setCeiling_lightsourceObject:ceiling_lightsource_object];
    [theTarget setArea:area];
    [theTarget setFirst_objectObject:first_object_pointer];
    [theTarget setFloor_transfer_mode:floor_transfer_mode];
    [theTarget setCeiling_transfer_mode:ceiling_transfer_mode];
    [theTarget setCenter:center];
}

-(int)getLineNumberFor:(LELine *)theLine
{
    int i;
    for (i = 0; i < vertexCountForPoly; i++)
    {
        if (lineObjects[i] == theLine)
        return i;
    }
    return -1;
}

-(void)setLightsThatAre:(id)theLightInQuestion to:(id)setToLight
{
    if (floor_lightsource_object == theLightInQuestion)
        floor_lightsource_object = setToLight;
    
    if (ceiling_lightsource_object == theLightInQuestion)
        ceiling_lightsource_object = setToLight;
}

-(void)thePolyMap:(NSBezierPath *)poly
{
    short i;
        
    //If there is not at least 3 points, there can be no polygon as far as marathon is concerned (in theory) :)
    if (vertexCountForPoly > 2) 
    {
        [poly moveToPoint:[vertexObjects[0] as32Point]];
        for (i = 1; i < vertexCountForPoly; i++)
        {            
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
    for(i = 0; i < vertexCountForPoly; i++)
        if (lineObjects[i] == theLine)
            lineObjects[i] = nil;
}

-(void)removePointAssotication:(LELine *)theLine
{
        int i;
        for(i = 0; i < vertexCountForPoly; i++)
            if (vertexObjects[i] == theLine)
                vertexObjects[i] = nil;
}

-(void)removeAssoticationOf:(id)theObj
{
    int i;
    
    if ([theObj isKindOfClass:[LEPolygon class]])
    {
        for(i = 0; i < 8; i++)
        {
            if (adjacent_polygon_objects[i] == theObj)
                adjacent_polygon_objects[i] = nil;
        }
    }
    else if ([theObj isKindOfClass:[LELine class]])
    {
        for(i = 0; i < vertexCountForPoly; i++)
        {
            if (lineObjects[i] == theObj)
                lineObjects[i] = nil;
        }
    }
    else if ([theObj isKindOfClass:[LEMapPoint class]])
    {
        for(i = 0; i < vertexCountForPoly; i++)
        {
            if (vertexObjects[i] == theObj)
                vertexObjects[i] = nil;
            }
    }
    
    return;
}

-(void)setAllAdjacentPolygonPointersToNil
{
    int i;
    for(i = 0; i < 8; i++)
    {
        adjacent_polygon_objects[i] = nil;
    }
}

// ****************** Polygon Layer *********************
#pragma mark -
#pragma mark ********* Polygon Layer *********
-(PhLayer *)polyLayer
{
    return polyLayer;
}
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
    
    for (i = 1; i < vertexCountForPoly; i++)
    {
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
    
    //If there is not at least 3 points, there can be no polygon as far as marathon is concerned (in thory) :)
    if (vertexCountForPoly > 2) 
    {
        for (i = 0; i < vertexCountForPoly; i++)
        {
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
-(void)setPolygonConcaveFlag:(BOOL)v { polygonConcave = v; }

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

-(void)setFlags:(LEPolygonFlags)v { flags = v; }
-(void)setPermutation:(short)v
{
    /*if (type == _polygon_is_platform)
    {
        
    }
    else*/
    SEND_ERROR_MSG(@"An obsolet method setPermutation:(short)v was called in a polygon object, this is a possible error!");
    //permutation = v;
}

-(void)setPermutationObject:(id)theObject
{
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        [permutationObject release];
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

-(void)setV1:(short)v { [self setVertexWith:v i:0];  } //
-(void)setV2:(short)v { [self setVertexWith:v i:1];  } //
-(void)setV3:(short)v { [self setVertexWith:v i:2];  } //
-(void)setV4:(short)v { [self setVertexWith:v i:3];  } //
-(void)setV5:(short)v { [self setVertexWith:v i:4];  } //
-(void)setV6:(short)v { [self setVertexWith:v i:5];  } //
-(void)setV7:(short)v { [self setVertexWith:v i:6];  } //
-(void)setV8:(short)v { [self setVertexWith:v i:7];  } //


-(void)setVertexWith:(short)v i:(short)i
{
    //vertexIndexes[i] = v;
    if (v == -1)
        vertexObjects[i] = nil;
    else if (everythingLoadedST)
        vertexObjects[i] = [theMapPointsST objectAtIndex:v];
} //

-(void)setVertexWithObject:(id)v i:(short)i
{
    vertexObjects[i] = v;
} //

-(void)setLines:(short)v i:(short)i 
{
    //lineIndexes[i] = v;
    
    if (v == -1)
        lineObjects[i] = nil;
    else if (everythingLoadedST)
        lineObjects[i] = [theMapLinesST objectAtIndex:v];
} //
-(void)setLinesObject:(id)v i:(short)i 
{
    
    lineObjects[i] = v;
} //
-(void)setFloorTexture:(short)v { floor_texture = v; }
-(void)setCeilingTexture:(short)v { ceiling_texture = v; }

-(void)setFloor_height_no_sides:(short)v { floor_height = v; }
-(void)setCeiling_height_no_sides:(short)v { ceiling_height = v; }

-(void)setFloor_height:(short)v
{
    int i;
    floor_height = v;
    for (i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}
-(void)setCeiling_height:(short)v
{
    int i;
    ceiling_height = v;
    for (i = 0; i < vertexCountForPoly; i++)
        [lineObjects[i] caculateSides];
}

-(void)setFloor_lightsource:(short)v 
{
    //floor_lightsource_index = v; 
    if (v == -1)
        floor_lightsource_object = nil;
    else if (everythingLoadedST)
        floor_lightsource_object = [theMapLightsST objectAtIndex:v];
} //
-(void)setFloor_lightsourceObject:(id)v 
{ 
    floor_lightsource_object = v; 
} //

-(void)setCeiling_lightsource:(short)v
{ 
    //ceiling_lightsource_index = v; 
    if (v == -1)
        ceiling_lightsource_object = nil;
    else if (everythingLoadedST)
        ceiling_lightsource_object = [theMapLightsST objectAtIndex:v];
} //
-(void)setCeiling_lightsourceObject:(id)v 
{ 
    ceiling_lightsource_object = v; 
    
} //

-(void)setArea:(int)v { area = v; }

-(void)setFirst_object:(short)v 
{ 
    //first_object_index = v; 
    if (v == -1)
        first_object_pointer = nil;
    else if (everythingLoadedST)
        first_object_pointer = [theMapObjectsST objectAtIndex:v];
} //
-(void)setFirst_objectObject:(id)v 
{ 
    first_object_pointer = v; 
} //

-(void)setFirst_exclusion_zone_index:(short)v { first_exclusion_zone_index = v; }
-(void)setLine_exclusion_zone_count:(short)v { line_exclusion_zone_count = v; }
-(void)setPoint_exclusion_zone_count:(short)v { point_exclusion_zone_count = v; }
-(void)setFloor_transfer_mode:(short)v { floor_transfer_mode = v; }
-(void)setCeiling_transfer_mode:(short)v { ceiling_transfer_mode = v; }

-(void)setAdjacent_polygon:(short)v i:(short)i 
{ 
    //adjacent_polygon_indexes[i] = v; 
    if (v == -1)
        adjacent_polygon_objects[i] = nil;
    else if (everythingLoadedST)
        adjacent_polygon_objects[i] = [theMapPolysST objectAtIndex:v];
} //
-(void)setAdjacent_polygonObject:(id)v i:(short)i 
{ 
    adjacent_polygon_objects[i] = v; 
} //

-(void)setFirst_neighbor:(short)v 
{ 
    //first_neighbor_index = v; 
    if (v == -1)
        first_neighbor_object = nil;
    else if (everythingLoadedST)
        first_neighbor_object = [theMapPolysST objectAtIndex:v];
} //
-(void)setFirst_neighborObject:(id)v 
{ 
    first_neighbor_object = v; 
} //

-(void)setNeighbor_count:(short)v { neighbor_count = v; }
-(void)setCenter:(NSPoint)v { center = v; }

-(void)setSides:(short)v i:(short)i 
{
    //side_indexes[i] = v; 
    
    side_objects[i] = nil;
    return;
    
    if (v == -1)
        side_objects[i] = nil;
    else if (everythingLoadedST)
        side_objects[i] = [theMapSidesST objectAtIndex:v];
} //
-(void)setSidesObject:(id)v i:(short)i 
{ 
    side_objects[i] = nil;
    return;
    
    side_objects[i] = v; 
} //

-(void)setFloor_origin:(NSPoint)v { floor_origin = v; }
-(void)setCeiling_origin:(NSPoint)v { ceiling_origin = v; }

-(void)setMedia:(short)v { [self setMediaIndex:v]; }
-(void)setMediaIndex:(short)v 
{ 
    //media_index = v; 
    if (v == -1)
        media_object = nil;
    else if (everythingLoadedST)
        media_object = [theMediaST objectAtIndex:v];
} //
-(void)setMediaObject:(id)v 
{ 
    media_object = v; 
    
} //

-(void)setMedia_lightsource:(short)v 
{ 
    //media_lightsource_index = v; 
    if (v == -1)
        media_lightsource_object = nil;
    else if (everythingLoadedST)
        media_lightsource_object = [theMapLightsST objectAtIndex:v];
} //
-(void)setMedia_lightsourceObject:(id)v 
{ 
    media_lightsource_object = v; 
    
} //

-(void)setSound_sources:(short)v 
{ 
    sound_source_indexes = v;   // ******** FIRGURE THIS OUT SOMETIME *********
} //
-(void)setSound_sourcesObject:(id)v 
{ 
    sound_source_objects = v;
} //

-(void)setAmbient_sound:(short)v 
{ 
    //ambient_sound_image_index = v; 
    if (v == -1)
        ambient_sound_image_object = nil;
    else if (everythingLoadedST)
        ambient_sound_image_object = [theAmbientSoundsST objectAtIndex:v];
} //
-(void)setAmbient_soundObject:(id)v 
{ 
    ambient_sound_image_object = v; 
    
} //

-(void)setRandom_sound:(short)v 
{ 
    //random_sound_image_index = v; 
    if (v == -1)
        random_sound_image_object = nil;
    else if (everythingLoadedST)
        random_sound_image_object = [theRandomSoundsST objectAtIndex:v];
} //
-(void)setRandom_soundObject:(id)v 
{ 
    random_sound_image_object = v; 

} //


// ************************************* Get Accsessors ********************************************************
-(BOOL)getPolygonConcaveFlag { return polygonConcave; }

-(LEPolygonType)getType { return type; }
-(LEPolygonFlags)getFlags { return flags; }

-(short)getPermutation
{
    ///SEND_ERROR_MSG(@"An obsolet method -(short)getPermutation was called in a polygon object, this is a possible error!");
    
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        /*NSLog(@"polygonPermutation NSNumber value: %d", [permutationObject shortValue]);*/
        return [permutationObject shortValue];
    }
    
    /*if (permutationObject != nil)
        NSLog(@"polygonPermutation index number: %d", [permutationObject getIndex]);*/
    
    return (permutationObject == nil) ? (-1) : ([permutationObject getIndex]);
}
-(short)getPermutationZero { return (permutationObject == nil) ? (0) : ([self getPermutation]); } // ***

-(id)getPermutationObject
{
    if (permutationObject == nil)
        return nil;
    
    if ([permutationObject isKindOfClass:[NSNumber class]])
    {
        return [[permutationObject copy] autorelease];
    }
    
    return permutationObject;
}

-(short *)getTheVertexes // ********** <-- NEED TO FIX THIS UP FOR NEW OBJECT MODULE!!! *********
{
    int i;
    
    for (i = 0; i < 8; i++)
        vertexIndexes[i] = [self getVertexIndexes:i];
    
    return vertexIndexes;
}

-(short)getTheVertexCount { // NSLog(@"RETURNING The Poly Vertex Count (poly): %d", vertexCount);
                            return vertexCountForPoly; }

-(short)getVertexIndexes:(short)i { return (vertexObjects[i] == nil) ? -1 : [vertexObjects[i] getIndex]; }
-(short)getLineIndexes:(short)i { return (lineObjects[i] == nil) ? -1 : [lineObjects[i] getIndex]; }

-(short)getVertexIndexesZero:(short)i { return (vertexObjects[i] == nil) ? 0 : [vertexObjects[i] getIndex]; }  // ***
-(short)getLineIndexesZero:(short)i { return (lineObjects[i] == nil) ? 0 : [lineObjects[i] getIndex]; }  // ***

-(NSArray *)getVertexArray
{
    return [NSArray arrayWithObjects:vertexObjects count:vertexCountForPoly];
}
-(id)getVertexObject:(short)i { return vertexObjects[i]; }

-(NSArray *)getLineArray
{
    return [NSArray arrayWithObjects:lineObjects count:vertexCountForPoly];
}
-(id)getLineObject:(short)i { return lineObjects[i]; }
//-(id)getLineObjects { return lineObjects; }

-(short)getFloor_texture { return floor_texture; }
-(short)getCeiling_texture { return ceiling_texture; }

-(short)getFloor_height { return floor_height; }
-(short)getCeiling_height { return ceiling_height; }

-(NSDecimalNumber *)getFloor_height_decimal { return [self divideAndRound:floor_height by:1024]; }
-(NSDecimalNumber *)getCeiling_height_decimal { return [self divideAndRound:ceiling_height by:1024]; }

-(NSString *)getFloor_height_decimal_string { return [[self getFloor_height_decimal] stringValue]; }
-(NSString *)getCeiling_height_decimal_string { return [[self getCeiling_height_decimal] stringValue]; }

-(short)getFloor_lightsource_index { return (floor_lightsource_object == nil) ? -1 : [floor_lightsource_object getIndex]; }
-(short)getCeiling_lightsource_index { return (ceiling_lightsource_object == nil) ? -1 : [ceiling_lightsource_object getIndex]; }

-(short)getFloor_lightsource_index_zero { return (floor_lightsource_object == nil) ? 0 : [floor_lightsource_object getIndex]; }  // ***
-(short)getCeiling_lightsource_index_zero { return (ceiling_lightsource_object == nil) ? 0 : [ceiling_lightsource_object getIndex]; }  // ***

-(id)getFloor_lightsource_object { return floor_lightsource_object; } // ---
-(id)getCeiling_lightsource_object { return ceiling_lightsource_object; } // ---

-(int)getArea { return area; }
-(short)getFirst_object_index { return first_object_index; } //
-(short)getFirst_exclusion_zone_index { return first_exclusion_zone_index; }
-(short)getLine_exclusion_zone_count { return line_exclusion_zone_count; }
-(short)getPoint_exclusion_zone_count { return point_exclusion_zone_count; }
-(short)getFloor_transfer_mode { return floor_transfer_mode; }
-(short)getCeiling_transfer_mode { return ceiling_transfer_mode; }

-(short)getAdjacent_polygon_indexes:(short)i { return (adjacent_polygon_objects[i] == nil) ? 0 : [adjacent_polygon_objects[i] getIndex]; }  // ***
-(id)getAdjacent_polygon_objects:(short)i { return adjacent_polygon_objects[i]; } //

-(short)getFirst_neighbor_index { return (first_neighbor_object == nil) ? -1 : [first_neighbor_object getIndex]; } //
-(id)getFirst_neighbor_object { return first_neighbor_object; } // ---

-(short)getNeighbor_count { return neighbor_count; }
-(NSPoint)getCenter { return center; }

-(short)getSide_indexes:(short)i { return (side_objects[i] == nil) ? 0 : [side_objects[i] getIndex]; }  // ***
-(id)getSide_objects:(short)i { return side_objects[i]; } //

-(NSPoint)getFloor_origin { return floor_origin; }
-(NSPoint)getCeiling_origin { return ceiling_origin; }

-(short)getMedia_index { return (media_object == nil) ? -1 : [media_object getIndex]; } //
-(short)getMedia_lightsource_index { return (media_lightsource_object == nil) ? 0 : [media_lightsource_object getIndex]; }  // ***
-(short)getSound_source_indexes { return sound_source_indexes; } // *** WORK ON THIS ONE ***
-(short)getAmbient_sound_image_index { return (ambient_sound_image_object == nil) ? -1 : [ambient_sound_image_object getIndex]; } //
-(short)getRandom_sound_image_index { return (random_sound_image_object == nil) ? -1 : [random_sound_image_object getIndex]; } //

-(id)getMedia_object { return media_object; } // ---
-(id)getMedia_lightsource_object { return media_lightsource_object; } // ---
-(id)getSound_source_objects { return sound_source_objects; } // ---  *** WORK ON THIS ONE ***
-(id)getAmbient_sound_image_object { return ambient_sound_image_object; } // ---
-(id)getRandom_sound_image_object { return random_sound_image_object; } // ---

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
    
    leftMostX = [vertexObjects[0] getX];
    greatestY = [vertexObjects[0] getY];
    leastY = [vertexObjects[0] getY];
    leftMostPoint = vertexObjects[0];
    for (i = 1; i < vertexCountForPoly; i++)
    {
        if (vertexObjects[i] != nil)
        {
            if ([vertexObjects[i] getX] < leftMostX)
            {
                leftMostX = [vertexObjects[i] getX];
                leftMostPoint = vertexObjects[i];
                //NSLog(@"Less Then to leftMostX, point index: %d",
                //[theMapPointsST indexOfObjectIdenticalTo:vertexObjects[i]]);
                ////NSLog(@"leftMostX: %d", leftMostX);
            }
            else if ([vertexObjects[i] getX] == leftMostX)
            {
                leftMostX = [vertexObjects[i] getX];
                leftMostPoint = vertexObjects[i];
                //NSLog(@"Equal to leftMostX, point index: %d",
                //[theMapPointsST indexOfObjectIdenticalTo:vertexObjects[i]]);
                /*if ([vertexObjects[i] getY] != [leftMostPoint getY])
                {
                    // Found It!!!
                    secondLeftMostPoint = vertexObjects[i];
                }
                else// if ([vertexObjects[i] getY] == [leftMostPoint getY])
                {
                    //This may be illegal, ???
                    [self setPolygonConcaveFlag:NO];
                    return NO;
                }*/
            }
            
            if ([vertexObjects[i] getY] > greatestY) // Get The Bottom Most Point...
                greatestY = [vertexObjects[i] getY];
            
            if ([vertexObjects[i] getY] < leastY) // Get The Top Most Point...
                leastY = [vertexObjects[i] getY];
        }
        else if (vertexObjects[i] == nil)
        {
            //   not suposed to be nil, error!!!
            // ****************** Somthing Wrong With Polgonal Data!!! **********************
            // Invalidate the polygon here!!!
            // Data inregertiy for this polygon is corupted!!!
            NSLog(@"vertextObject nil when it was not suposed to be...?");
            [self setPolygonConcaveFlag:NO];
            return NO;
        }
        else
        {
            SEND_ERROR_MSG(@"Somthing wrong with program logic!!! MAJOR, proably even FATEL error!!!");
            [self setPolygonConcaveFlag:NO];
            return NO; // What would bring it here?
        }
    } // END FOR
    
    if (leftMostPoint == nil)
      NSLog(@"Polygon %d had No Left Most Point???", [self getIndex]);
        
  // NSLog(@"It's Point Indexes for leftMostPointIndex: %d", [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]);
    
    bottomMost = (BOOL)(greatestY == [leftMostPoint getY]);
    topMost =  (BOOL)(leastY == [leftMostPoint getY]);
    
    //   See if the Left Point Object is the same object
    //   as one of the point objects for this line...
    for (i = 0; i < vertexCountForPoly; i++)
    {
        BOOL foundTheLine = NO;
      // NSLog(@"Tesing Line %d", [lineObjects[i] getIndex]);
      // NSLog(@"It's Point Indexes are p1: %d p2: %d leftMostPointIndex: %d", [theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] getMapPoint1]], [theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] getMapPoint2]], [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]);
        
        if (([theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] getMapPoint1]] == [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]) || ([theMapPointsST indexOfObjectIdenticalTo:[lineObjects[i] getMapPoint2]] == [theMapPointsST indexOfObjectIdenticalTo:leftMostPoint]))
        {
            //NSLog(@"Line %d passed", [lineObjects[i] getIndex]);
            
            
            if ([[lineObjects[i] getMapPoint1] getY] != [[lineObjects[i] getMapPoint2] getY])
            {
                id theCurSecPoint;
                
                if (pointOneGotten && !gettingSlope)
                {
                    foundTheLine = YES;
                  // NSLog(@"foundTheLine set to YES at Begining");
                }
                // *** See which point is the secondary point ***
                if (leftMostPoint == [lineObjects[i] getMapPoint2])
                {
                    theCurSecPoint = [lineObjects[i] getMapPoint1];
                }
                else if  (leftMostPoint == [lineObjects[i] getMapPoint1])
                {
                    theCurSecPoint = [lineObjects[i] getMapPoint2];
                }
                else
                {
                    NSLog(@"ERROR, polygon %d is not concave due to programming logic mistake!", [self getIndex]);
                    [self setPolygonConcaveFlag:NO];
                    return NO;
                }
                
                // *** do the slope checking, etc... ***
                
                if ((topMost || bottomMost) && !pointOneGotten && !gettingSlope)
                {
                    thePrevPointY = [theCurSecPoint getY];
                    thePrevPointX = [theCurSecPoint getX];
                    theMainPointX = [leftMostPoint getX];
                    theMainPointY = [leftMostPoint getY];
                    gettingSlope = YES;
                    thePrevLine = lineObjects[i];
                  // NSLog(@"Found a line 1 for slop check, line %d", [lineObjects[i] getIndex]);
                }
                else if ((topMost || bottomMost) && pointOneGotten && gettingSlope)
                {
                    double previousX = thePrevPointX - theMainPointX; //
                    double previousY = thePrevPointY - theMainPointY; //
                    double thisX = [theCurSecPoint getX] - theMainPointX;
                    double thisY = [theCurSecPoint getY] - theMainPointY; //
                    
                    double slope = previousY / previousX;
                    double theXfromSlope = thisY / slope;
                  // NSLog(@"F previousY: %g previousX: %g", previousY, previousX);
                  // NSLog(@"F slope: %g theY: %g", slope, thisY);
                  // NSLog(@"F theXfromSlop: %g", theXfromSlope);

                    if (thisX < theXfromSlope) // other one ok
                        foundTheLine = YES;
                    else if (thisX > theXfromSlope) //this one ok
                    {
                        //Found A Qualified Left Most Line!!!
                        leftMostLine = thePrevLine;
                        indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                        currentLine = leftMostLine;
                        //foundTheLine = YES;
                      // NSLog(@"1-1 Found a line, line %d", [leftMostLine getIndex]);
                        break;
                    }
                    else // if (thisX == theXfromSlope)
                    {
                        // ???
                      // NSLog(@"???, the First Slope Check Equal Each Other (thisX == theXfromSlope)");
                        foundTheLine = YES;
                    }
                }
                
                if (pointOneGotten || !(topMost || bottomMost) /* || (slope check thingy) */ )
                {
                    foundTheLine = YES;
                  // NSLog(@"foundTheLine set to YES at END");
                }
            }
            else if ((topMost || bottomMost) && pointOneGotten)
            {
                //Found A Qualified Left Most Line!!!
                leftMostLine = thePrevLine;
                indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                currentLine = leftMostLine;
                //foundTheLine = YES;
              // NSLog(@"1-1 Found a line, line %d", [leftMostLine getIndex]);
                break;
            }
            
            if (foundTheLine)
            {
                    //Found A Qualified Left Most Line!!!
                    leftMostLine = lineObjects[i];
                    indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                    currentLine = leftMostLine;
                  // NSLog(@"2 Found a line(*), line %d", [leftMostLine getIndex]);
                    break;
            }
            else if (pointOneGotten)
            {
                //of the two lines from that point
                //both are not qualified?
                NSLog(@"Sorry, but could not determin if polygon %d was concave, the left most points lines were not qualified?", [self getIndex]);
                //[self setPolygonConcaveFlag:NO];
                //return NO;
                leftMostLine = lineObjects[i];
                indexOfLineFound = [theMapLinesST indexOfObjectIdenticalTo:leftMostLine];
                currentLine = leftMostLine;
                foundTheLine = YES;
                // NSLog(@"Found a line, line %d", [leftMostLine getIndex]);
                break;
            }
            
            pointOneGotten = YES;
        }
        else //previouse if was the one checking to see if points belong to the line...
        {
            
        }
    }
    
    for (i = 0; i < vertexCountForPoly; i++)
    {
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
    
    if (point1.y < point2.y)
    {
        currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
        currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
    }
    else if (point1.y > point2.y)
    {
        currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
        currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
    }
    else
    {
        if (point1.x > point2.x)
        {
            currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
            currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
        }
        else
        {
            currentLineMainPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex1]];
            currentLineSecondaryPoint = [theMapPointsST objectAtIndex:[currentLine pointIndex2]];
        }
    }
    
    // NSLog(@"currentLineMainPoint index: %d",
            // [theMapPointsST indexOfObjectIdenticalTo:currentLineMainPoint]);
    // NSLog(@"currentLineSecondaryPoint index: %d",
            // [theMapPointsST indexOfObjectIdenticalTo:currentLineSecondaryPoint]);
    // NSLog(@"currentLine: %d", [currentLine getIndex]);
    
    //while (keepFollowingTheLines)
    for (i = 0; i < vertexCountForPoly; i++)
    {
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
        while (tmpLine = [numer nextObject])
        {
            if ((([tmpLine getMapPoint1] == currentLineMainPoint) || //Used to be [currentLine getMapPoint1]
                ([tmpLine getMapPoint2] == currentLineMainPoint)) && //Used to be [currentLine getMapPoint2]
                    (tmpLine != currentLine))
            {
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

                previousX = [currentLineSecondaryPoint getX] - [currentLineMainPoint getX];
                previousY = [currentLineSecondaryPoint getY] - [currentLineMainPoint getY];
                thisX = [theCurPoint getX] - [currentLineMainPoint getX];
                thisY = [theCurPoint getY] - [currentLineMainPoint getY];
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
                theta = theta * 180.0 / 3.141593;
                alpha = asin(alpha);
                alpha = alpha * 180.0 / 3.141593;
                tango = atan(tango);
                tango = tango * 180.0 / 3.141593;
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
                
                
                if (theta != 180.0)
                {
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
                }// End if ( theta <= 180.0 && theta < smallestAngle && [theCurPoint getX] >= [firstPoint getX])
                else
                {
                    /*if (slopeChecksOut)
                        NSLog(@"For polygon %d, line %d angle was not correct, not concave, theta: %f  slopeChecksOut TRUE",
                            [self getIndex], [thisMapLine getIndex], theta);
                    else
                        NSLog(@"For polygon %d, line %d angle was not correct, not concave, theta: %f  slopeChecksOut FALSE",
                            [self getIndex], [thisMapLine getIndex], theta);*/
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
          // NSLog(@"Poly %d Concave M1", [self getIndex]);
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
  // NSLog(@"Poly %d Concave M2", [self getIndex]);
    [self setPolygonConcaveFlag:YES];
    return YES;
    
} // End -(BOOL)isPolygonConcave


@end
