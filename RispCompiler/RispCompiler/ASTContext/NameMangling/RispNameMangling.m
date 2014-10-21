//
//  RispNameMangling.m
//  RispCompiler
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispNameMangling.h"
#import "RispASTContext.h"
#import "RispNameManglingFunctionDescriptor.h"
#import "RispNameManglingArgumentsDescriptor.h"

@interface RispNameMangling (Private)
+ (NSString *)_prefixString;
+ (NSString *)_postString;
+ (NSString *)_closureIdentifier;
@end

@implementation RispNameMangling
+ (NSString *)_prefixString {
    static NSString *prefixString = @"_";
    return prefixString;
}

+ (NSString *)_postString {
    static NSString *postString = @"_";
    return postString;
}

+ (NSString *)_closureIdentifier {
    return @"csxp";
}

+ (instancetype)nameMangling {
    static RispNameMangling *__RispNameMangling = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __RispNameMangling = [[RispNameMangling alloc] init];
    });
    return __RispNameMangling;
}

- (RispNameManglingFunctionDescriptor *)functionManglingWithName:(NSString *)name arguments:(RispVector *)args {
    RispNameManglingFunctionDescriptor *descriptor = [RispNameManglingFunctionDescriptor descriptorWithFunctionName:name argumentsDescriptor:[RispNameManglingArgumentsDescriptor descriptorWithArguments:args] isNameMangling:NO];
    return descriptor;
}

- (RispNameManglingFunctionDescriptor *)closureManglingWithName:(NSString *)name arguments:(RispVector *)args {
    RispNameManglingFunctionDescriptor *descriptor = [RispNameManglingFunctionDescriptor descriptorWithFunctionName:name argumentsDescriptor:[RispNameManglingArgumentsDescriptor descriptorWithArguments:args] isNameMangling:NO isClosure:YES];
    return descriptor;
}

- (RispNameManglingFunctionDescriptor *)methodMangling:(RispMethodExpression *)method functionName:(NSString *)functionName {
    RispNameManglingFunctionDescriptor *descriptor = [RispNameManglingFunctionDescriptor descriptorWithFunctionName:functionName argumentsDescriptor:[RispNameManglingArgumentsDescriptor descriptorWithMethod:method] isNameMangling:NO isClosure:[[method captures] count] != 0];
    return descriptor;
}

- (NSArray *)functionMangling:(RispFnExpression *)fnExpression {
    NSMutableArray *names = [[NSMutableArray alloc] init];
    @autoreleasepool {
        NSString *functionName = [[fnExpression name] stringValue];
        for (RispMethodExpression *method in [fnExpression methods]) {
            RispNameManglingFunctionDescriptor *descriptor = [self methodMangling:method functionName:functionName];
            [names addObject:descriptor];
        }
    }
    return names;
}


- (BOOL)_checkManglingFunction:(NSString *)name context:(RispASTContext *)context isNameMangling:(BOOL)isDemangling output:(__autoreleasing RispNameManglingFunctionDescriptor **)descriptor {
    if (![name hasPrefix:[RispNameMangling _prefixString]]) {
        return NO;
    }
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:32];
    const char *basePtr = [name UTF8String];
    NSUInteger namelenOffset = 0;
    NSUInteger length = [name length];
    
    char *ptr = (char *)basePtr;
    ptr += [[RispNameMangling _prefixString] length];
    char *namePtr = ptr;
    for (; *ptr != 0 && isnumber(*ptr) && namelenOffset <= length; ptr++) {
        namelenOffset ++;
    }
    
    if (namelenOffset == 0) {
        return NO;
    }
    
    char c = (ptr -= namelenOffset)[namelenOffset];
    ptr[namelenOffset] = 0;
    NSUInteger funcPartNameLength = atoi(ptr);
    ptr[namelenOffset] = c;
    namePtr += namelenOffset;
    for (NSUInteger idx = 0; idx < funcPartNameLength; idx++) {
        [str appendFormat:@"%c", namePtr[idx]];
    }
    
    namePtr += funcPartNameLength;
    NSString *post = [RispNameMangling _postString];
    if (0 != strncmp(namePtr, [post UTF8String], [post length])) {
        return NO;
    }
    namePtr += [post length];
    
    BOOL isClosure = NO;
    NSUInteger ptrOffset = namePtr - basePtr;
    if (ptrOffset < length) {
        // check if closure
        NSString *closureIdentifier = [RispNameMangling _closureIdentifier];
        NSUInteger closureLength = [closureIdentifier length];
        if ((ptrOffset + closureLength) <= length) {
            NSString *givenIdentifier = nil;
            c = namePtr[ptrOffset + closureLength];
            namePtr[ptrOffset + closureLength] = 0;
            givenIdentifier = [NSString stringWithUTF8String:namePtr];
            namePtr[ptrOffset + closureLength] = c;
            if ([givenIdentifier isEqualToString:closureIdentifier]) {
                isClosure = YES;
                
                namePtr += closureLength;
                if (0 != strncmp(namePtr, [post UTF8String], [post length])) {
                    return NO;
                }
                namePtr += [post length];
                
            }
        }
    }
    
    
    if (namePtr[0] != 'v') {
        return NO;
    }
    
    namePtr++;
    namelenOffset = 0;
    for (; *namePtr != 0 && isnumber(*ptr); namePtr++) {
        namelenOffset++;
    }
    
    c = (namePtr -= namelenOffset)[namelenOffset];
    namePtr[namelenOffset] = 0;
    NSUInteger argumentsCount = atoi(namePtr);
    namePtr[namelenOffset] = c;
    
    if (descriptor) {
        *descriptor = [RispNameManglingFunctionDescriptor descriptorWithFunctionName:str argumentsDescriptor:[RispNameManglingArgumentsDescriptor descriptorWithCountOfArguments:argumentsCount] isNameMangling:isDemangling isClosure:isClosure];
    }
    
    return YES;
}

- (BOOL)isManglingFunction:(NSString *)name context:(RispASTContext *)context {
    BOOL result = [self _checkManglingFunction:name context:context isNameMangling:NO output:nil];
    return result;
}

- (RispNameManglingFunctionDescriptor *)demanglingFunctionName:(NSString *)name context:(RispASTContext *)context {
    RispNameManglingFunctionDescriptor *descriptor = nil;
    BOOL isMangling = [self _checkManglingFunction:name context:context isNameMangling:YES output:&descriptor];
    if (!isMangling) {
        return descriptor;
    }
    return descriptor;
}

+ (NSString *)anonymousFunctionName:(NSUInteger)count {
    return [NSString stringWithFormat:@"RispAnonymousFunction%ld", count];
}
@end
