//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDTestViewController.h"
#import "TestContext.h"
#import "FDTestSettings.h"
#import "FDAppDelegate.h"
#import "FDMessageViewController.h"
#import "FDFeedMessagesViewController.h"
#import "FDTableCell.h"

@interface FDTestViewController (Private)

- (void) updateStatus:(NSString*)statusMessage;
- (void) log:(NSString*)logMessage;
- (void) clearLog;
- (void) openFeed:(NSManagedObject *)feedObject;
- (NSManagedObject*) feedEntityMatchingFeed:(BCFeed*)f;
- (void) saveMessage:(BCMessage*)message onFeed:(BCFeed*)feed;

- (UITableViewCell *) connectCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;
- (UITableViewCell *) feedCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;
- (UITableViewCell *) inputCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;
- (UITableViewCell *) logCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;
- (void)configureLogCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FDTestViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Private

@synthesize bc;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _openFeeds = [NSMutableArray new];
    _writableFeeds = [NSMutableArray new];
    
    // create a test context
    TestContext* ctx = [TestContext new];
    ctx.settings = [FDTestSettings new];
    self.bc = ctx;
    self.statusMessage = @"Context Loaded";
    
    // inject the auto-edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // inject the clear log button
    UIBarButtonItem* clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearLog)];
    self.navigationItem.rightBarButtonItem = clearButton;
}

- (NSManagedObject *)feedEntityMatchingFeed:(BCFeed *)f
{
    BCFeedSettings* fs = f.settings;
    NSDictionary* filterDictionary = fs.filterValues;
    NSMutableString* filterMatch = [NSMutableString stringWithFormat:@"procId = '%@'", fs.procId];
    for (NSString* k in [filterDictionary allKeys]) {
        [filterMatch appendString:@" AND "];
        NSString* v = [filterDictionary objectForKey:k];
        [filterMatch appendFormat:@"filter like '*%@*' and filter like '*%@*'", k, v];  // wtf, need a better way, sort keys, then do string match?
    }
    NSPredicate* feedFilterMatch = [NSPredicate predicateWithFormat:filterMatch];
    
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSArray* matchingFeeds = [d fetchResultsOfType:@"Feed" batchSize:1 predicate:feedFilterMatch];
    if (matchingFeeds.count == 1) {
        NSManagedObject* feedEntity = [matchingFeeds objectAtIndex:0];
        return feedEntity;
    } else {
        NSLog(@"Error: feed filter mismatch!  results: %@", matchingFeeds);
        return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openFeed"]) {
        FDSelectFeedViewController* openFeedDetail = [segue destinationViewController];
        [openFeedDetail setDelegate:self];
    } else if ([[segue identifier] isEqualToString:@"showMessage"]) {
        FDMessageViewController* messageDetail = [segue destinationViewController];
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[selectedRows objectAtIndex:0]];
        [messageDetail setMessageText:cell.textLabel.text];
        [messageDetail setTitle:cell.detailTextLabel.text];
    } else if ([[segue identifier] isEqualToString:@"showFeedMessages"]) {
        NSIndexPath* selectedPath = [self.tableView indexPathForSelectedRow];
        BCFeed* f = [_openFeeds objectAtIndex:selectedPath.row];
        NSManagedObject* feedEntity = [self feedEntityMatchingFeed:f];
        if (feedEntity) {
            FDFeedMessagesViewController* feedMessageDetail = [segue destinationViewController];
            feedMessageDetail.feed = feedEntity;
        }
    }
}

@synthesize statusMessage;

- (void) updateStatus:(NSString*)m
{
    [self.tableView beginUpdates];
    self.statusMessage = m;
    NSIndexPath* statusRow = [NSIndexPath indexPathForRow:0 inSection:ConnectSection];
    NSArray* updatedRows = [NSArray arrayWithObject:statusRow]; 
    [self.tableView reloadRowsAtIndexPaths:updatedRows
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self log:m];
}

