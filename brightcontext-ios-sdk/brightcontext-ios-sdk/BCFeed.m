//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCSerializable.h"
#import "BCMessage.h"
#import "BCConnectionManager.h"
#import "BCFeedDescription.h"
#import "BCEvent.h"
#import "BCFeed.h"
#import "BCFeed_Private.h"
#import "BCConstants.h"
#import "BCCommand.h"

@implementation BCFeed

+ (BCFeedType)feedTypeFromString:(NSString *)feedTypeString
{
    BCFeedType t = BCFeedType_Unknown;
    
    if ([feedTypeString isEqualToString:BC_FEED_TYPE_THRU]) {
        t = BCFeedType_Through;
    } else if ([feedTypeString isEqualToString:BC_FEED_TYPE_OUT]) {
        t = BCFeedType_Output;
    } else if ([feedTypeString isEqualToString:BC_FEED_TYPE_IN]) {
        t = BCFeedType_Input;
    }
    
    return t;
}

+ (BCFeed*) feedWithMetadata:(BCFeedMetadata *)md
{
    BCFeed* f = [[[BCFeed alloc] init] autorelease];
    f.metadata = md;
    f.type = BCFeedType_Unknown;
    return f;
}

@synthesize procId, type, key, netId, throttleRate, filters, settings, connection;
@synthesize usesPolling, revoteInterval, pollFields, revoteTimer, timeOfLastVote, previousMessage, currentPollingTimeslot;

- (void)loadSettings:(NSDictionary *)data
{
    NSString* feedTypeString = [data objectForKey:@"feedType"];
    self.type = [BCFeed feedTypeFromString:feedTypeString];
    
    self.procId = [data objectForKey:@"procId"];
    self.key = [data objectForKey:@"feedKey"];
    self.netId = [data objectForKey:@"netId"];
    self.throttleRate = [data objectForKey:@"throttleRate"];
    
    id activePollingMode = [data objectForKey:@"activeUserFlag"];
    if ((NULL != activePollingMode) && (![[NSNull null] isEqual:activePollingMode])) {
        self.usesPolling = [activePollingMode boolValue];
    } else {
        self.usesPolling = NO;
    }
    
    NSArray* activeUserFields = nil;
    id activeUserCycle = [data objectForKey:@"activeUserCycle"];
    if ((NULL != activeUserCycle) && (![[NSNull null] isEqual:activeUserCycle])) {
        self.revoteInterval = [activeUserCycle intValue];
        activeUserFields = [data objectForKey:@"activeUserFields"];
        self.pollFields = activeUserFields;
    }
    
    id writeKeyFlag = [data objectForKey:@"writeKeyFlag"];
    if ((NULL != writeKeyFlag) && (![[NSNull null] isEqual:writeKeyFlag])) {
        _isWriteProtected = [writeKeyFlag boolValue];
    } else {
        _isWriteProtected = NO;
    }
    
    id msgContract = [data objectForKey:@"msgContract"];
    if ((NULL != msgContract) && (![[NSNull null] isEqual:msgContract])) {
        if ([msgContract isKindOfClass:[NSArray class]]) {
            NSArray* msgContractArr = (NSArray*) msgContract;
            if (0 != msgContractArr.count) {
#if BC_MESSAGE_CONTRACT_VALIDATION
                self.messageContract = msgContract;
#endif
                
                if (self.usesPolling && activeUserFields) {
                    NSMutableArray* dimensions = [NSMutableArray arrayWithCapacity:msgContractArr.count];
                    for (NSDictionary* d in msgContractArr) {
                        NSString* fieldName = [d objectForKey:@"fieldName"];
                        if (![activeUserFields containsObject:fieldName]) {
                            [dimensions addObject:fieldName];
                        }

                    }
                    self.pollDimensions = dimensions;
                }
                
            }
        }
    }
    
    if ([[data allKeys] containsObject:@"filters"]) {
        id filterData = [data objectForKey:@"filters"];
        if ([filterData isKindOfClass:[NSDictionary class]]) {
            self.filters = filterData;
        } else if ([filterData isKindOfClass:[NSString class]]) {
            if ((nil != filterData) && (![filterData isEqualToString:@""])) {
                id parsedFilters = [filterData JSONValue];
                if ([parsedFilters isKindOfClass:[NSDictionary class]]) {
                    self.filters = parsedFilters;
                }
            }
        }
    }
    
    BCFeedSettings* derivedSettings = [[BCFeedSettings new] autorelease];
    derivedSettings.type = feedTypeString;
    derivedSettings.procId = self.procId;
    
    if (self.filters) {
        derivedSettings.filters = [self.filters allKeys];
        derivedSettings.filterValues = self.filters;
    }
    self.settings = derivedSettings;
    
    if (self.usesPolling) {
        _activePollingMessageQueue = dispatch_queue_create("com.brightcontext.feed.activepolling.messagequeue", DISPATCH_QUEUE_SERIAL);
        _activePollingResponseSemaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(_activePollingResponseSemaphore);
    }
}

