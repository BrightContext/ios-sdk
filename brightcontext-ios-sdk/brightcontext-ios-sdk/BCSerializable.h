//
//  BCSerializable.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BCSerializable <NSObject>

@optional

- (id) initWithDictionary:(NSDictionary*)data;

- (NSString*) toJson;

@end
