//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCConstants.h"
#import "BCSerializable.h"
#import "BCFeedDescription.h"
#import "BCFeedListener.h"
#import "BCChannelDescription.h"
#import "BCConnectionManager.h"

#import "BCProject.h"
#import "BCEvent.h"
#import "BCCommand.h"
#import "BCMessage.h"

@interface BCProject (Private)

- (BCFeed*) open:(NSString*)channelName connector:(NSString*)connectorName filters:(NSDictionary*)filterObject listener:(id<BCFeedListener>)listener;

@end


@implementation BCProject

+ (id)projectWithName:(NSString *)n inContext:(id<BCConnectionManager>)cm
{
    BCProject* p = [[BCProject new] autorelease];
    p.name = n;
    p.connection = cm;
    return p;
}

@synthesize name, connection;

- (void)dealloc
{
    [name release];
    [super dealloc];
}

#pragma Channel Metadata

- (void)loadChannel:(NSString *)channelName completion:(BCChannelDescriptionFetchCompletion)completion
{
    BCChannelDescriptionFetchCompletion b = [completion copy];
    BCCommand* getChannelDescription = [BCCommand channelDescription:channelName inProject:self.name];

    [self.connection sendRequest:getChannelDescription onResponse:^(BCEvent *evt) {
        if ([evt isError]) {
            b(nil, [evt error]);
        } else {
            NSDictionary* channelMd = [[evt message] rawData];
            BCChannelDescription* channel = [[[BCChannelDescription alloc] initWithDictionary:channelMd] autorelease];
            b(channel,nil);
        }
        [b release];
    }];
}

#pragma Feeds and Listeners

- (BCFeed*) open:(NSString*)channelName connector:(NSString*)connectorName filters:(NSDictionary*)filterObject listener:(id<BCFeedListener>)listener
{
    BCFeedMetadata* md = [BCFeedMetadata metadataWithProject:self.name
                                                     channel:channelName
                                                   connector:connectorName
                                                     filters:filterObject];
    return [self.connection openFeedWithMetaData:md
                                        listener:listener];
}

- (BCFeed*)open:(NSString *)unprocessedChannelName listener:(id<BCFeedListener>)listener
{
    return [self open:unprocessedChannelName
            connector:BC_FEED_DEFAULT_SUBCHANNEL
              filters:nil
             listener:listener];
}

- (BCFeed*)open:(NSString *)unprocessedChannelName subchannel:(NSString *)subchannelFilter listener:(id<BCFeedListener>)listener
{
    return [self open:unprocessedChannelName
            connector:subchannelFilter
              filters:nil
             listener:listener];
}

- (BCFeed*)open:(NSString *)processedChannelName feed:(NSString *)feedName listener:(id<BCFeedListener>)listener
{
    return [self open:processedChannelName
            connector:feedName
              filters:nil
             listener:listener];
}

- (BCFeed*)open:(NSString *)processedChannelName feed:(NSString *)feedName filter:(NSDictionary *)filters listener:(id<BCFeedListener>)listener
{
    return [self open:processedChannelName
            connector:feedName
              filters:filters
             listener:listener];
}


@end
