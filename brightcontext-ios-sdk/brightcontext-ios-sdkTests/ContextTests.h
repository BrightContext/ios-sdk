//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the
// LICENSE file. You may not use this file except in
// compliance with the License.
//-----------------------------------------------------------------

#import <SenTestingKit/SenTestingKit.h>

#import "BrightContext.h"
#import "TestSettings.h"

@interface ContextTests : SenTestCase <BCFeedListener>

@property (readwrite,nonatomic,retain) BrightContext* context;
@property (readwrite,nonatomic,retain) BCFeed* feed;
@property (readwrite,nonatomic,retain) id<TestSettings> settings;

@end
