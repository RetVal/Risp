//
//  RispKBKeyCodeTransformer.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick

#import <RispKeyboardBinding/RispKBKeyCodeTransformer.h>
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>
#import <RispKeyboardBinding/RispKBCommon.h>

static NSMutableDictionary  *stringToKeyCodeDict = nil;
static NSDictionary         *keyCodeToStringDict = nil;
static NSArray              *padKeysArray        = nil;

@interface RispKBKeyCodeTransformer( Private )
+ (void) regenerateStringToKeyCodeMapping;
@end

#pragma mark -

@implementation RispKBKeyCodeTransformer

//---------------------------------------------------------- 
//  initialize
//---------------------------------------------------------- 
+ (void) initialize;
{
    if ( self != [RispKBKeyCodeTransformer class] )
        return;
    
    // Some keys need a special glyph
	keyCodeToStringDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		@"F1", RispKBInt(122),
		@"F2", RispKBInt(120),
		@"F3", RispKBInt(99),
		@"F4", RispKBInt(118),
		@"F5", RispKBInt(96),
		@"F6", RispKBInt(97),
		@"F7", RispKBInt(98),
		@"F8", RispKBInt(100),
		@"F9", RispKBInt(101),
		@"F10", RispKBInt(109),
		@"F11", RispKBInt(103),
		@"F12", RispKBInt(111),
		@"F13", RispKBInt(105),
		@"F14", RispKBInt(107),
		@"F15", RispKBInt(113),
		@"F16", RispKBInt(106),
		@"F17", RispKBInt(64),
		@"F18", RispKBInt(79),
		@"F19", RispKBInt(80),
		RispKBLoc(@"Space"), RispKBInt(49),
		RispKBChar(KeyboardDeleteLeftGlyph), RispKBInt(51),
		RispKBChar(KeyboardDeleteRightGlyph), RispKBInt(117),
		RispKBChar(KeyboardPadClearGlyph), RispKBInt(71),
		RispKBChar(KeyboardLeftArrowGlyph), RispKBInt(123),
		RispKBChar(KeyboardRightArrowGlyph), RispKBInt(124),
		RispKBChar(KeyboardUpArrowGlyph), RispKBInt(126),
		RispKBChar(KeyboardDownArrowGlyph), RispKBInt(125),
		RispKBChar(KeyboardSoutheastArrowGlyph), RispKBInt(119),
		RispKBChar(KeyboardNorthwestArrowGlyph), RispKBInt(115),
		RispKBChar(KeyboardEscapeGlyph), RispKBInt(53),
		RispKBChar(KeyboardPageDownGlyph), RispKBInt(121),
		RispKBChar(KeyboardPageUpGlyph), RispKBInt(116),
		RispKBChar(KeyboardReturnR2LGlyph), RispKBInt(36),
		RispKBChar(KeyboardReturnGlyph), RispKBInt(76),
		RispKBChar(KeyboardTabRightGlyph), RispKBInt(48),
		RispKBChar(KeyboardHelpGlyph), RispKBInt(114),
		nil];    
    
    // We want to identify if the key was pressed on the numpad
	padKeysArray = [[NSArray alloc] initWithObjects: 
		RispKBInt(65), // ,
		RispKBInt(67), // *
		RispKBInt(69), // +
		RispKBInt(75), // /
		RispKBInt(78), // -
		RispKBInt(81), // =
		RispKBInt(82), // 0
		RispKBInt(83), // 1
		RispKBInt(84), // 2
		RispKBInt(85), // 3
		RispKBInt(86), // 4
		RispKBInt(87), // 5
		RispKBInt(88), // 6
		RispKBInt(89), // 7
		RispKBInt(91), // 8
		RispKBInt(92), // 9
		nil];
    
    // generate the string to keycode mapping dict...
    stringToKeyCodeDict = [[NSMutableDictionary alloc] init];
    [self regenerateStringToKeyCodeMapping];

	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(regenerateStringToKeyCodeMapping) name:(NSString*)kTISNotifySelectedKeyboardInputSourceChanged object:nil];
}

