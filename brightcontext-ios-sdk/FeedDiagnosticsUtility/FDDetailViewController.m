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
@synthesize feedFilter = _feedFilter;
@synthesize feedFilterLarge = _feedFilterLarge;
@synthesize writeKey = _writeKey;
@synthesize container = _container;
@synthesize masterPopoverController = _masterPopoverController;
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
        
        self.channelName.text = [self.detailItem valueForKey:@"channel"];
        self.feedName.text = [self.detailItem valueForKey:@"name"];
        self.writeKey.text = [self.detailItem valueForKey:@"writekey"];
        NSString* filter = [self.detailItem valueForKey:@"filter"];
        self.feedFilter.text = filter;
        self.feedFilterLarge.text = filter;
        
        NSNumber* procId = [self.detailItem valueForKey:@"procId"];
        [self showFeedTypeTitle:[self.detailItem valueForKey:@"type"] withId:[procId unsignedIntegerValue]];
        
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
    [self setFeedName:nil];
    [self setFeedFilter:nil];
    [self setFeedFilterLarge:nil];
    [self setContainer:nil];
    [self setNoItem:nil];
    [self setWriteKey:nil];
    [self setChannelName:nil];
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

- (void)showFeedTypeTitle:(NSString *)title withId:(NSUInteger)procId
{
    if (title) {
        [self.feedId setText:[NSString stringWithFormat:@"%d - %@", procId, title]];
    } else {
        [self.feedId setText:@"Unknown"];
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

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.settingsPopover = nil;
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
