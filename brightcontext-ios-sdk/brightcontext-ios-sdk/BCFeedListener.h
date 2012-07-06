//
//  BCFeedListener.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCFeed;
@class BCMessage;

/**
 @protocol BCFeedListener
 
 \brief Main protocol for event dispatch
 
 Listeners are automatically registered to receive events about a feed when they use BCProject
 
 \code
 
 - (void) connect:(id)sender
 {
    [project open:@"chat" listener:self];   // instance of BCProject we got during app startup
 }
 
 - (void)didOpenFeed:(BCFeed *)feed
 {
    NSDictionary* d = [NSDictionary dictionaryWithObject:@"hello" forKey:@"text"]; 
    BCMessage* m = [BCMessage messageFromDictionary:d];
    [feed send:m];
 }

 - (void)didReceiveMessage:(BCMessage *)message onFeed:(BCFeed *)feed
 {
    NSLog(@"%@", message);
 }
 
 \endcode
 
 \example TestListener.h
 \example TestListener.m
 
 */
@protocol BCFeedListener <NSObject>

@optional

/**
 \brief Called when there has been a feed error.
 
 An error could happen before or after the feed is ready for use.
 Inspect the provided error object to determine recovery options.
 
 @param error The error encountered opening, closing, or sending a message on a feed
 
 \see kBCEventErrorDomain
 \see kBCEventError_UserInfo_Message
 */
- (void) didError:(NSError*)error;

/**
 \brief Called when a feed has been opened and is ready for use
 @param feed the feed that was opened
 */
- (void) didOpenFeed:(BCFeed*)feed;
/**
 \brief Called when a feed has been closed and can no longer be used
 @param feed the feed that was closed
*/
- (void) didCloseFeed:(BCFeed*)feed;
/**
 \brief Called when a message is delivered from the server to the client
 @param message the message object that contains the data
 @param feed the feed on which the message was delivered
 */
- (void) didReceiveMessage:(BCMessage*)message onFeed:(BCFeed*)feed;
/**
 \brief Called when a message is delivered from the client to the server
 @param message the message object that contains the data
 @param feed the feed on which the message was delivered
 */
- (void) didSendMessage:(BCMessage*)message onFeed:(BCFeed*)feed;

@end

