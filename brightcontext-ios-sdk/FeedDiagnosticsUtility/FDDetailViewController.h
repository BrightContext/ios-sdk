//
//  FDDetailViewController.h
//  FeedDiagnosticsUtility
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDDetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UITextField *feedName;
@property (strong, nonatomic) IBOutlet UITextField *feedProcId;
@property (strong, nonatomic) IBOutlet UITextField *writeKey;
@property (strong, nonatomic) IBOutlet UITextField *feedFilter;
@property (strong, nonatomic) IBOutlet UITextView *feedFilterLarge;
@property (strong, nonatomic) IBOutlet UIButton *feedType;
@property (strong, nonatomic) IBOutlet UIStepper *procIdStepper;
@property (strong, nonatomic) IBOutlet UIScrollView *container;

@property (strong, nonatomic) UIPopoverController* feedTypePopover;
@property (strong, nonatomic) UIPopoverController* settingsPopover;

@property (strong, nonatomic) IBOutlet UILabel *noItem;

- (IBAction)typeTouchUpInside:(id)sender;
- (IBAction)stepperValueChanged:(id)sender;

- (NSString*) titleForFeedTypeId:(int)feedTypeId;
- (void) showFeedTypeTitle:(NSString*)title;

- (IBAction)save:(id)sender;

@end
