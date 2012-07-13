//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDSettingEditViewController.h"
#import "FDAppDelegate.h"

@implementation FDSettingEditViewController

@synthesize editField, detailItem, propertyKey;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.editField.text = [self.detailItem valueForKey:self.propertyKey];
}

- (IBAction)done:(id)sender
{
    NSString* apiKeyValue = self.editField.text;

    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = d.managedObjectContext;
    
    if (!self.detailItem) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Context"
                                                  inManagedObjectContext:ctx];
        NSManagedObject* o = [[NSManagedObject alloc] initWithEntity:entity 
                                       insertIntoManagedObjectContext:ctx];
        self.detailItem = o;
    }
    
    [self.detailItem setValue:apiKeyValue forKey:self.propertyKey];
    
    NSError* saveError = nil;
    BOOL saveOk = [ctx save:&saveError];
    
    if (!saveOk) {
        NSLog(@"save error: %@", saveError);
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
