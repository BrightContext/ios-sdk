//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "TestListener.h"

@implementation TestListener

@synthesize numOpens, numCloses, numErrors;
@synthesize messagesSent, messagesReceived;
@synthesize testFeed;

- (id)init
{
    self = [super init];
    if (self) {
        self.messagesSent = [NSMutableArray array];
        self.messagesReceived = [NSMutableArray array];
    }
    return self;
}

- (void)didError:(NSError *)error
{
    NSLog(@"didError %@", error);
    ++numErrors;
}

- (void)didOpenFeed:(BCFeed *)feed
{
    NSLog(@"didOpenFeed %@", feed);
    ++numOpens;
    
    self.testFeed = feed;
}

- (void)didReceiveMessage:(BCMessage *)message onFeed:(BCFeed *)feed
{
    NSLog(@"didReceiveMessage: %@ onFeed: %@", message, feed);
    [messagesReceived addObject:message];
}

- (void)didSendMessage:(BCMessage *)message onFeed:(BCFeed *)feed
{
    NSLog(@"didSendMessage: %@ onFeed: %@", message, feed);
    [messagesSent addObject:message];
}

- (void)didCloseFeed:(BCFeed *)feed
{
    NSLog(@"didCloseFeed %@", feed);
    ++numCloses;
}

@end
