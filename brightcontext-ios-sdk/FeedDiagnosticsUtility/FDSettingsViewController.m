//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDSettingsViewController.h"
#import "FDAppDelegate.h"
#import "FDSettingEditViewController.h"
#import "FDTestSettings.h"

@interface FDSettingsViewController(Private)


@end

@implementation FDSettingsViewController

@synthesize contextEntity, apiKey, host, port, apiRoot, project;


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.contextEntity = [FDTestSettings fetchContextEntity];
    
    if (self.contextEntity) {
        self.apiKey.text = [self.contextEntity valueForKey:@"apikey"];
        self.apiRoot.text = [self.contextEntity valueForKey:@"apiroot"];
        self.host.text = [self.contextEntity valueForKey:@"host"];
        self.port.text = [self.contextEntity valueForKey:@"port"];
        self.project.text = [self.contextEntity valueForKey:@"testProject"];
    } else {
        self.apiKey.text = @"unknown";
        self.apiRoot.text = @"unknown";
        self.host.text = @"unknown";
        self.port.text = @"unknown";
        self.project.text = @"unknown";
    }
    
    [[self tableView] reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FDSettingEditViewController* detailView = segue.destinationViewController;
    detailView.detailItem = self.contextEntity;
    
    if ([[segue identifier] isEqualToString:@"editApiKey"]) {
        detailView.propertyKey = @"apikey";
        detailView.title = @"API Key";
    } else if ([[segue identifier] isEqualToString:@"editHost"]) {
        detailView.propertyKey = @"host";
        detailView.title = @"Host";
    } else if ([[segue identifier] isEqualToString:@"editPort"]) {
        detailView.propertyKey = @"port";
        detailView.title = @"Port";
    } else if ([[segue identifier] isEqualToString:@"editApiRoot"]) {
        detailView.propertyKey = @"apiroot";
        detailView.title = @"API Root Path";
    } else if ([[segue identifier] isEqualToString:@"editProjectName"]) {
        detailView.propertyKey = @"testProject";
        detailView.title = @"Project Name";
    }
}


@end
