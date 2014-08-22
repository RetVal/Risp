//
//  RispBaseExpression+ASTDescription.h
//  Risp
//
//  Created by closure on 5/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#include <Risp/RispBaseExpression.h>

@interface RispBaseExpression (ASTDescription)
- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc;
@end
