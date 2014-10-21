//
//  RispLLVMProjectDescriptor.h
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispLLVMTargetDescriptor;
@interface RispLLVMProjectDescriptor : NSObject
@property (nonatomic, copy, readonly) NSString *projectName;
@property (nonatomic, strong, readonly) NSArray *targets; // RispLLVMTargetDescriptor inside
- (instancetype)initWithContentsOfProjectDescriptor:(NSString *)path;
- (instancetype)initWithProjectDescriptorContent:(NSDictionary *)content;

@end
