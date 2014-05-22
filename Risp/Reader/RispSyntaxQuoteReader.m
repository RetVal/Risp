//
//  RispSyntaxQuoteReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispSyntaxQuoteReader.h>
#import <Risp/RispReader.h>
#import <Risp/RispContext.h>
#import <Risp/RispSymbol+BIF.h>

@interface RispSequence (Concat)
- (id <RispSequence>)concat:(id <RispSequence>)seq;
@end

@implementation RispSequence (Concat)
- (id<RispSequence>)concat:(id<RispSequence>)seq {
    return self;
}
@end

@implementation RispSyntaxQuoteReader

+ (id)_rewriteSyntaxQuote:(id)form {
    if ([form conformsToProtocol:@protocol(RispSequence)]) {
//        for (id f in form) {
//            if ([f conformsToProtocol:@protocol(RispSequence)]) {
//                
//            }
//        }
    }
    return nil;
}

- (id)invoke:(RispReader *)reader object:(id)object {
    RispContext *currentContext = [RispContext currentContext];
    id form = nil;
    @try {
        [currentContext pushScope];
        form = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [currentContext popScope];
    }
    id <RispSequence> syntaxQuoteSequence = [RispSyntaxQuoteReader syntaxQuote:form];
    id rewrite = nil;
    if (syntaxQuoteSequence) {
        @try {
            rewrite = [RispSyntaxQuoteReader _rewriteSyntaxQuote:syntaxQuoteSequence];
        }
        @catch (NSException *exception) {
            @throw exception;
        }
        @finally {
            
        }
    }
    return syntaxQuoteSequence;
}

+ (BOOL)isUnQuote:(id)form {
    return [form conformsToProtocol:@protocol(RispSequence)] && [[form first] isEqualTo:[RispSymbol UNQUOTE]];
}

+ (BOOL)isUnquoteSplicing:(id)form {
    return [form conformsToProtocol:@protocol(RispSequence)] && [[form first] isEqualTo:[RispSymbol UNQUOTESPLICING]];
}

+ (id)syntaxQuote:(id)form {
    id ret;
    if([[RispContext currentContext] specialForKey:form]) {
        ret = [RispList listWithObjectsFromArray:@[[RispSymbol QUOTE], form]];
    } else if([form isKindOfClass:[RispSymbol class]]) {
        RispSymbol *sym = form;
        if([[sym stringValue] hasSuffix:@"#"]) {
            // gen randon-symbol
        }
        ret = [RispList listWithObjectsFromArray:@[[RispSymbol QUOTE], sym]];
    } else if ([RispSyntaxQuoteReader isUnQuote:form]) {
        return [(id <RispSequence>)form second];
    } else if ([RispSyntaxQuoteReader isUnquoteSplicing:form]) {
        [NSException raise:RispIllegalArgumentException format:@"splice not in list"];
    } else if ([form conformsToProtocol:@protocol(RispSequence)]) {
        if ([form isKindOfClass:[RispMap class]]) {
            
        } else if ([form isKindOfClass:[RispVector class]]) {
            
        } else if ([form isKindOfClass:[RispSequence class]]) {
            NSArray *seq = [form array];
            if(seq == nil)
                ret = [RispList listWithObjects:[RispSymbol named:@"list"], nil];
            else
                ret = [RispList listWithRest:[RispList listWithObjectsFromArray:[RispSyntaxQuoteReader sqExpandList:seq]] objects:[RispSymbol named:@"concat"], nil];
//                ret = RT.list(SEQ, RT.cons(CONCAT, sqExpandList(seq)));
        }
    } else if ([form isKindOfClass:[NSNumber class]] ||
               [form isKindOfClass:[RispKeyword class]] ||
               [form isKindOfClass:[NSString class]]) {
        ret = form;
    } else {
        ret = [RispList listWithObjectsFromArray:@[[RispSymbol QUOTE], form]];
    }
    return ret;
}

+ (NSArray *)sqExpandList:(NSArray *)seq {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (id item in seq) {
        if ([RispSyntaxQuoteReader isUnQuote:item]) {
            [ret addObject:[RispList listWithObjects:[item objectAtIndex:1], [RispSymbol named:@"list"], nil]];
        } else if ([RispSyntaxQuoteReader isUnquoteSplicing:item]) {
            id x = [(id <RispSequence>)item second];
            [ret addObject:x];
        } else {
            [ret addObject:[RispList listWithObjects:[RispSyntaxQuoteReader syntaxQuote:item], [RispSymbol named:@"list"], nil]];
        }
    }
    return ret;
}
@end
