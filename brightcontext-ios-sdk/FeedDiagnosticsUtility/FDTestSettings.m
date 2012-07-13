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
        return nil;
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

@end
