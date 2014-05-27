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
+ (void)renderWindowController:(RispREPLAlphaWindowController *)window resultValue:(id)v insertNewLine:(BOOL)insertNewLine;

+ (NSUInteger)lineNumberOfTextView:(NSTextView *)textView;
+ (NSArray *)textView:(NSTextView *)textView processLinesWithHandler:(id (^)(NSTextView *text, NSRange range))handler;
+ (NSRange)rangeOfCurrentLine:(NSTextView *)textView;

+ (void)removeAttachmentsFromTextView:(NSTextView *)textView;
@end
