//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@protocol FDSelectFeedViewControllerDelegate;

@interface FDSelectFeedViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (readwrite, nonatomic, assign) id<FDSelectFeedViewControllerDelegate> delegate;

@property (readwrite, nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (NSManagedObjectContext*) managedObjectContext;

@end


@protocol FDSelectFeedViewControllerDelegate <NSObject>

@optional

- (void) feedSelector:(FDSelectFeedViewController*)selectFeedVc didSelectFeed:(NSManagedObject*)feedObject;

@end
