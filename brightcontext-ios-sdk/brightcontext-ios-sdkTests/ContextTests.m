//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the
// LICENSE file. You may not use this file except in
// compliance with the License.
//-----------------------------------------------------------------

#import "ContextTests.h"
#import "TestContext.h"

@implementation ContextTests

@synthesize context, feed, settings;

- (void)setUp
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    self.context = ctx;
    
    self.feed = nil;
    self.settings = ctx.settings;
}

- (void)tearDown
{
    [self.context shutdown:^(NSError *err) {
        STAssertNil(err, @"");
    }];
    
    spinwait(5);
}

- (void) testVersion
{
    NSString* versionNumber = [BrightContext version];
    STAssertEqualObjects(@"1.8.0", versionNumber, @"");
}

- (void) testSystemTime
{
    __block int numcallbacks = 0;
    
    [self.context getServerTime:^(NSError *err, NSTimeInterval serverTime) {
        ++numcallbacks;
        
        STAssertNil(err, @"");
        STAssertTrue(serverTime != 0, @"");
    }];
    
    spinwait(5);
    
    STAssertEquals(1, numcallbacks, @"");
}

- (void) testUniqueId
{
    __block int numcallbacks = 0;
    
    [self.context makeUniqueId:^(NSError *err, NSString *uniqueId) {
        ++numcallbacks;
        
        STAssertNil(err, @"");
        STAssertNotNil(uniqueId, @"");
        STAssertTrue(36 == [uniqueId length], @"");
    }];
    
    spinwait(5);
    
    STAssertEquals(1, numcallbacks, @"");
}

@end
