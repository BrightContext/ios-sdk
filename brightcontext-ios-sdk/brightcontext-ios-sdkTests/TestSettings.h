//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

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

#else

#define BC_TEST_SETTINGS [[LocalhostSettings new] autorelease]

#endif