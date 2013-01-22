//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SessionTests.h"


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
    
    NSString* apikey = [self.context.settings apiKey];
    STAssertNotNil(apikey, @"");
    
    __block NSError* testSessionError = nil;
    __block BCSession* testSession = nil;
    
    [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                      usingApiKey:apikey
                                       completion:^(NSError * err, BCSession * s) {
                                           ++executionCount;
                                           
                                           testSessionError = [err retain];
                                           testSession = [s retain];
                                       }];
    
    spinwait(2);
    
    STAssertEquals(1, executionCount, @"callback should have fired exactly once");
    
    STAssertNil(testSessionError, [testSessionError localizedDescription]);
    STAssertNotNil(testSession, @"Session should not be nil");
    
    NSLog(@"Session: %@", testSession);
    
    STAssertNotNil(testSession.sessionId, @"");
    STAssertTrue(0 != testSession.serverTime, @"");
    STAssertFalse(testSession.isSecure, @"");
}

- (void) testSecureSessionCreate
{
    __block int executionCount = 0;
    
    NSURL* environmentUrl = [self.context secureEnvironmentURL];
    STAssertNotNil(environmentUrl, @"");
    STAssertEqualObjects(@"https", [environmentUrl scheme], @"");
    
    NSString* apikey = [self.context.settings secureApiKey];
    STAssertNotNil(apikey, @"");
    
    __block NSError* testSessionError = nil;
    __block BCSession* testSession = nil;
    
    [BrightContext createSessionUsingLoadBalancer:environmentUrl
                                      usingApiKey:apikey
                                       completion:^(NSError * err, BCSession * s) {
                                           ++executionCount;
                                           
                                           testSessionError = [err retain];
                                           testSession = [s retain];
                                       }];
    
    spinwait(2);
    
    STAssertEquals(1, executionCount, @"callback should have fired exactly once");
    
    STAssertNil(testSessionError, [testSessionError localizedDescription]);
    STAssertNotNil(testSession, @"Session should not be nil");
    
    NSLog(@"Session: %@", testSession);
    
    STAssertNotNil(testSession.sessionId, @"");
    STAssertTrue(0 != testSession.serverTime, @"");
    STAssertTrue(testSession.isSecure, @"");
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
