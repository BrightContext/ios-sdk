//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCHTTPResponse.h"

NSString* kBCJSONPayloadErrorCodeKey = @"errorCode";

@implementation BCHTTPResponse

@synthesize httpStatusCode;
@synthesize error;
@synthesize jsonResponse;
@synthesize rawResponse;
@synthesize originalRequest;

- (id)initWithRequest:(NSURLRequest*)req
{
    self = [super init];
    if (self) {
        self.originalRequest = req;
        self.rawResponse = [[[NSMutableData alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [error release];
    [jsonResponse release];
    [originalRequest release];
    [rawResponse release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Req: %@\nStatus: %d\nPayload: %@\nError:%@\nRaw Buff Size: %d",
            originalRequest, httpStatusCode, jsonResponse, error, [rawResponse length]];
}

- (NSString *)rawResponseString
{
    NSData* d = [self rawResponse];
    unsigned int i = [d length];
    if (i != 0) {
        char buff[i];
        [d getBytes:&buff length:i];
        NSString* s = [[[NSString alloc] initWithBytes:&buff
                                                length:i
                                              encoding:NSUTF8StringEncoding] autorelease];
        return s;
    }
    
    return nil;
}

- (NSDictionary *)responseObject
{
    return (NSDictionary*) self.jsonResponse;
}

- (NSArray*) responseArray
{
    return (NSArray*) self.jsonResponse;
}

- (id) responseAs:(Class)c
{
    return [[[c alloc] initWithDictionary:self.responseObject] autorelease];
}

- (id) responseAsArrayOf:(Class)c
{
    return [self responseAsArrayOf:c
                        usingArray:self.responseArray];
}

- (id) responseAsArrayOf:(Class)c usingArray:(NSArray*)a
{
    if (!a) {
        return nil;
    }
    
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity:a.count];
    for (NSDictionary* d in a) {
        id obj = [[c alloc] initWithDictionary:d];
        [objects addObject:obj];
        [obj release];
    }
    return objects;
}

@end
