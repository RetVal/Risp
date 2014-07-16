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
#import "RispAbstractSyntaxTree.h"
#import "RispREPLAlphaWindowController.h"
#import "RispRender.h"

#import "ASUserNotification.h"

@implementation RispReaderEvalCore
+ (NSArray *)evalCurrentLine:(NSString *)sender {
    return [RispReaderEvalCore evalCurrentLine:sender expressions:nil];
}

+ (NSArray *)evalCurrentLine:(NSString *)sender expressions:(NSArray **)expressions {
    RispContext *context = [RispContext currentContext];
    RispReader *_reader = [[RispReader alloc] initWithContent:sender fileNamed:@"RispREPL"];
    id value = nil;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *exprs = nil;
    if (expressions) {
        exprs = [[NSMutableArray alloc] init];
        *expressions = exprs;
    }
    while (![_reader isEnd]) {
        @autoreleasepool {
            @try {
                value = [_reader readEofIsError:YES eofValue:nil isRecursive:YES];
                [[_reader reader] skip];
                if (value == _reader) {
                    continue;
                }
                id expr = [RispCompiler compile:context form:value];
                if (exprs || expr) {
                    [exprs addObject:expr];
                }
                id v = [expr eval];
//                id v = nil;
                [values addObject:v ? : [NSNull null]];
                
                if ([expr conformsToProtocol:@protocol(RispExpression)]) {
                    NSLog(@"%@ -\n%@\n-> %@", value, [[[RispAbstractSyntaxTree alloc] initWithExpression:expr] description], v);
                } else {
                    NSLog(@"%@ -\n%@\n-> %@", value, [RispAbstractSyntaxTree descriptionAppendIndentation:0 forObject:expr], v);
                }
            }
            @catch (NSException *exception) {
                ASUserNotification *notification = [[ASUserNotification alloc] init];
                [notification setTitle:[exception name]];
                [notification setSubtitle:[NSString stringWithFormat:@"%@", value]];
                [notification setInformativeText:[NSString stringWithFormat:@"%@", exception]];
                [notification setHasActionButton: NO];
                [[ASUserNotificationCenter customUserNotificationCenter] deliverNotification:notification];
                NSLog(@"%@ - %@\n%@", value, exception, [exception callStackSymbols]);
            }
        }
    }
    return values;
}

#pragma mark -
#pragma mark Render Value

+ (void)renderTextView:(NSTextView *)textView resultValue:(id)v insertNewLine:(BOOL)insertNewLine block:(void (^)(id v))defaultRender {
    if ([v isKindOfClass:[NSImage class]]) {
        [self renderTextView:textView renderImage:v insertNewLine:insertNewLine];
    } else if ([v isKindOfClass:[NSFileWrapper class]]) {
        [self renderTextView:textView renderFileWrapper:v insertNewLine:insertNewLine];
    } else if ([v respondsToSelector:@selector(enumerateObjectsUsingBlock:)]) {
        [v enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self renderTextView:textView resultValue:obj insertNewLine:insertNewLine block:defaultRender];
        }];
    } else {
        defaultRender(v);
    }
}

+ (void)renderTextView:(NSTextView *)textView renderImage:(NSImage *)image insertNewLine:(BOOL)insertNewLine {
    if (![image isValid]) return;
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:image];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:attachmentCell];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    [[textView textStorage] appendAttributedString:attributedString];
    if (insertNewLine)
        [textView insertNewline:nil];
    [textView didChangeText];
}

+ (void)renderTextView:(NSTextView *)textView renderFileWrapper:(NSFileWrapper *)fileWrapper insertNewLine:(BOOL)insertNewLine {
    if (![fileWrapper isRegularFile]) return;
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    [[textView textStorage] appendAttributedString:attributedString];
    if (insertNewLine)
        [textView insertNewline:nil];
    [textView didChangeText];
}

+ (void)renderTextFieldCell:(NSTextFieldCell *)cell resultValue:(id)v insertNewLine:(BOOL)insertNewLine block:(void (^)(id v))defaultRender {
    if ([v isKindOfClass:[NSImage class]]) {
        [self renderTextFieldCell:cell renderImage:v insertNewLine:insertNewLine];
        return;
    } else if ([v isKindOfClass:[NSFileWrapper class]]) {
        [self renderTextFieldCell:cell renderFileWrapper:v insertNewLine:insertNewLine];
        return;
    } else if ([v respondsToSelector:@selector(enumerateObjectsUsingBlock:)]) {
        if ([v isKindOfClass:[RispSequence class]]) {
            defaultRender(@"(");
        } else if ([v isKindOfClass:[RispVector class]]) {
            defaultRender(@"[");
        } else if ([v isKindOfClass:[RispMap class]]) {
            defaultRender(@"{");
        }
        [v enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self renderTextFieldCell:cell resultValue:obj insertNewLine:insertNewLine block:defaultRender];
        }];
        if ([v isKindOfClass:[RispSequence class]]) {
            defaultRender(@")");
        } else if ([v isKindOfClass:[RispVector class]]) {
            defaultRender(@"]");
        } else if ([v isKindOfClass:[RispMap class]]) {
            defaultRender(@"}");
        }
        return;
    }
    defaultRender(v);
}

+ (void)renderTextFieldCell:(NSTextFieldCell *)cell renderImage:(NSImage *)image insertNewLine:(BOOL)insertNewLine {
    if (![image isValid]) return;
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:image];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:attachmentCell];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    [cell setPlaceholderAttributedString:attributedString];
}

+ (void)renderTextFieldCell:(NSTextFieldCell *)cell renderFileWrapper:(NSFileWrapper *)fileWrapper insertNewLine:(BOOL)insertNewLine {
    if (![fileWrapper isRegularFile]) return;
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment:attachment];
    [cell setPlaceholderAttributedString:attributedString];
}

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
