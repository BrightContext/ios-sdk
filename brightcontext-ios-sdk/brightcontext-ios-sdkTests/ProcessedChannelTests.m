//
//  ProcessedChannelTests.m
//  brightcontext-ios-sdk
//
//  Created by Steven Fusco on 7/16/12.
//  Copyright (c) 2012 BrightContext Corporation. All rights reserved.
//

#import "ProcessedChannelTests.h"

#import "TestContext.h"
#import "TestListener.h"

@implementation ProcessedChannelTests

- (void) testBasicAverages
{
    id<TestSettings> settings = BC_TEST_SETTINGS;
    
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = settings;
    
    TestListener* inputHandler = [[TestListener new] autorelease];
    TestListener* outputHandler = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:[settings testProject]];
    [p open:@"basic averages" feed:@"i" listener:inputHandler];
    [p open:@"basic averages" feed:@"o" listener:outputHandler];
    
    spinwait(1);
    
    // check if things opened correctly
    STAssertTrue(1 == inputHandler.numOpens, @"");
    STAssertTrue(1 == outputHandler.numOpens, @"");
    STAssertTrue(0 == inputHandler.numErrors, @"");
    STAssertTrue(0 == outputHandler.numErrors, @"");
    STAssertTrue(0 == inputHandler.numCloses, @"");
    STAssertTrue(0 == outputHandler.numCloses, @"");

    BCMetricPrint();
    
    BCFeed* inputfeed = inputHandler.testFeed;
    STAssertNotNil(inputfeed, @"input feed null");
    if (!inputfeed) return; // bail early
    
    float sum,count,avg = 0;
    for (int i=1; i<=10; ++i) {
        BCMessage* m = [[BCMessage alloc] init];
        [m setNumber:[NSNumber numberWithInt:i] forKey:@"v"];
        [inputfeed send:m];
        [m release];
        ++count;
        sum += i;
    }
    avg = sum / count;
    
    // wait for calculations
    spinwait(5);
    
    // test math
    NSArray* outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(1 == outputmessages.count, @"");
    
    BCMessage* m = [outputmessages lastObject];
    NSNumber* avg_actual = [m numberForKey:@"avg_v"];
    STAssertTrue(avg == [avg_actual floatValue], @"");
    
    [ctx shutdown:^(NSError *err) {
        STAssertNil(err, @"Shutdown Error: %@", err);
    }];
    
    // wait for shutdown
    spinwait(5);
}

- (void) testFieldValues
{
    id<TestSettings> settings = BC_TEST_SETTINGS;
    
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = settings;
    
    TestListener* inputHandler = [[TestListener new] autorelease];
    TestListener* outputHandler = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:[settings testProject]];
    [p open:@"field types" feed:@"i" listener:inputHandler];
    [p open:@"field types" feed:@"o" listener:outputHandler];
    
    spinwait(5);
    
    // check if things opened correctly
    STAssertTrue(1 == inputHandler.numOpens, @"");
    STAssertTrue(1 == outputHandler.numOpens, @"");
    STAssertTrue(0 == inputHandler.numErrors, @"");
    STAssertTrue(0 == outputHandler.numErrors, @"");
    STAssertTrue(0 == inputHandler.numCloses, @"");
    STAssertTrue(0 == outputHandler.numCloses, @"");
    
    BCMetricPrint();
    
    BCFeed* inputfeed = inputHandler.testFeed;
    STAssertNotNil(inputfeed, @"input feed null");
    if (!inputfeed) return; // bail early
    
    
    NSNumber* expected_number = [NSNumber numberWithInt:7];
    NSDate* expected_date = [NSDate date];
    NSString* expected_string = @"string";
    
    BCMessage* input_msg = [[BCMessage alloc] init];
    [input_msg setNumber:expected_number forKey:@"n"];
    [input_msg setDate:expected_date forKey:@"d"];
    [input_msg setString:expected_string forKey:@"s"];
    
    [inputfeed send:input_msg];
    
    // wait for calculations
    spinwait(5);
    
    // test math
    NSArray* outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(1 == outputmessages.count, @"");
    
    BCMessage* output_msg = [outputmessages lastObject];
    NSNumber* actual_number = [output_msg numberForKey:@"n"];
    NSDate* actual_date = [output_msg dateForKey:@"d"];
    NSString* actual_string = [output_msg stringForKey:@"s"];
    
    STAssertEqualObjects(actual_number, expected_number, @"");
    STAssertEqualObjects([actual_date description], [expected_date description], @"");
    STAssertEqualObjects(actual_string, expected_string, @"");
    
    [ctx shutdown:^(NSError *err) {
        STAssertNil(err, @"Shutdown Error: %@", err);
    }];
    
    // wait for shutdown
    spinwait(5);
}

