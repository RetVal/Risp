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
+ (NSString *)_closureIdentifier;
@end

@interface RispNameManglingFunctionDescriptor () {
    @private
    NSString *_functionName;
}

@end

@implementation RispNameManglingFunctionDescriptor
+ (RispNameManglingFunctionDescriptor *)descriptorWithFunctionName:(NSString *)functionName argumentsDescriptor:(RispNameManglingArgumentsDescriptor *)argumentsDescriptor isNameMangling:(BOOL)nameMangling {
    return [self descriptorWithFunctionName:functionName argumentsDescriptor:argumentsDescriptor isNameMangling:nameMangling isClosure:NO];
}

+ (RispNameManglingFunctionDescriptor *)descriptorWithFunctionName:(NSString *)functionName argumentsDescriptor:(RispNameManglingArgumentsDescriptor *)argumentsDescriptor isNameMangling:(BOOL)nameMangling isClosure:(BOOL)isClosure {
    RispNameManglingFunctionDescriptor *descriptor = [[RispNameManglingFunctionDescriptor alloc] init];
    descriptor->_functionName = [functionName copy];
    descriptor->_argumentsDescriptor = argumentsDescriptor;
    descriptor->_nameMangling = nameMangling;
    descriptor->_closure = isClosure;
    return descriptor;
}

+ (NSString *)_manglingFunctionName:(NSString *)name isClosure:(BOOL)isClosure {
    if (name == nil) {
        return @"";
    }
    NSString *prefixString = [NSString stringWithFormat:@"%@%ld", [RispNameMangling _prefixString], [name length]];
    
    NSMutableString *mangling = [[NSMutableString alloc] initWithString:prefixString];
    [mangling appendString:name];
    [mangling replaceOccurrencesOfString:@"-" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [mangling length])];
    [mangling appendString:[RispNameMangling _postString]];
    if (isClosure) {
        [mangling appendString:[RispNameMangling _closureIdentifier]];
        [mangling appendString:[RispNameMangling _postString]];
    }
    return mangling;
}

- (NSString *)functionName {
    if (_nameMangling) {
        return _functionName;
    }
    return [NSString stringWithFormat:@"%@%@", [RispNameManglingFunctionDescriptor _manglingFunctionName:_functionName isClosure:_closure], _argumentsDescriptor];
}

- (NSString *)description {
    return [self functionName];
}
@end
