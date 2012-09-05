//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

@protocol BCSerializable;
@class BCFeed;
@class BCFeedSettings;

typedef enum {
    BCCommandActionType_GET,
    BCCommandActionType_PUT,
} BCCommandActionType;

@interface BCCommand : NSObject <BCSerializable>

+ (BCCommand*) serverTime;
+ (BCCommand*) heartbeat;
+ (BCCommand*) channelDescription:(NSString*)channelName inProject:(NSString*)projectName;
+ (BCCommand*) openFeed:(BCFeedSettings*)settings;
+ (BCCommand*) closeFeed:(BCFeed*)feed;
+ (BCCommand*) closeFeeds:(NSArray*)feeds;

+ (BCCommand*) sendMessage:(BCMessage*)msg
                    onFeed:(BCFeed*)feed;
+ (BCCommand*) sendMessage:(BCMessage *)msg
                    onFeed:(BCFeed *)feed
         withActivityState:(BCActivityState)state
                     forTS:(NSNumber *)tslot;

+ (BCCommand*) getHistory:(BCFeed*)feed limit:(NSUInteger)limit ending:(NSDate*)ending;

@property (readwrite,nonatomic,assign) BCEventKey* eventKey;
@property (readwrite,nonatomic,assign) BCCommandActionType action;
@property (readwrite,nonatomic,retain) NSString* resource;
@property (readwrite,nonatomic,retain) NSMutableDictionary* parameters;

- (void) setObject:(id)value forParam:(NSString*)key;
- (id) getParam:(NSString*)key;

- (NSString*) commandPath;

@end

@interface BCCommandHeartbeat : BCCommand

@end
