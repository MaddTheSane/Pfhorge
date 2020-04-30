
#import <Cocoa/Cocoa.h>
#import "PluginProtocol.h"
#import "PluginManagerInterface.h"

//	This is the plug-in class interface. All methods of the plug-in protocol must be
//	implemented. Common methods and instance variables of the plug-in class cluster may
//	also be declared here. Usually the main class itself will never be instantiated.
//	IBOutlets and IBActions are more conveniently declared in the subclasses, unless they're
//	common to all subclasses. In the example, the IBOutlet to the view (and the method that
//	returns it) could have been moved to the main class by using the same outlet name
//	in both associated nib files.

@interface AppPlugin : NSWindowController<PhLevelPluginProtocol> {
	NSString* theViewName;						//	the name to be used in tabs
	id theObject;								//	the parameter object
}

@end

//	This is the other of the concrete plug-in classes which may be instantiated; in the example,
//	it manages a simple view containing a text which is modified with data from the parameter
//	object, and a button which alters the text.

@interface AppTextPlugin : AppPlugin {
	IBOutlet NSView* textView;
	IBOutlet NSTextView* actualText;
}
+ (AppTextPlugin*)pluginFor:(id)anObject;
- (id)initWithObject:(id)anObject name:(NSString*)name;
- (void)appendText:(NSString*)text;
- (IBAction)nowAction:(id)sender;
@end
