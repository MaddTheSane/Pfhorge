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
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

// *********************** Class Methods ***********************
+ (id)sharedErrorController {
    static ErrorNotificationWinController *sharedErrorController = nil;

    if (!sharedErrorController) {
        sharedErrorController = [[ErrorNotificationWinController alloc] init];
    }

    return sharedErrorController;
}

// *********************** Regular Methods ***********************
- (void)standardGenericErrorMsg:(NSString *)msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
    alert.informativeText = msg;
    
    [alert runModal];
}

- (void)standardGenericErrorMsg:(NSString *)msg title:(NSString *)title
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = title;
    alert.informativeText = msg;
    [alert addButtonWithTitle:NSLocalizedString(@"Darn!", @"Darn!")];
    
    [alert runModal];
}

- (void)standardInfoMsg:(NSString *)msg title:(NSString *)title
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.messageText = title;
    alert.informativeText = msg;
    
    [alert runModal];
}
@end
