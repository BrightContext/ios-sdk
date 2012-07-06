//
//  ConnectionTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "ConnectionTests.h"

#import "TestListener.h"

@implementation ConnectionTests

@synthesize context, settings;

- (void)setUp
{
    // server timeout is 5 minutes, so we add a few seconds to that
    _socket_timeout = 305;
    
    self.settings = BC_TEST_SETTINGS;
    
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = self.settings;
    self.context = ctx;
}

- (void)tearDown
{
    self.context = nil;
}

- (void) testConnectionTimeout
{
    TestListener* feedListener = [[[TestListener alloc] init] autorelease];
    
    BCProject* p = [self.context loadProject:[self.settings testProject]];
    [p open:self.settings.unprotectedThruChannel listener:feedListener];
    
    spinwait(5);
    
    [self.context stopHeartbeats];
    [self.context setShouldAutoReconnect:NO];
    
    spinwait(_socket_timeout);
    
    STAssertFalse([self.context isConnected], @"");
    STAssertTrue(1 == feedListener.numOpens, @"");
    STAssertTrue(0 == feedListener.numErrors, @"");
    STAssertTrue(1 == feedListener.numCloses, @"");
}

- (void) testAutoReconnect
{
    TestListener* feedListener = [[[TestListener alloc] init] autorelease];
    
    BCProject* p = [self.context loadProject:[self.settings testProject]];
    [p open:self.settings.unprotectedThruChannel listener:feedListener];
    
    // wait for connection, check event counts, then go dark
    spinwait(5);
    
    STAssertTrue([self.context isConnected], @"");
    STAssertTrue(1 == feedListener.numOpens, @"");
    STAssertTrue(0 == feedListener.numErrors, @"");
    STAssertTrue(0 == feedListener.numCloses, @"");

    [self.context stopHeartbeats];
    
    // wait for idle timeout
    spinwait(_socket_timeout);
    BCMetricPrint();
    
    // wait for auto-reconnect
    spinwait(5);
    
    // should not see more 'open' or 'close' events on the feed
    STAssertTrue([self.context isConnected], @"");
    STAssertTrue(1 == feedListener.numOpens, @"");
    STAssertTrue(0 == feedListener.numErrors, @"");
    STAssertTrue(0 == feedListener.numCloses, @"");
    
    BCMetricPrint();
    
    // force shutdown
    [self.context shutdown:^(NSError *err) {
        STAssertNil(err, @"%@", err);
    }];

    spinwait(5);
    
    BCMetricPrint();
}

@end
