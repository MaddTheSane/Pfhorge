//
//  PhAbstractName.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Nov 24 2001.
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


#import "PhAbstractName.h"
#import "LEExtras.h"


@implementation PhAbstractName

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

-(void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet *)mainObjs
{
    NSData *theData = [NSArchiver archivedDataWithRootObject:myName];
    long length = [theData length];
    ExportLong((int)length);
    [myData appendData:theData];
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
}

-(void)superClassImportWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg
{
    NSData *theData;
    int length;
    
    ImportInt(length);
    theData = [myData getSubDataLength:length];
    myName = [[NSUnarchiver unarchiveObjectWithData:theData] retain];
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}


-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeObj(coder, myName);
}

-(id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    myName = decodeObjRetain(coder);
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    PhAbstractName *copy = [[PhAbstractName allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
 #pragma mark -
#pragma mark ********* Init and Dealloc Methods *********
-(PhAbstractName *)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    myName = nil;
    
    return self;
}

-(void)dealloc
{
    [myName release];
    [super dealloc];
}

@synthesize phName=myName;

-(NSString *)getPhName
{
    return (myName != nil) ? [[myName copy] autorelease] : [[NSNumber numberWithShort:[self getIndex]] stringValue];
}

-(BOOL)doIHaveAName
{
    return ((myName != nil) ? YES : NO);
}

-(BOOL)doIHaveACustomName
{
    NSScanner *scanner = [NSScanner scannerWithString:myName];
    int tmpInt = 0;
    BOOL gotInt = [scanner scanInt:&tmpInt];
    int myIndex = [self getIndex];
    
    // Should I use the trinary ? operator instead?
    
    if (gotInt == YES && tmpInt == myIndex)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)resetNameToMyIndex
{
    [self setPhName:[numShort([self getIndex]) stringValue]];
}

@end
