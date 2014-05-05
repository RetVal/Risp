//
//  RispKBCommon.m
//  ShortcutRecorder
//
//  Copyright 2006-2011 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick
//      Andy Kim

#import <RispKeyboardBinding/RispKBCommon.h>
#import <RispKeyboardBinding/RispKBKeyCodeTransformer.h>

#include <IOKit/hidsystem/IOLLEvent.h>

//#define RispKBCommon_PotentiallyUsefulDebugInfo

#ifdef	RispKBCommon_PotentiallyUsefulDebugInfo
#warning 64BIT: Check formatting arguments
#define PUDNSLog(X,...)	NSLog(X,##__VA_ARGS__)
#else
#define PUDNSLog(X,...)	{ ; }
#endif

#pragma mark -
#pragma mark dummy class 

@implementation RispKBDummyClass @end

#pragma mark -

//---------------------------------------------------------- 
// RispKBStringForKeyCode()
//---------------------------------------------------------- 
NSString * RispKBStringForKeyCode( NSInteger keyCode )
{
    static RispKBKeyCodeTransformer *keyCodeTransformer = nil;
    if ( !keyCodeTransformer )
        keyCodeTransformer = [[RispKBKeyCodeTransformer alloc] init];
    return [keyCodeTransformer transformedValue:[NSNumber numberWithShort:keyCode]];
}

//---------------------------------------------------------- 
// RispKBStringForCarbonModifierFlags()
//---------------------------------------------------------- 
NSString * RispKBStringForCarbonModifierFlags( NSUInteger flags )
{
    NSString *modifierFlagsString = [NSString stringWithFormat:@"%@%@%@%@", 
		( flags & controlKey ? RispKBChar(KeyboardControlGlyph) : @"" ),
		( flags & optionKey ? RispKBChar(KeyboardOptionGlyph) : @"" ),
		( flags & shiftKey ? RispKBChar(KeyboardShiftGlyph) : @"" ),
		( flags & cmdKey ? RispKBChar(KeyboardCommandGlyph) : @"" )];
	return modifierFlagsString;
}

//---------------------------------------------------------- 
// RispKBStringForCarbonModifierFlagsAndKeyCode()
//---------------------------------------------------------- 
NSString * RispKBStringForCarbonModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode )
{
    return [NSString stringWithFormat: @"%@%@", 
        RispKBStringForCarbonModifierFlags( flags ), 
        RispKBStringForKeyCode( keyCode )];
}

//---------------------------------------------------------- 
// RispKBStringForCocoaModifierFlags()
//---------------------------------------------------------- 
NSString * RispKBStringForCocoaModifierFlags( NSUInteger flags )
{
    NSString *modifierFlagsString = [NSString stringWithFormat:@"%@%@%@%@", 
		( flags & NSControlKeyMask ? RispKBChar(KeyboardControlGlyph) : @"" ),
		( flags & NSAlternateKeyMask ? RispKBChar(KeyboardOptionGlyph) : @"" ),
		( flags & NSShiftKeyMask ? RispKBChar(KeyboardShiftGlyph) : @"" ),
		( flags & NSCommandKeyMask ? RispKBChar(KeyboardCommandGlyph) : @"" )];
	
	return modifierFlagsString;
}

//---------------------------------------------------------- 
// RispKBStringForCocoaModifierFlagsAndKeyCode()
//---------------------------------------------------------- 
NSString * RispKBStringForCocoaModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode )
{
    return [NSString stringWithFormat: @"%@%@", 
        RispKBStringForCocoaModifierFlags( flags ),
        RispKBStringForKeyCode( keyCode )];
}

//---------------------------------------------------------- 
// RispKBReadableStringForCarbonModifierFlagsAndKeyCode()
//---------------------------------------------------------- 
NSString * RispKBReadableStringForCarbonModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode )
{
    NSString *readableString = [NSString stringWithFormat:@"%@%@%@%@%@", 
		( flags & cmdKey ? RispKBLoc(@"Command + ") : @""),
		( flags & optionKey ? RispKBLoc(@"Option + ") : @""),
		( flags & controlKey ? RispKBLoc(@"Control + ") : @""),
		( flags & shiftKey ? RispKBLoc(@"Shift + ") : @""),
        RispKBStringForKeyCode( keyCode )];
	return readableString;    
}

