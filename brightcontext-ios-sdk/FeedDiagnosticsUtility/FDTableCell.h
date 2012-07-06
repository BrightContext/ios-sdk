//
//  FDTableCell.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

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