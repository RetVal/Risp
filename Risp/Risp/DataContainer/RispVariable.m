//
//  RispVariable.m
//  Risp
//
//  Created by closure on 4/19/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispVariable.h>
#import <Risp/RispSequence.h>

@interface RispTBox : NSObject
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) id val;
@end

@interface RispUnbound : NSObject
@property (nonatomic, strong) RispVariable *var;
+ (instancetype)unbound:(RispVariable *)var;
@end

@implementation RispUnbound

+ (instancetype)unbound:(RispVariable *)var {
    RispUnbound *unbound = [[RispUnbound alloc] init];
    [unbound setVar:var];
    return unbound;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Unbound: %@", _var];
}

@end

@implementation RispVariable
- (id)applyTo:(id <RispSequence>)seq {
//    RT.cons(form,RT.cons(LOCAL_ENV.get(),form.next()))
    return nil;
}
@end
