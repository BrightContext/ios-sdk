//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDAppDelegate.h"

#import "FDMasterViewController.h"

@implementation FDAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UITabBarController* tabBarController = (UITabBarController*) [[self window] rootViewController];
        UISplitViewController* splitViewController = (UISplitViewController*) [[tabBarController viewControllers] objectAtIndex:0];
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
//        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
//        FDMasterViewController *controller = (FDMasterViewController *)masterNavigationController.topViewController;
//        controller.managedObjectContext = self.managedObjectContext;
    } else {
//        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//        FDMasterViewController *controller = (FDMasterViewController *)navigationController.topViewController;
//        controller.managedObjectContext = self.managedObjectContext;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges]) {
                NSError *error = nil;
                BOOL saveOk = [managedObjectContext save:&error];
                if (!saveOk) {
                    NSLog(@"Unresolved error %@", error);
                }
            }
        }
    });
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FeedDiagnosticsUtility" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FeedDiagnosticsUtility.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    
    return __persistentStoreCoordinator;
}

- (NSArray *)fetchResultsOfType:(NSString *)objectType batchSize:(int)size
{
    return [self fetchResultsOfType:objectType batchSize:size predicate:nil];
}

- (NSArray *)fetchResultsOfType:(NSString *)objectType batchSize:(int)size predicate:(NSPredicate*)predicate
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = d.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType
                                              inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:size];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *fetchError = nil;
    NSArray* results = [ctx executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"fetch error: %@", fetchError);
        return nil;
    } else {
        return results;
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName batchSize:(int)size section:(NSString *)sectionNameKeyPath cacheName:(NSString*)cacheName sortDescriptors:(NSArray*)sortDescriptors predicate:(NSPredicate*)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:size];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    if (sortDescriptors) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
    return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName sortedBy:(NSString*)sortedPropertyName accending:(BOOL)accending
{
    NSArray* sortDescriptors = nil;
    if (sortedPropertyName) {
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortedPropertyName
                                                                       ascending:accending];
        sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    }
    
    return [self fetchedResultsControllerForEntity:entityName
                                         batchSize:20
                                           section:nil
                                         cacheName:@"Master"
                                   sortDescriptors:sortDescriptors
                                         predicate:nil];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
