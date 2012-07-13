//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <SenTestingKit/SenTestingKit.h>

#import "TestSettings.h"
#import "TestContext.h"

@interface SessionTests : SenTestCase

@property (readwrite,nonatomic,retain) TestContext* context;

@end
