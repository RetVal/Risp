//
//  RispRenderFoundationSyntaxColouringDelegate.h
//  Fragaria
//
//  Created by Jonathan on 14/04/2013.
//
//

#import <Foundation/Foundation.h>

// syntax colouring information dictionary keys
extern NSString *RispRenderFoundationSyntaxGroup;
extern NSString *RispRenderFoundationSyntaxGroupID;
extern NSString *RispRenderFoundationSyntaxWillColour;
extern NSString *RispRenderFoundationSyntaxAttributes;
extern NSString *RispRenderFoundationSyntaxInfo;

// syntax colouring group names
extern NSString *RispRenderFoundationSyntaxGroupNumber;
extern NSString *RispRenderFoundationSyntaxGroupCommand;
extern NSString *RispRenderFoundationSyntaxGroupInstruction;
extern NSString *RispRenderFoundationSyntaxGroupKeyword;
extern NSString *RispRenderFoundationSyntaxGroupAutoComplete;
extern NSString *RispRenderFoundationSyntaxGroupVariable;
extern NSString *RispRenderFoundationSyntaxGroupFirstString;
extern NSString *RispRenderFoundationSyntaxGroupSecondString;
extern NSString *RispRenderFoundationSyntaxGroupAttribute;
extern NSString *RispRenderFoundationSyntaxGroupSingleLineComment;
extern NSString *RispRenderFoundationSyntaxGroupMultiLineComment;
extern NSString *RispRenderFoundationSyntaxGroupSecondStringPass2;

// syntax colouring group IDs
enum {
    kRRFSyntaxGroupNumber = 0,
    kRRFSyntaxGroupCommand = 1,
    kRRFSyntaxGroupInstruction = 2,
    kRRFSyntaxGroupKeyword = 3,
    kRRFSyntaxGroupAutoComplete = 4,
    kRRFSyntaxGroupVariable = 5,
    kRRFSyntaxGroupSecondString = 6,
    kRRFSyntaxGroupFirstString = 7,
    kRRFSyntaxGroupAttribute = 8,
    kRRFSyntaxGroupSingleLineComment = 9,
    kRRFSyntaxGroupMultiLineComment = 10,
    kRRFSyntaxGroupSecondStringPass2 = 11
};
typedef NSInteger RispRenderFoundationSyntaxGroupInteger;

@protocol RispRenderFoundationSyntaxColouringDelegate <NSObject>

/*
 
 Use these methods to partially customise or overridde the syntax colouring.
 
 Arguments used in the delegate methods
 ======================================
 
 document: Fragaria document spec
 block: block to colour string. the arguments are a colour info dictionary and the range to be coloured
 string: document string. This is supplied as a convenience. The string can also be retrieved from the document.
 range: range of string to colour.
 info: an information dictionary
 
 Info dictionary keys 
 ======================
 
 RispRenderFoundationSyntaxGroup: NSString describing the group being coloured.
 RispRenderFoundationSyntaxGroupID:  NSNumber identyfying the group being coloured.
 RispRenderFoundationSyntaxWillColour: NSNumber containing a BOOL indicating whether the caller will colour the string.
 RispRenderFoundationSyntaxAttributes: NSDictionary of NSAttributed string attributes used to colour the string.
 RispRenderFoundationSyntaxInfo: NSDictionary containing Fragaria syntax definition.
 
 Syntax Info dictionary keys
 ===========================
 
 For key values see RispRenderFoundationSyntaxDefinition.h
 
 Delegate calling
 ================
 
 The delegate will receive messages in the following sequence:
 
 // query delegate if should colour this document
 doColouring = document:shouldColourWithBlock:string:range:info
 if !doColouring quit colouring
 
 // send *ColourGroupWithBlock methods for each group defined by RispRenderFoundationSyntaxGroupInteger
 foreach group
 
    // query delegate if should colour this group
    doColouring = document:shouldColourGroupWithBlock:string:range:info

    if doColouring
 
        colour the group
 
        // inform delegate group was coloured
        document:didColourGroupWithBlock:string:range:info
 
    end if
 end
 
 // inform delegate document was coloured
 document:willDidWithBlock:string:range:info
 
 Colouring the string
 ====================
 
 Each delegate method includes a block that can can be called with a dictionary of attributes and a range to affect colouring.
 
 */
- (BOOL)document:(id)document shouldColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (BOOL)document:(id)document shouldColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)document:(id)document didColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)document:(id)document didColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
@end
