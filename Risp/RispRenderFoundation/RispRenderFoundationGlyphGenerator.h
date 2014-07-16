//
//  RispRenderFoundationGlyphGenerator.h
//  Fragaria
//
//  Created by Jonathan on 23/09/2012.
//
//

#import <Cocoa/Cocoa.h>

@interface RispRenderFoundationGlyphGenerator : NSGlyphGenerator <NSGlyphStorage> {
    id <NSGlyphStorage> _destination;
}

@end
