//
//  PhProgress.m
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


#import "PhProgress.h"
#import "PhColorListController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"

#import "PhTextureRepository.h"

//Other Classes...
#import "LEExtras.h"

@implementation PhProgress

//LESelectionChangedNotification

// *********************** Overridden Methods ***********************

- (id)init
{
    self = [super initWithWindowNibName:@"StatusWin"];
    [self window];
    onlyUseSecondBar = NO;
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {

    [super windowDidLoad];
    
    //[self setMainWindow:[NSApp mainWindow]];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) 	//name:NSWindowDidBecomeMainNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) 	//name:NSWindowDidResignMainNotification object:nil];
    
    //[[[[colorListTable tableColumns] objectAtIndex:0] dataCell] 
        //setDrawsBackground:YES];
    //[[[[colorListTable tableColumns] objectAtIndex:0] dataCell] 
        //setEditable:NO];
}

-(void)orderOutWin:(id)sender
{
    [theStatusWindow orderOut:self];
}

-(void)setUseSecondBarOnly:(BOOL)value { onlyUseSecondBar = value; }

// *********************** Class Methods ***********************
+ (id)sharedPhProgress {
    static PhProgress *sharedPhProgress = nil;

    if (!sharedPhProgress) {
        sharedPhProgress = [[PhProgress alloc] init];
    }

    return sharedPhProgress;
}

// *********************** Updater Methods ***********************
#pragma mark -
#pragma mark ••••••••• First Bar •••••••••

-(void)setInformationalText:(NSString *)theInfo
{
    id informationTextToUse = informationText;
    
    [informationTextToUse setStringValue:theInfo];
    [informationTextToUse displayIfNeeded];
}

-(void)setStatusText:(NSString *)theStatus
{
    id statusTxtToUse = ((onlyUseSecondBar == NO) ? (theCurStatTxt) : (theSecondStatTxt));
    
    [statusTxtToUse setStringValue:theStatus];
    [statusTxtToUse displayIfNeeded];
}

-(void)setProgressPostion:(double)thePostion
{
    id statusBarToUse = ((onlyUseSecondBar == NO) ? (statusBar) : (theSecondStatusBar));
    
    [statusBarToUse setDoubleValue:thePostion];
    [statusBarToUse displayIfNeeded];
}

-(void)increaseProgressBy:(double)increaseBy
{
    //[statusText setStringValue:@"askudjlksad"];
    //[statusText drawCell:[statusText cell]];
    //[statusText drawCellInside:[statusText cell]];
    //[statusText displayIfNeeded];
    
    id statusBarToUse = ((onlyUseSecondBar == NO) ? (statusBar) : (theSecondStatusBar));
    
    [statusBarToUse incrementBy:increaseBy];
    [statusBarToUse displayIfNeeded];
}

-(void)setMaxProgress:(double)max
{
    id statusBarToUse = ((onlyUseSecondBar == NO) ? (statusBar) : (theSecondStatusBar));
    
    [statusBarToUse setMaxValue:max];
    [statusBarToUse displayIfNeeded];
}

-(void)setMinProgress:(double)min
{
    id statusBarToUse = ((onlyUseSecondBar == NO) ? (statusBar) : (theSecondStatusBar));
    
    [statusBarToUse setMinValue:min];
    [statusBarToUse displayIfNeeded];
}

#pragma mark -
#pragma mark ••••••••• Second Bar •••••••••

-(void)setSecondStatusText:(NSString *)theStatus
{
    [theSecondStatTxt setStringValue:theStatus];
    [theSecondStatTxt displayIfNeeded];
}

-(void)setSecondProgressPostion:(double)thePostion
{
    [theSecondStatusBar setDoubleValue:thePostion];
    [theSecondStatusBar displayIfNeeded];
}

-(void)increaseSecondProgressBy:(double)increaseBy
{
    //[theSecondStatTxt setStringValue:@"askudjlksad"];
    //[theSecondStatTxt drawCell:[statusText cell]];
    //[theSecondStatTxt drawCellInside:[statusText cell]];
    //[theSecondStatTxt displayIfNeeded];
    
    [theSecondStatusBar incrementBy:increaseBy];
    [theSecondStatusBar displayIfNeeded];
}

-(void)setSecondMaxProgress:(double)max
{
    [theSecondStatusBar setMaxValue:max];
    [theSecondStatusBar displayIfNeeded];
}

-(void)setSecondMinProgress:(double)min
{
    [theSecondStatusBar setMinValue:min];
    [theSecondStatusBar displayIfNeeded];
}

@end


