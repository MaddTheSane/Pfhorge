#import "PhDynamicPrefSubController.h"
#import "PhPrefsController.h"
#import "LEExtras.h"

///#include <math.h>
///#include "MapManager.h"
///#include "KeyControls.h"

#import <ApplicationServices/ApplicationServices.h>

#import <AppKit/AppKit.h>

///#import <drivers/event_status_driver.h>

@implementation PhDynamicPrefSubController

//   indexOfSelectedItem

+ (void)initialize
{
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary
        dictionaryWithObject:@"010" forKey:PhPhorgePrefVersion];
    
    //Set Grid Default
    [appDefaults setObject:[NSNumber numberWithFloat:1]  forKey:PhGridFactor];
    
    [defaults registerDefaults:appDefaults];
    NSLog(@"Done Regestering The Grid Defaults...");*/
}

- (void)mainPrefWindowLoaded
{
    [self loadAndSetGridPrefUI];
    [self loadAndSetGeneralPrefUI];
    NSLog(@"1");
    [self loadAndSetVisualModePrefUI];
    NSLog(@"2");
    [self loadAndSetVisualModePrefKeys];
    NSLog(@"3");
}

- (void)loadAndSetGridPrefUI
{
    float theGridFactorFloat = [preferences floatForKey:PhGridFactor];
    
    [enableGridCheckbox setState:[preferences boolForKey:PhEnableGridBool]];
    [snapToGridCheckbox setState:[preferences boolForKey:PhSnapToGridBool]];
    [enableAntialiasingCheckbox setState:[preferences boolForKey:PhEnableAntialiasing]];
    [enableObjectOutlining setState:[preferences boolForKey:PhEnableObjectOutling]];

    if (theGridFactorFloat == 0.125)
        [gridSizePopupMenu selectItemAtIndex:0];
    else if (theGridFactorFloat == 0.250)
        [gridSizePopupMenu selectItemAtIndex:1];
    else if (theGridFactorFloat == 0.500)
        [gridSizePopupMenu selectItemAtIndex:2];
    else if (theGridFactorFloat == 1.000)
        [gridSizePopupMenu selectItemAtIndex:3];
    else if (theGridFactorFloat == 2.000)
        [gridSizePopupMenu selectItemAtIndex:4];
    else if (theGridFactorFloat == 4.000)
        [gridSizePopupMenu selectItemAtIndex:5];
    else if (theGridFactorFloat == 8.000)
        [gridSizePopupMenu selectItemAtIndex:6];
    else // Custom Grid Factor
        [gridSizePopupMenu selectItemAtIndex:7];
    
    [gridFactor setObjectValue:[[NSNumber numberWithFloat:[preferences floatForKey:PhGridFactor]] stringValue]];
}

- (void)loadAndSetGeneralPrefUI
{
    [anglerSnapToMatrix deselectAllCells];
     
    if ([preferences boolForKey:PhUseRightAngleSnap])
        SelectS(anglerSnapToMatrix, 0);
    if ([preferences boolForKey:PhUseIsometricAngleSnap])
        SelectS(anglerSnapToMatrix, 1);
    
    
    [snapToPointLengthSlider setFloatValue:[preferences integerForKey:PhSnapFromLength]];
    
    
    [generalMatrixCheckboxes deselectAllCells];
    
    if ([preferences boolForKey:PhSnapToPoints])
        SelectS(generalMatrixCheckboxes, 0);
    if ([preferences boolForKey:PhSnapObjectsToGrid])
        SelectS(generalMatrixCheckboxes, 1);
    //if ([preferences boolForKey:PhSnapToLines])
    //    SelectS(generalMatrixCheckboxes, 2);
    //if ([preferences boolForKey:PhSplitNonPolygonLines])
    //    SelectS(generalMatrixCheckboxes, 3);
    //if ([preferences boolForKey:PhSplitPolygonLines])
    //    SelectS(generalMatrixCheckboxes, 4);
    if ([preferences boolForKey:PhSelectObjectWhenCreated])
        SelectS(generalMatrixCheckboxes, 5);
    if ([preferences boolForKey:PhDrawOnlyLayerPoints])
        SelectS(generalMatrixCheckboxes, 6);
    if ([preferences boolForKey:PhSnapFromPoints])
        SelectS(generalMatrixCheckboxes, 7);
    
    
    [snapToPointLengthSlider setFloatValue:[preferences integerForKey:PhSnapToPointsLength]];
}

