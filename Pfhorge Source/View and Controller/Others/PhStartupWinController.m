#import "PhStartupWinController.h"
#import "PhTextureRepository.h"
#import "LELevelData.h"

#import "LEExtras.h"

#define waterTex(i) [[[PhTextureRepository sharedTextureRepository] getTextureCollection:_water] objectAtIndex:(i)]

@interface PhStartupWinController ()
- (void)setupWindow;
- (void)closeWindow;
- (void)setStatusText:(NSString *)msg;
- (void)setProgressPostion:(double)thePostion;
- (void)increaseProgressBy:(double)increaseBy;
- (void)setMaxProgress:(double)max;
- (void)setMinProgress:(double)min;
@end

@implementation PhStartupWinController

-(id)init
{
    self = [super initWithWindowNibName:@"Startup"];
    
    if (self == nil)
        return nil;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    cView = theView;//[[self window] contentView];
    theScreen = [NSScreen mainScreen];
    mainWindow = [self window];
    NSRect screenRect = [theScreen frame];
    
    // Get the shielding window level
    //windowLevel = CGShieldingWindowLevel();
 
    int x = (screenRect.size.width / 2) - 229;
    int y = (screenRect.size.height / 2) - 130;
    
    screenRect.origin.x = x;
    screenRect.origin.y = y;
    screenRect.size.height = 260;
    screenRect.size.width = 458;
    [mainWindow setFrame:screenRect display:NO];
}

- (void)setupWindow
{
    // NSLog(@"screenRect: (%g, %g), [%g, %g]",
    //      screenRect.origin.x, screenRect.origin.y,
    //      screenRect.size.width, screenRect.size.height);
    
    // Put up a new window...
    // Here we create the window using the NSBorderlessWindowMask
    //	styleMask (which basically omits the title bar)...
    
    
    //mainWindow = [[NSWindow alloc] initWithContentRect:screenRect//NSMakeRect(20, 500, 400, 400)//screenRect
    //                            styleMask:NSTitledWindowMask//NSTitledWindowMask//NSBorderlessWindowMask
    //                            backing:NSBackingStoreBuffered//NSBackingStoreRetained//NSBackingStoreBuffered
    //                            defer:NO
    //                            screen:theScreen/*[NSScreen mainScreen]*/];
   
    //[mainWindow setBackgroundColor:[NSColor whiteColor]];
    
    [mainWindow setLevel:NSFloatingWindowLevel];
    [mainWindow makeKeyAndOrderFront:nil];
    
    //[mainWindow setContentView:cView];
    [mainWindow displayIfNeeded];
}

- (void)closeWindow
{
    [mainWindow orderOut:self];
    //[mainWindow release];
}

- (void)loadTexturesNow
{
    PhTextureRepository *textures = [PhTextureRepository sharedTextureRepository];
    
    [self setupWindow];
    
    [self setProgressPostion:0.0];
    [self setMinProgress:0.0];
    [self setMaxProgress:60.0];
      
    [self setStatusText:@"Loading Water Textures…"];
    [textures loadTextureSet:_water];
    
    if ([textures getTextureCollection:_water] == nil)
    {
        [self setStatusText:@"Can't load, choose shapes location in prefs…"];
        [self closeWindow];
        SEND_ERROR_MSG_TITLE(@"Could not load textures, please set shapes location in the prefs.",
                             @"Shapes Not Found");
        return;
    }
    
    [self increaseProgressBy:10.0];
    
    [self setStatusText:@"Loading Lava Textures…"];
    [textures loadTextureSet:_lava];
    [self increaseProgressBy:10.0];
    
    [self setStatusText:@"Loading Sewage Textures…"];
    [textures loadTextureSet:_sewage];
    [self increaseProgressBy:10.0];
    
    [self setStatusText:@"Loading Jjaro Textures…"];
    [textures loadTextureSet:_jjaro];
    [self increaseProgressBy:10.0];
    
    [self setStatusText:@"Loading Pfhor Textures…"];
    [textures loadTextureSet:_pfhor];
    [self increaseProgressBy:10.0];
    
    // Loads landscape textures…
    [self setStatusText:@"Loading Landscape Textures…"];
    [textures loadTextureSet:99.0];
    [self increaseProgressBy:10.0];
    
    [self setStatusText:@"Done Loading Textures…"];
    [self closeWindow];
}

