//
//  RispNameManglingFunctionDescriptor.h
//  RispCompiler
//
//  Created by closure on 8/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispNameManglingArgumentsDescriptor;

@interface RispNameManglingFunctionDescriptor : NSObject
@property (nonatomic, copy,   readonly) NSString * functionName;
@property (nonatomic, assign, readonly, getter=isNameMangling) BOOL nameMangling;
@property (nonatomic, strong, readonly) RispNameManglingArgumentsDescriptor *argumentsDescriptor;
@property (nonatomic, assign, getter = isClosure) BOOL closure;
+ (RispNameManglingFunctionDescriptor *)descriptorWithFunctionName:(NSString *)functionName argumentsDescriptor:(RispNameManglingArgumentsDescriptor *)argumentsDescriptor isNameMangling:(BOOL)nameMangling;
+ (RispNameManglingFunctionDescriptor *)descriptorWithFunctionName:(NSString *)functionName argumentsDescriptor:(RispNameManglingArgumentsDescriptor *)argumentsDescriptor isNameMangling:(BOOL)nameMangling isClosure:(BOOL)isClosure;
@end
