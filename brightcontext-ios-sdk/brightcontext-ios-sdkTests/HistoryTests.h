//
//  HistoryTests.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "BrightContext.h"
#import "TestSettings.h"

@interface HistoryTests : SenTestCase <BCFeedListener>

@property (readwrite,nonatomic,retain) BrightContext* context;
@property (readwrite,nonatomic,retain) BCFeed* feed;
@property (readwrite,nonatomic,retain) id<TestSettings> settings; 

@end
