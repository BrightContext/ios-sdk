//
//  BCFeedDescription.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

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