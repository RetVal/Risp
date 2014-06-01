//
//  RispPushBackReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispBaseReader.h"

@interface RispPushBackReader : RispBaseReader {
@private
    UniChar *_buf;
    NSInteger _length;
}
@property (assign, nonatomic, readonly) NSInteger pos;
@property (assign, nonatomic, readonly) NSInteger length;

@property (assign, nonatomic, readonly) NSInteger columnNumber;
@property (assign, nonatomic, readonly) NSInteger lineNumber;

- (id)initWithContent:(NSString *)content fileNamed:(NSString *)file;
- (id)initWithContentsOfFile:(NSString *)file;
- (UniChar)read;
- (UniChar)read1;

- (UniChar)read:(NSMutableString *)buffer offset:(NSInteger)offset count:(NSInteger)count;
- (BOOL)ready;
- (void)unreadFromBuffer:(NSMutableString *)buffer;
- (void)unread:(NSMutableString *)buffer offset:(NSInteger)offset length:(NSInteger)length;
- (void)unread:(NSInteger)oneChar;
- (NSInteger)skip;
@end

