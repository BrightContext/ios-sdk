//
//  TestListener.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BrightContext.h"

@interface TestListener : NSObject
<BCFeedListener>

@property (readwrite,retain) NSMutableArray* messagesReceived;
@property (readwrite,retain) NSMutableArray* messagesSent;
@property (readwrite,assign) NSUInteger numOpens;
@property (readwrite,assign) NSUInteger numCloses;
@property (readwrite,assign) NSUInteger numErrors;

@property (readwrite,retain) BCFeed* testFeed;

@end
