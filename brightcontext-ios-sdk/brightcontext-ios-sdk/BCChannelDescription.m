//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCChannelDescription.h"

@implementation BCChannelDescription

@synthesize name, type;

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.name = [data objectForKey:@"channelName"];
        self.type = ([@"PROCESSED" isEqualToString:[data objectForKey:@"channelType"]]) 
            ? BCChannelType_Processed : BCChannelType_Unprocessed;
        
        NSArray* feedDescriptions = [data objectForKey:@"feeds"];
        if (feedDescriptions) {
            _feedDescriptions = [[NSMutableArray alloc] initWithCapacity:[feedDescriptions count]];
            
            for (NSDictionary* fd in feedDescriptions) {
                BCFeedDescription* fdo = [[BCFeedDescription alloc] initWithDictionary:fd];
                [_feedDescriptions addObject:fdo];
                [fdo release];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [_feedDescriptions release];
    [super dealloc];
}

- (NSUInteger)feedDescriptionsCount
{
    return [_feedDescriptions count];
}

- (BCFeedDescription *)feedDescriptionAtIndex:(NSUInteger)index
{
    if (index < [_feedDescriptions count]) {
        return [_feedDescriptions objectAtIndex:index];
    } else {
        return nil;
    }
}

- (BCFeedDescription *)feedDescriptionWithName:(NSString *)feedName
{
    __block BCFeedDescription* found = nil;
    [_feedDescriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BCFeedDescription* fd = obj;
        if ([feedName isEqualToString:fd.name]) {
            found = fd;
        }
    }];
    return found;
}

@end
