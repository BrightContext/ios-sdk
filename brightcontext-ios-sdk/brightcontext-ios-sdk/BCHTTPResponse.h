//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

/** key used to retrieve json payload error */
extern NSString* kBCJSONPayloadErrorCodeKey;

/** error codes used inside of JSON Payload, dictionary key @"errorCode" */
typedef enum kBCJSONErrorCodeEnum {
    kBCJSONErrorCode_DomainWidgetMismatch = 1,     // The domain of the call doesn’t match the domain set for one of the widgets
    kBCJSONErrorCode_MissingRequiredParameter,     // Missing a required parameter
    kBCJSONErrorCode_ImproperUse                   // Improper use of API call
} kBCJSONErrorCode;

/* Wraps the results of BCHTTPRequest.  Allows access to the raw response, or the parsed json object */
@interface BCHTTPResponse : NSObject
{
}

/** creates a new result and retains a handle to the original request
 @param req the original request that caused this response
 @returns newly allocated instance of BCHTTPResponse
 */
- (id)initWithRequest:(NSURLRequest*)req;

/** status code returned by the server */
@property (readwrite,nonatomic,assign) NSInteger httpStatusCode;

/** error object, nil on success */
@property (readwrite,nonatomic,retain) NSError* error;

/** deserialized payload */
@property (readwrite,nonatomic,retain) id<NSObject> jsonResponse;

/** raw response payload from server */
@property (readwrite,nonatomic,retain) NSMutableData* rawResponse;

/** handle to the original request that was sent to get this result */
@property (readwrite,nonatomic,retain) NSURLRequest* originalRequest;

/** @returns the raw response NSData as a decoded UTF8 string */
- (NSString*) rawResponseString;

/** @returns the json response as NSDictionary */
- (NSDictionary*) responseObject;

/** @returns the json response as NSArray */
- (NSArray*) responseArray;

/** Passes the responseObject to the provided class initWithDictionary constructor
 @param c The model class to create
 @returns new autoreleased instance of type c
 */
- (id) responseAs:(Class)c;

/** Passes each NSDictionary inside responseArray to the provided class initWithDictionary constructor
 @param c The model class to create
 @returns new autoreleased array containing a collection of new intances of type c
 */
- (id) responseAsArrayOf:(Class)c;

/** Same as responseAsArrayOf but allows caller to pass arbitrary source array
 @param c The model class to create
 @param a The array to iterate when building instances of c
 @returns new autoreleased array containing a collection of new intances of type c
 */
- (id) responseAsArrayOf:(Class)c
              usingArray:(NSArray*)a;

@end
