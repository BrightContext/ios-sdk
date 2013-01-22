//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDDetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITableViewDataSource, UIPopoverControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel* feedId;
@property (retain, nonatomic) IBOutlet UITextField *channelName;
@property (strong, nonatomic) IBOutlet UITextField *feedName;
@property (strong, nonatomic) IBOutlet UITextField *writeKey;
@property (strong, nonatomic) IBOutlet UITextField *feedFilter;
@property (strong, nonatomic) IBOutlet UITextView *feedFilterLarge;
@property (strong, nonatomic) IBOutlet UIScrollView *container;

@property (strong, nonatomic) UIPopoverController* settingsPopover;

@property (strong, nonatomic) IBOutlet UILabel *noItem;

- (NSString*) titleForFeedTypeId:(int)feedTypeId;
- (void) showFeedTypeTitle:(NSString *)title withId:(NSUInteger)procId;

- (IBAction)save:(id)sender;

@end
