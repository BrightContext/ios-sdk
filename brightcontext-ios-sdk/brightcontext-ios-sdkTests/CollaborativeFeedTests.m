//
//  CollaborativeFeedTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "CollaborativeFeedTests.h"
#import "TestContext.h"
#import "TestListener.h"

@implementation CollaborativeFeedTests

- (void) testCollaborativeThruFeed
{
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = BC_TEST_SETTINGS;
    
    TestListener* testListener = [TestListener new];
    
    BCFeedSettings* roomA = [BCFeedSettings new];
    roomA.type = BC_FEED_TYPE_THRU;
    roomA.name = @"room a";
    roomA.procId = [NSNumber numberWithInt:129];
    roomA.filterValues = [NSDictionary dictionaryWithObject:@"roomA" forKey:@"subChannel"];
    
    [ctx establishConnection:^(NSError *err, BCSession *s) {
        [ctx openFeedWithSettings:roomA listener:testListener];
    }];
    
    spinwait(12000);
}

@end
