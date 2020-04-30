//
//  Written by Rainer Brockerhoff for MacHack 2002.
//  Copyright (c) 2002 Rainer Brockerhoff.
//	rainer@brockerhoff.net
//	http://www.brockerhoff.net/
//
//	This is part of the sample code for the MacHack 2002 paper "Plugged-in Cocoa".
//	You may reuse this code anywhere as long as you assume all responsibility.
//	If you do so, please put a short acknowledgement in the documentation or "About" box.
//

#import "AppPlugin.h"

//	The plug-in is most conveniently implemented as a class cluster. The pluginsFor: method
//	may examine its parameter object and decide to return as many instances of its several
//	concrete subclasses. The calling application doesn't (and shouldn't) care which actual
//	subclass instances it gets back, and just treats each one as a NSObject<PAPluginProtocol>.

//	Variables common to all plug-in instances and subclasses are declared as
//	static globals. Here we store a reference to the plug-in's bundle, which would be
//	convenient to access local resources like icons and help files. We also use the bundle
//	reference as an indicator to check whether the plug-in has already been initialized.

static NSBundle* pluginBundle = nil;

//	This is the main plug-in class implementation.

@implementation AppPlugin

//	initializeClass: is called once when the plug-in is loaded. The plug-in's bundle is passed
//	as argument; the plug-in could discover its own bundle again, but since we have it available
//	anyway when this is called, this saves some time and space.
//	In a real implementation, we might also pass a NSDictionary with the appropriate preferences.
//	This method should do all global plug-in initialization, such as loading preferences; if
//	initialization fails, it should return NO, and the plug-in won't be called again.
//	Here we just check if the plug-in already has been initialized; if not, we store a reference
//	to the bundle (which isn't actually used) and return YES.

+ (BOOL)initializeClass:(NSBundle*)theBundle {
	if (pluginBundle) {
		return NO;
	}
	pluginBundle = [theBundle retain];
	return YES;
}

//	terminateClass is called once when the plug-in won't be used again. NSBundle-based plug-ins
//	can't be unloaded at present, this capability may be added to Cocoa in the future.
//	Here we release the bundle's reference and zero out the pointer, just for form's sake.

+ (void)terminateClass {
	if (pluginBundle) {
		[pluginBundle release];
		pluginBundle = nil;
	}
}

//	pluginsFor: is called whenever the calling application wants to instantiate a plug-in class.
//	An object is passed in as parameter; this object might be validated by the plug-in class to
//	decide which sort of instances, or how many instances to return. The object reference may also
//	be stored by the instances and thereafter be used as a bridge to the calling application.
//	This method returns an enumerator of an array of plug-in instances. This enumerator, the array
//	itself, and the plug-in instances are all autoreleased, so the calling application needs to retain
//	whatever it wants to keep. If no instances were generated, this returns nil.
//	Here we just try to instantiate one of each subclass, repassing the parameter object to the
//	subclass' pluginFor: method; if this returns nil, the subclass doesn't want to handle that
//	particular object.

+ (NSEnumerator*)pluginsFor:(id)anObject {
	//AppImagePlugin* imgp;
	AppTextPlugin* txtp;
	NSMutableArray* plugs = [[[NSMutableArray alloc] init] autorelease];
	if ((txtp = [AppTextPlugin pluginFor:anObject])) {
		[plugs addObject:txtp];
	}
	/*if ((imgp = [AppImagePlugin pluginFor:anObject])) {
		[plugs addObject:imgp];
	}*/
	return [plugs count]?[plugs objectEnumerator]:nil;
}

//	dealloc for the plug-in class cluster, of course, releases the parameter references.

- (void)dealloc {
	[theViewName release];
	[theObject release];
	[super dealloc];
}


//	theViewName returns the name of the instance. This is common to all subclasses.

- (NSString*)name {
	return theViewName;
}

// This is called when user selects plugin from menu.
// This exsample brings up the window.

- (void)activate
{
    [self showWindow:nil];
}

@end


// *** *** *** *** *** *** *** *** ***


//	This is the other of the actual plug-in classes which may be instantiated; in the example,
//	it manages a simple view containing a text which is modified with data from the parameter
//	object.

@implementation AppTextPlugin

//	We substitute dummy classes for initializeClass:/terminateClass. It makes no sense to
//	call these for the concrete classes, actually.

+ (BOOL)initializeClass:(NSBundle*)theBundle {
	return NO;
}

+ (void)terminateClass {
}

//	pluginFor: returns a single instance of the plug-in subclass, or nil if the parameter
//	object (or some external circumstance) is inappropriate.
//	Here we allocate and initialize an empty plug-in. Then we try to load the nib file for
//	the "text" view. This will connect the textView and actualText outlets. If everything is
//	OK, we append the parameter object's description to the existing text and return the
//	subclass instance.

+ (AppTextPlugin*)pluginFor:(id)anObject {
	AppTextPlugin* instance = [[[AppTextPlugin alloc] initWithObject:anObject name:@"Text"] autorelease];
        
	return instance;
}

//	initWithObject:name: is the designated initializer for the plug-in class cluster.
//	It stores the retained parameter references.

- (id)initWithObject:(id)anObject name:(NSString*)name {
	        
        self = [super initWithWindowNibName:@"TextView"];
        
	theViewName = [name retain];
	//theObject = [anObject retain];
        theObject = nil;
        
	return self;
}

//	dealloc needs to release anything required

- (void)dealloc {
	[theViewName release];
	[super dealloc];
}

//	appendText: appends some text to the existing text in the NSTextView.

- (void)appendText:(NSString*)text {
	[actualText setSelectedRange:NSMakeRange([[actualText string] length],0)];
	[actualText insertText:text];
}

//	nowAction: connected to the "Now" button, sets the text to the current date and time.

- (IBAction)nowAction:(id)sender {
	[actualText setString:[[NSCalendarDate calendarDate] description]];
}

@end

