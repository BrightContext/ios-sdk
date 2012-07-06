//
//  TestContext.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BrightContext.h"
#import "BrightContext_Private.h"
#import "TestSettings.h"

@interface TestContext : BrightContext

@property (readwrite,nonatomic,retain) id<TestSettings> settings;

@end