/*
-(void)loadTexturesNowOLD
{

    id item, imagePopUp;
    
    PhTextureRepository *textures = [PhTextureRepository sharedTextureRepository];
    
    [textures loadTextureSet:_water];
    
    if ([textures getTextureCollection:_water] == nil)
    {
        [statusTB setStringValue:@"Can't load, shoose shapes location in prefs..."];
        return;
    }
    
    [waterTextureNSImageView setImage:[[textures getTextureCollection:_water] objectAtIndex:19]];
    [waterTextureNSImageView displayIfNeeded];
    
    [textures loadTextureSet:_lava];
    [lavaTextureNSImageView setImage:[[textures getTextureCollection:_lava] objectAtIndex:19]];
    [lavaTextureNSImageView displayIfNeeded];
    
    [textures loadTextureSet:_sewage];
    [sewageTextureNSImageView setImage:[[textures getTextureCollection:_sewage] objectAtIndex:19]];
    [sewageTextureNSImageView displayIfNeeded];
    
    [textures loadTextureSet:_jjaro];
    [jjaroTextureNSImageView setImage:[[textures getTextureCollection:_jjaro] objectAtIndex:19]];
    [jjaroTextureNSImageView displayIfNeeded];
    
    [textures loadTextureSet:_pfhor];
    [pfhorTextureNSImageView setImage:[[textures getTextureCollection:_pfhor] objectAtIndex:19]];
    [pfhorTextureNSImageView displayIfNeeded];
    
    
    [textures loadTextureSet:99];
    
    // Image popup
    imagePopUp = waterTextureMenu; //[[NSPopUpButton alloc] initWithFrame:NSMakeRect(50.0, 140.0, 50.0, 50.0) pullsDown:NO];
    
    [imagePopUp setPullsDown:NO];
    [[imagePopUp cell] setBezelStyle:NSSmallIconButtonBezelStyle];
    [[imagePopUp cell] setArrowPosition:NSPopUpArrowAtBottom];
    [[imagePopUp cell] setImagePosition:NSImageOnly];

    [imagePopUp addItemWithTitle:@""];
    item = [imagePopUp itemAtIndex:0];
    [item setImage:waterTex(10)];
    [item setOnStateImage:nil];
    [item setMixedStateImage:nil];

    [imagePopUp addItemWithTitle:@""];
    item = [imagePopUp itemAtIndex:1];
    [item setImage:waterTex(11)];
    [item setOnStateImage:nil];
    [item setMixedStateImage:nil];

    [imagePopUp addItemWithTitle:@""];
    item = [imagePopUp itemAtIndex:2];
    [item setImage:waterTex(12)];
    [item setOnStateImage:nil];
    [item setMixedStateImage:nil];

    [[[imagePopUp menu] menuRepresentation] setHorizontalEdgePadding:0.0];
    //[imagePopUp sizeToFit];
    //[contentView addSubview:imagePopUp];
    
    [statusTB setStringValue:@"Done Loading Textures, Below Is A Test…"];
}
*/

- (void)setStatusText:(NSString *)msg
{
    [statusTBNew setStringValue:msg];
    [statusTBNew displayIfNeeded];
}

- (void)setProgressPostion:(double)thePostion
{
    [statusSBNew setDoubleValue:thePostion];
    [statusSBNew displayIfNeeded];
}

- (void)increaseProgressBy:(double)increaseBy
{
    //[statusText setStringValue:@"askudjlksad"];
    //[statusText drawCell:[statusText cell]];
    //[statusText drawCellInside:[statusText cell]];
    //[statusText displayIfNeeded];
    
    [statusSBNew incrementBy:increaseBy];
    [statusSBNew displayIfNeeded];
}

- (void)setMaxProgress:(double)max
{
    [statusSBNew setMaxValue:max];
    //[statusSBNew displayIfNeeded];
}

- (void)setMinProgress:(double)min
{
    [statusSBNew setMinValue:min];
    //[statusSBNew displayIfNeeded];
}

@end
