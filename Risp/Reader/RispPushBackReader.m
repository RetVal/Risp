//
//  RispPushBackReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispPushBackReader.h>

@implementation RispPushBackReader
- (id)initWithContent:(NSString *)content {
    if (self = [super initWithContent:content]) {
        NSUInteger length = [[self content] lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
        _buf = calloc(length, 1);
        NSUInteger usedLength = 0;
        [[self content] getBytes:_buf maxLength:length usedLength:&usedLength encoding:NSUnicodeStringEncoding options:0 range:NSMakeRange(0, [[self content] length]) remainingRange:nil];
        _length = [[self content] length];
        _pos = 0;
    }
    return self;
}

- (void)dealloc {
    free(_buf);
    _buf = nil;
    _length = 0;
    _pos = 0;
}

- (UniChar)read {
    if (_pos < _length) {
        return _buf[_pos++];
    }
    return 0;
}

- (UniChar)read1 {
    return [self read];
}

- (UniChar)read:(NSMutableString *)buffer offset:(NSInteger)offset count:(NSInteger)count {
    if (offset < 0 || count < 0)
        [NSException raise:@"" format:@""];
    NSInteger copiedChars = 0;
    NSInteger copyLength = 0;
    NSInteger newOffset __unused = offset;
    if (_pos < _length) {
        copyLength = ([buffer length] - _pos >= count) ? count : [buffer length] - _pos;
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:copyLength];
        [data appendBytes:_buf + _pos length:copyLength];
        [buffer appendString:[[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding]];
        newOffset += copyLength;
        copiedChars += copyLength;
        _pos += copyLength;
    }
    if (copyLength == count) {
        return count;
    }
    return copiedChars;
}

- (BOOL)ready {
    return _pos < _length;
}

- (void)unreadFromBuffer:(NSMutableString *)buffer {
    [self unread:buffer offset:0 length:[buffer length]];
}

- (void)unread:(NSMutableString *)buffer offset:(NSInteger)offset length:(NSInteger)length {
    if (length > _pos) {
        [NSException raise:@"" format:@"Pushback buffer full"];
    }
    
    if (offset > [buffer length] - length || offset < 0) {
        [NSException raise:@"" format:@"Offset out of bounds: %ld", offset];
    }
    if (length < 0) {
        [NSException raise:@"" format:@"Length out of bounds: %ld", length];
    }
    
    for (NSInteger i = offset + length - 1; i >= offset; i--) {
        [self unread:[buffer characterAtIndex:i]];
    }
}

- (void)unread:(NSInteger)oneChar {
    if (_buf == nil) {
        [NSException raise:@"" format:@"Stream is closed"];
    }
    if (_pos == 0) {
        [NSException raise:@"" format:@"Pushback buffer full"];
    }
    _buf[--_pos] = oneChar;
}

- (NSInteger)skip {
    NSUInteger idx = 0;
    while (_pos < _length) {
        UniChar c = [self read];
        if (c == 0 || isblank(c) || c == ',' || c == '\n' || c == '\r') {
            idx++;
            continue;
        } else {
            [self unread:c];
            break;
        }
    }
    return idx;
}
@end
