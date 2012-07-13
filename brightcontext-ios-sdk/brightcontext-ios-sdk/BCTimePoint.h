//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

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
