//
//  BCMetrics.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 All BC metrics keys are com.brightcontext.metric.*
 Notifications are posted any time a key is incremented or decremented.
 The name of the notification is the key that changed.
 */
@interface BCMetrics : NSObject
{
    @private
    NSMutableDictionary* _data;
    dispatch_queue_t _metricQ;
}

/** Increments the value of a metric
 @param key the FQDN of the metric
 */
- (void) increment:(NSString*)key;

/** Decrements the value of a metric
 @param key the FQDN of the metric
 */
- (void) decrement:(NSString*)key;

/**
 @param key the FQDN of the metric
 @returns the current value of a metric */
- (NSUInteger) get:(NSString*)key;

/** Sets all metrics to zero */
- (void) reset;

/** @returns NSDictionary of metrics for SBJson */
- (id) proxyForJson;

@end

/** Name of the synchronous dispatch queue used for changes */
extern NSString* kBCMetricsQueueName;

/** Number of http requests sent */
extern NSString* kBCMetrics_requests;
/** Number of http requests successful */
extern NSString* kBCMetrics_requestsSuccessful;
/** Number of http requests failed */
extern NSString* kBCMetrics_requestsFailed;

/** Number of http responses */
extern NSString* kBCMetrics_responses;

/** Number of session objects created */
extern NSString* kBCMetrics_sessionsCreated;

/** Number of web streams opened */
extern NSString* kBCMetrics_streamOpens;
/** Number of times the auto-reconnect logic kicked off a new stream when a stream ended */
extern NSString* kBCMetrics_streamReconnects;
/** Number of web streams closed */
extern NSString* kBCMetrics_streamCloses;
/** Number of errors encountered on the stream */
extern NSString* kBCMetrics_streamErrors;
/** Number of objects serialized to json and sent to the server */
extern NSString* kBCMetrics_streamObjectWrites;
/** Number of objects deserialized from json string from the server */
extern NSString* kBCMetrics_streamObjectReads;


/*
 Shared storage for default metrics
 When BC_METRICS_ENABLED is defined, provides a simple shared counter mechanism about SDK usage.
 */
@interface BCMetricStore : NSObject

/** @returns the shared metric storage singleton */
+ (BCMetricStore*) sharedMetricStore;

/** Session related metrics used by requests, responses and streams */
@property (readwrite,retain) BCMetrics* sessionMetrics;

@end

#ifdef BC_METRICS_ENABLED

#define BCMetricInc(_M_) [[[BCMetricStore sharedMetricStore] sessionMetrics] increment:_M_]
#define BCMetricDec(_M_) [[[BCMetricStore sharedMetricStore] sessionMetrics] decrement:_M_]
#define BCMetricPrint() BCLog(@"%@", [[[BCMetricStore sharedMetricStore] sessionMetrics] description] )

#else

#define BCMetricInc(_M_) 
#define BCMetricDec(_M_) 
#define BCMetricPrint()

#endif