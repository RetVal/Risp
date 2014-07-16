/*
 *  RispRenderFoundation.h
 *  Fragaria
 *
 *  Created by Jonathan on 30/04/2010.
 *  Copyright 2010 mugginsoft.com. All rights reserved.
 *
 */

// valid keys for 
// - (void)setObject:(id)object forKey:(id)key;
// - (id)objectForKey:(id)key;

// BOOL
extern NSString * const RispRenderFoundationFOIsSyntaxColoured;
extern NSString * const RispRenderFoundationFOShowLineNumberGutter;
extern NSString * const RispRenderFoundationFOIsEdited;

// string
extern NSString * const RispRenderFoundationFOSyntaxDefinitionName;
extern NSString * const RispRenderFoundationFODocumentName;

// integer
extern NSString * const RispRenderFoundationFOGutterWidth;

// NSView *
extern NSString * const ro_MGSFOTextView; // readonly
extern NSString * const ro_MGSFOScrollView; // readonly
extern NSString * const ro_MGSFOGutterScrollView; // readonly

// NSObject
extern NSString * const RispRenderFoundationFODelegate;
extern NSString * const RispRenderFoundationFOBreakpointDelegate;
extern NSString * const RispRenderFoundationFOAutoCompleteDelegate;
extern NSString * const RispRenderFoundationFOSyntaxColouringDelegate;
extern NSString * const ro_MGSFOLineNumbers; // readonly
extern NSString * const ro_MGSFOSyntaxColouring; // readonly

@class RispRenderFoundationTextMenuController;
@class RispRenderFoundationExtraInterfaceController;

#import <RispRenderFoundation/RispRenderFoundationPreferences.h>
#import <RispRenderFoundation/RispRenderFoundationBreakpointDelegate.h>
#import <RispRenderFoundation/RispRenderFoundationSyntaxError.h>
#import <RispRenderFoundation/RispRenderFoundationSyntaxColouringDelegate.h>
#import <RispRenderFoundation/RispRenderFoundationSyntaxDefinition.h>
#import <RispRenderFoundation/RispRenderFoundationTextView.h>
#import <RispRenderFoundation/RispRenderFoundationSyntaxColouring.h>

@interface RispRenderFoundation : NSObject
{
	@private
	RispRenderFoundationExtraInterfaceController *extraInterfaceController;
    id docSpec;
    NSSet* objectGetterKeys;
    NSSet* objectSetterKeys;
}

@property (nonatomic, readonly, strong) RispRenderFoundationExtraInterfaceController *extraInterfaceController;
@property (nonatomic, retain) IBOutlet id docSpec;

// class methods
+ (id)currentInstance;
+ (void)setCurrentInstance:(RispRenderFoundation *)anInstance;
+ (void)initializeFramework;
+ (id)createDocSpec;
+ (void)docSpec:(id)docSpec setString:(NSString *)string;
+ (void)docSpec:(id)docSpec setString:(NSString *)string options:(NSDictionary *)options;
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string;
+ (void)docSpec:(id)docSpec setAttributedString:(NSAttributedString *)string options:(NSDictionary *)options;
+ (NSString *)stringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringForDocSpec:(id)docSpec;
+ (NSAttributedString *)attributedStringWithTemporaryAttributesAppliedForDocSpec:(id)docSpec;

// instance methods
- (id)initWithObject:(id)object;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)embedInView:(NSView *)view;
- (void)setString:(NSString *)aString;
- (void)setString:(NSString *)aString options:(NSDictionary *)options;
- (void)setAttributedString:(NSAttributedString *)aString;
- (void)setAttributedString:(NSAttributedString *)aString options:(NSDictionary *)options;
- (NSAttributedString *)attributedString;
- (NSAttributedString *)attributedStringWithTemporaryAttributesApplied;
- (NSString *)string;
- (NSTextView *)textView;
- (RispRenderFoundationTextMenuController *)textMenuController;
- (void)setSyntaxColoured:(BOOL)value;
- (BOOL)isSyntaxColoured;
- (void)setShowsLineNumbers:(BOOL)value;
- (BOOL)showsLineNumbers;
- (void)reloadString;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)text options:(NSDictionary *)options;
- (void)setSyntaxErrors:(NSArray *)errors;
- (NSArray *)syntaxErrors;
+ (NSImage *)imageNamed:(NSString *)name;

@end
