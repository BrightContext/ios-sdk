//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the
// LICENSE file. You may not use this file except in
// compliance with the License.
//-----------------------------------------------------------------

#import "FeedMetadataTests.h"

#import "BrightContext.h"

@implementation FeedMetadataTests

- (void) testFeedEqualsOtherFeedWithSameMetadata
{
    BCFeedMetadata* md1;
    BCFeedMetadata* md2;
    BCFeed* f1;
    BCFeed* f2;
    
    md1 = [BCFeedMetadata metadataWithProject:nil
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:nil
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    STAssertEqualObjects(md1, md2, @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertEqualObjects(f1, f2, @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    STAssertEqualObjects(md1, md2, @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertEqualObjects(f1, f2, @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:nil
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:nil
                                      filters:nil];
    STAssertEqualObjects(md1, md2, @"");

    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertEqualObjects(f1, f2, @"");

    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:nil];
    STAssertEqualObjects(md1, md2, @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertEqualObjects(f1, f2, @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:@{ @"a": @"one", @"b": @"two" }];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:@{ @"a": @"one", @"b": @"two" }];
    STAssertEqualObjects(md1, md2, @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertEqualObjects(f1, f2, @"");
}

- (void) testFeedDoesNotEqualOtherFeedWithDifferentMetadata
{
    BCFeedMetadata* md1;
    BCFeedMetadata* md2;
    BCFeed* f1;
    BCFeed* f2;
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"b"
                                      channel:nil
                                    connector:nil
                                      filters:nil];
    STAssertFalse([md1 isEqual:md2], @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertFalse([f1 isEqual:f2], @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:nil
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"b"
                                    connector:nil
                                      filters:nil];
    STAssertFalse([md1 isEqual:md2], @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertFalse([f1 isEqual:f2], @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:nil];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"b"
                                      filters:nil];
    STAssertFalse([md1 isEqual:md2], @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertFalse([f1 isEqual:f2], @"");
    
    md1 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:@{ @"a": @"one", @"b": @"two" }];
    md2 = [BCFeedMetadata metadataWithProject:@"a"
                                      channel:@"a"
                                    connector:@"a"
                                      filters:@{ @"a": @"one", @"b": @"two", @"c": @"three" }];
    STAssertFalse([md1 isEqual:md2], @"");
    
    f1 = [BCFeed feedWithMetadata:md1];
    f2 = [BCFeed feedWithMetadata:md2];
    STAssertFalse([f1 isEqual:f2], @"");
}

@end
