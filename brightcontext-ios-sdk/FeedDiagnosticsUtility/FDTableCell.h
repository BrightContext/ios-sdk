//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDButtonCell : UITableViewCell

@property (readwrite, strong) IBOutlet UILabel* buttonTitle;

@end

@interface FDTextInputCell : UITableViewCell

@property (readwrite, strong) IBOutlet UITextField* inputText;

@end

@interface FDFeedKeyCell : UITableViewCell

@property (readwrite, strong) IBOutlet UILabel* feedKey;
@property (readwrite, strong) IBOutlet UILabel* messageCount;

@end

@interface FDStatusCell : UITableViewCell

@property (readwrite, strong) IBOutlet UILabel* message;

@end