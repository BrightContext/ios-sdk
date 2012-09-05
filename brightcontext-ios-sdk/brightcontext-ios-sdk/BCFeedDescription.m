//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCSerializable.h"
#import "BCFeedDescription.h"
#import "BCConstants.h"

@implementation BCFeedDescription

@synthesize type, procId, name, filters;

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.type = [data objectForKey:@"feedType"];
        self.name = [data objectForKey:@"name"];
        self.procId = [data objectForKey:@"id"];
        self.filters = [data objectForKey:@"filters"];
    }
    return self;
}

- (void)dealloc
{
    [procId release];
    [type release];
    [name release];
    [filters release];
    [super dealloc];
}

- (NSString *)description
{
    return [self toJson];
}

- (NSString *)toJson
{
    return [self JSONRepresentation];
}

@end



@implementation BCFeedSettings

+ (BCFeedSettings *)settingsWithDescription:(BCFeedDescription *)fd filterValues:(NSDictionary *)fv
{
    BCFeedSettings* settings = [[BCFeedSettings new] autorelease];
    settings.type = fd.type;
    settings.procId = fd.procId;
    settings.name = fd.name;
    settings.filters = fd.filters;
    settings.filterValues = fv;
    return settings;
}

@synthesize filterValues;

- (void)dealloc
{
    [filterValues release];
    [super dealloc];
}

- (NSString *)generateHashCode
{
    NSUInteger hashPropSize = 3 + (self.filters.count * 2);
    NSMutableArray* hashProps = [NSMutableArray arrayWithCapacity:hashPropSize];
    
    [hashProps addObject:self.type];
    [hashProps addObject:self.procId];
    if (self.name) {
        [hashProps addObject:self.name];
    }
    
    NSArray* sortedFilterPropNames = [self.filters sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* s1 = obj1;
        NSString* s2 = obj2;
        return [s1 compare:s2];
    }];
    
    for (NSString* filterPropName in sortedFilterPropNames) {
        [hashProps addObject:filterPropName];
        
        id filterValue = [self.filterValues objectForKey:filterPropName];
        [hashProps addObject:((filterValue) ? filterValue : @"(null)")];
    }
    
    NSString* hashCode = [hashProps JSONRepresentation];
    return hashCode;
}

- (NSString *)description
{
    return [self generateHashCode];
}

#pragma mark BCSerializable

- (id)proxyForJson
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [d setObject:self.procId forKey:BC_PARAM_PROC_ID];
    if (self.filterValues) {
        if (0 != [[self.filterValues allKeys] count]) {
            [d setObject:self.filterValues forKey:BC_PARAM_FILTERS];
        }
    }
    
    return d;
}

@end