- (void)loadAndSetVisualModePrefUI
{
    NSURL *theShapesPath = [preferences URLForKey:VMShapesPath];
    
    [renderModePM selectItemAtIndex:[preferences integerForKey:VMRenderMode]];
    [startPositionPM selectItemAtIndex:[preferences integerForKey:VMStartPosition]];
    
    if (theShapesPath) {
        [shapesPathTB setStringValue:theShapesPath.path];
    } else {
        [shapesPathTB setStringValue:NSLocalizedString(@"No Shapes Selected", @"No Shapes Selected")];
    }
 
    [showLiquids setState:[preferences boolForKey:VMShowLiquids]];
    [showTransparent setState:[preferences boolForKey:VMShowTransparent]];
    [showLandscapes setState:[preferences boolForKey:VMShowLandscapes]];
    [showInvalid setState:[preferences boolForKey:VMShowInvalid]];
    [showObjects setState:[preferences boolForKey:VMShowObjects]];

    [liquidsTransparent setState:[preferences boolForKey:VMLiquidsTransparent]];
    [useFog setState:[preferences boolForKey:VMUseFog]];
    [fogDepthSlider setFloatValue:[preferences floatForKey:VMFogDepth]];
    
    [smoothRenderingCB setState:[preferences boolForKey:VMSmoothRendering]];

    [useLighting setState:[preferences boolForKey:VMUseLighting]];
    [whatLightingPM selectItemAtIndex:[preferences integerForKey:VMWhatLighting]];
    
    [platformStatePM selectItemAtIndex:[preferences integerForKey:VMPlatformState]];
    [visibleSidePM selectItemAtIndex:[preferences integerForKey:VMVisibleSide]];
    [verticalLookPM selectItemAtIndex:[preferences integerForKey:VMVerticalLook]];
    [fieldOfViewPM selectItemAtIndex:[preferences integerForKey:VMFieldOfView]];
    [visibilityModePM selectItemAtIndex:[preferences integerForKey:VMVisibilityMode]];
   
    [invertMouseCB setState:[preferences boolForKey:VMInvertMouse]];
    [mouseSpeedSlider setFloatValue:[preferences floatForKey:VMMouseSpeed]];
    [keySpeedSlider setFloatValue:[preferences integerForKey:VMKeySpeed]];
}

/*
extern NSString *VMKeySpeed;
extern NSString *VMMouseSpeed;
extern NSString *VMInvertMouse;

extern NSString *VMUpKey;
extern NSString *VMDownKey;
extern NSString *VMLeftKey;
extern NSString *VMRightKey;
extern NSString *VMForwardKey;
extern NSString *VMBackwardKey;
*/

- (void)loadAndSetVisualModePrefKeys
{
    unichar theChar = (unichar)[preferences integerForKey:VMUpKey];
    //[NSString stringWithCharacters:&theChar length:1];
    
    [[keySettings cellWithTag:0] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMDownKey];
    [[keySettings cellWithTag:1] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMLeftKey];
    [[keySettings cellWithTag:2] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMRightKey];
    [[keySettings cellWithTag:3] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMForwardKey];
    [[keySettings cellWithTag:4] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMBackwardKey];
    [[keySettings cellWithTag:5] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMSlideLeftKey];
    [[keySettings cellWithTag:6] setStringValue:[self getKeyNameFromUnichar:theChar]];
    theChar = (unichar)[preferences integerForKey:VMSlideRightKey];
    [[keySettings cellWithTag:7] setStringValue:[self getKeyNameFromUnichar:theChar]];
    
}

