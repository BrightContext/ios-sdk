//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

@class BCMessage;

@interface BCFeed (Private)

- (void) startRevoteTimer;
- (void) stopRevoteTimer;

- (void) sendInitial:(BCMessage*)msg;
- (void) sendUpdateDelta:(BCMessage*)msg;
- (void) revote:(NSTimer*)t;

@end
