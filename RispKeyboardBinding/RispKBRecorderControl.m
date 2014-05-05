//
//  RispKBRecorderControl.m
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

#import <RispKeyboardBinding/RispKBRecorderControl.h>
#import <RispKeyboardBinding/RispKBCommon.h>

#define RispKBCell (RispKBRecorderCell *)[self cell]

@interface RispKBRecorderControl (Private)
- (void)resetTrackingRects;
@end

@implementation RispKBRecorderControl

+ (void)initialize
{
    if (self == [RispKBRecorderControl class])
	{
        [self setCellClass: [RispKBRecorderCell class]];
    }
}

+ (Class)cellClass
{
    return [RispKBRecorderCell class];
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	
	[RispKBCell setDelegate: self];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder: aDecoder];
	
	[RispKBCell setDelegate: self];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder: aCoder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark *** Cell Behavior ***

// We need keyboard access
- (BOOL)acceptsFirstResponder
{
    return YES;
}

// Allow the control to be activated with the first click on it even if it's window isn't the key window
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (BOOL) becomeFirstResponder 
{
    BOOL okToChange = [RispKBCell becomeFirstResponder];
    if (okToChange) [super setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return okToChange;
}

- (BOOL) resignFirstResponder 
{
    BOOL okToChange = [RispKBCell resignFirstResponder];
    if (okToChange) [super setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return okToChange;
}

#pragma mark *** Aesthetics ***
- (BOOL)animates {
	return [RispKBCell animates];
}

- (void)setAnimates:(BOOL)an {
	[RispKBCell setAnimates:an];
}

- (RispKBRecorderStyle)style {
	return [RispKBCell style];
}

- (void)setStyle:(RispKBRecorderStyle)nStyle {
	[RispKBCell setStyle:nStyle];
}

#pragma mark *** Interface Stuff ***


// If the control is set to be resizeable in width, this will make sure that the tracking rects are always updated
- (void)viewDidMoveToWindow
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if ([self window]) 
    {
        [center removeObserver: self];
        [center addObserver:self selector:@selector(viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:self];
        [self resetTrackingRects];
	}
}

- (void)viewFrameDidChange:(NSNotification *)aNotification
{
	[self resetTrackingRects];
}

// Prevent from being too small
- (void)setFrameSize:(NSSize)newSize
{
	NSSize correctedSize = newSize;
	correctedSize.height = RispKBMaxHeight;
	if (correctedSize.width < RispKBMinWidth) correctedSize.width = RispKBMinWidth;
	
	[super setFrameSize: correctedSize];
}

- (void)setFrame:(NSRect)frameRect
{
	NSRect correctedFrarme = frameRect;
	correctedFrarme.size.height = RispKBMaxHeight;
	if (correctedFrarme.size.width < RispKBMinWidth) correctedFrarme.size.width = RispKBMinWidth;

	[super setFrame: correctedFrarme];
}

- (NSString *)keyChars {
	return [RispKBCell keyChars];
}

- (NSString *)keyCharsIgnoringModifiers {
	return [RispKBCell keyCharsIgnoringModifiers];	
}

#pragma mark *** Key Interception ***

// Like most NSControls, pass things on to the cell
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	// Only if we're key, please. Otherwise hitting Space after having
	// tabbed past RispKBRecorderControl will put you into recording mode.
	if (([[[self window] firstResponder] isEqualTo:self])) { 
		if ([RispKBCell performKeyEquivalent:theEvent]) return YES;
	}

	return [super performKeyEquivalent: theEvent];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[RispKBCell flagsChanged:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ( [RispKBCell performKeyEquivalent: theEvent] )
        return;
    
    [super keyDown:theEvent];
}

#pragma mark *** Key Combination Control ***

- (NSUInteger)allowedFlags
{
	return [RispKBCell allowedFlags];
}

- (void)setAllowedFlags:(NSUInteger)flags
{
	[RispKBCell setAllowedFlags: flags];
}

- (BOOL)allowsKeyOnly {
	return [RispKBCell allowsKeyOnly];
}

- (void)setAllowsKeyOnly:(BOOL)nAllowsKeyOnly {
    [self setAllowsKeyOnly:nAllowsKeyOnly escapeKeysRecord:NO];
}

- (void)setAllowsKeyOnly:(BOOL)nAllowsKeyOnly escapeKeysRecord:(BOOL)nEscapeKeysRecord {
	[RispKBCell setAllowsKeyOnly:nAllowsKeyOnly escapeKeysRecord:nEscapeKeysRecord];
}

- (BOOL)escapeKeysRecord {
	return [RispKBCell escapeKeysRecord];
}

- (void)setEscapeKeysRecord:(BOOL)nEscapeKeysRecord {
	[RispKBCell setEscapeKeysRecord:nEscapeKeysRecord];
}

- (BOOL)canCaptureGlobalHotKeys
{
	return [[self cell] canCaptureGlobalHotKeys];
}

- (void)setCanCaptureGlobalHotKeys:(BOOL)inState
{
	[[self cell] setCanCaptureGlobalHotKeys:inState];
}

- (NSUInteger)requiredFlags
{
	return [RispKBCell requiredFlags];
}

- (void)setRequiredFlags:(NSUInteger)flags
{
	[RispKBCell setRequiredFlags: flags];
}

- (KeyCombo)keyCombo
{
	return [RispKBCell keyCombo];
}

- (void)setKeyCombo:(KeyCombo)aKeyCombo
{
	[RispKBCell setKeyCombo: aKeyCombo];
}

#pragma mark *** Binding Methods ***

- (NSDictionary *)objectValue
{
    KeyCombo keyCombo = [self keyCombo];
    if (keyCombo.code == ShortcutRecorderEmptyCode || keyCombo.flags == ShortcutRecorderEmptyFlags)
        return nil;

    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self keyCharsIgnoringModifiers], @"characters",
            [NSNumber numberWithInteger:keyCombo.code], @"keyCode",
            [NSNumber numberWithUnsignedInteger:keyCombo.flags], @"modifierFlags",
            nil];
}

