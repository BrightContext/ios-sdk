//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import "BCSerializable.h"

@class BCMetrics;

@interface BCSession : NSObject <BCSerializable>

@property (readonly,nonatomic,retain) NSString* domain;
@property (readonly,nonatomic,retain) NSString* sessionId;
@property (readonly,nonatomic,assign) NSTimeInterval serverTime;

- (NSURL*) socketUrl;

@end
