//
//  RispLLVMCompiler.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RispCompiler/RispASTContextDoneOptions.h>

@interface RispLLVMCompiler : NSObject
+ (NSArray *)compileFiles:(NSArray *)inputFiles outputDirectory:(NSString *)outputDirectory options:(RispASTContextDoneOptions)options;
@end
