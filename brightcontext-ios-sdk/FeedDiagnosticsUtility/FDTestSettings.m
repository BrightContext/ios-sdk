//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "FDTestSettings.h"
#import "FDAppDelegate.h"

@implementation FDTestSettings


+ (NSManagedObject *)fetchContextEntity
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSArray* results = [d fetchResultsOfType:@"Context" batchSize:1];
    
    if (1 == results.count) {
        return [results objectAtIndex:0];
    } else {
        return [self injectDefaultSettings];
    }
}

+ (NSManagedObject *)injectDefaultSettings
{
    FDAppDelegate* d = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* ctx = d.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Context"
                                              inManagedObjectContext:ctx];
    NSManagedObject* o = [[NSManagedObject alloc] initWithEntity:entity 
                                  insertIntoManagedObjectContext:ctx];
    
    ProdSettings* prodSettings = [ProdSettings new];
    [o setValue:@"api key not set" forKey:@"apikey"];
    [o setValue:prodSettings.apiRoot forKey:@"apiroot"];
    [o setValue:prodSettings.host forKey:@"host"];
    [o setValue:[NSString stringWithFormat:@"%d", prodSettings.port] forKey:@"port"];
    [o setValue:@"Demo Apps" forKey:@"testProject"];
    
    NSError* saveError = nil;
    BOOL saveOk = [ctx save:&saveError];
    
    if (!saveOk) {
        NSLog(@"save error: %@", saveError);
        return nil;
    } else {
        return o;
    }
}

- (NSString *)apiKey
{
    return [[[self class] fetchContextEntity] valueForKey:@"apikey"];
}

- (NSString *)apiRoot
{
    return [[[self class] fetchContextEntity] valueForKey:@"apiroot"];
}

- (NSString *)host
{
    return [[[self class] fetchContextEntity] valueForKey:@"host"];
}

- (NSUInteger)port
{
    NSString* p = [[[self class] fetchContextEntity] valueForKey:@"port"];
    return [p integerValue];
}

- (NSString*)testProject
{
    return [[[self class] fetchContextEntity] valueForKey:@"testProject"];
}

@synthesize unprotectedThruChannel;
@synthesize protectedThruChannel;
@synthesize protectedThruChannelWriteKey;




@end
