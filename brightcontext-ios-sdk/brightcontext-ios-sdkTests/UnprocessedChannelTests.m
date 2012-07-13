//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "UnprocessedChannelTests.h"

#import "BrightContext.h"
#import "TestContext.h"
#import "TestSettings.h"
#import "TestListener.h"


@implementation UnprocessedChannelTests

- (void) testDefaultThruFeed
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    
    TestListener* testListener = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:ctx.settings.testProject];
    [p open:ctx.settings.unprotectedThruChannel listener:testListener];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");
    
    NSDictionary* hello = [NSDictionary dictionaryWithObject:@"ios" forKey:@"hello"];
    BCMessage* msg = [BCMessage messageFromDictionary:hello];
    [testListener.testFeed send:msg];
    
    spinwait(3);

    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(1 == testListener.messagesSent.count, @"");
    
    spinwait(30);
    
    // receive our own message echo'd back
    STAssertTrue(1 == testListener.messagesReceived.count, @"");
    
    spinwait(3);
    
    [testListener.testFeed close];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(1 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(1 == testListener.messagesSent.count, @"");
    STAssertTrue(1 == testListener.messagesReceived.count, @"");
}

- (void) testWriteKeyOnThruFeed
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    
    TestListener* testListener = [[TestListener new] autorelease];

    BCProject* p = [ctx loadProject:ctx.settings.testProject];
    [p open:ctx.settings.protectedThruChannel listener:testListener];

    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");

    NSDictionary* hello = [NSDictionary dictionaryWithObject:@"ios" forKey:@"hello"];
    BCMessage* msg = [BCMessage messageFromDictionary:hello];
    [testListener.testFeed setWriteKey:ctx.settings.protectedThruChannelWriteKey];
    [testListener.testFeed send:msg];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(1 == testListener.messagesSent.count, @"");
    
    spinwait(30);
    
    // receive our own message echo'd back
    STAssertTrue(1 == testListener.messagesReceived.count, @"");
    
    spinwait(3);
    
    [testListener.testFeed close];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(1 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(1 == testListener.messagesSent.count, @"");
    STAssertTrue(1 == testListener.messagesReceived.count, @"");
}


- (void) testWriteKeyFailureOnThruFeed
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    
    TestListener* testListener = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:ctx.settings.testProject];
    [p open:ctx.settings.protectedThruChannel listener:testListener];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(0 == testListener.numErrors, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");
    
    NSDictionary* hello = [NSDictionary dictionaryWithObject:@"ios" forKey:@"hello"];
    BCMessage* msg = [BCMessage messageFromDictionary:hello];
    [testListener.testFeed send:msg];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(0 == testListener.numCloses, @"");
    STAssertTrue(1 == testListener.numErrors, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");
    
    spinwait(30);
    
    // will not receive our own message echo'd back, invalid write key
    STAssertTrue(0 == testListener.messagesReceived.count, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");
    
    spinwait(3);
    
    [testListener.testFeed close];
    
    spinwait(3);
    
    STAssertTrue(1 == testListener.numOpens, @"");
    STAssertTrue(1 == testListener.numCloses, @"");
    STAssertTrue(1 == testListener.numErrors, @"");
    STAssertTrue(0 == testListener.messagesSent.count, @"");
    STAssertTrue(0 == testListener.messagesReceived.count, @"");
}


@end



