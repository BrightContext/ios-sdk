//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import <BrightContext.h>
#import <BrightContext_Private.h>

#import "TestSettings.h"

@interface TestContext : BrightContext

@property (readwrite,nonatomic,retain) id<TestSettings> settings;

- (NSURL *)secureEnvironmentURL;

@end
