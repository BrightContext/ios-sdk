//
//  TestSettings.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TestSettings <NSObject>

@property (readonly) NSString* host;
@property (readonly) NSUInteger port;
@property (readonly) NSString* apiRoot;
@property (readonly) NSString* apiKey;
@property (readonly) NSString* testProject;
@property (readonly) NSString* unprotectedThruChannel;
@property (readonly) NSString* protectedThruChannel;
@property (readonly) NSString* protectedThruChannelWriteKey;

@end

@interface LocalhostSettings : NSObject <TestSettings>
{
}
@end

@interface Te1Settings : NSObject <TestSettings>
{
}
@end

@interface ProdSettings : NSObject <TestSettings>
{
}
@end

#ifdef BC_TEST_ENVIRONMENT

#define BC_TEST_SETTINGS [[BC_TEST_ENVIRONMENT new] autorelease]

#endif