//
//  RispReaderEvalCore.h
//  Risp
//
//  Created by closure on 4/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispREPLAlphaWindowController;
@interface RispReaderEvalCore : NSObject
+ (NSArray *)evalCurrentLine:(NSString *)sender;
+ (NSArray *)evalCurrentLine:(NSString *)sender expressions:(NSArray **)expressions;
+ (void)renderTextView:(NSTextView *)textView resultValue:(id)v insertNewLine:(BOOL)insertNewLine block:(void (^)(id v))defaultRender;

+ (void)renderTextFieldCell:(NSTextFieldCell *)cell resultValue:(id)v insertNewLine:(BOOL)insertNewLine block:(void (^)(id v))defaultRender;

+ (NSUInteger)lineNumberOfTextView:(NSTextView *)textView;
+ (NSArray *)textView:(NSTextView *)textView processLinesWithHandler:(id (^)(NSTextView *text, NSRange range))handler;
+ (NSRange)rangeOfCurrentLine:(NSTextView *)textView;

+ (void)removeAttachmentsFromTextView:(NSTextView *)textView;
@end
