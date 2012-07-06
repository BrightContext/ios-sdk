//
//  BrightContext.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BrightContext.h"
#import "BrightContext_Private.h"
#import "BCFeed_Private.h"

@implementation BrightContext

+ (id)contextWithApiKey:(NSString *)apikey
{
    BrightContext* ctx = [[BrightContext new] autorelease];
    ctx.apiKey = apikey;
    return ctx;
}

#pragma mark -

@synthesize apiKey, session, connection, dispatcher;

- (id)init
{
    self = [super init];
    if (self) {
        _activePollingEnabled = YES;
        _autoReconnect = YES;
    }
    return self;
}

- (void)dealloc
{
    if (_heartbeatTimer) {
        [self stopHeartbeats];
    }
    
    [apiKey release];
    [session release];
    [connection release];
    [dispatcher release];
    [super dealloc];
}

- (NSURL *)environmentURL
{
    return [NSURL URLWithString:BC_API_LOADBALANCER];
}

#pragma mark Registration and Dispatch

- (BCFeed*)registerOpenedFeedWithEvent:(BCEvent *)evt
{
    NSDictionary* feedData = nil;
    BCMessage* msg = evt.message;
    BCMessageVariantType msgT = msg.type;
    if (BCMessageVariant_Dictionary == msgT) {
        feedData = msg.rawData;
    } else if (BCMessageVariant_String == msgT) {
        id parsedData = [msg.rawData JSONValue];
        if ([parsedData isKindOfClass:[NSDictionary class]]) {
            feedData = parsedData;
        } 
    }
    
    if (!feedData) {
        NSAssert(feedData != nil, @"Incomprehensible feed open response: %@", msg);
        return nil;
    } else {
        BCFeed* feed = [[[BCFeed alloc] initWithDictionary:feedData] autorelease];
        feed.connection = self;
        
        [self.dispatcher registerFeed:feed];
        
        return feed;
    }
}

- (void) registerNewListener:(id<BCFeedListener>)listener forOpenFeed:(BCFeed*)feed;
{
    [self addListener:listener forFeed:feed];
    
    if ([listener respondsToSelector:@selector(didOpenFeed:)]) {
        [listener didOpenFeed:feed];
    }
}

- (void)dispatchError:(NSError *)err toListener:(id<BCFeedListener>)listener
{
    if ([listener respondsToSelector:@selector(didError:)]) {
        [listener didError:err];
    }
}

- (BCProject *)loadProject:(NSString *)projectName
{
    return [BCProject projectWithName:projectName inContext:self];
}

#pragma mark Heartbeats

- (void)startHeartbeats
{
    if (_heartbeatTimer) {
        [self stopHeartbeats];
    }
    
    _heartbeatTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:BC_HEARTBEAT_INTERVAL]
                                               interval:BC_HEARTBEAT_INTERVAL
                                                 target:self
                                               selector:@selector(heartbeatTimerDidFire:)
                                               userInfo:nil
                                                repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_heartbeatTimer
                                 forMode:NSRunLoopCommonModes];
}

- (void)heartbeatTimerDidFire:(NSTimer *)t
{
    BCCommand* hb = [BCCommand heartbeat];
    [self.connection send:hb];
}

- (void)stopHeartbeats
{
    [_heartbeatTimer invalidate];
    [_heartbeatTimer release];
    _heartbeatTimer = nil;
}

#pragma mark BCConnectionDelegate

- (NSURL *)socketUrlForConnection:(BCConnection *)conn
{
    return self.session.socketUrl;
}

- (void) connection:(BCConnection *)conn didParseEvent:(BCEvent *)event
{
    [self.dispatcher dispatch:event];
}

- (void)connectionDidOpen:(BCConnection *)conn
{
//    BCCommand* syncServerTime = [BCCommand serverTime];
//    [self sendRequest:syncServerTime onResponse:^(BCEvent *evt) {
//        BCLog(@"todo: calculate offset from %@", evt.message);
//    }];
    
    [self startHeartbeats];
}

- (void)connectionDidClose:(BCConnection *)conn
{
    [self reconnectWithError:nil];
}

- (void)connection:(BCConnection *)conn didError:(NSError *)error
{
    [self reconnectWithError:error];
}

#pragma mark BCConnectionManager