//---------------------------------------------------------- 
//  allowsReverseTransformation
//---------------------------------------------------------- 
+ (BOOL) allowsReverseTransformation
{
    return YES;
}

//---------------------------------------------------------- 
//  transformedValueClass
//---------------------------------------------------------- 
+ (Class) transformedValueClass;
{
    return [NSString class];
}


//---------------------------------------------------------- 
//  init
//---------------------------------------------------------- 
- (id)init
{
	if((self = [super init]))
	{
	}
	return self;
}

//---------------------------------------------------------- 
//  dealloc
//---------------------------------------------------------- 

//---------------------------------------------------------- 
//  transformedValue: 
//---------------------------------------------------------- 
- (id) transformedValue:(id)value
{
    if ( ![value isKindOfClass:[NSNumber class]] )
        return nil;
    
    // Can be -1 when empty
    NSInteger keyCode = [value shortValue];
	if ( keyCode < 0 ) return nil;
	
	// We have some special gylphs for some special keys...
	NSString *unmappedString = [keyCodeToStringDict objectForKey: RispKBInt( keyCode )];
	if ( unmappedString != nil ) return unmappedString;
	
	BOOL isPadKey = [padKeysArray containsObject: RispKBInt( keyCode )];	
	
	OSStatus err;
	TISInputSourceRef tisSource = TISCopyCurrentKeyboardInputSource();
	if(!tisSource) return nil;
	
	CFDataRef layoutData;
	UInt32 keysDown = 0;
	layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
	
	CFRelease(tisSource);
	
	// For non-unicode layouts such as Chinese, Japanese, and Korean, get the ASCII capable layout
	if(!layoutData) {
		tisSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
		layoutData = (CFDataRef)TISGetInputSourceProperty(tisSource, kTISPropertyUnicodeKeyLayoutData);
		CFRelease(tisSource);
	}

	if (!layoutData) return nil;
	
	const UCKeyboardLayout *keyLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
	
	UniCharCount length = 4, realLength;
	UniChar chars[4];
	
	err = UCKeyTranslate( keyLayout, 
						 keyCode,
						 kUCKeyActionDisplay,
						 0,
						 LMGetKbdType(),
						 kUCKeyTranslateNoDeadKeysBit,
						 &keysDown,
						 length,
						 &realLength,
						 chars);
	
	if ( err != noErr ) return nil;
	
	NSString *keyString = [[NSString stringWithCharacters:chars length:1] uppercaseString];
	
	return ( isPadKey ? [NSString stringWithFormat: RispKBLoc(@"Pad %@"), keyString] : keyString );
}

//---------------------------------------------------------- 
//  reverseTransformedValue: 
//---------------------------------------------------------- 
- (id) reverseTransformedValue:(id)value
{
    if ( ![value isKindOfClass:[NSString class]] )
        return nil;
    
    // try and retrieve a mapped keycode from the reverse mapping dict...
    return [stringToKeyCodeDict objectForKey:value];
}

@end

#pragma mark -

@implementation RispKBKeyCodeTransformer( Private )

//---------------------------------------------------------- 
//  regenerateStringToKeyCodeMapping: 
//---------------------------------------------------------- 
+ (void) regenerateStringToKeyCodeMapping;
{
    RispKBKeyCodeTransformer *transformer = [[self alloc] init];
    [stringToKeyCodeDict removeAllObjects];
    
    // loop over every keycode (0 - 127) finding its current string mapping...
	NSUInteger i;
    for ( i = 0U; i < 128U; i++ )
    {
        NSNumber *keyCode = [NSNumber numberWithUnsignedInteger:i];
        NSString *string = [transformer transformedValue:keyCode];
        if ( ( string ) && ( [string length] ) )
        {
            [stringToKeyCodeDict setObject:keyCode forKey:string];
        }
    }
}

@end
