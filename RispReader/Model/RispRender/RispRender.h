//
//  RispRender.h
//  Risp
//
//  Created by closure on 5/29/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/Risp.h>

@interface NSObject (Render)
- (NSAttributedString *)render;
@end

@interface RispSequence (Render)
- (NSAttributedString *)render;
@end

@interface RispList (Render)
- (NSAttributedString *)render;
@end

@interface RispVector (Render)
- (NSAttributedString *)render;
@end

@interface RispKeyword (Render)
- (NSAttributedString *)render;
@end

@interface RispMap (Render)
- (NSAttributedString *)render;
@end

@interface RispLazySequence (Render)
- (NSAttributedString *)render;
@end

@interface RispSymbol (Render)
- (NSAttributedString *)render;
@end

@interface NSDecimalNumber (Render)
- (NSAttributedString *)render;
@end

@interface NSString (Render)
- (NSAttributedString *)render;
@end

@interface NSImage (Render)
- (NSAttributedString *)render;
@end

@interface NSFileWrapper (Render)
- (NSAttributedString *)render;
@end

@interface NSArray (Render)
- (NSAttributedString *)render;
@end
