//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "TestContext.h"

@implementation TestContext

@synthesize settings=_settings;

- (NSString *)apiKey
{
    return self.settings.apiKey;
}

- (NSURL*) makeUrlFromSettingsSecurely:(BOOL)securely
{
    id<TestSettings> s = self.settings;
    NSString* host = [s host];
    NSUInteger port = (securely) ? 443 : [s port];
    
    NSString* apiRoot = [s apiRoot];
    if (!apiRoot) {
        apiRoot = @"";
    } else if ([apiRoot isEqualToString:@"/"]) {
        apiRoot = @"";
    }
    
    NSString* protocol = (securely) ? @"https" : @"http";
    
    NSString* urlString = [NSString stringWithFormat:@"%@://%@:%d%@", protocol, host, port, apiRoot];
    NSURL* url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)environmentURL
{
    return [self makeUrlFromSettingsSecurely:NO];
}

- (NSURL *)secureEnvironmentURL
{
    return [self makeUrlFromSettingsSecurely:YES];
}

@end
