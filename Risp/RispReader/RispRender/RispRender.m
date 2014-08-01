//
//  RispRender.m
//  Risp
//
//  Created by closure on 5/29/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispRender.h"

@implementation NSObject (Render)

+ (NSAttributedString *)renderObject:(id)object {
    if ([object respondsToSelector:@selector(enumerateObjectsUsingBlock:)]) {
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] init];
        NSInteger cnt = [object count];
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mas appendAttributedString:[obj render]];
            if (idx + 1 < cnt)
                [mas appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }];
        return mas;
    }
    return [object render];
}

- (NSAttributedString *)render {
    return [[NSAttributedString alloc] initWithString:[self description]];
}

@end

@implementation RispSequence (Render)
- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:@"("];
    [mas appendAttributedString:[NSObject renderObject:self]];
    [mas appendAttributedString:[[NSAttributedString alloc] initWithString:@")"]];
    return mas;
}
@end

@implementation RispList (Render)

- (NSAttributedString *)render {
    return [super render];
}

@end

@implementation RispVector (Render)

- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:@"["];
    [mas appendAttributedString:[NSObject renderObject:self]];
    [mas appendAttributedString:[[NSAttributedString alloc] initWithString:@"]"]];
    return mas;
}

@end

@implementation RispKeyword (Render)

- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:[self stringValue]];
    return mas;
}

@end

@implementation RispMap (Render)

- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:@"{"];
    [mas appendAttributedString:[NSObject renderObject:self]];
    [mas appendAttributedString:[[NSAttributedString alloc] initWithString:@"}"]];
    return mas;
}

@end

@implementation RispLazySequence (Render)

- (NSAttributedString *)render {
    return nil;
}

@end

@implementation NSDecimalNumber (Render)

- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:[self description]];
    return mas;
}

@end

@implementation NSString (Render)

- (NSAttributedString *)render {
    return [[NSAttributedString alloc] initWithString:self];
}

@end

@implementation NSImage (Render)

- (NSAttributedString *)render {
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:self];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:attachmentCell];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    return attributedString;
}

@end

@implementation NSFileWrapper (Render)

- (NSAttributedString *)render {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:self];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    return attributedString;
}

@end

@implementation NSArray (Render)

- (NSAttributedString *)render {
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] init];
    [mas appendAttributedString:[NSObject renderObject:self]];
    return mas;
}

@end


