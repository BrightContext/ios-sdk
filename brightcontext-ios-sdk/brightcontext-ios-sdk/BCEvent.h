//
//  BCEvent.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCSerializable.h"
#import "BCConnectionManager.h"
#import "BCMessage.h"

/**
 \relates BCFeedListener
 \brief The const string used when building any NSError object from the SDK
 */
extern NSString* kBCEventErrorDomain;
/**
 \relates BCFeedListener
 \brief The const string key used when populating the NSError user info dictionary with a BCMessage object
 */
extern NSString* kBCEventError_UserInfo_Message;

typedef enum {
    kBCEventErrorCode_CommandError = 0,             // commad failed
    kBCEventErrorCode_NoSuchFeedError,              // feed does not exist in management console
    kBCEventErrorCode_InvalidChannelMetadata,       // the channel loaded contains invalid metadata
    kBCEventErrorCode_MissingWriteKey               // a feed is write protected
} kBCEventErrorCode;

typedef enum {
    BCEventType_response,                           // event raised in response to a coorosponding request
    BCEventType_message,                            // event raised for calculated or broadcast message
    BCEventType_error                               // event raised when a request fails
} BCEventType;

typedef NSString BCEventKey;

@interface BCEvent : NSObject <BCSerializable>

@property (readwrite,nonatomic,assign) BCEventType type;
@property (readwrite,nonatomic,retain) BCEventKey* eventKey;
@property (readwrite,nonatomic,retain) BCMessage* message;

- (BOOL) isError;
- (NSError*) error;

@end
