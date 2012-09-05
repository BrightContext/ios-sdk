//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCSerializable.h"
#import "BCEvent.h"
#import "BCFeedDescription.h"
#import "BCFeed.h"
#import "BCConstants.h"

#import "BCCommand.h"

@interface BCCommand(Private)

+ (BCEventKey*) nextEventKey;

@end

@implementation BCCommand

+ (BCEventKey*)nextEventKey
{
    static unsigned int _lastUsedEventKey = 0;
    NSString* ek = [NSString stringWithFormat:@"%d", ++_lastUsedEventKey];
    return ek;
}

#pragma mark Factory Methods

+ (BCCommand*) serverTime
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    cmd.action = BCCommandActionType_GET;
    cmd.resource = BC_API_SERVER_TIME;
    return cmd;
}

+ (BCCommand*) heartbeat
{
    return [[BCCommandHeartbeat new] autorelease];
}

+ (BCCommand*) channelDescription:(NSString*)channelName inProject:(NSString*)projectName
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    cmd.action = BCCommandActionType_GET;
    cmd.resource = BC_API_CHANNEL_DESCRIPTION;
    
    [cmd setObject:channelName forParam:BC_PARAM_NAME];
    [cmd setObject:projectName forParam:BC_PARAM_PROJECT];
    
    return cmd;
}

+ (BCCommand *)openFeed:(BCFeedSettings*)settings;
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    cmd.action = BCCommandActionType_PUT;
    cmd.resource = BC_API_FEED_SESSION_CREATE;
    
    id settingsJson = [settings proxyForJson];
    [cmd setObject:settingsJson forParam:BC_PARAM_FEED];
    
    return cmd;
}

+ (BCCommand *)sendMessage:(BCMessage *)msg onFeed:(BCFeed *)feed
{
    return [self sendMessage:msg
                      onFeed:feed
           withActivityState:BCActivityState_NONE
                       forTS:nil];
}

+ (BCCommand *)sendMessage:(BCMessage *)msg onFeed:(BCFeed *)feed withActivityState:(BCActivityState)state forTS:(NSNumber *)tslot
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    
    cmd.action = BCCommandActionType_PUT;
    cmd.resource = BC_API_FEED_MESSAGE_CREATE;
    
    [cmd setObject:msg forParam:BC_PARAM_MESSAGE];
    
    NSMutableDictionary* md = [NSMutableDictionary dictionary];
    [md setObject:feed.key forKey:BC_PARAM_FEED_KEY];
    
    NSString* wk = feed.writeKey;
    if (wk) {
        [md setObject:wk forKey:BC_PARAM_WRITE_KEY];
    }
    
    switch (state) {
        case BCActivityState_INITIAL:
            [md setObject:BC_RSTATE_INITIAL forKey:BC_PARAM_STATE];
            break;
        case BCActivityState_UPDATE:
            [md setObject:BC_RSTATE_UPDATE forKey:BC_PARAM_STATE];
            break;
        case BCActivityState_REVOTE:
            [md setObject:BC_RSTATE_REVOTE forKey:BC_PARAM_STATE];
            break;
            
        default:
            break;
    }
    
    if ((BCActivityState_UPDATE == state) && tslot) {
        [md setObject:tslot forKey:BC_PARAM_TSLOT_U];
    }
    
    [cmd setObject:md forParam:BC_PARAM_METADATA];
    
    return cmd;
}

+ (BCCommand *)closeFeed:(BCFeed *)feed
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    
    cmd.action = BCCommandActionType_PUT;
    cmd.resource = BC_API_FEED_SESSION_DELETE;
    
    [cmd setObject:feed.key forParam:BC_PARAM_FEED_KEY_LIST];
    
    return cmd;
}

+ (BCCommand *)closeFeeds:(NSArray*)feeds
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    
    cmd.action = BCCommandActionType_PUT;
    cmd.resource = BC_API_FEED_SESSION_DELETE;
    
    NSUInteger numFeeds = [feeds count];
    NSUInteger lastEntry = numFeeds-1;
    NSMutableString* feedKeyList = [NSMutableString string];
    for (NSUInteger i = 0; i!=numFeeds; ++i) {
        BCFeed* f = [feeds objectAtIndex:i];
        [feedKeyList appendString:f.key];
        if (i != lastEntry) {
            [feedKeyList appendString:@","];
        }
    }
    
    [cmd setObject:feedKeyList forParam:BC_PARAM_FEED_KEY_LIST];
    
    return cmd;
}

+ (BCCommand *)getHistory:(BCFeed *)feed limit:(NSUInteger)limit ending:(NSDate*)ending
{
    BCCommand* cmd = [[BCCommand new] autorelease];
    
    cmd.action = BCCommandActionType_GET;
    cmd.resource = BC_API_FEED_MESSAGE_HISTORY;
    
    [cmd setObject:feed.key
          forParam:BC_PARAM_FEED_KEY];
    [cmd setObject:[NSNumber numberWithUnsignedInteger:limit]
          forParam:BC_PARAM_LIMIT];
    
    NSNumber* unixtimestamp = BC_MAKETIMESTAMP(ending);
    [cmd setObject:unixtimestamp
          forParam:BC_PARAM_SINCE_TS];
    
    return cmd;
}

#pragma mark - Instance

@synthesize action, resource, parameters;

- (id)init
{
    self = [super init];
    if (self) {
        self.parameters = [NSMutableDictionary dictionary];
        self.eventKey = [BCCommand nextEventKey];
    }
    return self;
}

- (void)dealloc
{
    [resource release];
    [parameters release];
    [super dealloc];
}

- (BCEventKey*)eventKey
{
    BCEventKey* ek = [self getParam:BC_PARAM_EVENT_KEY];
    return ek;
}

- (void)setEventKey:(BCEventKey*)eventKey
{
    [self setObject:eventKey forParam:BC_PARAM_EVENT_KEY];
}

- (NSString *)commandPath
{
    NSString* a = nil;
    switch (self.action) {
        case BCCommandActionType_PUT:
            a = BC_ACTION_POST;
            break;
            
        default:
            a = BC_ACTION_GET;
            break;
    }
    
    NSString* p = [NSString stringWithFormat:@"%@ %@", a, self.resource];
    return p;
}

- (void)setObject:(id)value forParam:(NSString *)key
{
    [self.parameters setObject:value forKey:key];
}

- (id)getParam:(NSString *)key
{
    id v = [self.parameters objectForKey:key];
    return v;
}

#pragma mark BCSerializable

- (id) proxyForJson
{
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    [d setObject:[self commandPath]
          forKey:BC_PARAM_COMMAND];
    
    NSDictionary* params = [self parameters];
    if (params) {
        [d setObject:params
              forKey:BC_PARAM_COMMAND_PARAMS];
    }
    
    BCLog(@"%@", d);
    
    return d;
}

- (NSString *)toJson
{
    return [self JSONRepresentation];
}

- (NSString *)description
{
    return [self JSONRepresentation];
}

@end


@implementation BCCommandHeartbeat

- (id) proxyForJson
{
    return [NSDictionary dictionaryWithObject:BC_HEARTBEAT_COMMAND
                                       forKey:BC_PARAM_COMMAND];
}

@end
