//
//  RispKBKeyCodeTranslator.m
//  Chercher
//
//  Created by Finlay Dobbie on Sat Oct 11 2003.
//  Copyright (c) 2003 Cliché Software. All rights reserved.
//

#import <RispKeyboardBinding/RispKBKeyCodeTranslator.h>


@implementation RispKBKeyCodeTranslator

+ (id)currentTranslator
{
    static RispKBKeyCodeTranslator *current = nil;
    TISInputSourceRef currentLayout = TISCopyCurrentKeyboardLayoutInputSource();

    if (current == nil) {
        current = [[RispKBKeyCodeTranslator alloc] initWithKeyboardLayout:currentLayout];
    } else if ([current keyboardLayout] != currentLayout) {
        current = [[RispKBKeyCodeTranslator alloc] initWithKeyboardLayout:currentLayout];
    }

	CFRelease(currentLayout);

    return current;
}

- (id)initWithKeyboardLayout:(TISInputSourceRef)aLayout
{
    if ((self = [super init]) != nil) {
        keyboardLayout = aLayout;

		CFRetain(keyboardLayout);

        CFDataRef uchr = TISGetInputSourceProperty( keyboardLayout , kTISPropertyUnicodeKeyLayoutData );
        uchrData = ( const UCKeyboardLayout* )CFDataGetBytePtr(uchr);
    }

    return self;
}

- (void)dealloc
{
	CFRelease(keyboardLayout);

}

- (NSString *)translateKeyCode:(short)keyCode {
    UniCharCount maxStringLength = 4, actualStringLength;
    UniChar unicodeString[4];
    UCKeyTranslate( uchrData, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString );
    return [NSString stringWithCharacters:unicodeString length:1];
}

- (TISInputSourceRef)keyboardLayout {
    return keyboardLayout;
}

- (NSString *)description {
    NSString *kind;
    kind = @"uchr";

    NSString *layoutName;
    layoutName = (__bridge NSString *)(TISGetInputSourceProperty( keyboardLayout, kTISPropertyLocalizedName ));
    return [NSString stringWithFormat:@"RispKBKeyCodeTranslator layout=%@ (%@)", layoutName, kind];
}

@end
