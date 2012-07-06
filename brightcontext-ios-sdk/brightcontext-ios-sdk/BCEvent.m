//
//  BCEvent.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BCEvent.h"
#import "BCConstants.h"

NSString* kBCEventErrorDomain = @"com.brightcontext.event.error";
NSString* kBCEventError_UserInfo_Message = @"com.brightcontext.event.error.userinfo.message";

@implementation BCEvent

@synthesize type, eventKey, message;

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        NSString* t = [data objectForKey:BC_PARAM_EVENT_TYPE];
        if ([BC_EVENT_TYPE_ERROR isEqualToString:t]) {
            self.type = BCEventType_error;
        } else if ([BC_EVENT_TYPE_RESPONSE isEqualToString:t]) {
            self.type = BCEventType_response;
        } else if ([BC_EVENT_TYPE_MESSAGE isEqualToString:t]) {
            self.type = BCEventType_message;
        }
        
        self.eventKey = [data objectForKey:BC_PARAM_EVENT_KEY];
        
        if ([[data allKeys] containsObject:BC_PARAM_MSG]) {
            id messageData = [data objectForKey:BC_PARAM_MSG];
            BCMessage* msg = [BCMessage new];
            msg.rawData = messageData;
            self.message = msg;
            [msg release];
        }
    }
    return self;
}

- (void)dealloc
{
    [eventKey release];
    [message release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type: %d, eventKey: %@, message: %@ }",
            type, eventKey, message];
}

- (BOOL)isError
{
    BOOL e = (BCEventType_error == self.type);
    return e;
}

- (NSError*) error 
{
    if (BCEventType_error != self.type) {
        return nil;
    }
    
    NSDictionary* userInfo = nil;
    if (BCMessageVariant_Unknown != self.message.type) {
        NSString* errorMessage = self.message.rawData;
        userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:kBCEventError_UserInfo_Message];
    }
    
    NSError* error = [NSError errorWithDomain:kBCEventErrorDomain
                                         code:kBCEventErrorCode_CommandError
                                     userInfo:userInfo];
    return error;
}

@end
