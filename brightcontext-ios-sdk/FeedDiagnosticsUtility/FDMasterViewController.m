//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <SBJson.h>

#import "FDMasterViewController.h"

#import "FDTestSettings.h"

#import "FDDetailViewController.h"
#import "FDAppDelegate.h"
#import "FDTableCell.h"

@interface FDMasterViewController ()

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) loadChannelMetadata;
- (void) loadChannelMetadata:(BCChannelDescription*)channel;

@end

@implementation FDMasterViewController

@synthesize detailViewController = _detailViewController;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (FDDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:@" new feed" forKey:@"name"];
    [newManagedObject setValue:[NSNumber numberWithInt:0] forKey:@"procId"];
    [newManagedObject setValue:@"{ \"subChannel\" : \"DefaultThruFeed\" }" forKey:@"filter"];
    [newManagedObject setValue:BC_FEED_TYPE_THRU forKey:@"type"];
    
    FDAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];
}

- (void)loadChannelMetadata
{
    UIAlertView* v = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Channel Feeds", @"Load Channel Feeds") 
                                                message:NSLocalizedString(@"All feeds from this channel will be loaded into the feed list", @"All feeds from this channel will be loaded into the feed list")
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                      otherButtonTitles:NSLocalizedString(@"Load", @"Load"), nil];
    v.alertViewStyle = UIAlertViewStylePlainTextInput;
    [v show];
}

- (void)loadChannelMetadata:(BCChannelDescription *)channel
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = d.managedObjectContext;
    NSEntityDescription *feedDescr = [NSEntityDescription entityForName:@"Feed"
                                              inManagedObjectContext:ctx];
    for (int i=0; i < [channel feedDescriptionsCount]; ++i) {
        BCFeedDescription* fd = [channel feedDescriptionAtIndex:i];
        
        NSManagedObject* f = [[NSManagedObject alloc] initWithEntity:feedDescr
                                      insertIntoManagedObjectContext:ctx];
        [f setValue:fd.type forKey:@"type"];
        [f setValue:fd.procId forKey:@"procId"];
        
        [f setValue:[channel.name stringByAppendingFormat:@" - %@", fd.name] forKey:@"name"];
        
        NSMutableDictionary* filterExample = [NSMutableDictionary new];
        for (id k in fd.filters) {
            [filterExample setObject:@"default" forKey:k];
        }
        NSString* filterExampleJson = [filterExample JSONRepresentation];
        [f setValue:filterExampleJson forKey:@"filter"];
    }
    
    [d saveContext];
}

#pragma mark - UIAlertViewDelegate

@synthesize bc;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        NSString* channelName = [[alertView textFieldAtIndex:0] text];
        if (!channelName) {
            NSLog(@"BAIL: can't retrieve blank channel");
            return;
        }
        
        if (!self.bc) {
            TestContext* ctx = [TestContext new];
            ctx.settings = [FDTestSettings new];
            self.bc = ctx;
        }
        
        [self.bc establishConnection:^(NSError *err, BCSession *s) {
            if (err) {
                NSLog(@"Connection Error: %@", err);
            } else {
                FDTestSettings* s = (FDTestSettings*)bc.settings;
                NSString* projectName = [s testProject];
                BCCommand* getChannelDescription = [BCCommand channelDescription:channelName inProject:projectName];
                [self.bc sendRequest:getChannelDescription onResponse:^(BCEvent *evt) {
                    if ([evt isError]) {
                        NSLog(@"Channel Metadata Command Error: %@", evt.error);
                    } else {
                        NSDictionary* channelMd = [[evt message] rawData];
                        BCChannelDescription* channel = [[BCChannelDescription alloc] initWithDictionary:channelMd];
                        [self loadChannelMetadata:channel];
                    }
                }];
            }
        }];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField* tf = [alertView textFieldAtIndex:0];
    BOOL blank = ([tf.text isEqualToString:@""]);
    return !blank;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (indexPath.row < [sectionInfo numberOfObjects]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        FDButtonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        cell.buttonTitle.text = NSLocalizedString(@"Load Channel", @"Load Channel");
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    BOOL editable = (indexPath.row < [sectionInfo numberOfObjects]);
    return editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        FDAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        [delegate saveContext];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (indexPath.row < [sectionInfo numberOfObjects]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            self.detailViewController.detailItem = object;
        }
    } else {
        [self loadChannelMetadata];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

@synthesize fetchedResultsController = __fetchedResultsController;

- (NSManagedObjectContext *)managedObjectContext
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    return d.managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSFetchedResultsController* frc = [d fetchedResultsControllerForEntity:@"Feed"
                                                                  sortedBy:@"name"
                                                                 accending:YES];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"name"];
    cell.detailTextLabel.text = [object valueForKey:@"filter"];
}

@end
