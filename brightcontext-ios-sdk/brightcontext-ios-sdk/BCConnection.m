//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCConnection.h"
#import "BCMetrics.h"
#import "BCConstants.h"
#import "BrightContext.h"
#import "SBJson.h"
#import "BCEvent.h"
#import "BCCommand.h"

NSString* BCConnection_CommandQueueName = @"com.brightcontext.connection.commandqueue";

@implementation BCConnection

@synthesize delegate;

- (id)init
{
  self = [super init];
  if (self) {
      _parser = [[SBJsonParser alloc] init];
      _commandQ = [[NSOperationQueue alloc] init];
      [_commandQ setName:BCConnection_CommandQueueName];
      [_commandQ setSuspended:YES];
  }
  return self;
}

- (void)dealloc
{
    [_parser release];
    _parser = nil;
    
    [self disconnect];
    
    if (_commandQ) {
        [_commandQ cancelAllOperations];
        [_commandQ release];
        _commandQ = nil;
    }
    
    [super dealloc];
}
                                                         
- (void)connect
{
    if ([self isConnected]) {
        [self disconnect];
    }
    
    NSURL* socketUrl = [self.delegate socketUrlForConnection:self];
    NSURLRequest* r = [NSURLRequest requestWithURL:socketUrl];
    _socket = [[SRWebSocket alloc] initWithURLRequest:r];
    _socket.delegate = self;
    [_socket open];
}

- (BOOL)isConnected
{
    SRReadyState s = _socket.readyState;
    return (SR_OPEN == s);
}

- (BOOL)isConnecting
{
    SRReadyState s = _socket.readyState;
    return (SR_CONNECTING == s);
}

- (BOOL)isClosing
{
    SRReadyState s = _socket.readyState;
    return (SR_CLOSING == s);
}

- (BOOL)isClosed
{
    SRReadyState s = _socket.readyState;
    return (SR_CLOSED == s);
}

- (void)disconnect
{
    _socket.delegate = nil;
    [_socket close];
    [_socket release];
    _socket = nil;
}

- (void)send:(BCCommand *)cmd
{
    NSString* json = [[cmd toJson] retain];
    if (json) {
        [_commandQ addOperationWithBlock:^{
            if (SR_OPEN == _socket.readyState) {
                BCLog(@"socket: %@ send: %@", _socket, json);
                [_socket send:json];
                
                BCMetricInc(kBCMetrics_streamObjectWrites);
            }
            [json release];
        }];
    } else {
        BCLog(@"socket: %@ json serialization failed for command: %@", _socket, cmd);
    }
}

#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    BCLog(@"webSocket: %@ didReceiveMessage: %@", webSocket, message);
    BCMetricInc(kBCMetrics_streamObjectReads);
    
    NSDictionary* d = [_parser objectWithString:message];
    
    BCEvent* e = [[[BCEvent alloc] initWithDictionary:d] autorelease];
    [self.delegate connection:self didParseEvent:e];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    BCLog(@"webSocketDidOpen: %@", webSocket);
    BCMetricInc(kBCMetrics_streamOpens);

    [_commandQ setSuspended:NO];
    
    [self.delegate connectionDidOpen:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    BCLog(@"webSocket: %@ didFailWithError: %@", webSocket, error);
    BCMetricInc(kBCMetrics_streamErrors);
    
    [_commandQ setSuspended:YES];
    
    [self.delegate connection:self didError:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    BCLog(@"webSocket: %@ didCloseWithCode: %d reason: %@ wasClean: %@",
          webSocket, code, reason, (wasClean) ? @"YES" : @"NO");
    BCMetricInc(kBCMetrics_streamCloses);
    
    [_commandQ setSuspended:YES];
    
    [self.delegate connectionDidClose:self];
}

@end
