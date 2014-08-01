//
//  RispIRCodeGenerator.h
//  Risp
//
//  Created by closure on 5/8/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RispIRCodeGenerator <NSObject>
- (void *)generateCode:(id)context; // RispCodeGeneratorContext
@end
