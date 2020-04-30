//
//  PhDefaultLayerController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Dec 18 2001.
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



#import <AppKit/AppKit.h>


@interface PhDefaultLayerController : NSWindowController <NSTableViewDataSource>
{
    IBOutlet id tableView;
    
    IBOutlet id nameTB;
    
    IBOutlet id floorMaxTB;
    IBOutlet id floorMinTB;
    IBOutlet id ceilingMaxTB;
    IBOutlet id ceilingMinTB;
    
    IBOutlet id floorMaxSB;
    IBOutlet id floorMinSB;
    IBOutlet id ceilingMaxSB;
    IBOutlet id ceilingMinSB;
    
    NSMutableArray *records;
}

+ (PhDefaultLayerController  *)sharedLayerDefaultsController;

-(IBAction)revertToSavedPrefs:(id)sender;
-(IBAction)addRecord:(id)sender;
-(IBAction)insertRecord:(id)sender;
-(IBAction)deleteRecord:(id)sender;
-(IBAction)saveToPrefs:(id)sender;
-(IBAction)changeBtn:(id)sender;
-(IBAction)changeName:(id)sender;

-(NSDictionary *)createRecord;

@end
