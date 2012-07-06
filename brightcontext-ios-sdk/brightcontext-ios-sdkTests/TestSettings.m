//
//  TestSettings.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

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
    return @"7af00d4c-7812-11e1-a957-44cc34a085ba";
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
    return @"dev05.bcclabs.com";
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
    return @"b7d31fce-f06c-4a35-bf11-f36b3d80ce04";
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
    return @"4445598ce2a51481";
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
    return @"";
}

- (NSString *)apiKey
{
    return @"8b6522e5-d1ed-4bf9-870c-6ab2be742f4d";
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