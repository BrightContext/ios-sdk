//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDSettingsViewController : UITableViewController

@property (strong, readwrite) IBOutlet UILabel* apiKey;
@property (strong, readwrite) IBOutlet UILabel* host;
@property (strong, readwrite) IBOutlet UILabel* port;
@property (strong, readwrite) IBOutlet UILabel* apiRoot;
@property (strong, readwrite) IBOutlet UILabel* project;

@property (strong, readwrite) NSManagedObject* contextEntity;

@end