+ (void)createSessionUsingLoadBalancer:(NSURL *)loadBalancerRootUrl
                           usingApiKey:(NSString*)apiKey
                            completion:(void (^)(NSError *, BCSession *))completion
{
    NSURL* u = [BCURL urlWithRoot:loadBalancerRootUrl
                      forResource:BC_API_SESSION_CREATE
                   withParameters:[BCURL buildQueryString:BC_PARAM_API_KEY, apiKey, nil]];
    
    BCHTTPRequest* op = [BCHTTPRequest requestWithUrl:u
                                           withMethod:BCHTTPMethodPOST];
    
    [op startWithCallback:^(BCHTTPResponse *result) {
        if (nil == result.error) {
            BCSession* metadata = [[BCSession alloc] initWithDictionary:[result responseObject]];
            
            completion(nil, metadata);
            
            [metadata release];
        } else {
            BCLog(@"Error establishing load balanced session: %@", result.error);
            completion(result.error, nil);
        }
    } async:YES];
    
}

- (void)establishConnection:(BCSessionEstablishedCompletion)completion
{
    if ([self isConnected]) {
        completion(nil, self.session);
    } else {
        BCSessionEstablishedCompletion b = [completion copy];
        
        NSURL* environmentUrl = self.environmentURL;
        NSString* apikey = self.apiKey;
        [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                          usingApiKey:apikey
                                           completion:^(NSError * err, BCSession * s) {
                                               if (err) {
                                                   [self failConnectionWithError:err];
                                                   b(err, nil);
                                               } else {
                                                   [self initializeConnectionWithSession:s];
                                                   b(nil, s);
                                               }
                                               
                                               [b release];
                                           }];
    }
}

- (void)initializeConnectionWithSession:(BCSession *)s 
{
    self.session = s;
    
    BCConnection* conn = [[[BCConnection alloc] init] autorelease];
    conn.delegate = self;
    [conn connect];
    self.connection = conn;
    
    BCEventManager* evtMgr = [[[BCEventManager alloc] init] autorelease];
    self.dispatcher = evtMgr;
}

- (void)failConnectionWithError:(NSError *)error
{
    self.session = nil;
    
    if (self.connection) {
        [self.connection disconnect];
        self.connection = nil;
    }
    
    // TODO: metrics / post error notification
}

- (BOOL)shouldAutoReconnect
{
    @synchronized(self) {
        return _autoReconnect;
    }
}

- (void)setShouldAutoReconnect:(BOOL)enabled
{
    @synchronized(self) {
        _autoReconnect = enabled;
    }
}

- (void)restablishConnectionWithNewSession:(BCSession *)s
{
    BOOL shouldReopen = ![self.session.domain isEqualToString:s.domain];
    
    self.session = s;
    BCConnection* conn = [[[BCConnection alloc] init] autorelease];
    conn.delegate = self;
    [conn connect];
    self.connection = conn;
    
    if (shouldReopen) {
        for (BCFeed* f in [self.dispatcher registeredFeeds]) {
            BCCommand* openFeedCmd = [BCCommand openFeed:f.settings];
            [self sendRequest:openFeedCmd onResponse:^(BCEvent *evt) {
                if (evt.isError) {
                    [self.dispatcher notifyListenersFeedClosed:f withError:evt.error];
                    [self.dispatcher unregisterFeed:f];
                }
            }];
        }
    }
}

- (void)reconnectWithError:(NSError*)error
{
    [self stopHeartbeats];
    
    self.connection.delegate = nil;
    self.connection = nil;
    
    if (_autoReconnect) {
        BCMetricInc(kBCMetrics_streamReconnects);
        
        NSURL* environmentUrl = self.environmentURL;
        NSString* apikey = self.apiKey;
        [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                          usingApiKey:apikey
                                           completion:^(NSError * err, BCSession * newSession) {
                                               if (err) {
                                                   [self failConnectionWithError:err];
                                               } else {
                                                   [self restablishConnectionWithNewSession:newSession];
                                               }
                                           }];
    } else {
        for (BCFeed* f in [self.dispatcher registeredFeeds]) {
            [self.dispatcher notifyListenersFeedClosed:f withError:error];
        }
    }
}

- (BOOL)isConnected
{
    BOOL connected = (self.session && self.connection.isConnected && self.dispatcher);
    return connected;
}

- (BOOL)isActivePollingEnabled
{
    @synchronized(self) {
        return _activePollingEnabled;
    }
}