- (void) log:(NSString*)logMessage
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = [d managedObjectContext];
    NSEntityDescription* descr = [NSEntityDescription entityForName:@"Log" inManagedObjectContext:ctx];
    NSManagedObject* logEntity = [[NSManagedObject alloc] initWithEntity:descr insertIntoManagedObjectContext:ctx];
    [logEntity setValue:logMessage forKey:@"message"];
    [logEntity setValue:[NSDate date] forKey:@"timestamp"];
    [d saveContext];
}

- (void)openFeed:(NSManagedObject *)feedObject
{
    [self updateStatus:[NSString stringWithFormat:@"Opening %@", [feedObject valueForKey:@"name"]]];
        
    if (!self.bc.isConnected) {
        [self updateStatus:@"Not Connected"];
    } else {
        BCFeedSettings* s = [BCFeedSettings new];
        
        s.type = [feedObject valueForKey:@"type"];
        s.name = [feedObject valueForKey:@"name"];
        s.procId = [feedObject valueForKey:@"procId"];
        
        NSString* filterJson = [feedObject valueForKey:@"filter"];
        NSDictionary* filter = [filterJson JSONValue];
        s.filterValues = filter;
        s.filters = [filter allKeys];
        
        [self.bc openFeedWithSettings:s listener:self];
    }
}

#pragma mark - BCFeedListener

- (void)didError:(NSError *)error
{
    NSString* errorMsg = [NSString stringWithFormat:@"Error: %@ %@", [error localizedDescription], [error userInfo]];
    [self log:errorMsg];
}

- (void)didOpenFeed:(BCFeed *)feed
{
    if (feed.isWriteProtected) {
        FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
        NSPredicate* procIdMatch = [NSPredicate predicateWithFormat:@"procId = %@", feed.procId];
        NSArray* storedFeeds = [d fetchResultsOfType:@"Feed" batchSize:1 predicate:procIdMatch];
        if (1 == storedFeeds.count) {
            NSManagedObject* feedEntity = [storedFeeds objectAtIndex:0];
            NSString* wk = [feedEntity valueForKey:@"writekey"];
            if (wk && ![@"" isEqualToString:wk]) {
                feed.writeKey = wk;
            } else {
                NSLog(@"Couldn't find write key for %@", feed);
            }
        } else {
            NSLog(@"Couldn't find stored feed for %@", feed);
        }
    }
    
    [self.tableView beginUpdates];
    NSMutableArray* insertedRows = [NSMutableArray array];
    NSIndexPath* feedIndexPath = [NSIndexPath indexPathForRow:_openFeeds.count
                                                    inSection:FeedsSection];
    [insertedRows addObject:feedIndexPath];
    [_openFeeds addObject:feed];
    
    if ((BCFeedType_Input == feed.type) || (BCFeedType_Through == feed.type)) {
        NSIndexPath* writableIndexPath = [NSIndexPath indexPathForRow:_writableFeeds.count
                                                            inSection:InputSection];
        [insertedRows addObject:writableIndexPath];
        [_writableFeeds addObject:feed];
    }
    
    [self.tableView insertRowsAtIndexPaths:insertedRows
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self updateStatus:[NSString stringWithFormat:@"%@ opened", feed.key]];
}

- (void)didSendMessage:(BCMessage *)message onFeed:(BCFeed *)feed
{
    [self updateStatus:@"Message Sent OK"];
    
    [self log:[NSString stringWithFormat:@"S : %@", [message toJson]]];
    
    //[self saveMessage:message onFeed:feed];
}

- (void) saveMessage:(BCMessage*)message onFeed:(BCFeed*)feed
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = [d managedObjectContext];
    NSEntityDescription* descr = [NSEntityDescription entityForName:@"Message"
                                             inManagedObjectContext:ctx];
    NSManagedObject* messageEntity = [[NSManagedObject alloc] initWithEntity:descr
                                              insertIntoManagedObjectContext:ctx];
    [messageEntity setValue:[message toJson]
                     forKey:@"payload"];
    [messageEntity setValue:[NSDate date]
                     forKey:@"timestamp"];
    NSManagedObject* feedEntity = [self feedEntityMatchingFeed:feed];
    [messageEntity setValue:feedEntity
                     forKey:@"feed"];
    [d saveContext];
}

