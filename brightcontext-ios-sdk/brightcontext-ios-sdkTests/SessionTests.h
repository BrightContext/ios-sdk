//
//  SessionTests.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "TestSettings.h"
#import "TestContext.h"

@interface SessionTests : SenTestCase

@property (readwrite,nonatomic,retain) TestContext* context;

@end
