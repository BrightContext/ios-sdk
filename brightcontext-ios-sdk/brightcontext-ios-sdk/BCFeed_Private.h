//
//  BCFeed_Private.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

@class BCMessage;

@interface BCFeed (Private)

- (void) startRevoteTimer;
- (void) stopRevoteTimer;

- (void) sendInitial:(BCMessage*)msg;
- (void) sendUpdateDelta:(BCMessage*)msg;
- (void) revote:(NSTimer*)t;

@end

