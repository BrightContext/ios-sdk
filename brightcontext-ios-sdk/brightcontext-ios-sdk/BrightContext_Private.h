//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BrightContext.h"

@interface BrightContext(Private)

- (void) failConnectionWithError:(NSError*)error;
- (void) initializeConnectionWithSession:(BCSession*)s;
- (void) fireConnectionEstablishedCompletionsWithError:(NSError*)error;
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