- (void)didReceiveMessage:(BCMessage *)message onFeed:(BCFeed *)feed
{
    [self log:[NSString stringWithFormat:@"R : %@", [message toJson]]];
    
    [self saveMessage:message onFeed:feed];
}

- (void)didCloseFeed:(BCFeed *)feed
{
    [self.tableView beginUpdates];
    NSUInteger feedRowNumber = [_openFeeds indexOfObject:feed];
    NSMutableArray* deletedPaths = [NSMutableArray array];
    [deletedPaths addObject:[NSIndexPath indexPathForRow:feedRowNumber inSection:FeedsSection]];
    [_openFeeds removeObject:feed];
    if ((BCFeedType_Input == feed.type) || (BCFeedType_Through == feed.type)) {
        [deletedPaths addObject:[NSIndexPath indexPathForRow:[_writableFeeds indexOfObject:feed]
                                                   inSection:InputSection]];
        [_writableFeeds removeObject:feed];
    }
    
    [self.tableView deleteRowsAtIndexPaths:deletedPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self updateStatus:[NSString stringWithFormat:@"%@ closed", [feed key]]];
    
    if (_openFeeds.count == 0) {
        self.editing = NO;
    }
}

#pragma mark - UITextFieldDelegate

@synthesize isInputFocused;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.isInputFocused = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.isInputFocused = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger writableFeedIndex = textField.tag;
    BCFeed* f = [_writableFeeds objectAtIndex:writableFeedIndex];
    BCMessage* msg = [BCMessage messageFromString:textField.text];
    
    @try {
        [f send:msg];
    }
    @catch (NSException *ex) {
        NSLog(@"error sending message: %@", ex);
    }
    
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - FDSelectFeedViewControllerDelegate

- (void)feedSelector:(FDSelectFeedViewController *)selectFeedVc didSelectFeed:(NSManagedObject *)feedObject
{
    [self openFeed:feedObject];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case ConnectSection:
            return @"Connection";
        case FeedsSection:
            return @"Feeds";
        case InputSection:
            return @"Input";
        case LogSection:
            return @"Log";
            
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ConnectSection:
        {
            int buttonIndex = indexPath.row - 1;
            switch (buttonIndex) {
                case Connect:
                {
                    [self updateStatus:@"connecting..."];
                    [self.bc establishConnection:^(NSError *err, BCSession *s) {
                        [self updateStatus:@"connected"];
                    }];
                }
                    break;
                    
                case Disconnect:
                {
                    [self updateStatus:@"disconnecting..."];
                    [self.bc shutdown:^(NSError *err) {
                        [self updateStatus:@"disconnected"];
                    }];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            break;
        }
            
        case FeedsSection:
        {
        }
            break;
        
        case LogSection:
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.logFetchController sections] objectAtIndex:0];
            int numLogMessages = [sectionInfo numberOfObjects];
            if (indexPath.row == numLogMessages) {
                [self clearLog];
            }
        }
            break;
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = NumSections;
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ConnectSection:
            return ConnectSectionRowCount + 1;
            
        case FeedsSection:
            return _openFeeds.count + 1;
            
        case InputSection:
            return _writableFeeds.count;
        
        case LogSection:
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.logFetchController sections] objectAtIndex:0];
            return [sectionInfo numberOfObjects] + 1;
        }
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ConnectSection:
            return [self connectCellForRowAtIndexPath:indexPath inTable:tableView];
            
        case FeedsSection:
            return [self feedCellForRowAtIndexPath:indexPath inTable:tableView];
        
        case InputSection:
            return [self inputCellForRowAtIndexPath:indexPath inTable:tableView];
            
        case LogSection:
            return [self logCellForRowAtIndexPath:indexPath inTable:tableView];
            
        default:
            return nil;
    }
}

