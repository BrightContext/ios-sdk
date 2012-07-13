//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDMessageViewController : UIViewController

@property (strong, readwrite) IBOutlet UITextView* messageDetails;
@property (strong, readwrite) NSString* messageText;

@end
