//
//  RSMorphingLabel.h
//  RSMorphingLabel
//
//  Created by closure on 7/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSMorphingLabel : UILabel
@property (nonatomic, assign) CGFloat morphingProgress;
@property (nonatomic, assign) CGFloat morphingDuration;
@property (nonatomic, assign) CGFloat morphingCharacterDelay;

- (void)setText:(NSString *)text;
@end