- (NSString *)getKeyNameFromUnichar:(unichar)theUnichar
{
    NSString *theString = @"Set To: ";
    unichar theChar = theUnichar;
    
    if (theChar == 0xf700)
        return [theString stringByAppendingString:@"Up Key"];
    if (theChar == 0xf701)
        return [theString stringByAppendingString:@"Down Key"];
    if (theChar == 0xf702)
        return [theString stringByAppendingString:@"Left Key"];
    if (theChar == 0xf703)
        return [theString stringByAppendingString:@"Right Key"];
    
    if (theChar == 0xf704)
        return [theString stringByAppendingString:@"F1"];
    if (theChar == 0xf705)
        return [theString stringByAppendingString:@"F2"];
    if (theChar == 0xf706)
        return [theString stringByAppendingString:@"F3"];
    if (theChar == 0xf707)
        return [theString stringByAppendingString:@"F4"];
    if (theChar == 0xf708)
        return [theString stringByAppendingString:@"F5"];
    if (theChar == 0xf709)
        return [theString stringByAppendingString:@"F6"];
    if (theChar == 0xf70a)
        return [theString stringByAppendingString:@"F7"];
    if (theChar == 0xf70b)
        return [theString stringByAppendingString:@"F8"];
    if (theChar == 0xf70c)
        return [theString stringByAppendingString:@"F9"];
    if (theChar == 0xf70d)
        return [theString stringByAppendingString:@"F10"];
    if (theChar == 0xf70e)
        return [theString stringByAppendingString:@"F11"];
    if (theChar == 0xf70f)
        return [theString stringByAppendingString:@"F12"];
    if (theChar == 0xf710)
        return [theString stringByAppendingString:@"F13"];
    
     if (theChar == 0x09)
        return [theString stringByAppendingString:@"Tab"];
     if (theChar == 0x20)
        return [theString stringByAppendingString:@"Space"];
     if (theChar == 0x0d)
        return [theString stringByAppendingString:@"Return"];
     if (theChar == 0x03)
        return [theString stringByAppendingString:@"Enter"];
     if (theChar == 0xf739)
        return [theString stringByAppendingString:@"Num-Lock"];
     if (theChar == 0x2e)
        return [theString stringByAppendingString:@"Period"];
     if (theChar == 0xf746)
        return [theString stringByAppendingString:@"Help/Insert Key"];
     if (theChar == 0xf728)
        return [theString stringByAppendingString:@"Del Key"];
     if (theChar == 0x7f)
        return [theString stringByAppendingString:@"Delete Key"];
     if (theChar == 0xf729)
        return [theString stringByAppendingString:@"Home"];
     if (theChar == 0xf72b)
        return [theString stringByAppendingString:@"End"];
     if (theChar == 0xf72c)
        return [theString stringByAppendingString:@"Page Up"];
     if (theChar == 0xf72d)
        return [theString stringByAppendingString:@"Page Down"];
     if (theChar == 0x1b)
        return [theString stringByAppendingString:@"Escape"];
    
    return [theString stringByAppendingString:[NSString stringWithCharacters:&theChar length:1]];
}


-(IBAction)snapFromPointLengthSliderAction:(id)sender;
{
    [preferences setInteger:[snapFromPointLengthSlider intValue] forKey:PhSnapFromLength];
    
    // Not nessary to alert prefs changes, becuase the above two prefs are not cached somewhere,
    // they are checked for in the prefs every time they are used...
    //
    //[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)anglerSnapToMatrixAction:(id)sender
{
    [preferences setBool:SState(anglerSnapToMatrix, 0) forKey:PhUseRightAngleSnap];
    [preferences setBool:SState(anglerSnapToMatrix, 1) forKey:PhUseIsometricAngleSnap];
    
    // Not nessary to alert prefs changes, becuase the above two prefs are not cached somewhere,
    // they are checked for in the prefs every time they are used...
    //
    //[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}


-(IBAction)generalCheckBoxMatrixAction:(id)sender
{
    [preferences setBool:SState(generalMatrixCheckboxes, 0) forKey:PhSnapToPoints];
    [preferences setBool:SState(generalMatrixCheckboxes, 1) forKey:PhSnapObjectsToGrid];
    //[preferences setBool:SState(generalMatrixCheckboxes, 2) forKey:PhSnapToLines];
    //[preferences setBool:SState(generalMatrixCheckboxes, 3) forKey:PhSplitNonPolygonLines];
    //[preferences setBool:SState(generalMatrixCheckboxes, 4) forKey:PhSplitPolygonLines];
    [preferences setBool:SState(generalMatrixCheckboxes, 5) forKey:PhSelectObjectWhenCreated];
    [preferences setBool:SState(generalMatrixCheckboxes, 6) forKey:PhDrawOnlyLayerPoints];
    [preferences setBool:SState(generalMatrixCheckboxes, 7) forKey:PhSnapFromPoints];
    
    [preferences setInteger:[snapToPointLengthSlider intValue] forKey:PhSnapToPointsLength];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)chooseScriptFolder:(id)scriptFolder
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"scpt", @"applescript"];
    NSInteger returnCode = [panel runModal];
    
    if (returnCode == NSModalResponseOK) {
        NSString *path = [panel URL].path;
        NSLog(@"The Path: %@", path);
        //NSString *thePath = @"Test Script.scpt";
        createAndExecuteScriptObject(path);
    }
}

