//
//  MessageValidationTests.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "MessageValidationTests.h"

#import "BCFeed.h"

@implementation MessageValidationTests

- (void) testMessageNullValidation
{
    BCFeed* f = [[BCFeed new] autorelease];
    STAssertThrows([f send:nil], @"");
}

- (void) testMessageMissingField
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithInt:5], @"f2",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageExtraField
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithInt:5], @"f2",
                             [NSDate date], @"f3",
                             @"extra field", @"f4",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageNumberFieldType
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             @"should be a number", @"f2",
                             [NSDate date], @"f3",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageDateFieldType
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithFloat:2.5], @"f2",
                             @"should be a date", @"f3",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageWrongFields
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f4",
                             @"should be a number", @"f5",
                             @"should be a date", @"f6",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageWrongPayloadType
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    BCMessage* msg = [BCMessage message];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageNumericTooSmall
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithInt:-1], @"f2",
                             [NSDate date], @"f3",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testMessageNumericTooBig
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithInt:100], @"f2",
                             [NSDate date], @"f3",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    STAssertThrows([f send:msg], @"");
}

- (void) testValidMessage
{
    NSDictionary* expected1 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f1", @"fieldName",
                               @"S", @"fieldType",
                               @"0", @"validType",
                               nil];
    NSDictionary* expected2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f2", @"fieldName",
                               @"N", @"fieldType",
                               @"1", @"validType",
                               @"1", @"min",
                               @"10", @"max",
                               nil];
    NSDictionary* expected3 = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"f3", @"fieldName",
                               @"D", @"fieldType",
                               @"0", @"validType",
                               nil];
    
    NSArray* msgContract = [NSArray arrayWithObjects:expected1, expected2, expected3, nil];
    
    
    NSDictionary* payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"string value", @"f1",
                             [NSNumber numberWithInt:5], @"f2",
                             [NSDate date], @"f3",
                             nil];
    
    BCMessage* msg = [BCMessage messageFromDictionary:payload];
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    [f send:msg];
}

@end
