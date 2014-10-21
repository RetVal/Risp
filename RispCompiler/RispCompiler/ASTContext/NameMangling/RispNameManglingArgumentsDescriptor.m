//
//  RispNameManglingArgumentsDescriptor.m
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispNameManglingArgumentsDescriptor.h"
#import <Risp/RispMethodExpression.h>

@implementation RispNameManglingArgumentsDescriptor

+ (NSString *)_manglingMethodSignatureWithParamsCount:(NSUInteger)count {
    return [NSString stringWithFormat:@"v%ld", count];
}

+ (NSString *)_manglingMethodSignature:(RispMethodExpression *)method {
    return [self _manglingMethodSignatureWithParamsCount:[method paramsCount]];
}

+ (RispNameManglingArgumentsDescriptor *)descriptorWithCountOfArguments:(NSUInteger)countOfArguments {
    RispNameManglingArgumentsDescriptor *descriptor = [[RispNameManglingArgumentsDescriptor alloc] init];
    descriptor->_countOfArguments = countOfArguments;
    return descriptor;
}

+ (RispNameManglingArgumentsDescriptor *)descriptorWithArguments:(RispVector *)arguments {
    return [RispNameManglingArgumentsDescriptor descriptorWithCountOfArguments:[arguments count]];
}

+ (RispNameManglingArgumentsDescriptor *)descriptorWithMethod:(RispMethodExpression *)method {
    return [RispNameManglingArgumentsDescriptor descriptorWithArguments:[[method requiredParms] arguments]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"v%ld", _countOfArguments];
}
@end
