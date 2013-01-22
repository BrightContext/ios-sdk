//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>


@protocol BCSerializable <NSObject>

@optional

- (id) initWithDictionary:(NSDictionary*)data;

- (NSString*) toJson;

- (id)proxyForJson;

@end
