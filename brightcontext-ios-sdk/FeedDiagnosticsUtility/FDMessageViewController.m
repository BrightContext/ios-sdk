//
//  FDMessageViewController.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "FDMessageViewController.h"

@interface FDMessageViewController ()

@end

@implementation FDMessageViewController

@synthesize messageDetails, messageText;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.messageDetails.text = self.messageText;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
