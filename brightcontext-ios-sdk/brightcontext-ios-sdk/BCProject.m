//
//  BCProject.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BCProject.h"
#import "BCEvent.h"
#import "BCCommand.h"

@interface BCProject (Private)

- (void) loadChannel:(NSString*)channelName
          completion:(BCChannelDescriptionFetchCompletion)completion;
- (void) openChannel:(NSString*)channelName
          completion:(BCChannelDescriptionFetchCompletion)completion;

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

- (id)init
{
    self = [super init];
    if (self) {
        _channelMetadata = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [_channelMetadata release];
    [super dealloc];
}

#pragma Channel Metadata

- (void)loadChannel:(NSString *)channelName completion:(BCChannelDescriptionFetchCompletion)completion
{
    BCChannelDescription* cachedChannel = [_channelMetadata objectForKey:channelName];
    if (cachedChannel) {
        completion(cachedChannel, nil);
    } else {
        BCChannelDescriptionFetchCompletion b = [completion copy];
        BCCommand* getChannelDescription = [BCCommand channelDescription:channelName inProject:self.name];

        [self.connection sendRequest:getChannelDescription onResponse:^(BCEvent *evt) {
            if ([evt isError]) {
                b(nil, [evt error]);
            } else {
                NSDictionary* channelMd = [[evt message] rawData];
                BCChannelDescription* channel = [[[BCChannelDescription alloc] initWithDictionary:channelMd] autorelease];
                [_channelMetadata setObject:channel
                                     forKey:channelName];
                b(channel,nil);
            }
            [b release];
        }];
    }
}

- (void) openChannel:(NSString*)channelName completion:(BCChannelDescriptionFetchCompletion)completion
{
    BCChannelDescriptionFetchCompletion b = [completion copy];
    [self.connection establishConnection:^(NSError *connErr, BCSession *s) {
        if (connErr) {
            b(nil, connErr);
        } else {
            [self loadChannel:channelName
                   completion:b];
        }
        [b release];
    }];
}

#pragma Feeds and Listeners

- (void)open:(NSString *)unprocessedChannelName listener:(id<BCFeedListener>)listener
{
    [self open:unprocessedChannelName subchannel:nil listener:listener];
}

- (void)open:(NSString *)unprocessedChannelName subchannel:(NSString *)subchannelFilter listener:(id<BCFeedListener>)listener
{
    [self openChannel:unprocessedChannelName
           completion:^(BCChannelDescription *channel, NSError *err) {
               if (err) {
                   [self.connection dispatchError:err toListener:listener];
               } else {
                   NSAssert((1 == [channel feedDescriptionsCount]), @"should only see one feed description on unprocessed channels");
                   
                   BCFeedDescription* fd = [channel feedDescriptionAtIndex:0];
                   
                   NSString* subchannelName = (nil == subchannelFilter) ? fd.name : subchannelFilter;
                   
                   NSDictionary* filterValues = [NSDictionary dictionaryWithObject:subchannelName
                                                                            forKey:BC_PARAM_SUBCHANNEL];
                   
                   BCFeedSettings* fs = [BCFeedSettings settingsWithDescription:fd
                                                                   filterValues:filterValues];
                   
                   [self.connection openFeedWithSettings:fs listener:listener];
               }
           }];
}

- (void)open:(NSString *)processedChannelName feed:(NSString *)feedName listener:(id<BCFeedListener>)listener
{
    [self open:processedChannelName feed:feedName filter:nil listener:listener];
}

- (void)open:(NSString *)processedChannelName feed:(NSString *)feedName filter:(NSDictionary *)filters listener:(id<BCFeedListener>)listener
{
    [self openChannel:processedChannelName
           completion:^(BCChannelDescription *channel, NSError *err) {
               if (err) {
                   [self.connection dispatchError:err toListener:listener];
               } else {
                   if (0 == [channel feedDescriptionsCount]) {
                       NSError* invalidMd = [NSError errorWithDomain:kBCEventErrorDomain
                                                                code:kBCEventErrorCode_InvalidChannelMetadata
                                                            userInfo:[NSDictionary dictionaryWithObject:channel forKey:@"channel"]];
                       [self.connection dispatchError:invalidMd toListener:listener];
                   } else {
                       BCFeedDescription* fd = [channel feedDescriptionWithName:feedName];
                       if (!fd) {
                           NSError* noSuchFeedError = [NSError errorWithDomain:kBCEventErrorDomain
                                                                          code:kBCEventErrorCode_NoSuchFeedError
                                                                      userInfo:[NSDictionary dictionaryWithObject:channel forKey:@"channel"]];
                           [self.connection dispatchError:noSuchFeedError toListener:listener];
                       } else {
                           BCFeedSettings* fs = [BCFeedSettings settingsWithDescription:fd
                                                                           filterValues:filters];
                           [self.connection openFeedWithSettings:fs listener:listener];
                       }
                   }
               }
           }];
}


@end