//---------------------------------------------------------- 
// RispKBReadableStringForCocoaModifierFlagsAndKeyCode()
//---------------------------------------------------------- 
NSString * RispKBReadableStringForCocoaModifierFlagsAndKeyCode( NSUInteger flags, NSInteger keyCode )
{
    NSString *readableString = [NSString stringWithFormat:@"%@%@%@%@%@", 
		(flags & NSCommandKeyMask ? RispKBLoc(@"Command + ") : @""),
		(flags & NSAlternateKeyMask ? RispKBLoc(@"Option + ") : @""),
		(flags & NSControlKeyMask ? RispKBLoc(@"Control + ") : @""),
		(flags & NSShiftKeyMask ? RispKBLoc(@"Shift + ") : @""),
        RispKBStringForKeyCode( keyCode )];
	return readableString;
}

//---------------------------------------------------------- 
// RispKBCarbonToCocoaFlags()
//---------------------------------------------------------- 
NSUInteger RispKBCarbonToCocoaFlags( NSUInteger carbonFlags )
{
	NSUInteger cocoaFlags = ShortcutRecorderEmptyFlags;
	
	if (carbonFlags & cmdKey) cocoaFlags |= NSCommandKeyMask;
	if (carbonFlags & optionKey) cocoaFlags |= NSAlternateKeyMask;
	if (carbonFlags & controlKey) cocoaFlags |= NSControlKeyMask;
	if (carbonFlags & shiftKey) cocoaFlags |= NSShiftKeyMask;
	if (carbonFlags & NSFunctionKeyMask) cocoaFlags += NSFunctionKeyMask;
	
	return cocoaFlags;
}

//---------------------------------------------------------- 
// RispKBCocoaToCarbonFlags()
//---------------------------------------------------------- 
NSUInteger RispKBCocoaToCarbonFlags( NSUInteger cocoaFlags )
{
	NSUInteger carbonFlags = ShortcutRecorderEmptyFlags;
	
	if (cocoaFlags & NSCommandKeyMask) carbonFlags |= cmdKey;
	if (cocoaFlags & NSAlternateKeyMask) carbonFlags |= optionKey;
	if (cocoaFlags & NSControlKeyMask) carbonFlags |= controlKey;
	if (cocoaFlags & NSShiftKeyMask) carbonFlags |= shiftKey;
	if (cocoaFlags & NSFunctionKeyMask) carbonFlags |= NSFunctionKeyMask;
	
	return carbonFlags;
}

//---------------------------------------------------------- 
// RispKBCharacterForKeyCodeAndCarbonFlags()
//----------------------------------------------------------
NSString *RispKBCharacterForKeyCodeAndCarbonFlags(NSInteger keyCode, NSUInteger carbonFlags) {
	return RispKBCharacterForKeyCodeAndCocoaFlags(keyCode, RispKBCarbonToCocoaFlags(carbonFlags));
}

