//
//  RispNameManglingFunctionDescriptor.m
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispNameManglingFunctionDescriptor.h"
#import "RispNameManglingArgumentsDescriptor.h"
#import "RispNameMangling.h"

@interface RispNameMangling (Private)
+ (NSString *)_prefixString;
+ (NSString *)_postString;
@end

@interface RispNameManglingFunctionDescriptor () {
    @private
    NSString *_functionName;
}

@end

@implementation RispNameManglingFunctionDescriptor
+ (RispNameManglingFunctionDescriptor *)descriptorWithFunctionName:(NSString *)functionName argumentsDescriptor:(RispNameManglingArgumentsDescriptor *)argumentsDescriptor isNameMangling:(BOOL)nameMangling {
    RispNameManglingFunctionDescriptor *descriptor = [[RispNameManglingFunctionDescriptor alloc] init];
    descriptor->_functionName = [functionName copy];
    descriptor->_argumentsDescriptor = argumentsDescriptor;
    descriptor->_nameMangling = nameMangling;
    return descriptor;
}

+ (NSString *)_manglingFunctionName:(NSString *)name {
    if (name == nil) {
        return @"";
    }
    NSString *prefixString = [NSString stringWithFormat:@"%@%ld", [RispNameMangling _prefixString], [name length]];
    
    NSMutableString *mangling = [[NSMutableString alloc] initWithString:prefixString];
    [mangling appendString:name];
    [mangling replaceOccurrencesOfString:@"-" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [mangling length])];
    [mangling appendString:[RispNameMangling _postString]];
    return mangling;
}

- (NSString *)functionName {
    if (_nameMangling) {
        return _functionName;
    }
    return [NSString stringWithFormat:@"%@%@", [RispNameManglingFunctionDescriptor _manglingFunctionName:_functionName], _argumentsDescriptor];
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"%@%lu%@%@%@", [RispNameMangling _prefixString], [_functionName length], _functionName, [RispNameMangling _postString], [_argumentsDescriptor description]];
}
@end
