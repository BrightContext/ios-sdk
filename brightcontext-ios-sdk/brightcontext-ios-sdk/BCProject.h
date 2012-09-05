//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

@protocol BCConnectionManager;
@protocol BCFeedListener;
@class BCChannelDescription;

typedef void(^BCChannelDescriptionFetchCompletion)(BCChannelDescription* channelMetadata, NSError* err);

/*!
 \brief Represents a Project in the management console
 
 Used to load any type of feed on any type of channel using a single line of code.
 
 \section Overview
 Initialize a context (only once), then load a project
 
 \subsection setup Load a project with multiple channels
 \code
 BrightContext* ctx = [BrightContext contextWithApiKey:@"myapikey"];
 BCProject* p = [ctx loadProject:@"project name"];
 \endcode
 
 \section thru ThruChannels
 
 \subsection thru1 Open a ThruChannel and listen for messages on the default sub-channel
 \code
 [p open:@"chat" listener:self];
 \endcode
 
 \subsection thru2 Open a ThruChannel and listen for messages on a private sub-channel
 \code
 [p open:@"chat" subchannel:@"ten forward" listener:self];
 \endcode
 
 \section quant QuantChannels
 
 \subsection quant1 Open a QuantChannel Input to send in votes
 \code
 [p open:@"poll" feed:@"votes" listener:self];
 \endcode
 
 \subsection quant2 Open a QuantChannel Output with a run-time filter to show only results by current location
 \code
 [p open:@"poll" feed:@"results" filter:[NSDictionary dictionaryWithObject:@"78701" forKey:@"zip"] listener:self];
 \endcode
 
 @see BCFeedListener
 
 */
@interface BCProject : NSObject
{
    NSMutableDictionary* _channelMetadata;
}

+ (id)projectWithName:(NSString*)n inContext:(id<BCConnectionManager>)cm;

@property (readwrite,nonatomic,retain) NSString* name;
@property (readwrite,nonatomic,assign) id<BCConnectionManager> connection;

- (void) open:(NSString*)unprocessedChannelName
     listener:(id<BCFeedListener>)listener;

- (void) open:(NSString*)unprocessedChannelName
   subchannel:(NSString*)subchannelName
     listener:(id<BCFeedListener>)listener;

- (void) open:(NSString*)processedChannelName
         feed:(NSString*)feedName
     listener:(id<BCFeedListener>)listener;

- (void) open:(NSString*)processedChannelName
         feed:(NSString*)feedName
       filter:(NSDictionary*)filters
     listener:(id<BCFeedListener>)listener;

@end
