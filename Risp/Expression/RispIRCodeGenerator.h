//
//  RispIRCodeGenerator.h
//  Risp
//
//  Created by closure on 5/8/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispCodeGeneratorContext.h>

@class RispCodeGeneratorContext;
@protocol RispIRCodeGenerator <NSObject>
- (LLVMValueRef)generateCode:(RispCodeGeneratorContext *)context;
@end
