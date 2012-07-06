//
//  FDTestSettings.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TestSettings.h"

@interface FDTestSettings : NSObject <TestSettings>

+ (NSManagedObject *)fetchContextEntity;

@end
