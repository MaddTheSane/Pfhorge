#import <Cocoa/Cocoa.h>

@interface PhDynamicPrefSubController : NSObject //NSWindowController
{
    IBOutlet id mainController;
    
    IBOutlet id enableGridCheckbox;
    IBOutlet id gridSizePopupMenu;
    IBOutlet id snapToGridCheckbox;
    IBOutlet id gridFactor;
    
    IBOutlet id enableAntialiasingCheckbox;
    IBOutlet id enableObjectOutlining;
    
    IBOutlet id shapesPathTB;
    IBOutlet id renderModePM;
    IBOutlet id startPositionPM;
    
    IBOutlet id showLiquids;
    IBOutlet id showTransparent;
    IBOutlet id showLandscapes;
    IBOutlet id showInvalid;
    IBOutlet id showObjects;
    
    IBOutlet id liquidsTransparent;
    IBOutlet id useFog;
    IBOutlet id fogDepthSlider;
    
    IBOutlet id smoothRenderingCB;
    
    IBOutlet id useLighting;
    IBOutlet id whatLightingPM;
    
    IBOutlet id platformStatePM;
    IBOutlet id visibleSidePM;
    IBOutlet id verticalLookPM;
    IBOutlet id fieldOfViewPM;
    IBOutlet id visibilityModePM;
    
    IBOutlet id invertMouseCB;
    IBOutlet id mouseSpeedSlider;
    IBOutlet id keySpeedSlider;
    IBOutlet id keySettings;
    
    IBOutlet id generalMatrixCheckboxes;
    IBOutlet id snapToPointLengthSlider;
    
    IBOutlet id snapFromPointLengthSlider;
    
    IBOutlet id anglerSnapToMatrix;
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
