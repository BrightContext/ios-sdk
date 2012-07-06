//
//  BCCTimePoint.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2012 BrightContext.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCSerializable.h"

/*!
 \brief An asset at a given timestamp.
 Used to represent a historic message on a feed.
*/
@interface BCTimePoint : NSObject <BCSerializable>

- (id)initWithTime:(NSTimeInterval)t asset:(id)a;

/** the time index of the asset */
@property (readwrite,nonatomic,assign) NSTimeInterval timestamp;

/** the asset data */
@property (readwrite,nonatomic,retain) id<NSObject> asset;

@end

/*!
 \example HistoryTests.m
 */
