//
//  BCConnection.h
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRWebSocket.h"
#import "SBJson.h"

extern NSString* BCConnection_CommandQueueName;

@class BCCommand;
@class BCEvent;

@protocol BCConnectionDelegate;

@interface BCConnection : NSObject
<SRWebSocketDelegate>
{
    @private
    SRWebSocket* _socket;
    SBJsonParser* _parser;
    NSOperationQueue*  _commandQ;
}

@property (readwrite,nonatomic,assign) id<BCConnectionDelegate> delegate;

- (BOOL) isConnected;

- (void) connect;
- (void) disconnect;

- (void) send:(BCCommand*)cmd;

@end


@protocol BCConnectionDelegate <NSObject>

- (NSURL*) socketUrlForConnection:(BCConnection*)conn;

- (void) connection:(BCConnection*)conn didParseEvent:(BCEvent*)event;

- (void) connectionDidOpen:(BCConnection*)conn;
- (void) connectionDidClose:(BCConnection*)conn;
- (void) connection:(BCConnection*)conn didError:(NSError*)error;

@end