- (void)dealloc
{
    [procId release];
    [key release];
    [netId release];
    [throttleRate release];
    [filters release];
    [settings release];
    
    [pollFields release];
    [revoteTimer release];
    [previousMessage release];
    [currentPollingTimeslot release];
    
    if (usesPolling) {
        dispatch_release(_activePollingMessageQueue);
        
        long timedout = dispatch_semaphore_wait(_activePollingResponseSemaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
        if (!timedout) {
            dispatch_release(_activePollingResponseSemaphore);
        } else {
            BCLog(@"Failed to release active polling semaphore, timeout expired");
        }
    }
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key: %@ code: %@",
            self.key, [self.settings generateHashCode]];
}

- (BOOL)isEqual:(id)object
{
    if (!object) return NO;
    if (![object isKindOfClass:[BCFeed class]]) return NO;
    
    BCFeed* otherFeed = (BCFeed*) object;
    BCFeedMetadata* otherMetadata = otherFeed.metadata;
    
    if (!otherMetadata) return NO;
    
    BOOL metadataMatches = [self.metadata isEqual:otherMetadata];
    return metadataMatches;
}

- (void)send:(BCMessage *)msg
{
#if BC_MESSAGE_CONTRACT_VALIDATION
    [self validateMessage:msg];
#else
    if (!msg) return;
#endif
    
    if (self.usesPolling) {
        dispatch_async(_activePollingMessageQueue, ^{
            long timedout = dispatch_semaphore_wait(_activePollingResponseSemaphore, BC_FEED_MAX_ACTIVE_MESSAGE_QUEUE_WAIT_TIME);
            if (!timedout) {
                if (self.revoteTimer) {
                    [self sendUpdateDelta:msg];
                } else {
                    [self sendInitial:msg];
                }
            } else {
                BCLog(@"Wait time expired, active polling message skipped: %@", msg);
            }
        });
    } else {
        [connection sendMessage:msg onFeed:self];
    }
}

- (void)close
{
    [self stopRevoteTimer];
    [connection closeFeed:self];
}

- (void)getHistory:(BCFeedHistoryCallback)callback
{
    [self getHistory:callback limit:0];
}

- (void)getHistory:(BCFeedHistoryCallback)callback limit:(NSUInteger)limit
{
    [self getHistory:callback limit:limit ending:nil];
}

- (void)getHistory:(BCFeedHistoryCallback)callback limit:(NSUInteger)limit ending:(NSDate *)ending
{
    if (!callback) return;
    
    BCFeedHistoryCallback b = [callback copy];
    BCCommand* h = [BCCommand getHistory:self
                                   limit:limit
                                  ending:ending];
    
    [connection sendRequest:h onResponse:^(BCEvent *evt) {
        if (evt.isError) {
            b(nil, evt.error);
        } else {
            NSArray* rawpoints = evt.message.rawData;
            
            __block NSMutableArray* messages = [NSMutableArray arrayWithCapacity:rawpoints.count];
            [rawpoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary* d = obj;
                
                BCMessage* m = [BCMessage new];
                m.timestamp = BC_MAKENSREFSTAMP([[d objectForKey:@"ts"] doubleValue]);
                m.rawData = [d objectForKey:@"message"];
                
                [messages addObject:m];
                
                [m release];
            }];
            
            b(messages, nil);
        }
        
        [b release];
    }];
}

#pragma mark Write Protection

@synthesize writeKey;
@synthesize isWriteProtected=_isWriteProtected;

#pragma mark Active Polling

- (void) startRevoteTimer
{
    self.revoteTimer = [NSTimer timerWithTimeInterval:self.revoteInterval
                                               target:self
                                             selector:@selector(revote:)
                                             userInfo:nil
                                              repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.revoteTimer
                              forMode:NSRunLoopCommonModes];
}

- (void)stopRevoteTimer
{
    self.previousMessage = nil;
    [self.revoteTimer invalidate];
    self.revoteTimer = nil;
}

