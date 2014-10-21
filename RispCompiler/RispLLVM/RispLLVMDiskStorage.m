//
//  RispLLVMDiskStorage.m
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLLVMDiskStorage.h"
#import "RispLLVMDirectoryBuilder.h"

@interface RispLLVMDiskStorage ()

@end

@implementation RispLLVMDiskStorage
- (instancetype)initWithDirectoryBuilder:(RispLLVMDirectoryBuilder *)directoryBuilder {
    if (self = [super init]) {
        _directoryBuilder = directoryBuilder;
    }
    return self;
}

- (NSArray *)objectFiles {
    return @[];
}
@end
