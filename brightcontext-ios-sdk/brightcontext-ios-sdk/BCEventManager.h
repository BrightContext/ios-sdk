//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import <BCConnectionManager.h>

/*
 Main storage for three mappings.
 
 Feed keys - listeners
 Feed codes - listeners
 Event keys - responders
 
 Used during event dispatch to determine what events should be delivered where
 */
@interface BCEventManager : NSObject
{
    @private
    NSMutableDictionary* _feedKeyRegistry;
    NSMutableDictionary* _feedSettingsRegistry;
    NSMutableDictionary* _feedMetadataRegistry;
    
    NSMutableDictionary* _feedListeners;
    NSMutableDictionary* _responseListeners;
    
    dispatch_queue_t _eventQueue;
    dispatch_queue_t _mainQueue;
}

- (void) registerFeed:(BCFeed*)feed;
- (NSArray*) registeredFeeds;
- (void) indexRegisteredFeed:(BCFeed *)feed;
- (void) unregisterFeed:(BCFeed*)feed;

- (BCFeed*) registeredFeedMatchingMetadata:(BCFeedMetadata*)metadata;
- (BCFeed*) registeredFeedMatchingSettings:(BCFeedSettings*)settings;
- (BCFeed*) registeredFeedMatchingKey:(BCFeedKey*)feedKey;

- (void) addListener:(id<BCFeedListener>)listener forFeed:(BCFeed*)feed;
- (void) removeListener:(id<BCFeedListener>)listener forFeed:(BCFeed*)feed;
- (void) removeAllListeners;

- (void) addResponder:(BCResponseHandlerCompletion)responseBlock
          forEventKey:(BCEventKey*)eventKey;
- (void) removeResponderForEventKey:(BCEventKey*)eventKey;
- (void) removeAllResponders;

- (void) dispatch:(BCEvent*)event;

- (void) notifyListenersMessageSent:(BCMessage*)message
                          withError:(NSError*)error
                             onFeed:(BCFeed*)feed;
- (void) notifyListenersFeedClosed:(BCFeed*)feed
                         withError:(NSError*)error;

@end


/** The label attached to the event dispatch queue with dispatch_queue_create */
extern NSString* kBCEventManager_DispatchQueue;

