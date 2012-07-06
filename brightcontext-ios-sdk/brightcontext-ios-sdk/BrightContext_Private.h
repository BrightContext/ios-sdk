//
//  BrightContext_Private.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BrightContext.h"

@interface BrightContext(Private)

- (void) failConnectionWithError:(NSError*)error;
- (void) initializeConnectionWithSession:(BCSession*)s;
- (void) restablishConnectionWithNewSession:(BCSession*)s;

- (NSURL*) environmentURL;

- (BCFeed*) registerOpenedFeedWithEvent:(BCEvent*)evt;
- (void) registerNewListener:(id<BCFeedListener>)listener forOpenFeed:(BCFeed*)feed;

- (void) startHeartbeats;
- (void) heartbeatTimerDidFire:(NSTimer*)t;
- (void) stopHeartbeats;

- (void) closeAllFeeds:(BCResponseHandlerCompletion)completion;
- (void) reconnectWithError:(NSError*)error;

@end

