//
//  RispRenderFoundationTextEditingPrefsViewController.h
//  Fragaria
//
//  Created by Jonathan on 14/09/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "RispRenderFoundationPrefsViewController.h"

@interface RispRenderFoundationTextEditingPrefsViewController : RispRenderFoundationPrefsViewController {
    NSImage *toolbarImage;
}

- (IBAction)changeGutterWidth:(id)sender;
@end
