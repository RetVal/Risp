//
//  RispCompiler.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispContext.h>
#import <Risp/RispVariable.h>

typedef NS_ENUM(NSUInteger, RispCompilerStatus) {
    RispCompilerStatusREQ = 0,
    RispCompilerStatusREST = 1,
    RispCompilerStatusDONE = 2,
};

@interface RispCompiler : NSObject
+ (Class)targetIsClass:(id)target;
- (id)initWithObject:(id)object;

+ (id)compile:(RispContext *)context form:(id)form;
+ (id)macroexpand:(id)form;

+ (id)eval:(id)rispForm;
@end
