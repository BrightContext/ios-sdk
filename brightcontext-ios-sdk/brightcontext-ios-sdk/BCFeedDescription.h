//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import "BCSerializable.h"

@interface BCFeedDescription : NSObject <BCSerializable>

@property (readwrite,nonatomic,retain) NSString* type;
@property (readwrite,nonatomic,retain) NSNumber* procId;
@property (readwrite,nonatomic,retain) NSString* name;
@property (readwrite,nonatomic,retain) NSArray* filters;

@end


@interface BCFeedSettings : BCFeedDescription

+ (BCFeedSettings*) settingsWithDescription:(BCFeedDescription*)fd
                               filterValues:(NSDictionary*)fv;

@property (readwrite,nonatomic,retain) NSDictionary* filterValues;

- (NSString*) generateHashCode;

@end