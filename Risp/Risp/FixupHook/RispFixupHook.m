//
//  RispFixupHook.m
//  Risp
//
//  Created by closure on 5/12/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispFixupHook.h"
#include <objc/runtime.h>

@implementation RispFixupHook
+ (void)hookFromClass:(id)targetClass selector:(SEL)targetSelector withClass:(id)class withSelector:(SEL)selector {
    Method methodOfCFBoolean = class_getInstanceMethod(targetClass, targetSelector);
    Method methodOfImp = class_getInstanceMethod(class, selector);
    method_exchangeImplementations(methodOfCFBoolean, methodOfImp);
}
@end
