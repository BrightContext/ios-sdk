//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "HistoryTests.h"
#import "TestContext.h"

#define num_historic_messages_to_test 10

@implementation HistoryTests

@synthesize context, feed, settings;

- (void)setUp
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    self.context = ctx;
    
    self.feed = nil;
    self.settings = ctx.settings;
}

- (void) testGetHistoryThruFeed
{
    BCProject* p = [self.context loadProject:self.settings.testProject];
    [p open:self.settings.unprotectedThruChannel listener:self];
    
    spinwait(10);
    
    STAssertTrue(nil != self.feed, @"feed should be open");
    
    __block int firecount = 0;
    [self.feed getHistory:^(NSArray *messages, NSError *error) {
        ++firecount;
        
        STAssertNil(error, @"Error: %@", error);
        STAssertNotNil(messages, @"");
        
        STAssertTrue(num_historic_messages_to_test == messages.count, @"");
        
        if (num_historic_messages_to_test != messages.count) {
            return;
        }
        
        for (int i=0; i != num_historic_messages_to_test; ++i) {
            int h = num_historic_messages_to_test-1-i;  // from 9..0
            BCMessage* msg = [messages objectAtIndex:i];
            
            STAssertNotNil(msg, @"");
            
            NSString* msgbody = [msg stringForKey:@"m"];
            NSString* msgbodyexpected = [NSString stringWithFormat:@"message %d", h];
            STAssertEqualObjects(msgbody, msgbodyexpected, @"");
            
            STAssertTrue(0 != msg.timestamp, @"");
            STAssertTrue(NSTimeIntervalSince1970 != msg.timestamp, @"");
            
            if (i != 0) {
                BCMessage* nextMsg = [messages objectAtIndex:i-1];
                NSTimeInterval ts = msg.timestamp;
                NSTimeInterval nextTs = nextMsg.timestamp;
                STAssertTrue(nextTs >= ts, @"timestamps out of order");
            }
            
            if (i != num_historic_messages_to_test-1) {
                BCMessage* prevMsg = [messages objectAtIndex:i+1];
                NSTimeInterval ts = msg.timestamp;
                NSTimeInterval prevTs = prevMsg.timestamp;
                STAssertTrue(prevTs <= ts, @"timestamps out of order");
            }
        }
    }];
    
    spinwait(10);
    
    STAssertTrue(1 == firecount, @"fire count should be exactly 1");
}

- (void) testGetHistoryProcessedOutputFeed
{
    
}

#pragma mark BCFeedListener

- (void)didError:(NSError *)error
{
    STAssertNotNil(error, @"");
    
    NSString* errorStr = [NSString stringWithFormat:@"%@", error];
    STAssertTrue(false, errorStr);
}

- (void)didOpenFeed:(BCFeed *)f
{
    self.feed = f;
    
    for (int i=0; i!=num_historic_messages_to_test; ++i) {
        NSString* msgbody = [NSString stringWithFormat:@"message %d", i];
        BCMessage* msg = [BCMessage message];
        [msg setString:msgbody forKey:@"m"];
        [f send:msg];
        spinwait(1);
    }
}

- (void)didCloseFeed:(BCFeed *)feed
{
    self.feed = nil;
}

@end
