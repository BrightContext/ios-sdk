//
//  BCMessage.m
//  brightcontext-ios-sdk
//
//  Copyright (c) 2011 BrightContext Corporation. All rights reserved.
//

#import "BCMessage.h"
#import "SBJson.h"

@implementation BCMessage

+ (BCMessage *)message
{
    BCMessage* msg = [[[BCMessage alloc] init] autorelease];
    return msg;
}

+ (BCMessage *)messageFromString:(NSString *)stringValue
{
    BCMessage* msg = [[[BCMessage alloc] init] autorelease];
    msg.rawData = stringValue;
    return msg;
}

+ (BCMessage *)messageFromDictionary:(NSDictionary *)dict
{
    BCMessage* msg = [[[BCMessage alloc] init] autorelease];
    msg.rawData = dict;
    return msg;
}

+ (BCMessage *)messageFromArray:(NSArray *)arr
{
    BCMessage* msg = [[[BCMessage alloc] init] autorelease];
    msg.rawData = arr;
    return msg;
}

+ (BCMessage *)messageFromJson:(NSString *)json
{
    BCMessage* msg = [[[BCMessage alloc] init] autorelease];
    
    NSError* err = nil;
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    id o = [parser objectWithString:json error:&err];
    [parser release];
    
    if (!err) {
        msg.rawData = o;
    }
    
    return msg;
}

@synthesize type = _type;
@synthesize timestamp = _timestamp;

- (id)init
{
    self = [super init];
    if (self) {
        self.type = BCMessageVariant_Unknown;
        self.timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.type = BCMessageVariant_Dictionary;
        self.rawData = data;
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (id)rawData
{
    return _data;
}

- (void)setRawData:(id)rawData
{
    if (_data) {
        [_data release];
    }
    
    if (rawData) {
        
        // HACK: try to eval as json if it's a string
        if ([rawData isKindOfClass:[NSString class]]) {
            id parsedData = [rawData JSONValue];
            if ([parsedData isKindOfClass:[NSDictionary class]]) {
                rawData = parsedData;
            }
        }
        
        _data = [rawData retain];
        
        if ([rawData isKindOfClass:[NSString class]]) {
            _type = BCMessageVariant_String;
        } else if ([rawData isKindOfClass:[NSDictionary class]]) {
            _type = BCMessageVariant_Dictionary;
        } else if ([rawData isKindOfClass:[NSArray class]]) {
            _type = BCMessageVariant_Array;
        } else {
            _type = BCMessageVariant_Unknown;
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type: %d data: %@ }", _type, _data];
}

- (id)proxyForJson
{
    if (BCMessageVariant_Unknown == _type) {
        return nil;
    } else if (BCMessageVariant_String == _type) {
        return [NSDictionary dictionaryWithObject:_data forKey:@"string"];
    } else {
        return _data;
    }
}

- (NSString *)toJson
{
    return [self JSONRepresentation];
}

@end