- (void)setObjectValue:(NSDictionary *)shortcut
{
    KeyCombo keyCombo = RispKBMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
    if (shortcut != nil && [shortcut isKindOfClass:[NSDictionary class]]) {
        NSNumber *keyCode = [shortcut objectForKey:@"keyCode"];
        NSNumber *modifierFlags = [shortcut objectForKey:@"modifierFlags"];
        if ([keyCode isKindOfClass:[NSNumber class]] && [modifierFlags isKindOfClass:[NSNumber class]]) {
            keyCombo.code = [keyCode integerValue];
            keyCombo.flags = [modifierFlags unsignedIntegerValue];
        }
    }

	[self setKeyCombo: keyCombo];
}

- (Class)valueClassForBinding:(NSString *)binding
{
	if ([binding isEqualToString:@"value"])
		return [NSDictionary class];

	return [super valueClassForBinding:binding];
}

#pragma mark *** Autosave Control ***

- (NSString *)autosaveName
{
	return [RispKBCell autosaveName];
}

- (void)setAutosaveName:(NSString *)aName
{
	[RispKBCell setAutosaveName: aName];
}

#pragma mark -

- (NSString *)keyComboString
{
	return [RispKBCell keyComboString];
}

#pragma mark *** Conversion Methods ***

- (NSUInteger)cocoaToCarbonFlags:(NSUInteger)cocoaFlags
{
	return RispKBCocoaToCarbonFlags( cocoaFlags );
}

- (NSUInteger)carbonToCocoaFlags:(NSUInteger)carbonFlags;
{
	return RispKBCarbonToCocoaFlags( carbonFlags );
}

#pragma mark *** Delegate ***

// Only the delegate will be handled by the control
- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

#pragma mark *** Delegate pass-through ***

- (BOOL)shortcutRecorderCell:(RispKBRecorderCell *)aRecorderCell isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	if (delegate != nil && [delegate respondsToSelector: @selector(shortcutRecorder:isKeyCode:andFlagsTaken:reason:)])
		return [delegate shortcutRecorder:self isKeyCode:keyCode andFlagsTaken:flags reason:aReason];
	else
		return NO;
}

#define NilOrNull(o) ((o) == nil || (id)(o) == [NSNull null])

- (void)shortcutRecorderCell:(RispKBRecorderCell *)aRecorderCell keyComboDidChange:(KeyCombo)newKeyCombo
{
	if (delegate != nil && [delegate respondsToSelector: @selector(shortcutRecorder:keyComboDidChange:)])
		[delegate shortcutRecorder:self keyComboDidChange:newKeyCombo];

    // propagate view changes to binding (see http://www.tomdalling.com/cocoa/implementing-your-own-cocoa-bindings)
    NSDictionary *bindingInfo = [self infoForBinding:@"value"];
	if (!bindingInfo)
		return;

	// apply the value transformer, if one has been set
    NSDictionary *value = [self objectValue];
	NSDictionary *bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
	if (bindingOptions != nil) {
		NSValueTransformer *transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
		if (NilOrNull(transformer)) {
			NSString *transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
			if (!NilOrNull(transformerName))
				transformer = [NSValueTransformer valueTransformerForName:transformerName];
		}

		if (!NilOrNull(transformer)) {
			if ([[transformer class] allowsReverseTransformation])
				value = [transformer reverseTransformedValue:value];
			else
				NSLog(@"WARNING: value has value transformer, but it doesn't allow reverse transformations in %s", __PRETTY_FUNCTION__);
		}
	}

	id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
	if (NilOrNull(boundObject)) {
		NSLog(@"ERROR: NSObservedObjectKey was nil for value binding in %s", __PRETTY_FUNCTION__);
		return;
	}
    
	NSString *boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
    if (NilOrNull(boundKeyPath)) {
		NSLog(@"ERROR: NSObservedKeyPathKey was nil for value binding in %s", __PRETTY_FUNCTION__);
		return;
	}

	[boundObject setValue:value forKeyPath:boundKeyPath];
}

@end

@implementation RispKBRecorderControl (Private)

- (void)resetTrackingRects
{
	[RispKBCell resetTrackingRects];
}

@end