-(IBAction)enableGridCB:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:PhEnableGridBool];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)gridFactorChanged:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
    return;
}

-(IBAction)gridSizeMenu:(id)sender
{
    switch ([sender indexOfSelectedItem]) {
        case 0:
            [preferences setFloat:0.125 forKey:PhGridFactor];
            break;
        case 1:
            [preferences setFloat:0.250 forKey:PhGridFactor];
            break;
        case 2:
            [preferences setFloat:0.500 forKey:PhGridFactor];
            break;
        case 3:
            [preferences setFloat:1.000 forKey:PhGridFactor];
            break;
        case 4:
            [preferences setFloat:2.000 forKey:PhGridFactor];
            break;
        case 5:
            [preferences setFloat:4.000 forKey:PhGridFactor];
            break;
        case 6:
            [preferences setFloat:8.000 forKey:PhGridFactor];
            break;
        case 7: //TODO: get custom factor...
            //[preferences setFloat:0.125 forKey:PhGridFactor];
            break;
    }
    [self loadAndSetGridPrefUI];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)snapToGridCB:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:PhSnapToGridBool];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)enableAntialiasingCheckboxAction:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:PhEnableAntialiasing];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

-(IBAction)enableObjectOutliningAction:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:PhEnableObjectOutling];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
}

#pragma mark -
#pragma mark ********* VM (Visual Mode) Enviroment Pref Actions *********
-(IBAction)selectShapesBtnAction:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSModalResponse returnCode = 0;
    
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
	panel.allowedFileTypes = @[@"org.bungie.source.shapes", @"shpA", NSFileTypeForHFSTypeCode('shp2'), NSFileTypeForHFSTypeCode(0x736870B0 /*shp∞*/)];
    
    returnCode = [panel runModal];
    
    if (returnCode == NSModalResponseOK) {
        NSURL *path = [panel URL];
        NSLog(@"The Shapes Path Choosen: %@", path);
        [shapesPathTB setStringValue:path.path];
        [preferences setURL:path forKey:VMShapesPath];
    } else {
        [shapesPathTB setStringValue:NSLocalizedString(@"No Shapes Selected", @"No Shapes Selected")];
        [preferences setObject:@"" forKey:VMShapesPath];
    }
}

-(IBAction)renderModePMChanged:(id)sender
{
    // JDO Note: Could of used sender instead of renderModePM, but decided not to...
    [preferences setInteger:[renderModePM indexOfSelectedItem] forKey:VMRenderMode];
}

-(IBAction)startPositionPMChanged:(id)sender
{
    // JDO Note: Decided to use sender, then I can just copy and paste this into
    //			other popup menu actions with no changes.  I did it diffrently
    //			above to show that it can be done either way :)
    [preferences setInteger:[sender indexOfSelectedItem] forKey:VMStartPosition];
}

#pragma mark -
#pragma mark ********* VM (Visual Mode) Visability Pref Actions *********

-(IBAction)showObjectsChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMShowObjects];
}

-(IBAction)liquidsTransparentChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMLiquidsTransparent];
}

-(IBAction)platformStatePMChanged:(id)sender
{
    [preferences setInteger:[sender indexOfSelectedItem] forKey:VMPlatformState];
}

-(IBAction)showLiquidsChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMShowLiquids];
}

-(IBAction)showTransparentChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMShowTransparent];
}

-(IBAction)showLandscapesChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMShowLandscapes];
}

-(IBAction)showInvalidChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMShowInvalid];
}

-(IBAction)useFogChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMUseFog];
}

