//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCMetrics.h"

NSString* kBCMetricsQueueName = @"com.brightcontext.MetricDispatchQueue";

NSString* kBCMetrics_requests = @"com.brightcontext.metric.requests";
NSString* kBCMetrics_requestsSuccessful = @"com.brightcontext.metric.requestsSuccessful";
NSString* kBCMetrics_requestsFailed = @"com.brightcontext.metric.requestsFailed";

NSString* kBCMetrics_responses = @"com.brightcontext.metric.responses";

NSString* kBCMetrics_sessionsCreated = @"com.brightcontext.metric.sessionsCreated";

NSString* kBCMetrics_streamOpens = @"com.brightcontext.metric.streamOpens";
NSString* kBCMetrics_streamReconnects = @"com.brightcontext.metric.streamReconnects";
NSString* kBCMetrics_streamCloses = @"com.brightcontext.metric.streamCloses";
NSString* kBCMetrics_streamErrors = @"com.brightcontext.metric.streamErrors";
NSString* kBCMetrics_streamObjectWrites = @"com.brightcontext.metric.streamObjectWrites";
NSString* kBCMetrics_streamObjectReads = @"com.brightcontext.metric.streamObjectReads";

@implementation BCMetrics

- (id)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableDictionary alloc] initWithCapacity:12];
        _metricQ = dispatch_queue_create([kBCMetricsQueueName cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(_metricQ);
    [_data release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", _data];
}

- (void)reset
{
    dispatch_sync(_metricQ, ^{
        for (NSString* metric in [_data allKeys]) {
            [_data setObject:[NSNumber numberWithUnsignedInt:0] forKey:metric];
        }
    });
}

- (void)increment:(NSString *)key
{
    dispatch_sync(_metricQ, ^{
        NSNumber* m = [_data objectForKey:key];
        if (!m) {
            m = [NSNumber numberWithUnsignedInteger:1];
        } else {
            NSUInteger m_i = [m intValue];
            if (NSUIntegerMax != m_i) {
                ++m_i;
            }
            m = [NSNumber numberWithUnsignedInteger:m_i];
        }
        [_data setObject:m forKey:key];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:key
                                                            object:self];
    });
}

- (void)decrement:(NSString *)key
{
    dispatch_sync(_metricQ, ^{
        NSNumber* m = [_data objectForKey:key];
        if (!m) {
            m = [NSNumber numberWithUnsignedInteger:0];
        } else {
            NSUInteger m_i = [m intValue];
            if (0 != m_i) {
                --m_i;
            }
            m = [NSNumber numberWithUnsignedInteger:m_i];
        }
        [_data setObject:m forKey:key];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:key
                                                            object:self];
    });
}

- (NSUInteger)get:(NSString *)key
{
    __block NSUInteger m_v;
    dispatch_sync(_metricQ, ^{
        m_v = [[_data objectForKey:key] unsignedIntegerValue];
    });
    return m_v;
}

- (id)proxyForJson
{
    __block NSDictionary* d = nil;
    dispatch_sync(_metricQ, ^{
        d = [[_data copy] autorelease];
    });
    return d;
}

@end


@implementation BCMetricStore

static BCMetricStore* _sharedMetrics;

+ (BCMetricStore *)sharedMetricStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMetrics = [[BCMetricStore alloc] init];
        
        BCMetrics* defaultMetrics = [[BCMetrics alloc] init];
        _sharedMetrics.sessionMetrics = defaultMetrics;
        [defaultMetrics release];
    });
    return _sharedMetrics;
}

@synthesize sessionMetrics;

@end
