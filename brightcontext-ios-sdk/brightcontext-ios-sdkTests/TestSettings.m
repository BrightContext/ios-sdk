//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "TestSettings.h"

@implementation LocalhostSettings

- (NSString *)host
{
    return @"localhost";
}

- (NSUInteger)port
{
    return 9092;
}

- (NSString *)apiRoot
{
    return @"";
}

- (NSString *)apiKey
{
    return @"800f34dc-1b5b-492f-8017-d647ae1ef28a";
}

- (NSString *)secureApiKey
{
    return @"e921d6b4-2f75-4f53-a38e-3046d9405eb6";
}

- (NSString*)testProject
{
    return @"iOS unit test project";
}

- (NSString*)unprotectedThruChannel
{
    return @"unprotected thru channel";
}

- (NSString*)protectedThruChannel
{
    return @"protected thru channel";
}

- (NSString*)protectedThruChannelWriteKey
{
    return @"4445598ce2a51481";
}

@end

@implementation Te1Settings

- (NSString *)host
{
    return @"pub.bcclabs.com";
}

- (NSUInteger)port
{
    return 80;
}

- (NSString *)apiRoot
{
    return @"";
}

- (NSString *)apiKey
{
    return @"800f34dc-1b5b-492f-8017-d647ae1ef28a";
}

- (NSString *)secureApiKey
{
    return @"e921d6b4-2f75-4f53-a38e-3046d9405eb6";
}

- (NSString*)testProject
{
    return @"ios unit tests";
}

- (NSString*)unprotectedThruChannel
{
    return @"unprotected thru channel";
}

- (NSString*)protectedThruChannel
{
    return @"protected thru channel";
}

- (NSString*)protectedThruChannelWriteKey
{
    return @"c3d5ef421364a52a";
}

@end

@implementation ProdSettings

- (NSString *)host
{
    return @"pub.brightcontext.com";
}

- (NSUInteger)port
{
    return 80;
}

- (NSString *)apiRoot
{
    return @"/";
}

- (NSString *)apiKey
{
    return @"8b6522e5-d1ed-4bf9-870c-6ab2be742f4d";
}

- (NSString *)secureApiKey
{
    return @"e921d6b4-2f75-4f53-a38e-3046d9405eb6";
}

- (NSString*)testProject
{
    return @"ios unit tests";
}

- (NSString*)unprotectedThruChannel
{
    return @"unprotected thru channel";
}

- (NSString*)protectedThruChannel
{
    return @"protected thru channel";
}

- (NSString*)protectedThruChannelWriteKey
{
    return @"5ce3bc3de9dca9ca";
}


@end