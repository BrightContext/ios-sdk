//
//  ConnectionTests.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "TestSettings.h"
#import "TestContext.h"

@interface ConnectionTests : SenTestCase
{
    int _socket_timeout;
}

@property (readwrite,nonatomic,retain) TestContext* context;
@property (readwrite,nonatomic,retain) id<TestSettings> settings;

@end
