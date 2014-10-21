//
//  RispLLVMProjectDescriptor.m
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLLVMProjectDescriptor.h"

@interface RispLLVMProjectDescriptorImpl : NSObject

@end

@interface RispLLVMProjectDescriptor ()
@property (nonatomic, strong) NSMutableDictionary *info;
@end

@implementation RispLLVMProjectDescriptor
- (instancetype)initWithContentsOfProjectDescriptor:(NSString *)path {
    return [[RispLLVMProjectDescriptor alloc] initWithProjectDescriptorContent:[NSDictionary dictionaryWithContentsOfFile:path]];
}

- (instancetype)initWithProjectDescriptorContent:(NSDictionary *)content {
    if (content == nil) {
        return nil;
    }
    if (self = [super init]) {
        
    }
    return self;
}
@end
