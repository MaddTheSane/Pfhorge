//
//  ErrorNorificationWinController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
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


#import <Cocoa/Cocoa.h>

DEPRECATED_ATTRIBUTE
@interface ErrorNotificationWinController : NSWindowController
{
    IBOutlet NSPanel *genericErrorWindow;
    IBOutlet NSImageView *genericErrorWindowIcon;
    IBOutlet NSTextField *msgMain;
    IBOutlet NSTextField *msgTitle;
    IBOutlet NSButton *okButton;
}

// *********************** Class Methods ***********************
+ (ErrorNotificationWinController*)sharedErrorController;

// *********************** Other Methods ***********************


// *********************** Regular Methods ***********************
- (void)standardGenericErrorMsg:(NSString *)msg;
- (void)standardGenericErrorMsg:(NSString *)msg title:(NSString *)title;
- (void)standardInfoMsg:(NSString *)msg title:(NSString *)title;

// *********************** Accsessor Methods ***********************


// *********************** Action Methods ***********************
- (IBAction)genericOkButtonHit:(id)sender;

@end
