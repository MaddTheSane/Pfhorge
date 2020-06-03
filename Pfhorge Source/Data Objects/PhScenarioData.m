//
//  PhScenarioData.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jun 03 2002.
//  Copyright (c) 2002 Joshua D. Orr. All rights reserved.
//

#import "PhScenarioData.h"
#import "LEExtras.h"
#import "PhPfhorgeScenarioLevelDoc.h"

@implementation PhScenarioData

// **************************  Coding/Copy Protocal Methods  *************************
#pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (void) encodeWithCoder:(NSCoder *)coder
{
    if (coder.allowsKeyedCoding) {
        [coder encodeObject:levelFileNames forKey:@"levelFileNames"];
    } else {
        encodeNumInt(coder, 0);
        
        encodeObj(coder, levelFileNames);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (coder.allowsKeyedCoding) {
        levelFileNames = [[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSString class], nil] forKey:@"levelFileNames"] retain];
    } else {
        /*int versionNum = */decodeNumInt(coder);
        
        levelFileNames = decodeObjRetain(coder);
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    //LEMapPoint *copy = [[LEMapPoint allocWithZone:zone] initX:x Y:y];
    
    /*if (copy == nil)
        return nil;*/
    
    //[self setAllObjectSTsFor:copy];
    
    return nil; // copy
}

// **************************  Intlization and Deallocation  *************************
#pragma mark -
#pragma mark ********* Intlization and Deallocation *********

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    levelFileNames = [[NSMutableArray alloc] initWithCapacity:0];
    pictFileNames = [[NSMutableArray alloc] initWithCapacity:0];
    projectDir = nil;
    
    return self;
}

-(id)initWithProjectDirectory:(NSString *)theProjectDir
{
    // [(NSDocument *) fileName];
    
    self = [super init];
    
    if (self == nil)
        return nil;
    
    levelFileNames = [[NSMutableArray alloc] initWithCapacity:0];
    pictFileNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    projectDir = [theProjectDir copy];
    
    return self;
}

-(void)dealloc
{
    [levelFileNames release];
    levelFileNames = nil;
    
    [pictFileNames release];
    pictFileNames = nil;
    
    [projectDir release];
    projectDir = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark ********* Accsessors *********


- (void)setTableView:(NSTableView *)theTableView { theTable = theTableView; }

- (void)editSelected:(NSTableView *)aTableView
{
    [theScenarioDocument openADocumentFile:[self getLevelPathForLevel:[aTableView selectedRow]]];
}

-(void)setTheScenarioDocument:(PhPfhorgeScenarioLevelDoc *)value { theScenarioDocument = value; }

-(void)setProjectDirectory:(NSString *)theProjectDir
{
	[projectDir autorelease];
	projectDir = [theProjectDir copy];
	[self scanProjectDirectory];
}

@synthesize projectDirectory=projectDir;

-(NSArray *)levelFileNames { return levelFileNames; }

-(void)addLevelNames:(NSArray *)theNames
{
    [levelFileNames addObjectsFromArray:theNames];
    [self scanProjectDirectory];
}

-(void)scanProjectDirectory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray<NSString*> *subpaths;
    
    NSLog(@"scanProjectDirectory");
    
    for (NSString *fileName in levelFileNames) {
        BOOL isDir = YES;
        NSString *fullPath = [projectDir stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"pfhlev"]];
        BOOL exsists = [manager fileExistsAtPath:fullPath isDirectory:&isDir];
        
        if ((!exsists) || (isDir)) {
            NSLog(@"REMOVE");
            [levelFileNames removeObject:fileName];
           // [levelFileFullPaths removeObject:fullPath];
        }
    }
    
    subpaths = [manager contentsOfDirectoryAtPath:projectDir error:NULL];
    for (NSString *fileName in subpaths) {
        NSString *fullPath = [projectDir stringByAppendingPathComponent:fileName];
        //char buffer;
        NSString *firstChar = [fileName substringToIndex:1];
        
        if ([levelFileNames containsObject:[fileName stringByDeletingPathExtension]])
            continue;
        
        if (IsPathDirectory(manager, fullPath)) {
            continue;
        } else if ([[fileName pathExtension] caseInsensitiveCompare:@"pfhlev"] == NSOrderedSame) {
            [levelFileNames addObject:[fileName stringByDeletingPathExtension]];
            //[levelFileFullPaths addObject:[[levelFileNames copy] autorelease]]
        } else if (![[fileName pathExtension] isEqualToString:@"sen"] && ![firstChar isEqualToString:@"."]) {
            static BOOL alreadyHadLecture2 = NO;
            if (!alreadyHadLecture2) {
                SEND_ERROR_MSG_TITLE(@"Unknown File(s) in Scenario Directory.",
                                     @"Unknown Files(s)");
            }
            
            NSLog(@"Unkown file '%@' in scenario directory: '%@'", fileName, projectDir);
            alreadyHadLecture2 = YES;
        }
    }
    
    [theScenarioDocument reloadLevelTable:self];
}

