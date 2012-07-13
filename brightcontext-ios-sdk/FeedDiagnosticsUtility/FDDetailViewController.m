//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDDetailViewController.h"
#import "FDAppDelegate.h"
#import "BrightContext.h"

@interface FDDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation FDDetailViewController

@synthesize detailItem = _detailItem;
@synthesize feedName = _feedName;
@synthesize feedProcId = _feedProcId;
@synthesize feedFilter = _feedFilter;
@synthesize feedFilterLarge = _feedFilterLarge;
@synthesize feedType = _feedType;
@synthesize writeKey = _writeKey;
@synthesize procIdStepper = _procIdStepper;
@synthesize container = _container;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize feedTypePopover = _feedTypePopover;
@synthesize noItem = _noItem;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        if (_detailItem) {
            // first save what we have before switching
            [self save:nil];
        }
        
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        if (self.noItem) {
            [UIView animateWithDuration:.3
                             animations:^{
                                 self.noItem.alpha = 0;
                             }];
        }
        
        if (self.container) {
            CGRect f = self.view.frame;
            CGFloat w = CGRectGetWidth(f);
            CGFloat h = CGRectGetHeight(f);
            self.container.contentSize = CGSizeMake(w, h * 1.25);
        }
        
        self.feedName.text = [self.detailItem valueForKey:@"name"];
        NSNumber* procId = [self.detailItem valueForKey:@"procId"];
        self.feedProcId.text = [NSString stringWithFormat:@"%@", procId];
        [self.procIdStepper setValue:[procId doubleValue]];
        self.writeKey.text = [self.detailItem valueForKey:@"writekey"];
        NSString* filter = [self.detailItem valueForKey:@"filter"];
        self.feedFilter.text = filter;
        self.feedFilterLarge.text = filter;
        
        [self showFeedTypeTitle:[self.detailItem valueForKey:@"type"]];
        
    } else {
        if (self.noItem) {
            [self.view bringSubviewToFront:self.noItem];
            
            [UIView animateWithDuration:.3
                             animations:^{
                                 self.noItem.alpha = 1;
                             }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)viewDidUnload
{
    [self setFeedTypePopover:nil];
    [self setFeedName:nil];
    [self setFeedProcId:nil];
    [self setFeedFilter:nil];
    [self setFeedType:nil];
    [self setProcIdStepper:nil];
    [self setFeedFilterLarge:nil];
    [self setContainer:nil];
    [self setNoItem:nil];
    [self setWriteKey:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)save:(id)sender
{
    if (!self.detailItem) {
        return;
    }
    
    NSManagedObject* o = self.detailItem;
    [o setValue:self.feedName.text forKey:@"name"];
    
    int procId = [self.feedProcId.text intValue];
    [o setValue:[NSNumber numberWithInt:procId] forKey:@"procId"];
    
    NSString* wk = self.writeKey.text;
    [o setValue:wk forKey:@"writekey"];
    
    NSString* filter = self.feedFilterLarge.text;
    if (!filter) {
        filter = self.feedFilter.text;
    }
    [o setValue:filter forKey:@"filter"];
    
    FDAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)titleForFeedTypeId:(int)feedTypeId
{
    switch (feedTypeId) {
        case 0:
            return BC_FEED_TYPE_THRU;
        case 1:
            return BC_FEED_TYPE_IN;
        case 2:
            return BC_FEED_TYPE_OUT;
            
        default:
            return @"";
    }
}

- (void)showFeedTypeTitle:(NSString *)title
{
    if (title) {
        [self.feedType setTitle:[NSString stringWithFormat:@"Type - %@", title]
                       forState:UIControlStateNormal];
    } else {
        [self.feedType setTitle:@"Type" forState:UIControlStateNormal];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Feeds", @"Feeds");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.container) {
        [self.container setContentOffset:CGPointMake(0, CGRectGetMinY(textField.frame)-44) animated:YES];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self titleForFeedTypeId:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString* title = [self titleForFeedTypeId:row];
    [self showFeedTypeTitle:title];
    
    [self.detailItem setValue:title forKey:@"type"];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         pickerView.transform = CGAffineTransformMakeTranslation(0, 180);
                     } completion:^(BOOL finished) {
                         [pickerView removeFromSuperview];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"UITableViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString* title = [self titleForFeedTypeId:indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* title = [self titleForFeedTypeId:indexPath.row];
    [self showFeedTypeTitle:title];
    
    [self.feedTypePopover dismissPopoverAnimated:YES];
    self.feedTypePopover = nil;
    
    [self.detailItem setValue:title forKey:@"type"];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.feedTypePopover) {
        self.feedTypePopover = nil;
    } else {
        self.settingsPopover = nil;
    }
}

#pragma mark - Control Handlers

- (IBAction)typeTouchUpInside:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.feedName resignFirstResponder];
        [self.feedProcId resignFirstResponder];
        [self.feedFilter resignFirstResponder];

        CGRect viewFrame = self.view.frame;
        CGFloat x = 0;
        CGFloat y = CGRectGetHeight(viewFrame);
        CGFloat w = CGRectGetWidth(viewFrame);
        CGFloat h = 180;
        CGRect pickerFrame = CGRectMake(x, y, w, h);
        UIPickerView* typePicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        [typePicker setShowsSelectionIndicator:YES];
        typePicker.dataSource = self;
        typePicker.delegate = self;
        
        [self.view addSubview:typePicker];
        
        [UIView animateWithDuration:.25
                         animations:^{
                             typePicker.frame = CGRectMake(x, y-h, w, h);
                         }];
        
    } else {
        UITableViewController* tableVc = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tableVc.tableView.delegate = self;
        tableVc.tableView.dataSource = self;
        
        UIPopoverController* popOverVc = [[UIPopoverController alloc] initWithContentViewController:tableVc];
        popOverVc.popoverContentSize = CGSizeMake(320, 150);
        popOverVc.delegate = self;
        
        self.feedTypePopover = popOverVc;
        [popOverVc presentPopoverFromRect:self.feedType.frame
                                   inView:self.view
                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                 animated:YES];
    }
}

- (IBAction)stepperValueChanged:(id)sender
{
    double v = [self.procIdStepper value];
    self.feedProcId.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:v]];
}

#pragma mark - Settings

@synthesize settingsPopover;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        if (self.settingsPopover) {
            [self.settingsPopover dismissPopoverAnimated:NO];
            self.settingsPopover = nil;
        }
        
        UIStoryboardPopoverSegue* popoverSegue = (UIStoryboardPopoverSegue*)segue;
        self.settingsPopover = popoverSegue.popoverController;
        self.settingsPopover.delegate = self;
    }
}


@end
