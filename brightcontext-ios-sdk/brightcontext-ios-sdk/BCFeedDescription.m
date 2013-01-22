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

+ (NSString *)sortedKvps:(NSDictionary *)data
{
    NSMutableArray* a = [NSMutableArray array];
    
    NSArray* allKeys = [data allKeys];
    NSArray* sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* s1 = obj1;
        NSString* s2 = obj2;
        return [s1 compare:s2];
    }];
    
    for (NSString* k in sortedKeys) {
        [a addObject:k];
        
        id v = [data objectForKey:k];
        if (!v) {
            [a addObject:@"(null)"];
        } else {
            if ([v isKindOfClass:[NSDictionary class]]) {
                [a addObject:[self sortedKvps:(NSDictionary*)v]];
            } else {
                [a addObject:v];
            }
        }
    }
    
    return [a JSONRepresentation];
}

@end

@implementation BCFeedMetadata

@synthesize projectName, channelName, connectorName, filters;

- (void)dealloc
{
    [projectName release];
    [channelName release];
    [connectorName release];
    [filters release];
    [super dealloc];
}

+ (BCFeedMetadata *)metadataWithProject:(NSString *)projectName channel:(NSString *)channelName connector:(NSString *)connectorName filters:(NSDictionary *)filterObject
{
    BCFeedMetadata* md = [[BCFeedMetadata new] autorelease];
    md.projectName = projectName;
    md.channelName = channelName;
    md.connectorName = connectorName;
    md.filters = filterObject;
    
    return md;
}

#pragma mark BCSerializable

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.projectName = [data objectForKey:@"project"];
        self.channelName = [data objectForKey:@"channel"];
        self.connectorName = [data objectForKey:@"connector"];
        self.filters = [data objectForKey:@"filters"];
    }
    return self;
}

- (NSString *)generateHashCode
{
    NSMutableArray* hashProps = [NSMutableArray arrayWithCapacity:4];
    
    if (self.projectName) {
        [hashProps addObject:self.projectName];
    }
    
    if (self.channelName) {
        [hashProps addObject:self.channelName];
    }
    
    if (self.connectorName) {
        [hashProps addObject:self.connectorName];
    }
    
    if (self.filters) {
        [hashProps addObject:self.filters];
    }
    
    NSString* hashCode = [hashProps JSONRepresentation];
    return hashCode;
}

- (id)proxyForJson
{
    NSMutableDictionary* proxy = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (self.projectName) {
        [proxy setObject:self.projectName forKey:@"project"];
    }
    
    if (self.channelName) {
        [proxy setObject:self.channelName forKey:@"channel"];
    }
    
    if (self.connectorName) {
        [proxy setObject:self.connectorName forKey:@"connector"];
    }
    
    if (self.filters) {
        [proxy setObject:self.filters forKey:@"filters"];
    }
    
    return proxy;
}

- (NSString *)description
{
    return [self toJson];
}

- (NSString *)toJson
{
    return [self JSONRepresentation];
}

- (BOOL)isEqual:(id)object
{
    if (!object) return NO;
    if (![object isKindOfClass:[BCFeedMetadata class]]) return NO;
    
    BCFeedMetadata* otherMd = (BCFeedMetadata*) object;
    BOOL projectNamesMatch = ((nil == self.projectName && nil == otherMd.projectName) || [self.projectName isEqual:otherMd.projectName]);
    if (!projectNamesMatch) return NO;
    
    BOOL channelNamesMatch = ((nil == self.channelName && nil == otherMd.channelName) || [self.channelName isEqual:otherMd.channelName]);
    if (!channelNamesMatch) return NO;
    
    BOOL connectorNamesMatch = ((nil == self.connectorName && nil == otherMd.connectorName) || [self.connectorName isEqual:otherMd.connectorName]);
    if (!connectorNamesMatch) return NO;
    
    BOOL filtersMatch = ((nil == self.filters && nil == otherMd.filters) || [self.filters isEqualToDictionary:otherMd.filters]);
    
    return filtersMatch;
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
    NSMutableArray* hashProps = [NSMutableArray arrayWithCapacity:4];
    
    if (self.type) {
        [hashProps addObject:self.type];
    }
    
    if (self.procId) {
        [hashProps addObject:self.procId];
    }
    
    if (self.name) {
        [hashProps addObject:self.name];
    }
    
    if (self.filterValues) {
        [hashProps addObject:[BCFeedDescription sortedKvps:self.filterValues]];
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