-(int)levelCount { return (int)([levelFileNames count]); }

-(NSString *)getLevelNameForLevel:(int)levelNumber { return [levelFileNames objectAtIndex:levelNumber]; }
-(NSString *)getLevelPathForLevel:(int)levelNumber { return [projectDir stringByAppendingPathComponent:[[levelFileNames objectAtIndex:levelNumber] stringByAppendingPathExtension:@"pfhlev"]]; }
-(NSString *)getLevelPathForSelected { return [projectDir stringByAppendingPathComponent:[[levelFileNames objectAtIndex:[theTable selectedRow]] stringByAppendingPathExtension:@"pfhlev"]]; }

- (NSInteger)isFileAPartOfThisSceanario:(NSString *)queryingfullPath
{
    for (NSString *fileName in levelFileNames) {
        NSString *fullPath = [projectDir stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"pfhlev"]];
        
        if ([fullPath isEqualToString:queryingfullPath]) {
            return [levelFileNames indexOfObjectIdenticalTo:fileName];
        }
    }
    
    return NSNotFound;
}

// ••••••••• Table Data Source Updater Methods •••••••••
#pragma mark -
#pragma mark Table Data Source Updater Methods

// *** Data Source Messages ***

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    ///NSLog(@"numberOfRowsInTableView: %d", [self levelCount]);
    return [self levelCount];
}

-(id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
           row:(NSInteger)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"#"]) {
        return @(rowIndex);
    } else {
        return [self getLevelNameForLevel:(int)rowIndex];
    }
}


- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)col
              row:(NSInteger)rowIndex
{
    ///NSParameterAssert(rowIndex >= 0 && rowIndex < [names count]);
    
    //NSLog(@"editing somthing...");
    /*if (objs == nil)
        return NO;*/
    
    // Use rowIndex to open a level...
    
    [theScenarioDocument openADocumentFile:[self getLevelPathForLevel:(int)rowIndex]];
    
    return NO;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)rowIndex
{
    // Should never get here for right now, acutally...
    SEND_ERROR_MSG(@"Level List Table (Senerio) Attempted To Set Object.");
    return;
}

- (void)tableView:(NSTableView *)view
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)row
{
    //[cell setBackgroundColor: [colors objectAtIndex:row]];
    
    //[cell setForegroundColor: [colors objectAtIndex:row]];
}

- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard
{
    NSInteger rowNumber = [rowIndexes firstIndex];
    
    //NSData *theData = [NSArchiver archivedDataWithRootObject:obj];
    draggedLevel = [levelFileNames objectAtIndex:rowNumber];
    // Don't retain since this is just holding temporaral drag information,
    // and it is only used during a drag!  TODO: We could put this in the pboard actually.
    
    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:@[PfhorgeScenarioLevelsTableDataPasteboardType] owner:self];
    
    // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
    [pboard setData:[NSData data] forType:PfhorgeScenarioLevelsTableDataPasteboardType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation
{ // NSDraggingInfo
    ///NSLog(@"validateDrop");
    
    if (operation == NSTableViewDropOn) {
        return NSDragOperationNone;
    } else {
        return NSDragOperationGeneric;
    }
    
    /*BOOL targetNodeIsValid = NO;
    BOOL isOnDropTypeProposal = index==NSOutlineViewDropOnItemIndex;
    
    if (item == nil)
        targetNodeIsValid = NO;
    
    if ([item isKindOfClass:[Terminal class]])
        targetNodeIsValid = YES;
    
    return targetNodeIsValid ? NSDragOperationGeneric : NSDragOperationNone;*/
}

- (BOOL)tableView:(NSTableView*)tableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
    // NSDraggingInfo
    // draggedTerminalSection may not exsist, and may not be nil in that case. 
    //	it should not happen, but it is a possiblity.  Deal with this possibility elagently in the future...
    //Terminal *theTerm = [[theMap getCurrentLevelLoaded] getTerminalThatContains:draggedTerminalSection];
    NSMutableArray *destArray = levelFileNames;
    NSInteger rowNumberForItem = -1;
    
    [draggedLevel retain];
    [destArray removeObject:draggedLevel];
    
    if ([destArray count] <= row || NSOutlineViewDropOnItemIndex == row) {
        [destArray addObject:draggedLevel];
    } else {
        [destArray insertObject:draggedLevel atIndex:row];
    }
    
    [tableView reloadData];
    
    rowNumberForItem = row;//[tableView rowForItem:draggedTerminalSection];
    if (rowNumberForItem > -1) {
        [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowNumberForItem] byExtendingSelection:NO];
    } else {
        [tableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    }
    
    [draggedLevel release];
    
    //[theTeriminalTableView selectItems:[NSArray arrayWithObjects:draggedTerminalSection, nil] byExtendingSelection: NO];
    
    ///NSLog(@"acceptDrop");
    
    // Since is should of been validated, proably ok without checking...
    // 	But maby you should anyway, just in case...
    
    draggedLevel = nil;
    
    [theScenarioDocument reloadLevelTable:self];
    
    return YES;
}

@end
