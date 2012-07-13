//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCTimePoint.h"
#import "BCConstants.h"
#import "SBJson.h"

#define kASSET_KEY @"message"
#define kTS_KEY @"ts"

@implementation BCTimePoint

@synthesize timestamp, asset;

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.timestamp = [[data objectForKey:kTS_KEY] doubleValue];
        self.asset = [data objectForKey:kASSET_KEY];
    }
    return self;
}

- (id)initWithTime:(NSTimeInterval)t asset:(id)a
{
    self = [super init];
    if (self) {
        self.timestamp = t;
        self.asset = a;
    }
    return self;
}

- (void)dealloc {
    [asset release];
    [super dealloc];
}

- (NSString*) description
{
    return [self toJson];
}

- (BOOL)isEqual:(id)object
{
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[BCTimePoint class]]) {
        return NO;
    }
    
    BCTimePoint* otherTimepoint = (BCTimePoint*) object;
    if (!otherTimepoint) {
        return NO;
    }
    
    if (![otherTimepoint timestamp] == [self timestamp]) {
        return NO;
    }
    
    id otherAsset = [otherTimepoint asset];
    id thisAsset = [self asset];
    if ((nil == otherAsset) && (nil == thisAsset)) {
        return YES;
    } else {
        if (![otherAsset isEqual:[self asset]]) {
            return NO;
        }
    }
    
    return YES;
}

- (id)proxyForJson
{
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setObject:[NSNumber numberWithDouble:self.timestamp] forKey:kTS_KEY];
    if (asset) {
        [d setObject:self.asset forKey:kASSET_KEY];
    }
    return d;
}

- (NSString *)toJson
{
    return [self JSONRepresentation];
}

@end
