//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "MessageValidationTests.h"

#import <BCSerializable.h>
#import <BCFeed.h>
#import <BCMessage.h>

@implementation MessageValidationTests

#if BC_MESSAGE_CONTRACT_VALIDATION

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
    

    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:5] forKey:@"f2"];

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
    
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:5] forKey:@"f2"];
    [msg setDate:[NSDate date] forKey:@"f3"];
    [msg setString:@"extra field" forKey:@"f4"];
    
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
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setString:@"should be a number" forKey:@"f2"];
    [msg setDate:[NSDate date] forKey:@"f3"];

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
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:2.5] forKey:@"f2"];
    [msg setString:@"should be a date" forKey:@"f3"];

    STAssertNotNil([msg toJson], @"");

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
    
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setString:@"should be a number" forKey:@"f2"];
    [msg setString:@"should be a date" forKey:@"f3"];
    
    STAssertNotNil([msg toJson], @"");

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
    STAssertNil([msg toJson], @"");

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
    
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:-1] forKey:@"f2"];
    [msg setDate:[NSDate date] forKey:@"f3"];

    STAssertNotNil([msg toJson], @"");

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
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:100] forKey:@"f2"];
    [msg setDate:[NSDate date] forKey:@"f3"];

    STAssertNotNil([msg toJson], @"");

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
    
    BCMessage* msg = [BCMessage message];
    [msg setString:@"string value" forKey:@"f1"];
    [msg setNumber:[NSNumber numberWithInt:5] forKey:@"f2"];
    [msg setDate:[NSDate date] forKey:@"f3"];

    STAssertNotNil([msg toJson], @"");
    
    BCFeed* f = [[BCFeed new] autorelease];
    f.messageContract = msgContract;
    [f send:msg];
}

#endif

@end
