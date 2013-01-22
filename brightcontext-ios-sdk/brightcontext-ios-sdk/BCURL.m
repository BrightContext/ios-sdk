//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "BCURL.h"


@implementation BCURL

+ (NSString*) buildQueryString:(NSString*) firstObject, ...
{
    NSMutableString *queryString = [NSMutableString stringWithString:@"?"];
    
    BOOL first = YES;
    BOOL lhs = YES;
    va_list args;
    va_start(args, firstObject);
    for (id arg = firstObject; arg != nil; arg = va_arg(args, id))
    {
        if (lhs) {
            if (!first) {
                [queryString appendString:@"&"];
            }
            first = NO;
            [queryString appendString:(NSString*)arg];
        } else {
            [queryString appendString:@"="];
            
            if ([arg isKindOfClass:[NSString class]]) {
                [queryString appendString:arg];
            } else if ([arg isKindOfClass:[NSArray class]]) {
                NSArray* a = (NSArray*) arg;
                NSString* s = [a componentsJoinedByString:@","];
                [queryString appendString:s];
            }
        }
        
        lhs = !lhs;
    }
    va_end(args);
    
    return queryString;
}

+ (NSURL*) urlWithRoot:(NSURL *)urlRoot
           forResource:(NSString *)resource
        withParameters:(NSString *)queryString
{
    NSString* us = [[urlRoot absoluteString] stringByAppendingFormat:@"%@%@", resource, queryString];
    NSURL* u = [NSURL URLWithString:us];
    return u;
}

+ (NSURL*) urlWithRoot:(NSURL *)urlRoot
           forResource:(NSString *)resource
{
    NSString* us = [[urlRoot absoluteString] stringByAppendingFormat:@"%@", resource];
    NSURL* u = [NSURL URLWithString:us];
    return u;
}

@end
