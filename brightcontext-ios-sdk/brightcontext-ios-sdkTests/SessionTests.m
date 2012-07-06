//
//  SessionTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "SessionTests.h"
#import "BCConstants.h"

@implementation SessionTests

@synthesize context;

- (void)dealloc
{
    [context release];
    [super dealloc];
}

- (void)setUp
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    self.context = ctx;
}

- (void)tearDown
{
    self.context = nil;
}

- (void) testSessionCreate
{
    __block int executionCount = 0;
    
    NSURL* environmentUrl = [self.context environmentURL];
    STAssertNotNil(environmentUrl, @"");
    
    NSString* apikey = [self.context apiKey];
    STAssertNotNil(apikey, @"");
    
    [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                      usingApiKey:apikey
                                       completion:^(NSError * err, BCSession * s) {
                                           ++executionCount;
                                           STAssertNil(err, [err localizedDescription]);
                                           STAssertNotNil(s, @"Session should not be nil");
                                           
                                           NSLog(@"Session: %@", s);
                                           
                                           STAssertNotNil(s.domain, @"");
                                           STAssertNotNil(s.sessionId, @"");
                                           STAssertTrue(0 != s.serverTime, @"");
                                       }];
    
    spinwait(2);
    
    STAssertEquals(1, executionCount, @"callback should have fired exactly once");
}

- (void) testShortApiKey
{
    __block int executionCount = 0;
    
    NSURL* environmentUrl = [self.context environmentURL];
    STAssertNotNil(environmentUrl, @"");
    
    NSString* apikey = @"badkey";
    
    [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                      usingApiKey:apikey
                                       completion:^(NSError * err, BCSession * s) {
                                           ++executionCount;
                                           STAssertNotNil(err, [err localizedDescription]);
                                           STAssertNil(s, @"");
                                           
                                           NSLog(@"Error: %@", err);
                                       }];
    
    spinwait(2);
    
    STAssertEquals(1, executionCount, @"callback should have fired exactly once");
}

- (void) testInvalidApiKey
{
    __block int executionCount = 0;
    
    NSURL* environmentUrl = [self.context environmentURL];
    STAssertNotNil(environmentUrl, @"");
    
    NSString* apikey = @"000000000000000000000000000000000000";
    
    [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                      usingApiKey:apikey
                                       completion:^(NSError * err, BCSession * s) {
                                           ++executionCount;
                                           STAssertNotNil(err, [err localizedDescription]);
                                           STAssertNil(s, @"");
                                           
                                           NSLog(@"Error: %@", err);
                                       }];
    
    spinwait(2);
    
    STAssertEquals(1, executionCount, @"callback should have fired exactly once");
}

@end
