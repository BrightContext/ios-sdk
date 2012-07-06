//
//  BCFeed.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCSerializable.h"
#import "BCMessage.h"
#import "BCConnectionManager.h"
#import "BCFeedDescription.h"

typedef NSString BCFeedKey;

typedef enum BCFeedType {
    BCFeedType_Unknown,
    BCFeedType_Input,
    BCFeedType_Output,
    BCFeedType_Through
} BCFeedType;

/*!
 \memberof BCFeed
 @param timepoints Array of BCTimePoint instances that occurred on a feed, or nil on error
 @param error nil on success, otherwise contains the error that occurred while fetching the feed history
*/
typedef void(^BCFeedHistoryCallback)(NSArray* timepoints, NSError* error);

/*!
 \brief Represents a real-time stream of messages
 
 \see BCMessage
 \see BCTimePoint
 */
@interface BCFeed : NSObject <BCSerializable>
{
}

+ (BCFeedType) feedTypeFromString:(NSString*)feedTypeString;

@property (readwrite,nonatomic,retain) NSNumber* procId;
@property (readwrite,nonatomic,retain) NSString* state;
@property (readwrite,nonatomic,assign) BCFeedType type;
@property (readwrite,nonatomic,retain) BCFeedKey* key;
@property (readwrite,nonatomic,retain) NSNumber* netId;

@property (readwrite,nonatomic,retain) NSNumber* throttleRate;
@property (readwrite,nonatomic,retain) NSDictionary* filters;

@property (readwrite,nonatomic,retain) BCFeedSettings* settings;

@property (readwrite,nonatomic,assign) id<BCConnectionManager> connection;

- (void) open;

/**
 \brief Sends a message on a feed
 @param msg The message object to send, must be a dictionary on QuantChannel Inputs
 
 \code
 
 NSDictionary* d = [NSDictionary dictionaryWithObject:@"make it so" forKey:@"command"]; 
 BCMessage* m = [BCMessage messageFromDictionary:d];
 [feed send:m];
 
 \endcode
 */
- (void) send:(BCMessage*)msg;

/**
 \brief Closes a feed.
 Once a feed is closed, no messages will be received on it, and no messages can be sent on it. */
- (void) close;

/**
 \brief Fetches historic messages on a feed with a default limit of 10 up until the most recent item
 @param callback Async block executed when request is complete
 */
- (void) getHistory:(BCFeedHistoryCallback)callback;

/**
 \brief Fetches historic messages on a feed with the provided limit, up until the most recent item 
 @param callback Async block executed when request is complete
 @param limit The maximum number of timepoints to receive
 */
- (void) getHistory:(BCFeedHistoryCallback)callback
              limit:(NSUInteger)limit;

/**
 \brief Fetches historic messages on a feed
 
 @param callback Async block executed when request is complete
 @param limit The maximum number of timepoints to receive
 @param ending The most recent date matching an element of the history.
 For example, if 1pm is provided, no messages after 1pm will be fetched and handed to callback.
 
 \code
 
 [feed getHistory:^(NSArray* timepoints, NSError* error) {
   if (!error) {
     NSLog(@"%@", timepoints);
   }
 } limit:10 ending:[NSDate date]]];
 
 \endcode
 */
- (void) getHistory:(BCFeedHistoryCallback)callback
              limit:(NSUInteger)limit
             ending:(NSDate*)ending;

// active polling

@property (readwrite,nonatomic,assign) BOOL usesPolling;
@property (readwrite,nonatomic,retain) NSArray* pollFields;
@property (readwrite,nonatomic,retain) NSTimer* revoteTimer;
@property (readwrite,nonatomic,assign) NSTimeInterval revoteInterval;
@property (readwrite,nonatomic,retain) BCMessage* previousMessage;
@property (readwrite,retain) NSNumber* currentPollingTimeslot;
@property (readwrite,assign) NSTimeInterval timeOfLastVote;

// write protection

@property (readonly,nonatomic) BOOL isWriteProtected;
@property (readwrite,nonatomic,retain) NSString* writeKey;

// listener management

- (void) addListener:(id<BCFeedListener>)listener;
- (void) removeListener:(id<BCFeedListener>)listener;

#if BC_MESSAGE_CONTRACT_VALIDATION
@property (readwrite,nonatomic,retain) NSArray* messageContract;
- (void) validateMessage:(BCMessage*)msg;
- (void) validateMessagePayload:(NSDictionary*)payload hasField:(NSDictionary*)fieldDetails;
- (void) validateNumber:(NSNumber*)num isGreaterThanOrEqualTo:(NSNumber*)min andLessThanOrEqualTo:(NSNumber*)max;
#endif

@end