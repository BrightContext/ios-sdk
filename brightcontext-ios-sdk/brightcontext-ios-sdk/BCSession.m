//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

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

@synthesize domain=_domain;
@synthesize sessionId=_sessionId;
@synthesize serverTime=_serverTime;

- (id)initWithDictionary:(NSDictionary*)d
{
    self = [super init];
    if (self) {
        _domain = [[d objectForKey:@"domain"] retain];
        _sessionId = [[d objectForKey:@"sid"] retain];
        
        NSNumber* stime = [d objectForKey:@"stime"];
        // server is in unix epoch millis
        _serverTime = ([stime doubleValue] / 1000.) - NSTimeIntervalSince1970;
        
        BCMetricInc(kBCMetrics_sessionsCreated);
    }
    return self;
}

- (void)dealloc {
    [_domain release];
    [_sessionId release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ domain: %@, sid: %@, stime: %@ }", _domain, _sessionId, [NSDate dateWithTimeIntervalSinceReferenceDate:_serverTime]];
}

- (NSURL*) socketUrl
{
    NSRegularExpression* startsWithSlash = [NSRegularExpression regularExpressionWithPattern:@"^/"
                                                                                     options:0
                                                                                       error:nil];

    NSRegularExpression* endsWithSlash = [NSRegularExpression regularExpressionWithPattern:@"/$"
                                                                                   options:0
                                                                                     error:nil];
    NSString* root = [self.domain stringByReplacingOccurrencesOfString:@"http://"
                                                            withString:BC_API_PROTOCOL];
    root = [endsWithSlash stringByReplacingMatchesInString:root
                                                   options:0
                                                     range:NSMakeRange(0, [root length])
                                              withTemplate:@""];
    
    NSString* apiRoot = BC_API_ROOT;
    apiRoot = [startsWithSlash stringByReplacingMatchesInString:apiRoot
                                                        options:0
                                                          range:NSMakeRange(0, [apiRoot length])
                                                   withTemplate:@""];
    apiRoot = [endsWithSlash stringByReplacingMatchesInString:apiRoot
                                                      options:0
                                                        range:NSMakeRange(0, [apiRoot length])
                                                 withTemplate:@""];
    
    NSString* socketPath = BC_API_SOCKET_PATH;
    socketPath = [startsWithSlash stringByReplacingMatchesInString:socketPath
                                                           options:0
                                                             range:NSMakeRange(0, [socketPath length])
                                                      withTemplate:@""];
    socketPath = [endsWithSlash stringByReplacingMatchesInString:socketPath
                                                         options:0
                                                           range:NSMakeRange(0, [socketPath length])
                                                    withTemplate:@""];
    
    NSString* wsPath = [root stringByAppendingFormat:@"/%@/%@?%@=%@",
                        apiRoot,
                        socketPath,
                        BC_PARAM_SESSION_ID, self.sessionId];
    NSURL* wsUrl = [NSURL URLWithString:wsPath];
    return wsUrl;
}

@end