//
//  RispASTContextDoneOptions.h
//  RispCompiler
//
//  Created by closure on 9/3/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef RispCompiler_RispASTContextDoneOptions_h
#define RispCompiler_RispASTContextDoneOptions_h

typedef NS_ENUM(NSUInteger, RispASTContextDoneOptions) {
    RispASTContextDoneWithShowIRCode = 0x01,
    RispASTContextDoneWithShowASMCode = 0x02,
    RispASTContextDoneWithShowFunctionMeta = 0x04,
    RispASTContextDoneWithShowPerformance = 0x08,
    
    RispASTContextDoneWithOutputObjectFile = 0x100,
    RispASTContextDoneWithOutputIRCode = 0x200,
    RispASTContextDoneWithOutputASMCode = 0x400,
    RispASTContextDoneWithShowNothing = RispASTContextDoneWithOutputObjectFile,
};

#endif
