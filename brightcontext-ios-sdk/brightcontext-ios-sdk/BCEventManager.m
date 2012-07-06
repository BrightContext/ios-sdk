//
//  BCEventManager.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BCEventManager.h"
#import "BCConstants.h"


#pragma mark - NSDictionary Extensions

@implementation NSMutableDictionary (MutableSetValueExtensions)

- (NSMutableSet*) existingOrNewSetForKey:(id)key
{
    NSMutableSet* s = [self objectForKey:key];
    if (!s) {
        s = [NSMutableSet setWithCapacity:1];
    }
    return s;
}

- (void) addObject:(id)o toKey:(id)key
{
    NSMutableSet* s = [self existingOrNewSetForKey:key];
    [s addObject:o];
    [self setObject:s forKey:key];
}

- (void) removeObject:(id)o fromKey:(id)key
{
    NSMutableSet* s = [self existingOrNewSetForKey:key];
    [s removeObject:o];
    [self setObject:s forKey:key];
}

@end

#pragma mark - Private Methods

NSString* kBCEventManager_DispatchQueue = @"com.brightcontext.eventmanager.eventqueue";


@interface BCEventManager(Private)

- (NSArray*) filteredArrayUsingKeys:(NSArray*)fkListRequested thatShouldExist:(BOOL)existing;

- (void) dispatchMessage:(BCEvent*)messageEvent;
- (void) dispatchResponse:(BCEvent*)responseEvent;

- (void) enumerateListenersOnFeedKey:(BCFeedKey*)fk
                         andDispatch:(void(^)(BCFeed* feed, id<BCFeedListener> listener))asyncCallbackOnMain;

@end

#pragma mark -

@implementation BCEventManager

