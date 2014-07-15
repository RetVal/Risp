//
//  RispArgumentsReader.m
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispArgumentsReader.h>
#import <Risp/RispVector.h>
#import <Risp/RispList.h>
#import <Risp/RispReader.h>
#import <Risp/RispTokenReader.h>
#import <Risp/RispRuntime.h>

@implementation RispArgumentsReader
- (RispSymbol *)registerArguments:(NSInteger)n {
    RispSymbol *symbol = nil;
    if (n == 1) {
        symbol = [RispSymbol named:@"%"];
    } else {
        symbol = [RispSymbol named:[NSString stringWithFormat:@"%%%ld", n]];
    }
    [[[RispContext currentContext] currentScope] setObject:symbol forKey:symbol];
    return symbol;
}
//static Symbol registerArg(int n){
//	PersistentTreeMap argsyms = (PersistentTreeMap) ARG_ENV.deref();
//	if(argsyms == null)
//    {
//		throw new IllegalStateException("arg literal not in #()");
//    }
//	Symbol ret = (Symbol) argsyms.valAt(n);
//	if(ret == null)
//    {
//		ret = garg(n);
//		ARG_ENV.set(argsyms.assoc(n, ret));
//    }
//	return ret;
//}
- (id)invoke:(RispReader *)reader object:(id)object {
//    if ([rt isDeref] == nil) {
//        return [reader interpretToken:[[[RispTokenReader alloc] init] invoke:reader object:object]];
//    }
    RispPushBackReader *r = [reader reader];
    unichar ch = [r read1];
    [r unread:ch];
    if (ch == 0 || [RispBaseReader isWhiteSpace:ch] || [RispBaseReader isTerminatingMacro:ch]) {
        return [self registerArguments:1];
    }
    id n = [reader readEofIsError:YES eofValue:nil isRecursive:YES];
    if (n == reader) {
        return reader;
    }
    if ([n isEqualTo:@0]) {
        return [self registerArguments:-1];
    }
    if (![n isKindOfClass:[NSNumber class]]) {
        [NSException raise:RispIllegalArgumentException format:@"arg literal must be %%, %%& or %%integer"];
    }
    return [self registerArguments:[n intValue]];
//    {
//		PushbackReader r = (PushbackReader) reader;
//		if(ARG_ENV.deref() == null)
//        {
//			return interpretToken(readToken(r, '%'));
//        }
//		int ch = read1(r);
//		unread(r, ch);
//		//% alone is first arg
//		if(ch == -1 || isWhitespace(ch) || isTerminatingMacro(ch))
//        {
//			return registerArg(1);
//        }
//		Object n = read(r, true, null, true);
//		if(n.equals(Compiler._AMP_))
//			return registerArg(-1);
//		if(!(n instanceof Number))
//			throw new IllegalStateException("arg literal must be %, %& or %integer");
//		return registerArg(((Number) n).intValue());
//	}
}
@end
