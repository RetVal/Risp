//
//  RispLiteralExpression.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispBaseExpression.h>

@interface RispLiteralExpression : RispBaseExpression {
    @package
    id _value;
}

- (id)initWithValue:(id)value;
- (id)value;
- (id)literalValue;
- (id)eval;
@end
