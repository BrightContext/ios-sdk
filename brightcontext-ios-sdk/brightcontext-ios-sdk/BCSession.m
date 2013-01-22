//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCSerializable.h"
#import "BCSession.h"
#import "BCConstants.h"
#import "BCHTTPRequest.h"
#import "BCMetrics.h"

#import "NSObject+SBJson.h"

//NSString* kBCSessionCreatedNotificationName = @"com.brightcontext.session.notification.created";
//NSString* kBCSessionUpdatedNotificationName = @"com.brightcontext.session.notification.updated";
//NSString* kBCSessionMigrationNotificationName = @"com.brightcontext.session.notification.migration";
//
//NSString* kBCSessionUserInfoKey = @"com.brightcontext.session.notification.userinfo.sessionobject";
//NSString* kBCSessionOldSessionUserInfoKey = @"com.brightcontext.session.notification.userinfo.oldsession";
//NSString* kBCSessionNewSessionUserInfoKey = @"com.brightcontext.session.notification.userinfo.newsession";
//NSString* kBCSessionErrorUserInfoKey = @"com.brightcontext.session.notification.userinfo.error";


@implementation BCSession

@synthesize sessionId=_sessionId;
@synthesize serverTime=_serverTime;
@synthesize socketUrl=_socketUrl;
@synthesize isSecure=_isSecure;

- (id)initWithDictionary:(NSDictionary*)d
{
    self = [super init];
    if (self) {
//        {
//            "sid": "687f7e09-b117-4052-aec3-0a76a7a3d30b",
//            "stime": 1353942079692,
//            "endpoints": {
//                "flash": [
//                          "ws://pub01.bcclabs.com",
//                          "ws://pub01.bcclabs.com:8080"
//                          ],
//                "socket": [
//                           "ws://pub01.bcclabs.com",
//                           "ws://pub01.bcclabs.com:8080"
//                           ],
//                "rest": [
//                         "http://pub01.bcclabs.com",
//                         "http://pub01.bcclabs.com:8080"
//                         ]
//            },
//            "ssl": false
//        }
        
        _availableEndpoints = [[[d objectForKey:@"endpoints"] objectForKey:@"socket"] retain];
        _currentEndpointIndex = -1;
        
        _isSecure = [[d objectForKey:@"ssl"] boolValue];
        
        _sessionId = [[d objectForKey:@"sid"] retain];
        
        NSNumber* stime = [d objectForKey:@"stime"];
        // server is in unix epoch millis
        _serverTime = ([stime doubleValue] / 1000.) - NSTimeIntervalSince1970;
        
        BCMetricInc(kBCMetrics_sessionsCreated);
    }
    return self;
}

- (void)dealloc
{
    [_sessionId release];
    [_socketUrl release];
    [_availableEndpoints release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ endpoints: %@, sid: %@, stime: %@, secure: %@ }",
            _availableEndpoints,
            _sessionId,
            [NSDate dateWithTimeIntervalSinceReferenceDate:_serverTime],
            ((self.isSecure) ? @"true" : @"false")
    ];
}

-(void)parseNextSocketUrl
{
    ++_currentEndpointIndex;
    
    if (_currentEndpointIndex >= [_availableEndpoints count]) {
        self.socketUrl = nil;
        return; // fail fast
    }
    
    NSString* nextEndpoint = [_availableEndpoints objectAtIndex:_currentEndpointIndex];
    
    NSString* wsPath = [nextEndpoint stringByAppendingFormat:@"%@%@?%@=%@",
                        BC_API_ROOT,
                        BC_API_SOCKET_PATH,
                        BC_PARAM_SESSION_ID, self.sessionId];
    
    NSURL* wsUrl = [NSURL URLWithString:wsPath];
    self.socketUrl = wsUrl;
}

@end