//
//  FDFeedMessagesViewController.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDFeedMessagesViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (strong, readwrite, nonatomic) NSManagedObject* feed;

@end
