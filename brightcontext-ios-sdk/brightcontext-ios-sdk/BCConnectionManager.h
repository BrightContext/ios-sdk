//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

@class BCFeed;
@class BCFeedSettings;
@class BCMessage;
@class BCEvent;
@class BCCommand;
@class BCSession;
@protocol BCFeedListener;

typedef void(^BCSessionEstablishedCompletion)(NSError* err, BCSession* s);
typedef void(^BCResponseHandlerCompletion)(BCEvent* evt);
typedef void(^BCShutdownCompletion)(NSError* err);

@protocol BCConnectionManager <NSObject>

+ (void) createSessionUsingLoadBalancer:(NSURL *)loadBalancerRootUrl
                            usingApiKey:(NSString*)apiKey
                             completion:(BCSessionEstablishedCompletion)completion;

- (void) establishConnection:(BCSessionEstablishedCompletion)completion;

- (BOOL) isConnected;

- (BOOL) isActivePollingEnabled;
- (void) setActivePollingEnabled:(BOOL)enabled;

- (BOOL) shouldAutoReconnect;
- (void) setShouldAutoReconnect:(BOOL)enabled;

- (void) openFeed:(BCFeed*)f;
- (void) openFeed:(BCFeed*)f listener:(id<BCFeedListener>)listener;
- (void) openFeedWithSettings:(BCFeedSettings *)fs listener:(id<BCFeedListener>)listener;
- (void) closeFeed:(BCFeed*)f;

- (void) addListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed;
- (void) removeListener:(id<BCFeedListener>)listener forFeed:(BCFeed *)feed;

- (void) sendMessage:(BCMessage*)msg onFeed:(BCFeed*)feed;

- (void) sendRequest:(BCCommand *)cmd onResponse:(BCResponseHandlerCompletion)callback;

- (void) shutdown:(BCShutdownCompletion)completion;

- (void) dispatchError:(NSError*)error toListener:(id<BCFeedListener>)listener;

@end
