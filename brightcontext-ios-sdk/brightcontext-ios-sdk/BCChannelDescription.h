//
//  BCChannelDescription.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCSerializable.h"
#import "BCFeed.h"
#import "BCFeedDescription.h"

typedef enum {
    BCChannelType_Unprocessed,
    BCChannelType_Processed
} BCChannelType;

@interface BCChannelDescription : NSObject <BCSerializable>
{
    @private
    NSMutableArray* _feedDescriptions;
}

@property (readwrite,nonatomic,retain) NSString* name;
@property (readwrite,nonatomic,assign) BCChannelType type;

- (NSUInteger) feedDescriptionsCount;
- (BCFeedDescription*) feedDescriptionAtIndex:(NSUInteger)index;
- (BCFeedDescription*) feedDescriptionWithName:(NSString*)feedName;

@end

