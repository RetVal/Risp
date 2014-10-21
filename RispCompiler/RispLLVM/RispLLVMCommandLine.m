//
//  RispLLVMCommandLine.m
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLLVMCommandLine.h"

@interface RispLLVMCommandLine ()
@property (nonatomic, strong, readonly) NSDictionary *info;
- (instancetype)initWithInfo:(NSDictionary *)info;
@end

@implementation RispLLVMCommandLine
+ (instancetype)parseArgc:(int)argc argv:(const char **)argv {
    if (argc == 0 || argv == nil) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    //skip process path
    for (int idx = 1; idx < argc; idx++) {
        char *currentArg = (char *)argv[idx];
        size_t length = strlen(currentArg);
        if (currentArg[0] == '-') {
            if (length > 1) {
                if (currentArg[1] == '-') {
                    currentArg += 1;
                    NSString *key = [NSString stringWithUTF8String:currentArg];
                    result[key] = @YES;
                    continue;
                } if (idx > (argc - 1)) {
                    continue;
                } else {
                    NSString *value = [NSString stringWithUTF8String:argv[idx + 1]];
                    currentArg ++;
                    NSString *key = [NSString stringWithUTF8String:currentArg];
                    result[key] = value;
                }
            }
        }
    }
    return [[RispLLVMCommandLine alloc] initWithInfo:result];
}

- (instancetype)initWithInfo:(NSDictionary *)info {
    if (self = [super init]) {
        _info = info;
    }
    return self;
}

- (NSString *)stringForKey:(NSString *)defaultName {
    return [_info objectForKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName {
    NSString *valeus = [_info objectForKey:defaultName];
    return [valeus componentsSeparatedByString:@" "];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
    NSString *values = [_info objectForKey:defaultName];
    return [NSPropertyListSerialization propertyListWithData:[values dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:nil error:nil];
}

- (NSData *)dataForKey:(NSString *)defaultName {
    return [[_info objectForKey:defaultName] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName {
    NSString *valeus = [_info objectForKey:defaultName];
    return [valeus componentsSeparatedByString:@" "];
}

- (NSInteger)integerForKey:(NSString *)defaultName {
    return [_info[defaultName] integerValue];
}

- (float)floatForKey:(NSString *)defaultName {
    return [_info[defaultName] floatValue];
}

- (double)doubleForKey:(NSString *)defaultName {
    return [_info[defaultName] doubleValue];
}

- (BOOL)boolForKey:(NSString *)defaultName {
    return [_info[defaultName] boolValue];
}

- (NSURL *)URLForKey:(NSString *)defaultName NS_AVAILABLE(10_6, 4_0) {
    return [NSURL URLWithString:_info[defaultName]];
}
@end
