//
//  RispCharSequence.m
//  Risp
//
//  Created by closure on 5/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispCharSequence.h"

@interface RispCharSequence ()
@property (nonatomic, strong, readonly) NSString *content;
@end

@implementation RispCharSequence
- (id)initWithString:(NSString *)str {
    if (self = [super init]) {
        _content = str;
    }
    return self;
}

- (NSUInteger)count {
    return [_content length];
}

- (id)first {
    return @([_content characterAtIndex:0]);
}

- (id)next {
    return [[RispCharSequence alloc] initWithString:[_content substringWithRange:NSMakeRange(1, [_content length] - 1)]];
}

- (id)rest {
    return [self next] ? : [RispCharSequence empty];
}

+ (id)empty {
    return [[RispCharSequence alloc] init];
}

- (NSString *)description {
    return _content;
}
@end
