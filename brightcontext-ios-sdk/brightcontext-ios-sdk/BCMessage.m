//-----------------------------------------------------------------
// Copyright 2012 BrightContext Corporation
//
// Licensed under the MIT License defined in the 
// LICENSE file. You may not use this file except in 
// compliance with the License.
//----------------------------------------------------------------- 

#import "SBJson.h"

#import "BCConstants.h"
#import "BCSerializable.h"
#import "BCMessage.h"

@interface BCMessage(Private)

- (void) initRawDataAsDictionary;

@end

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
    return [NSString stringWithFormat:@"{ timestamp: %f data: %@ }", _timestamp, _data];
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
    if (BCMessageVariant_Unknown == _type) {
        return nil;
    } else {
        return [self JSONRepresentation];
    }
}

#pragma mark - Easy Dictionary Values

- (void)initRawDataAsDictionary
{
    if (!_data) {
        [self setRawData:[NSMutableDictionary dictionary]];
    } else if (BCMessageVariant_Dictionary != _type) {
        [NSException raise:@"Mixed Message Type"
                    format:@"Cannot set key values when message type is not BCMessageVariant_Dictionary"];
    }
}

- (void)setString:(NSString *)v forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:v forKey:k];
}

- (NSString*) stringForKey:(NSString*)k
{
    id v = [_data objectForKey:k];
    
    if (v) {
        if ([v isKindOfClass:[NSString class]]) {
            return v;
        } else {
            return [NSString stringWithFormat:@"%@", [v description]];
        }
    } else {
        return nil;
    }
}

- (void)setNumber:(NSNumber *)v forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:v forKey:k];
}

- (NSNumber*) numberForKey:(NSString*)k
{
    id v = [_data objectForKey:k];
    
    if ([v isKindOfClass:[NSNumber class]]) {
        return v;
    } else if ([v isKindOfClass:[NSString class]]) {
        NSNumber* n = [NSNumber numberWithDouble:[v doubleValue]];
        return n;
    } else {
        return nil;
    }
}

- (void)setDecimal:(NSDecimalNumber *)d forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:d forKey:k];
}

- (NSDecimalNumber *)decimalForKey:(NSString *)k
{
    id v = [_data objectForKey:k];
    
    if ([v isKindOfClass:[NSDecimalNumber class]]) {
        return v;
    } else if ([v isKindOfClass:[NSString class]]) {
        NSDecimalNumber* n = [NSDecimalNumber decimalNumberWithString:v];
        return n;
    } else {
        return nil;
    }
}

- (void)setDate:(NSDate *)v forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:BC_MAKETIMESTAMP(v) forKey:k];
}

- (NSDate*) dateForKey:(NSString*)k
{
    double unixtimestamp = 0;
    
    id v = [_data objectForKey:k];
    if (
        ([v isKindOfClass:[NSNumber class]])
        ||
        ([v isKindOfClass:[NSString class]])
    ) {
        unixtimestamp = [v doubleValue];
    }
    
    if (unixtimestamp) {
        NSTimeInterval t = unixtimestamp / 1000.0;
        NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];
        return d;
    } else {
        return nil;
    }
}

- (void)setArray:(NSArray *)a forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:a forKey:k];
}

- (NSArray *)arrayForKey:(NSString *)k
{
    id v = [_data objectForKey:k];
    
    if ([v isKindOfClass:[NSArray class]]) {
        return v;
    } else {
        return nil;
    }
}

- (void)setDictionary:(NSDictionary *)m forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:m forKey:k];
}

- (NSDictionary *)dictionaryForKey:(NSString *)k
{
    id v = [_data objectForKey:k];
    
    if ([v isKindOfClass:[NSDictionary class]]) {
        return v;
    } else {
        return nil;
    }
}

- (void)setInt:(int)i forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:[NSNumber numberWithInt:i] forKey:k];
}

- (int)intForKey:(NSString *)k
{
    return [[self numberForKey:k] integerValue];
}

- (void)setFloat:(float)f forKey:(NSString *)k
{
    NSDecimalNumber* dec = [[[NSDecimalNumber alloc] initWithFloat:f] autorelease];
    [self setDecimal:dec forKey:k];
}

- (float)floatForKey:(NSString *)k
{
    return [[self decimalForKey:k] floatValue];
}

- (void)setBool:(BOOL)b forKey:(NSString *)k
{
    [self initRawDataAsDictionary];
    [_data setObject:[NSNumber numberWithBool:b] forKey:k];
}

- (BOOL)boolForKey:(NSString *)k
{
    id v = [_data objectForKey:k];
    
    if ([v isKindOfClass:[NSNumber class]]) {
        return [v boolValue];
    } else if ([v isKindOfClass:[NSString class]]) {
        bool b = ([v isEqualToString:@"true"]);
        return b;
    } else {
        return false;
    }
}

@end
