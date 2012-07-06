//
//  FDSettingsViewController.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDSettingsViewController : UITableViewController

@property (strong, readwrite) IBOutlet UILabel* apiKey;
@property (strong, readwrite) IBOutlet UILabel* host;
@property (strong, readwrite) IBOutlet UILabel* port;
@property (strong, readwrite) IBOutlet UILabel* apiRoot;
@property (strong, readwrite) IBOutlet UILabel* project;

@property (strong, readwrite) NSManagedObject* contextEntity;

@end
