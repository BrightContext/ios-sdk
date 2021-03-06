//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SRWebSocket.h"
#import "SBJson.h"

#import "BrightContext.h"
#import "BrightContext_Private.h"
#import "BCFeed_Private.h"

@implementation BrightContext

+ (NSString*) version
{
    return [NSString stringWithFormat:@"%d.%d.%d", BC_VERSION_MAJOR, BC_VERSION_MINOR, BC_VERSION_REV];
}

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
        _connectionEstablishedCompletionBlocks = [NSMutableArray new];
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
    
    [_connectionEstablishedCompletionBlocks release];
    [_sessionCreateOperation release];
    
    [super dealloc];
}

- (NSURL *)environmentURL
{
    return [NSURL URLWithString:BC_API_LOADBALANCER];
}

#pragma mark Registration and Dispatch

- (void)loadFeed:(BCFeed*)feed usingEvent:(BCEvent *)evt
{
    BCMessage* msg = evt.message;
    NSDictionary* feedSettings = msg.rawData;
    
    if (!feedSettings) {
        NSAssert(feedSettings != nil, @"Incomprehensible feed open response: %@", msg);
    } else {
        [feed loadSettings:feedSettings];
        feed.connection = self;
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
    [self.session parseNextSocketUrl];
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

+ (BCHTTPRequest*)createSessionUsingLoadBalancer:(NSURL *)loadBalancerRootUrl
                           usingApiKey:(NSString*)apiKey
                            completion:(void (^)(NSError *, BCSession *))completion
{
    NSURL* u = [BCURL urlWithRoot:loadBalancerRootUrl
                      forResource:BC_API_SESSION_CREATE];
    
    BCHTTPRequest* op = [BCHTTPRequest requestWithUrl:u
                                           withMethod:BCHTTPMethodPOST];
    
    [op addPayload:apiKey forKey:BC_PARAM_API_KEY];
    
    [op startWithCallback:^(BCHTTPResponse *result) {
        if (nil == result.error) {
            BCSession* newSession = [[BCSession alloc] initWithDictionary:[result responseObject]];
            
            completion(nil, newSession);
            
            [newSession release];
        } else {
            BCLog(@"Error establishing load balanced session: %@", result.error);
            completion(result.error, nil);
        }
    } async:YES];
    
    return op;
}

- (void)establishConnection:(BCSessionEstablishedCompletion)completion
{
    if ([self isConnected]) {
        // when connected, respond immediately
        completion(nil, self.session);
    } else {
        // queue up this completion
        BCSessionEstablishedCompletion b = [[completion copy] autorelease];
        [_connectionEstablishedCompletionBlocks addObject:b];
        
        // only the first time, fire the http request
        if (!_sessionCreateOperation) {
            NSURL* environmentUrl = self.environmentURL;
            NSString* apikey = self.apiKey;
            _sessionCreateOperation = [BrightContext createSessionUsingLoadBalancer:environmentUrl usingApiKey:apikey completion:^(NSError * err, BCSession * s) {
               if (err) {
                   [self failConnectionWithError:err];
               } else {
                   [self initializeConnectionWithSession:s];
               }
               
               [self fireConnectionEstablishedCompletionsWithError:err];
            }];
            
            [_sessionCreateOperation retain];
        }
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
}

- (void)fireConnectionEstablishedCompletionsWithError:(NSError*)error
{
    for (BCSessionEstablishedCompletion b in _connectionEstablishedCompletionBlocks) {
        @try {
            b(error, self.session);
        }
        @catch (NSException *ex) {
            BCLog(@"Exception in connection established callback: %@", ex);
        }
    }
    
    [_connectionEstablishedCompletionBlocks removeAllObjects];
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
    BOOL shouldReopen = ![self.session.sessionId isEqualToString:s.sessionId];
    
    self.session = s;
    BCConnection* conn = [[[BCConnection alloc] init] autorelease];
    conn.delegate = self;
    [conn connect];
    self.connection = conn;
    
    if (shouldReopen) {
        for (BCFeed* f in [self.dispatcher registeredFeeds]) {
            BCCommand* openFeedCmd = [BCCommand openFeed:f.metadata];
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
    [_sessionCreateOperation release];
    _sessionCreateOperation = nil;
    
    if (_autoReconnect) {
        BCMetricInc(kBCMetrics_streamReconnects);
        
        NSURL* environmentUrl = self.environmentURL;
        NSString* apikey = self.apiKey;
        _sessionCreateOperation = [BrightContext createSessionUsingLoadBalancer:environmentUrl usingApiKey:apikey completion:^(NSError * err, BCSession * newSession) {
           if (err) {
               [self failConnectionWithError:err];
           } else {
               [self restablishConnectionWithNewSession:newSession];
           }
        }];
        [_sessionCreateOperation retain];
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

#pragma Feeds

- (BCFeed*) openFeed:(BCFeed *)f listener:(id<BCFeedListener>)listener
{
    if (!f) return nil;
    
    return [self openFeedWithMetaData:f.metadata
                             listener:listener];
}

- (BCFeed*) openFeedWithMetaData:(BCFeedMetadata*)feedMetadata
                        listener:(id<BCFeedListener>)listener
{
    if (!feedMetadata) return nil;
    
    BCFeed* feed = [self.dispatcher registeredFeedMatchingMetadata:feedMetadata];
    
    if (feed) {
        return feed;
    } else {
        feed = [BCFeed feedWithMetadata:feedMetadata];
        
        [self.dispatcher registerFeed:feed];
        
        [self establishConnection:^(NSError *connErr, BCSession *s) {
            if (connErr) {
                // failed to connect
                [self dispatchError:connErr toListener:listener];
                [self.dispatcher unregisterFeed:feed];
            } else {
                BCCommand* openFeedCmd = [BCCommand openFeed:feedMetadata];
                [self sendRequest:openFeedCmd onResponse:^(BCEvent *evt) {
                    if (evt.isError) {
                        // failed to open feed
                        [self dispatchError:evt.error toListener:listener];
                        [self.dispatcher unregisterFeed:feed];
                    } else {
                        // success
                        [self loadFeed:feed usingEvent:evt];
                        [self.dispatcher indexRegisteredFeed:feed];
                        
                        if (listener) {
                            [self registerNewListener:listener
                                          forOpenFeed:feed];
                        }
                    }
                }];
            }
        }];
    }
    
    return feed;
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
    if (0 == [feeds count]) {
        completion(nil);
    } else {
        for (BCFeed* f in feeds) {
            [f stopRevoteTimer];
        }
        
        BCCommand* closeAll = [BCCommand closeFeeds:feeds];
        [self sendRequest:closeAll onResponse:completion];
    }
}

#pragma Listeners

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

#pragma Messaging

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

#pragma Server Info

- (void)getServerTime:(BCServerTimeCompletion)completion
{
    [self establishConnection:^(NSError *err, BCSession *s) {
        if (err) {
            completion(err, 0);
        } else {
            BCCommand* makeUniqueId = [BCCommand serverTime];
            [self sendRequest:makeUniqueId onResponse:^(BCEvent *evt) {
                if (evt.isError) {
                    completion(evt.error, 0);
                } else {
                    NSNumber* stime = [evt.message numberForKey:@"stime"];
                    NSTimeInterval t = BC_MAKENSREFSTAMP([stime doubleValue]);
                    completion(nil, t);
                }
            }];
        }
    }];
}

- (void)makeUniqueId:(BCUniqueIdCompletion)completion
{
    [self establishConnection:^(NSError *err, BCSession *s) {
        if (err) {
            completion(err, nil);
        } else {
            BCCommand* makeUniqueId = [BCCommand uniqueId];
            [self sendRequest:makeUniqueId onResponse:^(BCEvent *evt) {
                if (evt.isError) {
                    completion(evt.error, nil);
                } else {
                    NSString* uniqueId = [evt.message stringForKey:@"d"];
                    completion(nil, uniqueId);
                }
            }];
        }
    }];
}

#pragma -

- (void)shutdown:(BCShutdownCompletion)completion
{
    if ([self isConnected]) {
        [self stopHeartbeats];
        
        [self closeAllFeeds:^(BCEvent *evt) {
            _autoReconnect = NO;
            
            self.connection.delegate = nil;
            [self.connection disconnect];
            
            self.dispatcher = nil;
            self.connection = nil;
            
            [_sessionCreateOperation release];
            _sessionCreateOperation = nil;
            
            BCMetricPrint();
            
            completion(evt.error);
        }];
    } else {
        completion(nil);
    }
}

- (void)notifyListenersMessageSent:(BCMessage *)message withError:(NSError *)error onFeed:(BCFeed *)feed
{
    [self.dispatcher notifyListenersMessageSent:message withError:error onFeed:feed];
}

@end

