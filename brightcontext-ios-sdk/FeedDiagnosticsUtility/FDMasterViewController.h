//
//  FDMasterViewController.h
//  FeedDiagnosticsUtility
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class FDDetailViewController;

#import "TestContext.h"

@interface FDMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) FDDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic, readwrite) TestContext* bc;

- (NSManagedObjectContext*) managedObjectContext;

@end
