//
//  PhAbstractNumber.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jan 29 2002.
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


#import "PhAbstractNumber.h"
#import "LEExtras.h"

@implementation PhAbstractNumber
 // **************************  Coding/Copy Protocol Methods  *************************
#pragma mark - Coding/Copy Protocol Methods

- (void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet *)mainObjs
{
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:assignedNumber requiringSecureCoding:NO error:NULL];
    long length = [theData length];
    ExportLong((int)length);
    [myData appendData:theData];
    [super superClassExportWithIndex:index selfData:myData futureData:futureData mainObjects:mainObjs];
}

- (void)superClassImportWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg
{
    NSData *theData;
    int length;
    
    ImportInt(length);
    theData = [myData getSubDataWithLength:length];
    assignedNumber = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSNumber class] fromData:theData error:NULL];
    if (!assignedNumber) {
        assignedNumber = [NSUnarchiver unarchiveObjectWithData:theData];
    }
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeObject:assignedNumber forKey:@"assignedNumber"];
    } else {
        encodeNumInt(coder, 0);
        
        encodeObj(coder, assignedNumber);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        if (coder.allowsKeyedCoding) {
            assignedNumber = [coder decodeObjectOfClass:[NSNumber class] forKey:@"assignedNumber"];
        } else {
            /*int versionNum = */decodeNumInt(coder);
            
            assignedNumber = decodeObjRetain(coder);
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
    PhAbstractNumber *copy = [[PhAbstractNumber allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
#pragma mark - Init and Dealloc Methods

-(id)init
{
    // FIXME: Find Lowest undes Tag Number And Use That In Future
    return [self initWithNumber:@-1];
}

-(id)initWithNumber:(NSNumber *)thePhNumber
{
    self = [super init];
    if (self == nil)
        return nil;
    
    assignedNumber = [thePhNumber copy];
    [self setPhName:[assignedNumber stringValue]];
    return self;
}

@synthesize phNumber=assignedNumber;

//-(short) index { return [theLevelTagObjectsST indexOfObjectIdenticalTo:self]; }

- (NSComparisonResult)compare:(id)object
{
    return [assignedNumber compare:[(PhAbstractNumber *)object phNumber]];
}


@end
