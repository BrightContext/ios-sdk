//
//  FDSelectFeedViewController.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

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