- (id)init
{
    self = [super init];
    if (self) {
        _feedKeyRegistry = [[NSMutableDictionary alloc] init];
        _feedCodeRegistry = [[NSMutableDictionary alloc] init];
        
        _feedListeners = [[NSMutableDictionary alloc] init];
        _responseListeners = [[NSMutableDictionary alloc] init];
        
        _mainQueue = dispatch_get_main_queue();
        _eventQueue = dispatch_queue_create([kBCEventManager_DispatchQueue cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    [_feedKeyRegistry release];
    [_feedCodeRegistry release];
    [_feedListeners release];
    [_responseListeners release];
    
    dispatch_release(_eventQueue);
    dispatch_release(_mainQueue);
    
    [super dealloc];
}

#pragma mark Feed Registry Collection Management

- (void)registerFeed:(BCFeed *)feed
{
    dispatch_sync(_eventQueue, ^{
        NSString* code = [feed.settings generateHashCode];
        [_feedCodeRegistry setObject:feed forKey:code];
        [_feedKeyRegistry setObject:feed forKey:feed.key];
    });
}

- (NSArray*) registeredFeeds
{
    __block NSArray* allRegistered = nil;
    dispatch_sync(_eventQueue, ^{
        allRegistered = [[_feedKeyRegistry allValues] copy];
    });
    return [allRegistered autorelease];
}

- (BCFeed *) registeredFeedMatchingSettings:(BCFeedSettings *)settings
{
    __block BCFeed* found = nil;
    dispatch_sync(_eventQueue, ^{
        NSString* code = [settings generateHashCode];
        found = [_feedCodeRegistry objectForKey:code];
    });
    return found;
}

- (BCFeed *)registeredFeedMatchingKey:(NSString *)feedKey
{
    __block BCFeed* found = nil;
    dispatch_sync(_eventQueue, ^{
        found = [_feedKeyRegistry objectForKey:feedKey];
    });
    return found;
}

- (void)unregisterFeed:(BCFeed *)feed
{
    dispatch_sync(_eventQueue, ^{
        BCFeedKey* fk = feed.key;
        
        // remove listeners
        [_feedListeners removeObjectForKey:fk];
        
        // remove feeds
        NSString* code = [feed.settings generateHashCode];
        [_feedCodeRegistry removeObjectForKey:code];
        [_feedKeyRegistry removeObjectForKey:fk];
    });
}

#pragma mark Listener Collection Management

- (void)addListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed
{
    if (!listener) return;
    if (!feed) return;
    
    dispatch_sync(_eventQueue, ^{
        [_feedListeners addObject:listener toKey:feed.key];
    });
}

- (void)removeListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed
{
    if (!listener) return;
    if (!feed) return;
    
    dispatch_sync(_eventQueue, ^{
        [_feedListeners removeObject:listener fromKey:feed.key];
    });
}

- (void)removeAllListeners
{
    dispatch_sync(_eventQueue, ^{
        [_feedListeners removeAllObjects];
    });
}

#pragma mark Responder Collection Management

- (void)addResponder:(BCResponseHandlerCompletion)responseBlock forEventKey:(BCEventKey *)eventKey
{
    BCResponseHandlerCompletion b;
    if (!responseBlock) {
        b = ^(BCEvent *evt) {
            BCLog(@"response ignored: %@", evt);
        };
    } else {
        b = [[responseBlock copy] autorelease];
    }
    
    dispatch_sync(_eventQueue, ^(void) {
        [_responseListeners setObject:b forKey:eventKey];
    });
}

- (void)removeResponderForEventKey:(BCEventKey *)eventKey
{
    dispatch_sync(_eventQueue, ^{
        BCResponseHandlerCompletion b = ^(BCEvent *evt) {
            BCLog(@"response removed: %@", evt);
        };
        [_responseListeners setObject:b forKey:eventKey];
    });
}
 
- (void)removeAllResponders
{
    dispatch_sync(_eventQueue, ^{
        [_responseListeners removeAllObjects];
    });
}

#pragma mark Event Dispatching

- (void)dispatch:(BCEvent *)event
{
    dispatch_async(_eventQueue, ^{
        switch (event.type) {
            case BCEventType_error:
                [self dispatchResponse:event];
                break;
            case BCEventType_message:
                [self dispatchMessage:event];
                break;
                
            case BCEventType_response:
                [self dispatchResponse:event];
                break;
                
            default:
                BCLog("Unknown event type, unable to dispatch: %@", event);
                break;
        }
    });
}

- (void)dispatchMessage:(BCEvent *)messageEvent
{
    BCLog(@"dispatchMessage: %@", messageEvent);
    
    BCFeedKey* feedKey = messageEvent.eventKey;
    BCMessage* msg = messageEvent.message;
    
    [self enumerateListenersOnFeedKey:feedKey andDispatch:^(BCFeed* f, id<BCFeedListener> listener) {
        if ([listener respondsToSelector:@selector(didReceiveMessage:onFeed:)]) {
            [listener didReceiveMessage:msg onFeed:f];
        }
    }];
    
}

- (void)dispatchResponse:(BCEvent *)responseEvent
{
    // ignore heartbeat responses
    BOOL isHeartbeatResponse = (
      (BCEventType_response == responseEvent.type)
      &&
      (BCMessageVariant_Dictionary == responseEvent.message.type)
      &&
      ([BC_HEARTBEAT_COMMAND isEqualToString:([((NSDictionary*)responseEvent.message.rawData) objectForKey:@"message"])])
    );
    if (isHeartbeatResponse) {
        return;
    } else {
        BCLog(@"dispatchResponse: %@", responseEvent);
    }
    
    BCEventKey* ek = responseEvent.eventKey;
    BCResponseHandlerCompletion block = [[_responseListeners objectForKey:ek] retain];
    
    if (!block) {
        BCLog(@"Null response handler for key: %@", ek);
    } else {
        dispatch_async(_mainQueue, ^{
            block(responseEvent);
            [block release];
        });
        
        [_responseListeners removeObjectForKey:ek];
    }
}


- (void)notifyListenersMessageSent:(BCMessage *)message withError:(NSError *)error onFeed:(BCFeed *)feed
{
    BCLog(@"notifyListenersMessageSent: %@ withError: %@ onFeed: %@",
          message, error, feed);
    
    dispatch_async(_eventQueue, ^{
        [self enumerateListenersOnFeedKey:feed.key andDispatch:^(BCFeed* f, id<BCFeedListener> listener) {
            if (error) {
                if ([listener respondsToSelector:@selector(didError:)]) {
                    [listener didError:error];
                }
            } else {
                if ([listener respondsToSelector:@selector(didSendMessage:onFeed:)]) {
                    [listener didSendMessage:message onFeed:f];
                }
            }
        }];
    });
}

- (void)notifyListenersFeedClosed:(BCFeed *)feed withError:(NSError *)error
{
    dispatch_async(_eventQueue, ^{
        [self enumerateListenersOnFeedKey:feed.key andDispatch:^(BCFeed *f, id<BCFeedListener> listener) {
            if (error) {
                if ([listener respondsToSelector:@selector(didError:)]) {
                    [listener didError:error];
                }
            } else {
                if ([listener respondsToSelector:@selector(didCloseFeed:)]) {
                    [listener didCloseFeed:f];
                }
            }
        }];
    });
}

- (void) enumerateListenersOnFeedKey:(BCFeedKey*)fk andDispatch:(void(^)(BCFeed* feed, id<BCFeedListener> listener))asyncCallbackOnMain
{
    // assuming we are on _eventQueue
    
    BCFeed* feed = [_feedKeyRegistry objectForKey:fk];
    if (!feed) {
        BCLog(@"unknown feed: %@", fk);
    } else {
        NSMutableSet* s = [_feedListeners objectForKey:fk];
        NSUInteger count = [s count];
        if (0 != count) {
            NSEnumerator* e = [s objectEnumerator];
            id<BCFeedListener> listener = [e nextObject];
            
             while (listener) {
                dispatch_async(_mainQueue, ^{
                    asyncCallbackOnMain(feed, listener);
                });
                
                listener = [e nextObject];
            }
            
        } else {
            BCLog(@"no listeners on feed: %@", feed);
        }
    }
}


@end


