//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

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