- (void) testActivePollingInput
{
    id<TestSettings> settings = BC_TEST_SETTINGS;
    
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = settings;
    
    TestListener* inputHandler = [[TestListener new] autorelease];
    TestListener* outputHandler = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:[settings testProject]];
    
    /*
     activeinput = {
     s : 'String',
     d : new Date(),
     n : 10
     }
     */
    [p open:@"active" feed:@"activeinput" listener:inputHandler];
    
    /*
     activeoutput = {
     sum : 10,
     avg : 10,
     count : 10
     }
     */
    [p open:@"active" feed:@"activeoutput" listener:outputHandler];
    
    spinwait(5);
    
    // check if things opened correctly
    STAssertTrue(1 == inputHandler.numOpens, @"");
    STAssertTrue(1 == outputHandler.numOpens, @"");
    STAssertTrue(0 == inputHandler.numErrors, @"");
    STAssertTrue(0 == outputHandler.numErrors, @"");
    STAssertTrue(0 == inputHandler.numCloses, @"");
    STAssertTrue(0 == outputHandler.numCloses, @"");
    
    BCMetricPrint();
    
    BCFeed* inputfeed = inputHandler.testFeed;
    STAssertNotNil(inputfeed, @"input feed null");
    if (!inputfeed) return; // bail early
    
    
    BCMessage* input_msg = [[BCMessage alloc] init];
    [input_msg setNumber:[NSNumber numberWithInt:1] forKey:@"n"];
    [input_msg setDate:[NSDate date] forKey:@"d"];
    [input_msg setString:@"string" forKey:@"s"];
    
    [inputfeed send:input_msg];
    [inputfeed send:input_msg];
    
    // wait for calculations
    spinwait(5);
    
    NSArray* inputmessages = [inputHandler messagesSent];
    STAssertNotNil(inputmessages, @"");
    STAssertTrue(2 == inputmessages.count, @"");
    
    // test math
    NSArray* outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(1 == outputmessages.count, @"");
    
    BCMessage* output_msg = [outputmessages lastObject];
    NSNumber* actual_sum = [output_msg numberForKey:@"sum"];
    NSNumber* actual_avg = [output_msg numberForKey:@"avg"];
    NSNumber* actual_count = [output_msg numberForKey:@"count"];
    
    NSNumber* expected_sum = [NSNumber numberWithInt:1];
    NSNumber* expected_avg = [NSNumber numberWithInt:1];
    NSNumber* expected_count = [NSNumber numberWithInt:1];
    STAssertEqualObjects(actual_sum, expected_sum, @"sum");
    STAssertEqualObjects(actual_avg, expected_avg, @"avg");
    STAssertEqualObjects(actual_count, expected_count, @"count");
    
    [ctx shutdown:^(NSError *err) {
        STAssertNil(err, @"Shutdown Error: %@", err);
    }];
    
    // wait for shutdown
    spinwait(5);
}

