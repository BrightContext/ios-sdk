//
//  BCSession.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCSerializable.h"

@class BCMetrics;

@interface BCSession : NSObject <BCSerializable>

@property (readonly,nonatomic,retain) NSString* domain;
@property (readonly,nonatomic,retain) NSString* sessionId;
@property (readonly,nonatomic,assign) NSTimeInterval serverTime;

- (NSURL*) socketUrl;

@end