-(IBAction)fogDepthSliderChanged:(id)sender
{
    // LP: See how this is floatValue?  See, you were very close to makeing
    //       this work!!!  [slider setFloatValue:theFloat] also works!
    [preferences setFloat:[fogDepthSlider floatValue] forKey:VMFogDepth];
}

-(IBAction)smoothRenderingCBChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMSmoothRendering];
}

-(IBAction)useLightingChanged:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMUseLighting];
}

-(IBAction)whatLightingPMChanged:(id)sender
{
    [preferences setInteger:[sender indexOfSelectedItem]  forKey:VMWhatLighting];
}

-(IBAction)visibleSidePMChanged:(id)sender
{
    [preferences setInteger:[visibleSidePM indexOfSelectedItem] forKey:VMVisibleSide];
}

-(IBAction)verticalLookPMChanged:(id)sender
{
    [preferences setInteger:[sender indexOfSelectedItem] forKey:VMVerticalLook];
}

-(IBAction)fieldOfViewPMChanged:(id)sender
{
    [preferences setInteger:[sender indexOfSelectedItem] forKey:VMFieldOfView];
}

-(IBAction)visibilityModePMChanged:(id)sender
{
    [preferences setInteger:[sender indexOfSelectedItem] forKey:VMVisibilityMode];
}

#pragma mark -
#pragma mark ********* VM (Visual Mode) Key Pref Actions *********

-(IBAction)setInvertMouseAction:(id)sender
{
    [preferences setBool:[sender state] == NSControlStateValueOn forKey:VMInvertMouse];
}

-(IBAction)setMouseSpeedAction:(id)sender
{
    [preferences setFloat:[sender floatValue] forKey:VMMouseSpeed];
}

-(IBAction)setKeySpeedAction:(id)sender
{
    [preferences setInteger:[sender integerValue] forKey:VMKeySpeed];
}

-(IBAction)setKeyButtonAction:(id)sender
{
    NSInteger theKeyTag = [sender tag];
    
    switch (theKeyTag) {
        case 0:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMUpKey];
            break;
            
        case 1:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMDownKey];
            break;
            
        case 2:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMLeftKey];
            break;
            
        case 3:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMRightKey];
            break;
            
        case 4:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMForwardKey];
            break;
            
        case 5:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMBackwardKey];
            break;
            
        case 6:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMSlideLeftKey];
            break;
            
        case 7:
            [preferences setInteger:(int)([self getKeyUnichar]) forKey:VMSlideRightKey];
            break;
            
        default:
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Generic Error";
            alert.informativeText = @"Could not determine which button was pressed.";
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
            break;
    }
    
    [self loadAndSetVisualModePrefKeys];
}

- (unichar)getKeyUnichar
{
    NSDate *distantPast = [NSDate distantPast];
    BOOL done = NO;
    NSEvent *event;
    unichar c = 0;
    ///unsigned int previousFlags = 0, newFlags, changed, down;
    ///unsigned int previousMouseButtons = 0, newMouseButtons;
    
    // Process events
    while (!done) {
        NSEventType type;
        event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:distantPast inMode:NSDefaultRunLoopMode dequeue:YES];
        
        // Handle the event we got
        type = [event type];
        switch (type) {
            case NSEventTypeKeyDown:
            case NSEventTypeKeyUp:
                {
                    NSString *characters;
                    
                    NSInteger characterIndex, characterCount;
                    
                    // There could be multiple characters in the event.  Additionally, if shift is down, these characters will be upper case.
                    characters = [event charactersIgnoringModifiers];
                    characterCount = [characters length];
                    
                    for (characterIndex = 0; characterIndex < characterCount; characterIndex++)
                    {
                        c = [characters characterAtIndex: characterIndex];
                        //[self _logString: [NSString stringWithFormat: @"KEY %@:  unichar=0x%02x\n", (type == NSKeyDown) ? @"DOWN" : @"UP", c]];
                        
                        done = YES;
                        break;
                        // Since we take over the event loop, 'cmd-q' will not quit the app.
                        // Quit is the "escape" key
                        if (c == 0x1b)
                            done = YES;


                    }
                }
                break;
            default:
                // Ignore any other events
                break;
        }
        
        //[pool release];
    }
    return c;
}

@end