//---------------------------------------------------------- 
// RispKBCharacterForKeyCodeAndCocoaFlags()
//----------------------------------------------------------
NSString *RispKBCharacterForKeyCodeAndCocoaFlags(NSInteger keyCode, NSUInteger cocoaFlags) {
	
	PUDNSLog(@"RispKBCharacterForKeyCodeAndCocoaFlags, keyCode: %hi, cocoaFlags: %u",
			 keyCode, cocoaFlags);
	
	// Fall back to string based on key code:
#define	FailWithNaiveString RispKBStringForKeyCode(keyCode)
	
	UInt32              deadKeyState;
    OSStatus err = noErr;
    CFLocaleRef locale = CFAutorelease(CFLocaleCopyCurrent());
	
	TISInputSourceRef tisSource = TISCopyCurrentKeyboardInputSource();
    if(!tisSource)
		return FailWithNaiveString;
	
	CFDataRef layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
    if (!layoutData)
		return FailWithNaiveString;
	
	const UCKeyboardLayout *keyLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    if (!keyLayout)
		return FailWithNaiveString;
	
	EventModifiers modifiers = 0;
	if (cocoaFlags & NSAlternateKeyMask)	modifiers |= optionKey;
	if (cocoaFlags & NSShiftKeyMask)		modifiers |= shiftKey;
	UniCharCount maxStringLength = 4, actualStringLength;
	UniChar unicodeString[4];
	err = UCKeyTranslate( keyLayout, (UInt16)keyCode, kUCKeyActionDisplay, modifiers, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString );
	if(err != noErr)
		return FailWithNaiveString;

	CFStringRef temp = CFStringCreateWithCharacters(kCFAllocatorDefault, unicodeString, 1);
	CFMutableStringRef mutableTemp = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, temp);

	CFStringCapitalize(mutableTemp, locale);

	NSString *resultString = [NSString stringWithString:(__bridge NSString *)mutableTemp];

	if (temp) CFRelease(temp);
	if (mutableTemp) CFRelease(mutableTemp);

	PUDNSLog(@"character: -%@-", (NSString *)resultString);

	return resultString;
}

#pragma mark Animation Easing

#define CG_M_PI (CGFloat)M_PI
#define CG_M_PI_2 (CGFloat)M_PI_2

#ifdef __LP64__
#define CGSin(x) sin(x)
#else
#define CGSin(x) sinf(x)
#endif

// From: http://developer.apple.com/samplecode/AnimatedSlider/ as "easeFunction"
CGFloat RispKBAnimationEaseInOut(CGFloat t) {
	// This function implements a sinusoidal ease-in/ease-out for t = 0 to 1.0.  T is scaled to represent the interval of one full period of the sine function, and transposed to lie above the X axis.
	CGFloat x = (CGSin((t * CG_M_PI) - CG_M_PI_2) + 1.0f ) / 2.0f;
	//	NSLog(@"RispKBAnimationEaseInOut: %f. a: %f, b: %f, c: %f, d: %f, e: %f", t, (t * M_PI), ((t * M_PI) - M_PI_2), sin((t * M_PI) - M_PI_2), (sin((t * M_PI) - M_PI_2) + 1.0), x);
	return x;
} 


#pragma mark -
#pragma mark additions

@implementation NSAlert( RispKBAdditions )

//---------------------------------------------------------- 
// + alertWithNonRecoverableError:
//---------------------------------------------------------- 
+ (NSAlert *) alertWithNonRecoverableError:(NSError *)error;
{
	NSString *reason = [error localizedRecoverySuggestion];
	return [self alertWithMessageText:[error localizedDescription]
						defaultButton:[[error localizedRecoveryOptions] objectAtIndex:0U]
					  alternateButton:nil
						  otherButton:nil
			informativeTextWithFormat:(reason ? reason : @""), nil];
}

@end

static NSMutableDictionary *RispKBSharedImageCache = nil;

@interface RispKBSharedImageProvider (Private)
+ (void)_drawRispKBSnapback:(id)anNSCustomImageRep;
+ (NSValue *)_sizeRispKBSnapback;
+ (void)_drawRispKBRemoveShortcut:(id)anNSCustomImageRep;
+ (NSValue *)_sizeRispKBRemoveShortcut;
+ (void)_drawRispKBRemoveShortcutRollover:(id)anNSCustomImageRep;
+ (NSValue *)_sizeRispKBRemoveShortcutRollover;
+ (void)_drawRispKBRemoveShortcutPressed:(id)anNSCustomImageRep;
+ (NSValue *)_sizeRispKBRemoveShortcutPressed;

+ (void)_drawARemoveShortcutBoxUsingRep:(id)anNSCustomImageRep opacity:(CGFloat)opacity;
@end

