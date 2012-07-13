//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import "BCSerializable.h"

typedef enum {
    BCMessageVariant_Unknown,
    BCMessageVariant_String,
    BCMessageVariant_Dictionary,
    BCMessageVariant_Array
} BCMessageVariantType;

/*!
 \brief a message that has been broadcast by the server
 
 Any message from the server broadcaster.
 On QuantChannel outputs, this contains the calculated values.
 On ThruChannels this would be the message broadcast directly to all clients.
 
 */
@interface BCMessage : NSObject <BCSerializable>
{
    id _data;
}

+ (BCMessage*) message;

+ (BCMessage*) messageFromString:(NSString*)stringValue;

/**
 @param dict A dictionary that will be serialized to json
 @returns a message that can be sent on a feed
 */
+ (BCMessage*) messageFromDictionary:(NSDictionary*)dict;
+ (BCMessage*) messageFromArray:(NSArray*)arr;

/**
 @param json A valid json string that will be used to build the message
 @returns a message that can be sent on a feed
 */
+ (BCMessage*) messageFromJson:(NSString*)json;

/** The time the message object was created.  Automatically populated by the init constructor.  The underlying value represents time in seconds from the system reference date. */
@property (readwrite,nonatomic,assign) NSTimeInterval timestamp;

@property (readwrite,nonatomic,assign) BCMessageVariantType type;

@property (readwrite,nonatomic,retain) id rawData;

@end