- (void)sendInitial:(BCMessage *)msg
{
    BCCommand* initial = [BCCommand sendMessage:msg
                                         onFeed:self
                              withActivityState:BCActivityState_INITIAL
                                          forTS:nil];
    
    [self.connection sendRequest:initial onResponse:^(BCEvent *evt) {
        if (evt.isError) {
          BCLog(@"Error sending initial: %@", [evt error]);
        } else {
          NSDictionary* d = [[evt message] rawData];
          NSNumber* tslot = [d objectForKey:BC_PARAM_TSLOT_C];
#if BC_DEBUG_POLLING
          NSAssert(nil != tslot, @"timeslot should not be nil on initial");
#endif
          self.currentPollingTimeslot = tslot;
          self.previousMessage = msg;   // save values, not adjustments
          self.timeOfLastVote = [NSDate timeIntervalSinceReferenceDate];
        }

        [self.connection notifyListenersMessageSent:msg withError:[evt error] onFeed:self];
        
        dispatch_semaphore_signal(_activePollingResponseSemaphore);
    }];
    
    [self startRevoteTimer];
}

- (void)sendUpdateDelta:(BCMessage *)msg
{
    if (BCMessageVariant_Dictionary != msg.type) {
        BCLog(@"only know how to adjust deltas for dictionaries, not type: %d", msg.type);
        return;
    }
    
    NSDictionary* msgDataPrev = [self.previousMessage rawData];
    NSMutableDictionary* msgData = [[[msg rawData] mutableCopy] autorelease];
    
    // test dimensions
    for (NSString* fieldName in self.pollDimensions) {
        id oldValue = [msgDataPrev objectForKey:fieldName];
        id newValue = [msgData objectForKey:fieldName];
        if (![newValue isEqual:oldValue]) {
            [self stopRevoteTimer];
            [self sendInitial:msg];
            return;
        }
    }
    
    // adjust values
    for (NSString* fieldName in self.pollFields) {
        float actual = [[msgData objectForKey:fieldName] floatValue];
        float prev = [[msgDataPrev objectForKey:fieldName] floatValue];
        float delta = actual - prev;
        [msgData setObject:[NSNumber numberWithFloat:delta] forKey:fieldName];
    }
    
    BCMessage* deltaMsg = [BCMessage messageFromDictionary:msgData];
    BCCommand* update = [BCCommand sendMessage:deltaMsg
                                        onFeed:self
                             withActivityState:BCActivityState_UPDATE
                                         forTS:self.currentPollingTimeslot];
    
    [self.connection sendRequest:update onResponse:^(BCEvent *evt) {
        if (evt.isError) {
          BCLog(@"Error sending update: %@", [evt error]);
        } else {
#if BC_DEBUG_POLLING
          NSDictionary* d = [[evt message] rawData];
          NSNumber* tslot = [d objectForKey:BC_PARAM_TSLOT_C];
          NSAssert(nil != tslot, @"timeslot should not be nil on update");
#endif
          self.previousMessage = msg;   // save values, not adjustments
          self.timeOfLastVote = [NSDate timeIntervalSinceReferenceDate];
        }
        
        [self.connection notifyListenersMessageSent:deltaMsg withError:[evt error] onFeed:self];
        
        dispatch_semaphore_signal(_activePollingResponseSemaphore);
    }];
}

- (void) revote:(NSTimer *)t
{
    if (![self.connection isActivePollingEnabled]) {
        BCLog(@"Active Polling Disabled");
        [self stopRevoteTimer];
        return;
    }
    
    dispatch_async(_activePollingMessageQueue, ^{
        long timedout = dispatch_semaphore_wait(_activePollingResponseSemaphore, BC_FEED_MAX_ACTIVE_MESSAGE_QUEUE_WAIT_TIME);
        
        BCCommand* revote = [BCCommand sendMessage:self.previousMessage
                                            onFeed:self
                                 withActivityState:BCActivityState_REVOTE
                                             forTS:nil];
        
        [self.connection sendRequest:revote onResponse:^(BCEvent *evt) {
            if (!timedout) {
                if (evt.isError) {
                    BCLog(@"Error sending re-vote: %@", [evt error]);
                } else {
                    NSDictionary* d = [[evt message] rawData];
                    NSNumber* tslot = [d objectForKey:BC_PARAM_TSLOT_C];
#if BC_DEBUG_POLLING
                    NSAssert(nil != tslot, @"timeslot should not be nil on revote");
#endif
                    self.currentPollingTimeslot = tslot;
                    
                    self.timeOfLastVote = [NSDate timeIntervalSinceReferenceDate];
                    
                    if ([self.connection isActivePollingEnabled]) {
                        [self startRevoteTimer];
                    } else {
                        [self stopRevoteTimer];
                    }
                }
                dispatch_semaphore_signal(_activePollingResponseSemaphore);
            }
        }];
    });
}

#pragma mark Listener Management

- (void)addListener:(id<BCFeedListener>)listener
{
    if (!listener) return;
    
    [self.connection addListener:listener forFeed:self];
}

