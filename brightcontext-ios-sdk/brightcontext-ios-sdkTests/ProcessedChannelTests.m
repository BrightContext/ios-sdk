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
    NSNumber* avg_actual = [m getNumberForKey:@"avg_v"];
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
    NSNumber* actual_number = [output_msg getNumberForKey:@"n"];
    NSDate* actual_date = [output_msg getDateForKey:@"d"];
    NSString* actual_string = [output_msg getStringForKey:@"s"];
    
    STAssertEqualObjects(actual_number, expected_number, @"");
    STAssertEqualObjects([actual_date description], [expected_date description], @"");
    STAssertEqualObjects(actual_string, expected_string, @"");
    
    [ctx shutdown:^(NSError *err) {
        STAssertNil(err, @"Shutdown Error: %@", err);
    }];
    
    // wait for shutdown
    spinwait(5);
}

@end
