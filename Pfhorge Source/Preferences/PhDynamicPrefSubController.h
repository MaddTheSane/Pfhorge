#import <Cocoa/Cocoa.h>

@class PhPrefsController;

@interface PhDynamicPrefSubController : NSObject //NSWindowController
{
    IBOutlet PhPrefsController *mainController;
    
    IBOutlet NSButton *enableGridCheckbox;
    IBOutlet NSPopUpButton *gridSizePopupMenu;
    IBOutlet NSButton *snapToGridCheckbox;
    IBOutlet NSTextField *gridFactor;
    
    IBOutlet NSButton *enableAntialiasingCheckbox;
    IBOutlet NSButton *enableObjectOutlining;
    
    IBOutlet NSTextField *shapesPathTB;
    IBOutlet NSPopUpButton *renderModePM;
    IBOutlet NSPopUpButton *startPositionPM;
    
    IBOutlet NSButton *showLiquids;
    IBOutlet NSButton *showTransparent;
    IBOutlet NSButton *showLandscapes;
    IBOutlet NSButton *showInvalid;
    IBOutlet NSButton *showObjects;
    
    IBOutlet NSButton *liquidsTransparent;
    IBOutlet NSButton *useFog;
    IBOutlet NSSlider *fogDepthSlider;
    
    IBOutlet NSButton *smoothRenderingCB;
    
    IBOutlet NSButton *useLighting;
    IBOutlet NSPopUpButton *whatLightingPM;
    
    IBOutlet NSPopUpButton *platformStatePM;
    IBOutlet NSPopUpButton *visibleSidePM;
    IBOutlet NSPopUpButton *verticalLookPM;
    IBOutlet NSPopUpButton *fieldOfViewPM;
    IBOutlet NSPopUpButton *visibilityModePM;
    
    IBOutlet NSButton *invertMouseCB;
    IBOutlet NSSlider *mouseSpeedSlider;
    IBOutlet NSSlider *keySpeedSlider;
    IBOutlet NSMatrix *keySettings;
    
    IBOutlet NSMatrix *generalMatrixCheckboxes;
    IBOutlet NSSlider *snapToPointLengthSlider;
    
    IBOutlet NSSlider *snapFromPointLengthSlider;
    
    IBOutlet NSMatrix *anglerSnapToMatrix;
}

// gridFactorChanged Action

- (void)mainPrefWindowLoaded;
- (void)loadAndSetGridPrefUI;
- (void)loadAndSetGeneralPrefUI;
- (void)loadAndSetVisualModePrefUI;
- (void)loadAndSetVisualModePrefKeys;

- (NSString *)getKeyNameFromUnichar:(unichar)theUnichar;


-(IBAction)snapFromPointLengthSliderAction:(id)sender;
-(IBAction)anglerSnapToMatrixAction:(id)sender;

-(IBAction)generalCheckBoxMatrixAction:(id)sender;

-(IBAction)enableGridCB:(id)sender;
-(IBAction)gridFactorChanged:(id)sender;
-(IBAction)gridSizeMenu:(id)sender;
-(IBAction)snapToGridCB:(id)sender;
-(IBAction)enableAntialiasingCheckboxAction:(id)sender;
-(IBAction)enableObjectOutliningAction:(id)sender;

-(IBAction)selectShapesBtnAction:(id)sender;
-(IBAction)renderModePMChanged:(id)sender;
-(IBAction)startPositionPMChanged:(id)sender;

-(IBAction)showLiquidsChanged:(id)sender;
-(IBAction)showTransparentChanged:(id)sender;
-(IBAction)showLandscapesChanged:(id)sender;
-(IBAction)showInvalidChanged:(id)sender;
-(IBAction)showObjectsChanged:(id)sender;

-(IBAction)liquidsTransparentChanged:(id)sender;
-(IBAction)useFogChanged:(id)sender;
-(IBAction)fogDepthSliderChanged:(id)sender;

-(IBAction)smoothRenderingCBChanged:(id)sender;

-(IBAction)useLightingChanged:(id)sender;
-(IBAction)whatLightingPMChanged:(id)sender;

-(IBAction)platformStatePMChanged:(id)sender;
-(IBAction)visibleSidePMChanged:(id)sender;
-(IBAction)verticalLookPMChanged:(id)sender;
-(IBAction)fieldOfViewPMChanged:(id)sender;
-(IBAction)visibilityModePMChanged:(id)sender;

-(IBAction)setInvertMouseAction:(id)sender;
-(IBAction)setMouseSpeedAction:(id)sender;
-(IBAction)setKeySpeedAction:(id)sender;

-(IBAction)setKeyButtonAction:(id)sender;


- (unichar)getKeyUnichar;

@end
