//
//  RispNameManglingArgumentsDescriptor.h
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispMethodExpression, RispVector;
@interface RispNameManglingArgumentsDescriptor : NSObject
@property (nonatomic, assign, readonly) NSUInteger countOfArguments;
+ (RispNameManglingArgumentsDescriptor *)descriptorWithMethod:(RispMethodExpression *)method;
+ (RispNameManglingArgumentsDescriptor *)descriptorWithArguments:(RispVector *)arguments;
+ (RispNameManglingArgumentsDescriptor *)descriptorWithCountOfArguments:(NSUInteger)countOfArguments;
@end
