//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

#import "BrightContext.h"

#import "FDSelectFeedViewController.h"

@interface FDTestViewController : UITableViewController
<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate, FDSelectFeedViewControllerDelegate, BCFeedListener>
{
    NSFetchedResultsController* _logFetchController;
    NSMutableArray* _openFeeds;
    NSMutableArray* _writableFeeds;
}

- (void) openFeed:(NSManagedObject*)feedObject;

@property (readwrite,strong) BrightContext* bc;
@property (readwrite,strong) NSString* statusMessage;
@property (readwrite,strong) NSFetchedResultsController* logFetchController;

@property (readwrite) BOOL isInputFocused;

@end

typedef enum {
    ConnectSection = 0,
    FeedsSection,
    InputSection,
    LogSection,
    NumSections
} FDTestViewControllerTableSections;

typedef enum {
    Connect = 0,
    Disconnect,
    ConnectSectionRowCount
} FDTestViewControllerConnectSectionRows;

