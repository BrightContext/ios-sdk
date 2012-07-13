//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <UIKit/UIKit.h>

@interface FDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL*) applicationDocumentsDirectory;

// core data store
- (void) saveContext;

- (NSArray*) fetchResultsOfType:(NSString*)objectType
                      batchSize:(int)size;

- (NSArray *)fetchResultsOfType:(NSString *)objectType
                      batchSize:(int)size
                      predicate:(NSPredicate*)predicate;

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName 
                                                        batchSize:(int)size
                                                          section:(NSString *)sectionNameKeyPath 
                                                        cacheName:(NSString*)cacheName 
                                                  sortDescriptors:(NSArray*)sortDescriptors
                                                        predicate:(NSPredicate*)predicate;

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName 
                                                         sortedBy:(NSString*)sortedPropertyName
                                                        accending:(BOOL)accending;

@end
