//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import <Foundation/Foundation.h>

#import <BCConstants.h>

#import <BCConnectionManager.h>
#import <BCSerializable.h>
#import <BCFeedListener.h>

#import <BCChannelDescription.h>
#import <BCEvent.h>
#import <BCCommand.h>
#import <BCFeed.h>
#import <BCFeedDescription.h>
#import <BCMessage.h>
#import <BCProject.h>
#import <BCSession.h>

#import <BCURL.h>
#import <BCHTTPRequest.h>
#import <BCHTTPResponse.h>

#import <BCMetrics.h>
#import <BCEventManager.h>
#import <BCConnection.h>

#pragma mark -

/*!
 \brief Main SDK entry point, initialized with an API key
 
 The main object that holds the connection and listener registries.
 Used to connect to the server and load project instances.
 
 \see BCProject
 
 \code
 BrightContext* ctx = [BrightContext contextWithApiKey:@"myapikey"];
 BCProject* p = [ctx loadProject:@"project name"];
 \endcode
 
 */
@interface BrightContext : NSObject
<BCConnectionManager, BCConnectionDelegate>
{
    @private
    NSTimer* _heartbeatTimer;
    BOOL _activePollingEnabled;
    BOOL _autoReconnect;
    NSMutableArray* _connectionEstablishedCompletionBlocks;
    BCHTTPRequest* _sessionCreateOperation;
}

/** The SDK Version Number
 * @returns The SDK Version Number in Major.Minor.Revision format
 */
+ (NSString*) version;

/** Build a context that uses the given API Key
 * @param apikey The api key to use
 * @returns a newly created autoreleased context associated with the given API key
 */
+ (id) contextWithApiKey:(NSString*)apikey;

@property (readwrite,nonatomic,retain) NSString* apiKey;
@property (readwrite,nonatomic,retain) BCSession* session;
@property (readwrite,nonatomic,retain) BCConnection* connection;
@property (readwrite,nonatomic,retain) BCEventManager* dispatcher;

/**
 Loads a project.  Projects contain Channels and Feeds.
 @param projectName the name of the project that was created in the management console
 @returns newly created autoreleased instance of a project bound to this context and API key that provides access to channels and feeds
 */
- (BCProject*) loadProject:(NSString*)projectName;

/**
 * Retrieves the current server time.  Useful when synchronizing clients or commands with a single time source.
 * @param completion async block callback with the following method signature: (NSError* err, NSTimeInterval serverTime)
 */
- (void)getServerTime:(BCServerTimeCompletion)completion;

/**
 * Asks the server to create a UUID (aka GUID).
 * Useful for identifying a user, grouping a set of related messages, or when creating a local UUID is not an option.
 * @param completion async block callback with the following method signature: (NSError* err, NSString* uniqueId)
 */
- (void)makeUniqueId:(BCUniqueIdCompletion)completion;

/** Retrieve if active polling is currently enabled.
 * @returns the current state of active polling, in other words, if the platform currently thinks this user is active on acive user inputs.
 * The default is YES, users are assumed to be active.
 */
- (BOOL) isActivePollingEnabled;
/** Changes the state of active polling.
 * While set to NO, the user is considered inactive on input feeds with active user tracking.
 * The default is YES, users are assumed to be active.
 * @param enabled YES if the user is active, NO otherwise.
 */
- (void) setActivePollingEnabled:(BOOL)enabled;

@end

/*! \mainpage
 
 \section overview Architecture at a glance
 
 \htmlonly
 <div align="center">
 <img src="/wp-content/themes/bcctheme2/uploads/2012/07/architecture.png">
 </div>
 \endhtmlonly
 
 \subsection step1 First Steps
 
 \code
 // Only once, probably in your AppDelegate or MainViewController
 BrightContext* ctx = [BrightContext contextWithApiKey:@"native API key from settings in management tool"];
 \endcode
 
 \subsection step2 Open as many projects as you like
 
 \code
 BCProject* p = [ctx loadProject:@"project name"];
 \endcode
 
 \subsection step3 Use the project to open feeds and listen for events
 
 \code
 [p open:@"thruchannel name" listener:mylistener];  // a basic chat channel
 \endcode
 
 It's ok to do this from wherever you like, as many times as you like.
 You don't need worry about opening the same feed multiple times and flooding the network.
 The SDK is smart enough to know what is opened and what is closed, even if you call open multiple times from different UI widgets.
 
 \subsection step4 Listeners conform to BCFeedListener
 
 \code
 
 //  TestListener.h
 
 @interface TestListener : NSObject <BCFeedListener>
 
 @end
 
 \endcode
 
 \code
 
 //  TestListener.m

 @implementation TestListener
 
 - (void)didError:(NSError *)error
 {
     NSLog(@"didError %@", error);
 }
 
 - (void)didOpenFeed:(BCFeed *)feed
 {
     NSLog(@"didOpenFeed %@", feed);
 }
 
 - (void)didReceiveMessage:(BCMessage *)message onFeed:(BCFeed *)feed
 {
     NSLog(@"didReceiveMessage: %@ onFeed: %@", message, feed);
 }
 
 - (void)didSendMessage:(BCMessage *)message onFeed:(BCFeed *)feed
 {
     NSLog(@"didSendMessage: %@ onFeed: %@", message, feed);
 }
 
 - (void)didCloseFeed:(BCFeed *)feed
 {
     NSLog(@"didCloseFeed %@", feed);
 }
 
 @end
 
 \endcode
 
 \subsection step5 When you are ready, send some data
 
 \code
 
 NSDictionary* d = [NSDictionary dictionaryWithObject:@"Mister Crusher, reconfigure working thrusters to manual input" forKey:@"shuttlecraft"]; 
 BCMessage* m = [BCMessage messageFromDictionary:d];
 [feed send:m];
 
 \endcode
 
 \subsection threading Notes about threading
 
 GCD is used heavily under the hood and all network activity happens
 on separate worker queues.  However, when your listener receives an event, 
 all your data will be handed back to you on the main thread so you
 can use it in your UI without having to do any extra work.
 
 \subsection building Building and Linking
 
 There are a few extra build flags you can turn on at compile time to enable extended features.
 In your project build settings for <code>GCC_PREPROCESSOR_DEFINITIONS</code> you can define the following:
 <ul>
 <li><code>BC_LOGGING=1</code> Turns on extra verbose debug logging for the SDK.
 <li><code>BC_MESSAGE_CONTRACT_VALIDATION=1</code> Turns on run-time assertions for data to make sure only valid messages are sent to feeds.
 </ul>
 
 <p>SocketRocket and SBJSON are library dependencies, a valid snapshot of each is included as a tarball.</p>
 
 <p>The core iOS SDK is not ARC based, however, if you are using ARC, non-ARC based code can cohabitate in your project,
 but you need to use the <a href="http://clang.llvm.org/docs/AutomaticReferenceCounting.html">CLANG compiler directives</a> <code>-fobjc-arc</code> and <code>-fno-objc-arc</code>.</p>
 
 
 \subsection more More Examples...
 
 For more examples see \ref BCProject, \ref BCFeed and \ref BCFeedListener
 
 */

