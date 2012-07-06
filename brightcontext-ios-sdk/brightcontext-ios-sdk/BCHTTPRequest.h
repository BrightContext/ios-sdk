//
//  BCNetworkOperation.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCURL.h"
#import "BCHTTPResponse.h"

/** name of the network operation queue */
extern NSString* kBCNetworkOperationQueueName;
/** NSError domain used */
extern NSString* kBCNetworkErrorDomain;
/** Dictionary key used for userInfo dictionary on NSErrors when an exception occurs */
extern NSString* kBCNetworkErrorUserInfoKey_Exception;
/** Dictionary key used for userInfo dictionary on NSErrors (typically not UI printable) */
extern NSString* kBCNetworkErrorUserInfoKey_Message;
/** Dictionary key used for userInfo dictionary on NSErrors, holds the original request url as an NSURL */
extern NSString* kBCNetworkErrorUserInfoKey_OriginalRequest;

/** Block type for result callbacks */
typedef void (^BCHTTPResponseCallback)(BCHTTPResponse* result);

/** error codes used inside of the kBCNetworkErrorDomain for NSError */
typedef enum kBCNetworkErrorCodeEnum {
    kBCNetworkErrorCode_Exception = 1,
    kBCNetworkErrorCode_ParserError,
    kBCNetworkErrorCode_HttpStatusError
} kBCNetworkErrorCode;

/* Async json call wrapper. Used when setting up the real time socket to establish a session on an available server. */
@interface BCHTTPRequest : NSObject
{
    @private
    NSURL* connectionURL;
    NSURLConnection* connection;
    BCHTTPResponseCallback resultCallback;
    BCHTTPResponse* result;
}

/** initializes the request, does not begin execution until start is called
 @param url a valid endpoint
 @returns a newly allocated BCHTTPRequest instance ready for use
 */
- (id) initWithURL:(NSURL*)url;

/** fire and forget, ignoring the response */
- (void) start;

/** fire and receive an async result on the main thread when complete
 @param cb block executed when http response is received
 */
- (void) startWithCallback:(BCHTTPResponseCallback)cb;

/** fire with the option to make a synchronous network call.
 By default all calls are asynchronous, this allows blocking the main thread for things like unit tests.
 @param cb block executed when http response is received
 @param async true if the request should be asynchronous, false otherwise
 */
- (void) startWithCallback:(BCHTTPResponseCallback)cb
                     async:(BOOL)async;

/** cancel the in progress request */
- (void) cancel;

/** Default: GET.  Sets the HTTP method used when the operation is started */
@property (readwrite,nonatomic,assign) BCHTTPMethod connectionMethod;

/** Default: YES.  Set to NO if you don't want to parse result payload */
@property (readwrite,nonatomic,assign) BOOL shouldParseResult;

/** Timeout in seconds.  Default: 60 */
@property (readwrite,nonatomic,assign) NSTimeInterval timeout;

/** convenience constructor
 @param url a valid endpoint
 @param m the HTTP method (GET or POST)
 @returns an autoreleased instance of a newly allocated BCHTTPRequest 
 */
+ (BCHTTPRequest*) requestWithUrl:(NSURL*)url
                       withMethod:(BCHTTPMethod)m;

@end
