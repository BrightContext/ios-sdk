//
//  HistoryTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "HistoryTests.h"
#import "TestContext.h"

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
    [self.feed getHistory:^(NSArray *timepoints, NSError *error) {
        ++firecount;
        
        STAssertNil(error, @"Error: %@", error);
        STAssertNotNil(timepoints, @"");
        
        STAssertTrue(10 == timepoints.count, @"");
        for (NSDictionary* td in timepoints) {
            BCTimePoint* t = [[BCTimePoint alloc] initWithDictionary:td];
            
            STAssertNotNil(t, @"");
            STAssertNotNil(t.asset, @"");
            STAssertTrue(0 != t.timestamp, @"");
            
            NSLog(@"historic timepoint: %@", t);
            
            [t release];
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
    
    for (int i=0; i!=10; ++i) {
        NSString* msgbody = [NSString stringWithFormat:@"message %d", i];
        [f send:[BCMessage messageFromString:msgbody]];
    }
}

- (void)didCloseFeed:(BCFeed *)feed
{
    self.feed = nil;
}

@end
