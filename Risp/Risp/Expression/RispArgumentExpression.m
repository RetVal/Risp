//
//  RispArgumentExpression.m
//  Risp
//
//  Created by closure on 9/4/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispArgumentExpression.h"
#import "RispBaseExpression+ASTDescription.h"

@implementation RispArgumentExpression
+ (RispBaseExpression *)parser:(id)object context:(RispContext *)context {
    return nil;
}

- (instancetype)initWithArguments:(RispVector *)arguments {
    if (self = [super init]) {
        _arguments = arguments;
    }
    return self;
}

- (NSString *)description {
    return [_arguments description];
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [super _descriptionWithIndentation:indentation desc:desc];
    [desc appendFormat:@"%@\n", [self class]];
    [_arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [desc appendString:[RispAbstractSyntaxTree descriptionAppendIndentation:indentation + 1 forObject:obj]];
    }];
}
@end
