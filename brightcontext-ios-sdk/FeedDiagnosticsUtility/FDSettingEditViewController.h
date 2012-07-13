//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDSettingEditViewController : UIViewController

@property (strong,nonatomic) IBOutlet UITextField* editField;
@property (strong,nonatomic) NSManagedObject* detailItem;
@property (strong,nonatomic) NSString* propertyKey;

- (IBAction)done:(id)sender;

@end
