//
//  DateTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "DateTests.h"
#import "TestContext.h"
#import "TestListener.h"

@implementation DateTests

- (void) testDateOnThruFeed
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    
    TestListener* testListener = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:[ctx.settings testProject]];
    [p open:ctx.settings.unprotectedThruChannel listener:testListener];
    
    spinwait(2);
    
    BCFeed* f = testListener.testFeed;
    BCMessage* msgWithDate = [BCMessage message];
    [msgWithDate setDate:[NSDate date] forKey:@"d"];
    [f send:msgWithDate];
    
    spinwait(2);
    
    STAssertTrue(0 == testListener.numErrors, @"should not have encountered errors");
    STAssertTrue(1 == testListener.numOpens, @"");
    
    spinwait(1);
    
    STAssertTrue(1 == testListener.messagesReceived.count, @"");
    STAssertTrue(1 == testListener.messagesSent.count, @"");

    [f close];
    
    spinwait(1);
    
    STAssertTrue(1 == testListener.numCloses, @"");
}

- (void) testInvalidObjectOnMessageConstructor
{
    NSDate* dateObj = [NSDate date];
    NSString* dateKey = @"d";
    
    BCMessage* msgWithDate = [BCMessage messageFromDictionary:[NSDictionary dictionaryWithObject:dateObj forKey:dateKey]];
    NSString* jsonPayload = [msgWithDate toJson];
    
    STAssertTrue(nil == jsonPayload, @"");
}

- (void) testDateOnMessageField
{
    NSDate* dateObj = [NSDate date];
    NSString* dateKey = @"d";

    BCMessage* msgWithDate = [BCMessage message];
    [msgWithDate setDate:dateObj forKey:dateKey];
    NSString* jsonPayload = [msgWithDate toJson];
    
    STAssertTrue(nil != jsonPayload, @"");
    STAssertTrue(![@"" isEqualToString:jsonPayload], @"");
    
    // known issue: we lose subsecond date precision on ios to be javascript friendly
    int expected = [dateObj timeIntervalSinceReferenceDate];
    NSDate* d = [msgWithDate getDateForKey:dateKey];
    int actual = [d timeIntervalSinceReferenceDate];
    STAssertTrue(expected == actual, @"expected: %d actual: %d", expected, actual);
}

@end
