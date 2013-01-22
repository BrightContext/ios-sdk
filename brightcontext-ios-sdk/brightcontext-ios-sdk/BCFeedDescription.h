//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

@protocol BCSerializable;

@interface BCFeedDescription : NSObject <BCSerializable>

@property (readwrite,nonatomic,retain) NSString* type;
@property (readwrite,nonatomic,retain) NSNumber* procId;
@property (readwrite,nonatomic,retain) NSString* name;
@property (readwrite,nonatomic,retain) NSArray* filters;

+ (NSString*) sortedKvps:(NSDictionary*)data;

@end


@interface BCFeedMetadata : NSObject <BCSerializable>

+ (BCFeedMetadata*) metadataWithProject:(NSString*)projectName
                                channel:(NSString*)channelName
                              connector:(NSString*)connectorName
                                filters:(NSDictionary*)filterObject;

@property (readwrite,nonatomic,retain) NSString* projectName;
@property (readwrite,nonatomic,retain) NSString* channelName;
@property (readwrite,nonatomic,retain) NSString* connectorName;
@property (readwrite,nonatomic,retain) NSDictionary* filters;

- (NSString*) generateHashCode;

@end


@interface BCFeedSettings : BCFeedDescription

+ (BCFeedSettings*) settingsWithDescription:(BCFeedDescription*)fd
                               filterValues:(NSDictionary*)fv;

@property (readwrite,nonatomic,retain) NSDictionary* filterValues;

- (NSString*) generateHashCode;

@end