- (UITableViewCell *) connectCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    if (0 == indexPath.row) {
        FDStatusCell* cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        cell.message.text = self.statusMessage;
        return cell;
    } else {
        NSString* title = nil;
        int buttonIndex = indexPath.row - 1;

        switch (buttonIndex) {
            case Connect:
                title = @"Connect";
                break;
            case Disconnect:
                title = @"Disconnect";
                
            default:
                break;
        }
        
        FDButtonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        cell.buttonTitle.text = title;
        return cell;
    }
}

- (UITableViewCell *) feedCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    if (indexPath.row < _openFeeds.count) {
        FDFeedKeyCell* cell = [tableView dequeueReusableCellWithIdentifier:@"feedNameCell"];
        BCFeed* f = [_openFeeds objectAtIndex:indexPath.row];
        cell.feedKey.text = [f key];
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"selectFeedCell"];
        return cell;
    }
}

- (UITableViewCell *) inputCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    FDTextInputCell* cell = [tableView dequeueReusableCellWithIdentifier:@"inputTextCell"];
    BCFeed* f = [_writableFeeds objectAtIndex:indexPath.row];
    cell.inputText.placeholder = f.key;
    cell.inputText.tag = indexPath.row;
    cell.inputText.delegate = self;
    return cell;
}

- (UITableViewCell *) logCellForRowAtIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.logFetchController sections] objectAtIndex:0];
    int numLogMessages = [sectionInfo numberOfObjects];
    if (indexPath.row < numLogMessages) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
        [self configureLogCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        FDButtonCell* clearLogButton = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        clearLogButton.buttonTitle.text = @"Clear Log";
        return clearLogButton;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL editable = ((indexPath.section == FeedsSection)
                     &&
                     (indexPath.row < _openFeeds.count));
    return editable;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case FeedsSection:
            return @"Close";
            
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (FeedsSection != indexPath.section) {
        return;
    }
    
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        BCFeed* f = [_openFeeds objectAtIndex:indexPath.row];
        [f close];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate


- (NSManagedObjectContext *)managedObjectContext
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    return d.managedObjectContext;
}

- (void)setLogFetchController:(NSFetchedResultsController *)logFetchController
{
    _logFetchController = logFetchController;
}

- (NSFetchedResultsController *)logFetchController
{
    if (_logFetchController != nil) {
        return _logFetchController;
    }
    
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    
    NSFetchedResultsController* frc = [d fetchedResultsControllerForEntity:@"Log"
                                                                  sortedBy:@"timestamp"
                                                                 accending:NO];
    frc.delegate = self;
    self.logFetchController = frc;
    
	NSError *error = nil;
	if (![_logFetchController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return _logFetchController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//    }
//}

//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView* tableView = self.tableView;
//    NSIndexPath* logIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:LogSection];
//    NSIndexPath* logNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:LogSection];
//
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:logNewIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:logIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureLogCell:[tableView cellForRowAtIndexPath:logIndexPath] atIndexPath:logIndexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:logIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:logNewIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.isInputFocused) {
        [self.tableView reloadData];
    }
}

- (void)configureLogCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.logFetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    cell.textLabel.text = [object valueForKey:@"message"];
    
    static NSDateFormatter* fmt = nil;
    if (!fmt) {
        fmt = [[NSDateFormatter alloc] init];
        [fmt setDateStyle:NSDateFormatterShortStyle];
        [fmt setTimeStyle:NSDateFormatterShortStyle];
        [fmt setDoesRelativeDateFormatting:YES];
    }
    
    NSDate* ts = [object valueForKey:@"timestamp"];
    cell.detailTextLabel.text = [fmt stringFromDate:ts];
}

- (void)clearLog
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = d.managedObjectContext;
    NSArray* logMessages = [d fetchResultsOfType:@"Log" batchSize:10];
    for (NSManagedObject* logMessage in logMessages) {
        [ctx deleteObject:logMessage];
    }
    
    [d saveContext];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

@end

