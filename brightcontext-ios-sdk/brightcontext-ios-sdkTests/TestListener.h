//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

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