- (void) testDimensionChanges
{
    spinwait(15);   // wait for calculations to clear
    
    id<TestSettings> settings = BC_TEST_SETTINGS;
    
    TestContext* ctx = [[TestContext new] autorelease];
    ctx.settings = settings;
    
    TestListener* inputHandler = [[TestListener new] autorelease];
    TestListener* outputHandler = [[TestListener new] autorelease];
    
    BCProject* p = [ctx loadProject:[settings testProject]];
    
    /*
     i = {
         group : 'String',
         value : 10
     }
     */
    [p open:@"activegroups" feed:@"i" listener:inputHandler];
    
    /*
     o = {
         c : 10,
         g1 : 10,
         g2 : 10
     }
     */
    [p open:@"activegroups" feed:@"o" listener:outputHandler];
    
    spinwait(3);
    
    // check if things opened correctly
    STAssertTrue(1 == inputHandler.numOpens, @"");
    STAssertTrue(1 == outputHandler.numOpens, @"");
    STAssertTrue(0 == inputHandler.numErrors, @"");
    STAssertTrue(0 == outputHandler.numErrors, @"");
    STAssertTrue(0 == inputHandler.numCloses, @"");
    STAssertTrue(0 == outputHandler.numCloses, @"");
    
    BCMetricPrint();
    
    BCFeed* inputfeed = inputHandler.testFeed;
    STAssertNotNil(inputfeed, @"input feed null");
    if (!inputfeed) return; // bail early
    
    [inputfeed send:[BCMessage messageFromDictionary:@{
                     @"group" : @"g1",
                     @"value" : [NSNumber numberWithInt:100]
                     }]];
    
    NSArray* inputmessages;
    NSArray* outputmessages;
    
    // wait for calculations
    spinwait(30);
    BCMetricPrint();
    
    inputmessages = [inputHandler messagesSent];
    STAssertNotNil(inputmessages, @"");
    STAssertTrue(1 == inputmessages.count, @"wrong count: %d", inputmessages.count);
    
    outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(6 == outputmessages.count, @"wrong count: %d", outputmessages.count);
    
    int message_index = 0;
    BCMessage* output_msg;
    NSNumber* actual_c;
    NSNumber* actual_g1;
    NSNumber* actual_g2;
    NSNumber* expected_c;
    NSNumber* expected_g1;
    NSNumber* expected_g2;
    
    // msg[0] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // msg[1] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // msg[2] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
        
    // msg[3] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // msg[4] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // msg[5] g1 should be active
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:100];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // shift to g2
    [inputfeed send:[BCMessage messageFromDictionary:@{
                     @"group" : @"g2",
                     @"value" : [NSNumber numberWithInt:12]
                     }]];
    
    // wait for more output
    spinwait(30);
    BCMetricPrint();
    
    inputmessages = [inputHandler messagesSent];
    STAssertNotNil(inputmessages, @"");
    STAssertTrue(2 == inputmessages.count, @"wrong count: %d", inputmessages.count);
    outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(12 == outputmessages.count, @"wrong count: %d", outputmessages.count);

    // watch g1 age off
        
    // msg[6] g2 active, g1 aged
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // msg[7] g2 revoting
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // msg[8] g2 revoting
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // msg[9] g2 revoting
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // msg[10] g2 revoting
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // msg[11] g2 revoting
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:1];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:12];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");
    
    // close the input and wait for more output
    [[inputHandler testFeed] close];
    spinwait(30);
    outputmessages = [outputHandler messagesReceived];
    STAssertNotNil(outputmessages, @"");
    STAssertTrue(14 == outputmessages.count, @"wrong count: %d", outputmessages.count);

    // msg[12] g2 trend off
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:0];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // msg[13] zeros
    output_msg = [outputmessages objectAtIndex:message_index++];
    actual_c = [output_msg numberForKey:@"c"];
    actual_g1 = [output_msg numberForKey:@"g1"];
    actual_g2 = [output_msg numberForKey:@"g2"];
    expected_c = [NSNumber numberWithInt:0];
    expected_g1 = [NSNumber numberWithInt:0];
    expected_g2 = [NSNumber numberWithInt:0];
    STAssertEqualObjects(actual_c, expected_c, @"c");
    STAssertEqualObjects(actual_g1, expected_g1, @"g1");
    STAssertEqualObjects(actual_g2, expected_g2, @"g2");

    // close output and cleanup
    [ctx shutdown:^(NSError *err) {
        STAssertNil(err, @"Shutdown Error: %@", err);
    }];
    
    // wait for shutdown
    spinwait(5);
}

@end