@implementation RispKBSharedImageProvider
+ (NSImage *)supportingImageWithName:(NSString *)name {
//	NSLog(@"supportingImageWithName: %@", name);
	if (nil == RispKBSharedImageCache) {
		RispKBSharedImageCache = [NSMutableDictionary dictionary];
//		NSLog(@"inited cache");
	}
	NSImage *cachedImage = nil;
	if (nil != (cachedImage = [RispKBSharedImageCache objectForKey:name])) {
//		NSLog(@"returned cached image: %@", cachedImage);
		return cachedImage;
	}
	
//	NSLog(@"constructing image");
	NSSize size;
	NSValue *sizeValue = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_size%@", name])];
	size = [sizeValue sizeValue];
//	NSLog(@"size: %@", NSStringFromSize(size));
	
	NSCustomImageRep *customImageRep = [[NSCustomImageRep alloc] initWithDrawSelector:NSSelectorFromString([NSString stringWithFormat:@"_draw%@:", name]) delegate:self];
	[customImageRep setSize:size];
//	NSLog(@"created customImageRep: %@", customImageRep);
	NSImage *returnImage = [[NSImage alloc] initWithSize:size];
	[returnImage addRepresentation:customImageRep];
	[returnImage setScalesWhenResized:YES];
	[RispKBSharedImageCache setObject:returnImage forKey:name];
	
#ifdef RispKBCommonWriteDebugImagery
	
	NSData *tiff = [returnImage TIFFRepresentation];
	[tiff writeToURL:[NSURL fileURLWithPath:[[NSString stringWithFormat:@"~/Desktop/m_%@.tiff", name] stringByExpandingTildeInPath]] atomically:YES];

	NSSize sizeQDRPL = NSMakeSize(size.width*4.0,size.height*4.0);
	
//	sizeQDRPL = NSMakeSize(70.0,70.0);
	NSCustomImageRep *customImageRepQDRPL = [[NSCustomImageRep alloc] initWithDrawSelector:NSSelectorFromString([NSString stringWithFormat:@"_draw%@:", name]) delegate:self];
	[customImageRepQDRPL setSize:sizeQDRPL];
//	NSLog(@"created customImageRepQDRPL: %@", customImageRepQDRPL);
	NSImage *returnImageQDRPL = [[NSImage alloc] initWithSize:sizeQDRPL];
	[returnImageQDRPL addRepresentation:customImageRepQDRPL];
	[customImageRepQDRPL release];
	[returnImageQDRPL setScalesWhenResized:YES];
	[returnImageQDRPL setFlipped:YES];
	NSData *tiffQDRPL = [returnImageQDRPL TIFFRepresentation];
	[tiffQDRPL writeToURL:[NSURL fileURLWithPath:[[NSString stringWithFormat:@"~/Desktop/m_QDRPL_%@.tiff", name] stringByExpandingTildeInPath]] atomically:YES];
	
#endif
	
//	NSLog(@"returned image: %@", returnImage);
	return returnImage;
}
@end

@implementation RispKBSharedImageProvider (Private)

#define MakeRelativePoint(x,y)	NSMakePoint(x*hScale, y*vScale)

