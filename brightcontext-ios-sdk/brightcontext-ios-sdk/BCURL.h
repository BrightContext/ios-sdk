//
//  BCURL.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


/** common http status codes */
typedef enum BCHTTPStatusEnum {
    BCHTTPStatusOK = 200,
    BCHTTPStatusServerError = 500,
    BCHTTPStatusClientError = 400,
    BCHTTPStatusUnauthorized = 401,
    BCHTTPStatusForbidden = 403
} BCHTTPStatus;

/** available HTTP methods for operations */
typedef enum BCHTTPMethodEnum {
    BCHTTPMethodGET = 1,
    BCHTTPMethodPOST
} BCHTTPMethod;

/* Helps build valid urls and query strings */
@interface BCURL : NSObject
{
}

/** builds a query string from a nil terminated list of arguments
 variadic parameters must be of type NSString or NSArray.
 Arrays will be concatinated using a comma
 @param firstObject strings that will be appended
 @param NS_REQUIRES_NIL_TERMINATION uses nil as a terminator
 @returns a set of key/value pairs that can be passed as a query string to some http resource
 */
+ (NSString*) buildQueryString:(NSString*) firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/** builds an entire url by combining the base, a resource, and the query string
 @param urlRoot the base url that will be used, including the protocol
 @param resource the full path to the resource
 @param queryString the query parameters for that resource, probably generated by buildQueryString
 @returns a new autoreleased NSURL with the provided root, resource, and query string
 */
+ (NSURL*) urlWithRoot:(NSURL*)urlRoot
           forResource:(NSString*)resource
        withParameters:(NSString*)queryString;

@end