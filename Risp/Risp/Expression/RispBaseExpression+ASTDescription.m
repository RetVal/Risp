//
//  RispBaseExpression+ASTDescription.m
//  Risp
//
//  Created by closure on 5/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseExpression+ASTDescription.h"
#import "RispAbstractSyntaxTree.h"

@implementation RispBaseExpression (ASTDescription)
- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
}
@end
