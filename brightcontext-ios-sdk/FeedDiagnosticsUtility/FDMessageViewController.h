//
//  FDMessageViewController.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDMessageViewController : UIViewController

@property (strong, readwrite) IBOutlet UITextView* messageDetails;
@property (strong, readwrite) NSString* messageText;

@end
