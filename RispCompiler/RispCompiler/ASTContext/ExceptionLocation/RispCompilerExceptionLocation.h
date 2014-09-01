//
//  RispCompilerExceptionLocation.h
//  RispCompiler
//
//  Created by closure on 8/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispBaseExpression.h>

@interface RispCompilerExceptionLocation : NSObject
@property (nonatomic, strong, readonly) RispBaseExpression *expression;
@property (nonatomic, strong, readonly) NSException *exception;
+ (void)exceptionLocationWithExpression:(RispBaseExpression *)expression exception:(NSException *)exception;
- (instancetype)initWithExpression:(RispBaseExpression *)expression exception:(NSException *)exception;
@end

FOUNDATION_EXPORT NSString * RispCompilerReturnTypeException;
