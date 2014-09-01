//
//  RispBuiltin.m
//  RispCompiler
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBuiltin.h"
#include <objc/runtime.h>

@implementation RispBuiltin
+ (id)show:(id)content {
    NSLog(@"%@ - %@ -> %@", self, NSStringFromSelector(_cmd), [content description]);
    return [NSNull null];
}

+ (void *)test {
    Class cls = self;
    IMP imp = method_getImplementation(class_getClassMethod(cls, @selector(show:)));
    return imp;
}

+ (id)test2 {
    NSString *str = @"hahahah";
    ((id(*)(Class, SEL, id x))[self test])(self, @selector(show:), str);
    return @"";
}
@end
