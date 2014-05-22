//
//  RispReaderEvalCore.m
//  Risp
//
//  Created by closure on 4/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispReaderEvalCore.h"
#import <Risp/Risp.h>
#import "RispRenderWindowController.h"

@implementation RispReaderEvalCore
+ (NSArray *)evalCurrentLine:(NSString *)sender {
    [RispContext setCurrentContext:[RispContext defaultContext]];
    RispReader *_reader = [[RispReader alloc] initWithContent:sender];
    id value = nil;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    while (![_reader isEnd]) {
        @autoreleasepool {
            @try {
                value = [_reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[_reader reader] skip];
                if (value == _reader) {
                    continue;
                }
                RispContext *context = [RispContext currentContext];
                id expr = [RispCompiler compile:context form:value];
                id v = [expr eval];
                NSLog(@"%@ - %@ - %@", value, [expr class], v);
                [values addObject:v ? : [NSNull null]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@ - %@", value, exception);
            }
        }
    }
    return values;
}

#pragma mark -
#pragma mark Render Value

//+ (void)renderWindowController:(RispRenderWindowController *)window resultValue:(id)v insertNewLine:(BOOL)insertNewLine {
//    if ([v isKindOfClass:[NSImage class]]) {
//        [self renderWindowController:window renderImage:v insertNewLine:insertNewLine];
//    } else if ([v isKindOfClass:[NSFileWrapper class]]) {
//        [self renderWindowController:window renderFileWrapper:v insertNewLine:insertNewLine];
//    }
//}
//
//+ (void)renderWindowController:(RispRenderWindowController *)window  renderImage:(NSImage *)image insertNewLine:(BOOL)insertNewLine {
//    if (![image isValid]) return;
//    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:image];
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//    [attachment setAttachmentCell:attachmentCell];
//    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
//    [[[window inputTextView] textStorage] appendAttributedString:attributedString];
//    if (insertNewLine)
//        [[window inputTextView] insertNewline:nil];
//    [[window inputTextView] didChangeText];
//}
//
//+ (void)renderWindowController:(RispRenderWindowController *)window renderFileWrapper:(NSFileWrapper *)fileWrapper insertNewLine:(BOOL)insertNewLine {
//    if (![fileWrapper isRegularFile]) return;
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
//    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
//    [[[window inputTextView] textStorage] appendAttributedString:attributedString];
//    if (insertNewLine)
//        [[window inputTextView] insertNewline:nil];
//    [[window inputTextView] didChangeText];
//}

#pragma mark -
#pragma mark 
+ (NSUInteger)lineNumberOfTextView:(NSTextView *)textView {
    NSUInteger numberOfLines = 0;
    NSUInteger index = 0;
    while (index < [[textView string] length])
    {
        index = NSMaxRange([[textView string] lineRangeForRange:NSMakeRange(index, 0)]);
        NSLog(@"line -> %ld", index);
        ++numberOfLines;
    }
    return numberOfLines;
}

+ (NSArray *)textView:(NSTextView *)textView processLinesWithHandler:(id (^)(NSTextView *text, NSRange range))handler {
    NSUInteger numberOfLines = 0;
    NSUInteger index = 0;
    NSUInteger start = 0;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while (index < [[textView string] length])
    {
        index = NSMaxRange([[textView string] lineRangeForRange:NSMakeRange(index, 0)]);
        [results addObject:handler(textView, NSMakeRange(start, index))];
        start = index;
        ++numberOfLines;
    }
    return results;
}

+ (NSRange)rangeOfCurrentLine:(NSTextView *)textView {
    NSUInteger numberOfLines = 0;
    NSUInteger index = 0;
    while (index < [[textView string] length])
    {
        index = NSMaxRange([[textView string] lineRangeForRange:NSMakeRange(index, 0)]);
        NSLog(@"line -> %ld", index);
        ++numberOfLines;
    }
    NSLog(@"number of lines -> %ld", numberOfLines);
    NSLog(@"layout manager lines -> %ld", [[textView layoutManager] numberOfGlyphs]);
    NSRange sel = [textView selectedRange];
    NSString *viewContent = [textView string];
    NSRange lineRange = [viewContent lineRangeForRange:NSMakeRange(sel.location,0)];
    NSLog(@"%@", [viewContent substringWithRange:lineRange]);
    return lineRange;
    
    NSTextStorage *textStorage = [textView textStorage];
    NSString *string = [textStorage string];
    
    NSInteger editEnd = [textView selectedRange].location;
    NSInteger editStart = editEnd-[textStorage editedRange].length;
    NSInteger maxLength = [string length];
    
    
    while (editStart > 0) {
        unichar theChr = [string characterAtIndex:editStart-1];
        if( theChr == '\n' || theChr == '\r' ) {
            break;
        }
        --editStart;
    }
    while (editEnd < maxLength) {
        unichar theChr = [string characterAtIndex:editEnd];
        if( theChr == '\n' || theChr == '\r' ) {
            break;
        }
        ++editEnd;
    }
    
    NSRange paragraphRange = NSMakeRange(editStart, editEnd-editStart);
    NSLog(@"paragraphRange -> %@", NSStringFromRange(paragraphRange));
}

+ (void)removeAttachmentsFromTextView:(NSTextView *)textView {
    NSTextStorage *attrString = [textView textStorage];
    NSTextView *view = textView;
    NSUInteger loc = 0;
    NSUInteger end = [attrString length];
    [attrString beginEditing];
    while (loc < end) {	/* Run through the string in terms of attachment runs */
        NSRange attachmentRange;	/* Attachment attribute run */
        NSTextAttachment *attachment = [attrString attribute:NSAttachmentAttributeName atIndex:loc longestEffectiveRange:&attachmentRange inRange:NSMakeRange(loc, end-loc)];
        if (attachment) {	/* If there is an attachment and it is on an attachment character, remove the character */
            unichar ch = [[attrString string] characterAtIndex:loc];
            if (ch == NSAttachmentCharacter) {
                if ([view shouldChangeTextInRange:NSMakeRange(loc, 1) replacementString:@""]) {
                    [attrString replaceCharactersInRange:NSMakeRange(loc, 1) withString:@""];
                    [view didChangeText];
                }
                end = [attrString length];	/* New length */
            }
            else loc++;	/* Just skip over the current character... */
        }
    	else loc = NSMaxRange(attachmentRange);
    }
    [attrString endEditing];
}

@end
