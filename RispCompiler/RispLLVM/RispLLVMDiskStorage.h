//
//  RispLLVMDiskStorage.h
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispLLVMDirectoryBuilder;
@interface RispLLVMDiskStorage : NSObject
@property (nonatomic, strong, readonly) RispLLVMDirectoryBuilder *directoryBuilder;
- (instancetype)initWithDirectoryBuilder:(RispLLVMDirectoryBuilder *)directoryBuilder;
- (NSArray *)objectFiles;
- (NSArray *)asmFiles;
- (NSArray *)llvmIRFiles;
@end
