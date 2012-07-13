//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import "TestSettings.h"

@interface FDTestSettings : NSObject <TestSettings>

+ (NSManagedObject *)fetchContextEntity;

@end
