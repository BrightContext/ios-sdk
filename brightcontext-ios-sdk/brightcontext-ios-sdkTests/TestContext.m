//
//  TestContext.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "TestContext.h"

@implementation TestContext

@synthesize settings=_settings;

- (NSString *)apiKey
{
    return self.settings.apiKey;
}

- (NSURL *)environmentURL
{
    id<TestSettings>s = self.settings;
    NSString* host = [s host];
    NSUInteger port = [s port];
    
    NSString* apiRoot = [s apiRoot];
    if (!apiRoot) {
        apiRoot = @"";
    } else if ([apiRoot isEqualToString:@"/"]) {
        apiRoot = @"";
    }
    
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%d%@", host, port, apiRoot];
    NSURL* url = [NSURL URLWithString:urlString];
    return url;
}

@end