- (void)setActivePollingEnabled:(BOOL)enabled
{
    @synchronized(self) {
        _activePollingEnabled = enabled;
    }
}

- (void) openFeed:(BCFeed*)f
{
    [self openFeedWithSettings:f.settings listener:nil];
}

- (void) openFeed:(BCFeed *)f listener:(id<BCFeedListener>)listener
{
    [self openFeedWithSettings:f.settings listener:listener];
}

- (void) openFeedWithSettings:(BCFeedSettings *)fs listener:(id<BCFeedListener>)listener
{
    if (!fs) return;
    
    BCFeed* existingFeed = [self.dispatcher registeredFeedMatchingSettings:fs];
    if (existingFeed) {
        // feed already opened
        
        if (listener) {
            [self registerNewListener:listener
                          forOpenFeed:existingFeed];
        }
    } else {
        // open new feed
        
        BCCommand* openFeedCmd = [BCCommand openFeed:fs];
        [self sendRequest:openFeedCmd onResponse:^(BCEvent *evt) {
            if (evt.isError) {
                [self dispatchError:evt.error toListener:listener];
            } else {
                BCFeed* newlyOpenedFeed = [self registerOpenedFeedWithEvent:evt];
                
                if (listener) {
                    [self registerNewListener:listener
                                  forOpenFeed:newlyOpenedFeed];
                }
            }
        }];
    }
}

- (void) closeFeed:(BCFeed *)f
{
    if (!f) return;
    
    BCCommand* closeFeedCmd = [BCCommand closeFeed:f];
    
    [self sendRequest:closeFeedCmd onResponse:^(BCEvent *evt) {
        if ([evt isError]) {
            BCLog(@"Feed Close Error: %@", [evt error]);
        } else {
            BCLog(@"Feed Close OK: %@", [evt message]);
        }
        
        [self.dispatcher notifyListenersFeedClosed:f withError:[evt error]];
        
        [self.dispatcher unregisterFeed:f];
    }];
}

- (void)closeAllFeeds:(BCResponseHandlerCompletion)completion
{
    NSArray* feeds = [self.dispatcher registeredFeeds];
    for (BCFeed* f in feeds) {
        [f stopRevoteTimer];
    }
    
    BCCommand* closeAll = [BCCommand closeFeeds:feeds];
    [self sendRequest:closeAll onResponse:completion];
}

- (void)addListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed
{
    if (!listener) return;
    if (!feed) return;
    
    [self.dispatcher addListener:listener forFeed:feed];
}

- (void)removeListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed
{
    if (!listener) return;
    if (!feed) return;
    
    [self.dispatcher removeListener:listener forFeed:feed];
}

- (void) sendMessage:(BCMessage *)msg onFeed:(BCFeed *)feed
{
    if (!msg || !feed) return;
    
    if ((feed.isWriteProtected) && (nil == feed.writeKey)) {
        NSError* writeKeyError = [NSError errorWithDomain:kBCEventErrorDomain
                                                     code:kBCEventErrorCode_MissingWriteKey
                                                 userInfo:nil];
        [self.dispatcher notifyListenersMessageSent:msg
                                          withError:writeKeyError
                                             onFeed:feed];
        return; // bail early and avoid sending the command
    }
    
    BCCommand* sendMessage = [BCCommand sendMessage:msg onFeed:feed];
    
    [feed retain];
    [self sendRequest:sendMessage onResponse:^(BCEvent *evt) {
        if ([evt isError]) {
            BCLog(@"Message Send Error: %@", [evt error]);
        } else {
            BCLog(@"Message Sent: %@", [evt message]);
        }
        
        [self.dispatcher notifyListenersMessageSent:msg
                                          withError:[evt error]
                                             onFeed:feed];
        [feed release];
    }];
}

- (void)sendRequest:(BCCommand *)cmd onResponse:(BCResponseHandlerCompletion)callback
{
    [self.dispatcher addResponder:callback forEventKey:cmd.eventKey];
    [self.connection send:cmd];
}

- (void)shutdown:(BCShutdownCompletion)completion
{
    [self stopHeartbeats];
    
    [self closeAllFeeds:^(BCEvent *evt) {
        _autoReconnect = NO;
        
        self.connection.delegate = nil;
        [self.connection disconnect];
        
        self.dispatcher = nil;
        self.connection = nil;
        
        BCMetricPrint();
        
        completion(evt.error);
    }];
}

@end

