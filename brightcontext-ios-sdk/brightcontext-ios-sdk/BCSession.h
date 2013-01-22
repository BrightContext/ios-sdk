//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

@protocol BCSerializable;
@class BCMetrics;

@interface BCSession : NSObject <BCSerializable>
{
    NSArray* _availableEndpoints;
    NSInteger _currentEndpointIndex;
}

@property (readonly,nonatomic,retain) NSString* sessionId;
@property (readonly,nonatomic,assign) NSTimeInterval serverTime;
@property (readonly,nonatomic,assign) BOOL isSecure;

@property (readwrite,nonatomic,retain) NSURL* socketUrl;

- (void) parseNextSocketUrl;

@end
