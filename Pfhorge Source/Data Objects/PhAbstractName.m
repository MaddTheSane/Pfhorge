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

 // **************************  Coding/Copy Protocol Methods  *************************
#pragma mark - Coding/Copy Protocol Methods

-(void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet *)mainObjs
{
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:myName requiringSecureCoding:YES error:NULL];
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
    theData = [myData getSubDataWithLength:length];
    self.phName = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:theData error:NULL];
    if (!myName) {
        self.phName = [NSUnarchiver unarchiveObjectWithData:theData];
    }
    
    [super superClassImportWithIndex:index withData:myData useOrginals:useOrg];
}


-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeObject:myName forKey:@"PhAbstractName"];
    } else {
        encodeNumInt(coder, 0);
        
        encodeObj(coder, myName);
    }
}

-(id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        if (coder.allowsKeyedCoding) {
            self.phName = [coder decodeObjectOfClass:[NSString class] forKey:@"PhAbstractName"];
        } else {
            /*int versionNum = */decodeNumInt(coder);
            
            self.phName = decodeObj(coder);
        }
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
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
#pragma mark - Init and Dealloc Methods

-(PhAbstractName *)init
{
    if (self = [super init]) {
        myName = nil;
    }
    
    return self;
}

@synthesize phName=myName;

-(NSString *)phName
{
    return (myName != nil) ? [myName copy] : [@([self index]) stringValue];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingDoIHaveAName
{
    return [NSSet setWithObject:@"phName"];
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
    int myIndex = [self index];
    
    // Should I use the trinary ? operator instead?
    
    if (gotInt == YES && tmpInt == myIndex) {
        return NO;
    } else {
        return YES;
    }
}

- (void)resetNameToMyIndex
{
    [self setPhName:[numShort([self index]) stringValue]];
}

@end