+ (NSValue *)_sizeRispKBSnapback {
	return [NSValue valueWithSize:NSMakeSize(14.0f,14.0f)];
}
+ (void)_drawRispKBSnapback:(id)anNSCustomImageRep {
	
//	NSLog(@"drawRispKBSnapback using: %@", anNSCustomImageRep);
	
	NSCustomImageRep *rep = anNSCustomImageRep;
	NSSize size = [rep size];
	[[NSColor whiteColor] setFill];
	CGFloat hScale = (size.width/1.0f);
	CGFloat vScale = (size.height/1.0f);
	
	NSBezierPath *bp = [[NSBezierPath alloc] init];
	[bp setLineWidth:hScale];
	
	[bp moveToPoint:MakeRelativePoint(0.0489685f, 0.6181513f)];
	[bp lineToPoint:MakeRelativePoint(0.4085750f, 0.9469318f)];
	[bp lineToPoint:MakeRelativePoint(0.4085750f, 0.7226146f)];
	[bp curveToPoint:MakeRelativePoint(0.8508247f, 0.4836237f) controlPoint1:MakeRelativePoint(0.4085750f, 0.7226146f) controlPoint2:MakeRelativePoint(0.8371143f, 0.7491841f)];
	[bp curveToPoint:MakeRelativePoint(0.5507195f, 0.0530682f) controlPoint1:MakeRelativePoint(0.8677834f, 0.1545071f) controlPoint2:MakeRelativePoint(0.5507195f, 0.0530682f)];
	[bp curveToPoint:MakeRelativePoint(0.7421721f, 0.3391942f) controlPoint1:MakeRelativePoint(0.5507195f, 0.0530682f) controlPoint2:MakeRelativePoint(0.7458685f, 0.1913146f)];
	[bp curveToPoint:MakeRelativePoint(0.4085750f, 0.5154130f) controlPoint1:MakeRelativePoint(0.7383412f, 0.4930328f) controlPoint2:MakeRelativePoint(0.4085750f, 0.5154130f)];
	[bp lineToPoint:MakeRelativePoint(0.4085750f, 0.2654000f)];
	
	NSAffineTransform *flip = [[NSAffineTransform alloc] init];
//	[flip translateXBy:0.95f yBy:-1.0f];
	[flip scaleXBy:0.9f yBy:1.0f];
	[flip translateXBy:0.5f yBy:-0.5f];
	
	[bp transformUsingAffineTransform:flip];
	
	NSShadow *sh = [[NSShadow alloc] init];
	[sh setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.45f]];
	[sh setShadowBlurRadius:1.0f];
	[sh setShadowOffset:NSMakeSize(0.0f,-1.0f)];
	[sh set];
	
	[bp fill];
	
}

+ (NSValue *)_sizeRispKBRemoveShortcut {
	return [NSValue valueWithSize:NSMakeSize(14.0f,14.0f)];
}
+ (NSValue *)_sizeRispKBRemoveShortcutRollover { return [self _sizeRispKBRemoveShortcut]; }
+ (NSValue *)_sizeRispKBRemoveShortcutPressed { return [self _sizeRispKBRemoveShortcut]; }
+ (void)_drawARemoveShortcutBoxUsingRep:(id)anNSCustomImageRep opacity:(CGFloat)opacity {
	
//	NSLog(@"drawARemoveShortcutBoxUsingRep: %@ opacity: %f", anNSCustomImageRep, opacity);
	
	NSCustomImageRep *rep = anNSCustomImageRep;
	NSSize size = [rep size];
	[[NSColor colorWithCalibratedWhite:0.0f alpha:1.0f-opacity] setFill];
	CGFloat hScale = (size.width/14.0f);
	CGFloat vScale = (size.height/14.0f);
	
	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0f,0.0f,size.width,size.height)] fill];
	
	[[NSColor whiteColor] setStroke];
	
	NSBezierPath *cross = [[NSBezierPath alloc] init];
	[cross setLineWidth:hScale*1.2f];
	
	[cross moveToPoint:MakeRelativePoint(4.0f,4.0f)];
	[cross lineToPoint:MakeRelativePoint(10.0f,10.0f)];
	[cross moveToPoint:MakeRelativePoint(10.0f,4.0f)];
	[cross lineToPoint:MakeRelativePoint(4.0f,10.0f)];
		
	[cross stroke];
}
+ (void)_drawRispKBRemoveShortcut:(id)anNSCustomImageRep {
	
//	NSLog(@"drawRispKBRemoveShortcut using: %@", anNSCustomImageRep);
	
	[self _drawARemoveShortcutBoxUsingRep:anNSCustomImageRep opacity:0.75f];
}
+ (void)_drawRispKBRemoveShortcutRollover:(id)anNSCustomImageRep {
	
//	NSLog(@"drawRispKBRemoveShortcutRollover using: %@", anNSCustomImageRep);
	
	[self _drawARemoveShortcutBoxUsingRep:anNSCustomImageRep opacity:0.65f];	
}
+ (void)_drawRispKBRemoveShortcutPressed:(id)anNSCustomImageRep {
	
//	NSLog(@"drawRispKBRemoveShortcutPressed using: %@", anNSCustomImageRep);
	
	[self _drawARemoveShortcutBoxUsingRep:anNSCustomImageRep opacity:0.55f];
}
@end
