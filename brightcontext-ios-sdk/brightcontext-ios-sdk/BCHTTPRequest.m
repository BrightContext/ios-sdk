//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCHTTPRequest.h"
#import "BCConstants.h"
#import "BCMetrics.h"

NSString* kBCNetworkErrorDomain = @"com.brightcontext.networkoperation.error";

NSString* kBCNetworkErrorUserInfoKey_Exception = @"com.brightcontext.networkoperation.error.userinfo.exception";
NSString* kBCNetworkErrorUserInfoKey_Message = @"com.brightcontext.networkoperation.error.userinfo.message";
NSString* kBCNetworkErrorUserInfoKey_OriginalRequest = @"com.brightcontext.networkoperation.error.userinfo.originalrequest";
NSString* kBCNetworkErrorUserInfoKey_ResponsePayload = @"com.brightcontext.networkoperation.error.userinfo.responsepayload";

@interface BCHTTPRequest(Private)

- (NSError*) errorWithMessage:(NSString*)message errorCode:(int)errorCode exception:(NSException*)ex;
- (void) sendRequest:(NSURLRequest*)req;
- (void) sendAsyncRequest:(NSURLRequest*)req;

- (void) failWithHttpStatus:(NSInteger)httpStatus;
- (void) failWithHttpError:(NSError*)httpErr;
- (void) failWithException:(NSException*)ex;
- (void) checkStatusAndSignalCaller;
- (void) finish;

@end

@implementation BCHTTPRequest

+ (BCHTTPRequest*) requestWithUrl:(NSURL*)url
                       withMethod:(BCHTTPMethod)m
{
    BCHTTPRequest* req = [[[BCHTTPRequest alloc] initWithURL:url] autorelease];
    req.connectionMethod = m;
    return req;
}

@synthesize connectionMethod;
@synthesize shouldParseResult;
@synthesize timeout;

- (id)initWithURL:(NSURL*)url
{
    self = [super init];
    if (self) {
        timeout = 60.;     // 1 minute timeout by default
        connectionURL = [url copy];
        connectionMethod = BCHTTPMethodGET;
        shouldParseResult = YES;
    }
    return self;
}

- (NSError*) errorWithMessage:(NSString*)message
                    errorCode:(int)errorCode
                    exception:(NSException*)ex
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:connectionURL forKey:kBCNetworkErrorUserInfoKey_OriginalRequest];
    [userInfo setObject:message forKey:kBCNetworkErrorUserInfoKey_Message];
    
    if (ex) {
        [userInfo setObject:ex forKey:kBCNetworkErrorUserInfoKey_Exception];
    }
    
    NSError* err = [NSError errorWithDomain:kBCNetworkErrorDomain
                                       code:errorCode
                                   userInfo:userInfo];
    return err;
}

- (void) sendRequest:(NSURLRequest*)req
{
    NSHTTPURLResponse* httpResp = nil;
    NSError* httpErr = nil;
    NSData* d = [NSURLConnection sendSynchronousRequest:req
                                      returningResponse:&httpResp
                                                  error:&httpErr];
    [result.rawResponse appendData:d];
    
    result.httpStatusCode = [httpResp statusCode];
    
    if (httpErr) {
        [self failWithHttpError:httpErr];
    } else {
        [self checkStatusAndSignalCaller];
    }
}

- (void)sendAsyncRequest:(NSURLRequest *)req
{
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
}

- (void) startWithCallback:(BCHTTPResponseCallback)cb async:(BOOL)async
{
    NSAssert(connectionURL != nil, @"url should not be nil");
    
    BCLog(@"BCNetworkOperation: %@", connectionURL);

    resultCallback = [cb copy];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:connectionURL
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:timeout];
    NSAssert(req != nil, @"url request should not be nil");
    
    if (BCHTTPMethodPOST == connectionMethod) {
        [req setHTTPMethod:BC_ACTION_POST];
    }
    
    result = [[BCHTTPResponse alloc] initWithRequest:req];
    
    @try {
        BCMetricInc(kBCMetrics_requests);
        
        if (!async) {
            [self sendRequest:req];
        } else {
            [self sendAsyncRequest:req];
        }
    }
    @catch (NSException *exception) {
        [self failWithException:exception];
    }
}

- (void)startWithCallback:(BCHTTPResponseCallback)cb
{
    [self startWithCallback:cb
               async:YES];
}

- (void)start
{
    [self startWithCallback:nil];
}

- (void)cancel
{
    [connection cancel];
}

- (void)failWithHttpStatus:(NSInteger)httpStatus
{
    NSString* msg = [NSHTTPURLResponse localizedStringForStatusCode:result.httpStatusCode];
    NSError* statusErr = [self errorWithMessage:msg
                                      errorCode:kBCNetworkErrorCode_HttpStatusError
                                      exception:nil];
    
    BCLog(@"HTTP Status Error: %@ Raw Response: %@", statusErr, [result rawResponseString]);
    BCMetricInc(kBCMetrics_requestsFailed);
    
    result.error = statusErr;
    
    [self finish];
}

- (void)failWithHttpError:(NSError *)httpErr
{
    BCLog(@"HTTP Error: %@ Raw Response: %@", httpErr, [result rawResponseString]);
    BCMetricInc(kBCMetrics_requestsFailed);
    
    result.error = httpErr;
    
    [self finish];
}

- (void)failWithException:(NSException *)ex
{
    BCLog(@"Exception: %@", ex);
    BCMetricInc(kBCMetrics_requestsFailed);
    
    result.error = [self errorWithMessage:[ex description]
                                errorCode:kBCNetworkErrorCode_Exception
                                exception:ex];
    [self finish];
}

- (void) checkStatusAndSignalCaller
{
    if (BCHTTPStatusOK != result.httpStatusCode) {
        [self failWithHttpStatus:result.httpStatusCode];
    } else {
        BCMetricInc(kBCMetrics_requestsSuccessful);
        
        [self finish];
    }
}

- (void)finish
{
    NSAssert(result != nil, @"result should not be nil");
    
    if (shouldParseResult && (0 != [result.rawResponse length])) {
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        result.jsonResponse = [parser objectWithData:result.rawResponse];
        
        NSString* errMsg = parser.error;
        if (errMsg) {
            BCLog(@"Parser Error: %@\nUnparsable Payload: %@", errMsg, [result rawResponseString]);
            
            if (!result.error) { // save the original error if we encountered one already
                NSError* parserError = [self errorWithMessage:errMsg
                                                    errorCode:kBCNetworkErrorCode_ParserError
                                                    exception:nil];
                result.error = parserError;
            } else {
                BCLog(@"Leaving existing error in place: %@", result.error);
            }
        }
    }
    
    BCLog(@"BCNetworkOperationResult: %@", result);
    
    if (resultCallback) {
        resultCallback(result);
        [resultCallback release];
        resultCallback = nil;
    } else {
        BCLog(@"%@", @"No result callback");
    }
    
    [result release];
    result = nil;
}

#pragma NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    BCLog(@"HTTP Response: %@", response);
    BCMetricInc(kBCMetrics_responses);
    
    result.httpStatusCode = [((NSHTTPURLResponse*) response) statusCode];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [[result rawResponse] appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [self failWithHttpError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self checkStatusAndSignalCaller];
}

#pragma Cleanup

- (void)dealloc
{
    [connectionURL release];
    [connection release];
    [result release];
    [resultCallback release];
    [super dealloc];
}

@end
