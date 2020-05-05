#import "ErrorNotificationWinController.h"

@implementation ErrorNotificationWinController

- (IBAction)genericOkButtonHit:(id)sender
{
    [genericErrorWindow orderOut:self];
    [msgTitle setStringValue:@""];
    [msgMain setStringValue:@""];
}
// *********************** Overridden Methods ***********************

- (id)init
{
    self = [super initWithWindowNibName:@"Errors, Inc."];
    [self window];
    [msgTitle setStringValue:@""];
    [msgMain setStringValue:@""];
    return self;
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

// *********************** Class Methods ***********************
+ (id)sharedErrorController {
    static ErrorNotificationWinController *sharedErrorController = nil;

    if (!sharedErrorController) {
        sharedErrorController = [[ErrorNotificationWinController allocWithZone:[self zone]] init];
    }

    return sharedErrorController;
}

// *********************** Regular Methods ***********************
- (void)standardGenericError
{
    //int NSRunAlertPanel(NSString *title, NSString *msg,
    //		NSString *defaultButton, NSString *alternateButton,
    //		NSString *otherButton, ...)

    //[msgTitle setStringValue:@"Oh my, an error has manifested! :)"];
    //[msgMain setStringValue:@"This is a generic error with no message."];
    //[self showWindow:self];
    
    NSRunAlertPanel(@"Generic Error", @"This is a generic error with no message.", @"Ok", nil, nil);

}

- (void)standardGenericErrorMsg:(NSString *)msg
{
    //[msgTitle setStringValue:@"Oh my, an error has manifested! :)"];
    //[msgMain setStringValue:msg];
    
    //[self showWindow:self];
    
    NSRunAlertPanel(@"Generic Error", @"%@", @"Ok", nil, nil, msg);
}

- (void)standardGenericErrorMsg:(NSString *)msg title:(NSString *)title
{
    //[msgTitle setStringValue:title];
    //[msgMain setStringValue:msg];
    
    //[self showWindow:self];
    
    NSRunAlertPanel(title, @"%@", @"Darn!", nil, nil, msg);
//int NSRunInformationalAlertPanel(title, msg, @"Ok", nil, nil);
}

- (void)standardInfoMsg:(NSString *)msg title:(NSString *)title
{
    //[msgTitle setStringValue:title];
    //[msgMain setStringValue:msg];
    
    //[self showWindow:self];
    
    //NSRunAlertPanel(title, msg, @"Darn!", nil, nil);
    
    NSRunInformationalAlertPanel(title, @"%@", @"Ok", nil, nil, msg);
}
@end
