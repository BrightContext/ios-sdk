//
//  FDSettingEditViewController.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDSettingEditViewController : UIViewController

@property (strong,nonatomic) IBOutlet UITextField* editField;
@property (strong,nonatomic) NSManagedObject* detailItem;
@property (strong,nonatomic) NSString* propertyKey;

- (IBAction)done:(id)sender;

@end