- (void)removeListener:(id<BCFeedListener>)listener
{
    if (!listener) return;
    
    [self.connection removeListener:listener forFeed:self];
}

#if BC_MESSAGE_CONTRACT_VALIDATION

#pragma mark Validation

@synthesize messageContract;

- (void) validateMessage:(BCMessage*)msg
{
    if (!msg) {
        [NSException raise:@"Null Message"
                    format:@"Cannot send null message objects"];
    }
    
    if (!self.messageContract) {
        return;
    }
    
    if (BCMessageVariant_Dictionary != msg.type) {
       [NSException raise: @"Message payload not BCMessageVariant_Dictionary"
                   format: @"Only NSDictionary can be validated, send only dictionaries, or set BC_MESSAGE_CONTRACT_VALIDATION=0 in the build settings"];
    }
    
    NSDictionary* payload = msg.rawData;
    
    NSUInteger numContractFields = self.messageContract.count;
    NSUInteger numMessageFields = [[payload allKeys] count];
    
    if (numContractFields != numMessageFields) {
        [NSException raise:@"Field Count Incorrect"
                    format:@"Field count does not match, expected %d fields, see %d", numContractFields, numMessageFields];
    }
    
    for (NSDictionary* fieldDetails in self.messageContract) {
        [self validateMessagePayload:payload
                            hasField:fieldDetails];
    }
}

- (void)validateMessagePayload:(NSDictionary *)payload hasField:(NSDictionary *)fieldDetails
{    
    NSString* expectedName = [fieldDetails objectForKey:@"fieldName"];
    
    id foundValue = nil;
    for (id k in [payload allKeys]) {
        if (![k isKindOfClass:[NSString class]]) {
            [NSException raise:@"Only NSString allows as dictionary key"
                        format:@"Message payloads should only provide field names as NSString, found %@", [k class]];
        }
        
        NSString* fieldName = k;
        if ([expectedName isEqualToString:fieldName]) {
            foundValue = [payload objectForKey:fieldName];
        }
    }
    
    if (!foundValue) {
        [NSException raise:@"Field Not Found"
                    format:@"Message should contain field named %@", expectedName];
    }

    NSString* expectedType = [fieldDetails objectForKey:@"fieldType"];
    Class expectedClass = nil;
    if ([BC_FIELDTYPE_STRING isEqualToString:expectedType]) {
        expectedClass = [NSString class];
    } else if ([BC_FIELDTYPE_DATE isEqualToString:expectedType]) {
        expectedClass = [NSNumber class];
    } else if ([BC_FIELDTYPE_NUMBER isEqualToString:expectedType]) {
        expectedClass = [NSNumber class];
    } else if ([BC_FIELDTYPE_LIST isEqualToString:expectedType]) {
        expectedClass = [NSArray class];
    } else if ([BC_FIELDTYPE_MAP isEqualToString:expectedType]) {
        expectedClass = [NSDictionary class];
    } else if ([BC_FIELDTYPE_BOOL isEqualToString:expectedType]) {
        expectedClass = [NSNumber class];
    }
    
    NSAssert(nil != expectedClass, @"unknown field type expectation: %@", expectedType);

    if (![foundValue isKindOfClass:expectedClass]) {
        [NSException raise:@"Incorrect Field Value Type"
                    format:@"Expected value of type %@ found %@ instead", expectedClass, [foundValue class]];
    }
    
    BCFieldValidationType expectedValidation = [[fieldDetails objectForKey:@"validType"] intValue];
    
    switch (expectedValidation) {
        case BCFieldValidation_MinMax:
        {
            if ([expectedClass isEqual:[NSNumber class]]) {
                NSNumber* min = [NSNumber numberWithFloat:[[fieldDetails objectForKey:@"min"] floatValue]];
                NSNumber* max = [NSNumber numberWithFloat:[[fieldDetails objectForKey:@"max"] floatValue]];
                NSNumber* num = foundValue;
                [self validateNumber:num isGreaterThanOrEqualTo:min andLessThanOrEqualTo:max];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)validateNumber:(NSNumber *)num isGreaterThanOrEqualTo:(NSNumber *)min andLessThanOrEqualTo:(NSNumber *)max
{
    NSComparisonResult r;
    r = [min compare:num];
    if (NSOrderedDescending == r) {
        [NSException raise:@"Value under minimum"
                    format:@"Expected numeric value greater than or equal to %@, found %@", min, num];
    }
    
    r = [max compare:num];
    if (NSOrderedAscending == r) {
        [NSException raise:@"Value over maximum"
                    format:@"Expected numeric value less than or equal to %@, found %@", max, num];
    }
}

#endif

@end
