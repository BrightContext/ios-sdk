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
 \brief. Set all the data for the message in one shot.
 
 Messages are not validated for json compliance until they are sent.
 Setting a non-serializable object graph will cause errors later when the message is sent on the feed during JSON serialization.
 
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

/** The type of data expected in the rawData property.  BCMessageVariant_Dictionary, BCMessageVariant_Array, BCMessageVariant_String, or BCMessageVariant_Unknown. */
@property (readwrite,nonatomic,assign) BCMessageVariantType type;

/** The raw data that will be serialized to JSON, use with caution. */
@property (readwrite,nonatomic,retain) id rawData;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Set a string value for the given key inside the message payload.
 @param v the value that will be serialized to JSON
 @param k the string key stored in the dictionary.
 */
- (void) setString:(NSString*)v forKey:(NSString*)k;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Get a string value for the given key from the message payload.
 @param k the string key stored in the dictionary.
 @returns the value for the given key, assumed to be an NSString* after parsing.
 */
- (NSString*) getStringForKey:(NSString*)k;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Set a number value for the given key inside the message payload.
 @param v the value that will be serialized to JSON
 @param k the string key stored in the dictionary.
 */
- (void) setNumber:(NSNumber*)v forKey:(NSString*)k;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Get a number value for the given key from the message payload.
 @param k the string key stored in the dictionary.
 @returns the value for the given key, assumed to be an NSNumber* after parsing.
 */
- (NSNumber*) getNumberForKey:(NSString*)k;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Set a date value as a unix timestamp for the given key inside the message payload.
 @param v the value that will be serialized to JSON
 @param k the string key stored in the dictionary.
 */
- (void) setDate:(NSDate*)v forKey:(NSString*)k;

/**
 Only valid when type == BCMessageVariant_Dictionary.
 Get a date value for the given key from the message payload.
 @param k the string key stored in the dictionary.
 @returns an autoreleased NSDate object using the number value stored in the field, assumed to be a unix timestamp as seconds from 1970 epoch.
 */
- (NSDate*) getDateForKey:(NSString*)k;

@end
