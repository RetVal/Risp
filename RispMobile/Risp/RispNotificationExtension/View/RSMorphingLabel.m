//
//  RSMorphingLabel.m
//  RSMorphingLabel
//
//  Created by closure on 7/20/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RSMorphingLabel.h"

typedef enum : NSUInteger {
    __RSMoriphingCharacterDiffSameType = 0,
    __RSMoriphingCharacterDiffAddType = 1,
    __RSMoriphingCharacterDiffDeleteType,
    __RSMoriphingCharacterDiffMoveType,
    __RSMoriphingCharacterDiffMoveAndAddType,
    __RSMoriphingCharacterDiffReplaceType
} __RSMoriphingCharacterDiffType;

@interface __RSMoriphingCharacterLimbo : NSObject
@property (nonatomic, assign) unichar character;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat size;
@end

@implementation __RSMoriphingCharacterLimbo

- (instancetype)initWithChar:(unichar)character rect:(CGRect)rect alpha:(CGFloat)alpha size:(CGFloat)size {
    if (self = [super init]) {
        _character = character;
        _rect = rect;
        _alpha = alpha;
        _size = size;
    }
    return self;
}

@end

@interface __RSMoriphingCharacterDiffResult : NSObject
@property (nonatomic, assign) __RSMoriphingCharacterDiffType diffType;
@property (nonatomic, assign) NSInteger moveOffset;
@property (nonatomic, assign, getter=isSkip) BOOL skip;

- (instancetype)initWithType:(__RSMoriphingCharacterDiffType)type moveOffset:(NSInteger)moveOffset isSkip:(BOOL)skip;
+ (instancetype)resultWithType:(__RSMoriphingCharacterDiffType)type moveOffset:(NSInteger)moveOffset isSkip:(BOOL)skip;
@end

@interface NSString (CharacterDiff)
- (NSArray *)__diffWithString:(NSString *)str;
@end

@interface RSMorphingLabel()
@property (nonatomic, strong) NSArray *_diffResults; // __RSMoriphingCharacterDiffResult
@property (nonatomic, strong) NSString *_originText;
@property (nonatomic, assign) NSUInteger _currentFrame;
@property (nonatomic, assign) NSUInteger _totalFrames;
@property (nonatomic, assign) CGFloat _totalWidth;
@property (nonatomic, assign) CGFloat _characterOffsetYRatio;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation RSMorphingLabel
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _morphingProgress = 0.0f;
        _morphingDuration = 0.36f;
        _morphingCharacterDelay = 0.03f;
        __diffResults = [[NSMutableArray alloc] init];
        __originText = @"";
        __currentFrame = 0;
        __totalFrames = 0;
        __totalWidth = 0.0f;
        __characterOffsetYRatio = 1.1f;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayFrameTick)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setText:(NSString *)text {
    __originText = [self text];
    __diffResults = [__originText __diffWithString:text];
    [super setText:text];
    _morphingProgress = 0.0f;
    __currentFrame = 0;
    [_displayLink setPaused:NO];
}

- (NSString *)text {
    return [super text];
}

- (void)_displayFrameTick {
    NSString *s = [self text];
    CGFloat totalDelay = ([s length] + [__originText length]) * _morphingCharacterDelay;
    NSInteger framesForCharacterDelay = ceilf(totalDelay);
    if ([_displayLink duration] > 0.0) {
        __totalFrames = (NSUInteger)roundf((_morphingDuration + totalDelay) / [_displayLink duration]);
    }
    if (__currentFrame++ < __totalFrames) {
        _morphingProgress += 1.0 / (CGFloat)__totalFrames;
        [self setNeedsDisplay];
    } else {
        [_displayLink setPaused:YES];
    }
}

- (CGFloat)easeOutQuintWithTime:(CGFloat)currentTime beginning:(CGFloat)beginning change:(CGFloat)change duration:(CGFloat)duration {
    CGFloat x = (^CGFloat(CGFloat x) {
        return change * (x * x * x * x * x + 1.0) + beginning;
    })(currentTime / duration - 1.0);
    return x;
}

- (NSArray *)rectsOfEachCharacter:(NSString *)textToDraw {
    NSMutableArray *charRects = [[NSMutableArray alloc] init];
    CGFloat leftOffset = 0.0f;
    NSInteger length = [textToDraw length];
    for (NSInteger i = 0; i < length; i++) {
        unichar character = [textToDraw characterAtIndex:i];
        CGSize charSize = [[NSString stringWithFormat:@"%c", character] sizeWithFont:[self font]];
        [charRects addObject:[NSValue valueWithCGRect:CGRectMake(leftOffset, 0, charSize.width, charSize.height)]];
        leftOffset += charSize.width;
    }
    
    __totalWidth = leftOffset;
    CGFloat stringLeftOffset = 0.0;
    switch ([self textAlignment]) {
        case NSTextAlignmentCenter:
            stringLeftOffset = (self.bounds.size.width - __totalWidth) / 2.0;
            break;
        case NSTextAlignmentRight:
            stringLeftOffset = (self.bounds.size.width - __totalWidth);
            break;
        default:
            break;
    }
    
    NSMutableArray *offsetedCharRects = [[NSMutableArray alloc] init];
    for (NSValue *r in charRects) {
        [offsetedCharRects addObject:[NSValue valueWithCGRect:CGRectOffset(r.CGRectValue, stringLeftOffset, 0.0f)]];
    }
    return offsetedCharRects;
}

- (NSArray *)limboOfCharacters {
    CGFloat fontSize = [[self font] pointSize];
    NSMutableArray *limbo = [[NSMutableArray alloc] init];
    NSArray *originRects = [self rectsOfEachCharacter:__originText];
    NSArray *newRects = [self rectsOfEachCharacter:[self text]];
    CGFloat targetLeftOffset = 0.0f;
    NSInteger length = [__originText length];
    for (NSUInteger i = 0; i < length; i++) {
        unichar character = [__originText characterAtIndex:i];
        
        CGRect currentRect = [originRects[i] CGRectValue];
        CGFloat currentAlpha = 1.0;
        CGFloat currentFontSize = [[self font] pointSize];
        CGFloat progress = MIN(1.0, MAX(0.0, _morphingProgress + _morphingCharacterDelay * i));
        __RSMoriphingCharacterDiffResult *diffResult = __diffResults[i];
        
        CGRect originRect = [originRects[i] CGRectValue];
        CGFloat oriX = originRect.origin.x;
        CGFloat newX = 0.0f;
        CGFloat currentX = 0.0f;
        switch ([diffResult diffType]) {
            case __RSMoriphingCharacterDiffMoveType:
            case __RSMoriphingCharacterDiffMoveAndAddType:
                newX = [newRects[i + [diffResult moveOffset]] CGRectValue].origin.x;
                currentX = [self easeOutQuintWithTime:progress beginning:oriX change:newX - oriX duration:1.0];
                currentRect.origin.x = currentX;
                break;
            case __RSMoriphingCharacterDiffSameType:
                oriX = currentRect.origin.x;
                newX = [newRects[i] CGRectValue].origin.x;
                currentX = [self easeOutQuintWithTime:progress beginning:oriX change:newX - oriX duration:1.0];
                currentRect.origin.x = currentX;
                break;
            default:
                currentFontSize = fontSize - [self easeOutQuintWithTime:progress beginning:0 change:fontSize duration:1.0];
                currentRect = [originRects[i] CGRectValue];
                currentAlpha = 1.0 - progress;
                break;
        }
        currentRect.origin.y += (fontSize - currentFontSize) / __characterOffsetYRatio;
        [limbo addObject:[[__RSMoriphingCharacterLimbo alloc] initWithChar:character rect:currentRect alpha:currentAlpha size:currentFontSize]];
    }
    
    length = [[self text] length];
    for (NSUInteger i = 0; i < length; i++) {
        unichar character = [[self text] characterAtIndex:i];
        if (i >= [__diffResults count]) {
            break;
        }
        CGFloat progress = MIN(1.0, MAX(0.0, _morphingProgress - _morphingCharacterDelay * i));
        CGRect currentRect = [newRects[i] CGRectValue];
        CGFloat currentAlpha = 1.0f;
        CGFloat currentFontSize = [[self font] pointSize];
        __RSMoriphingCharacterDiffResult *diffResult = __diffResults[i];
        if ([diffResult isSkip]) {
            continue;
        }
        switch ([diffResult diffType]) {
            case __RSMoriphingCharacterDiffAddType:
            case __RSMoriphingCharacterDiffDeleteType:
            case __RSMoriphingCharacterDiffMoveAndAddType:
            case __RSMoriphingCharacterDiffReplaceType:
                currentFontSize = [self easeOutQuintWithTime:progress beginning:0 change:fontSize duration:1.0];
                currentRect.origin.y += (fontSize - currentFontSize) / __characterOffsetYRatio;
                currentAlpha = _morphingProgress;
                [limbo addObject:[[__RSMoriphingCharacterLimbo alloc] initWithChar:character rect:currentRect alpha:currentAlpha size:currentFontSize]];
                break;
            default:
                break;
        }
    }
    return limbo;
}

- (void)didMoveToSuperview {
    NSString *s = [self text];
    [self setText:s];
}

- (void)drawTextInRect:(CGRect)rect {
    NSArray *limbos = [self limboOfCharacters];
    [limbos count];
    
    [limbos enumerateObjectsUsingBlock:^(__RSMoriphingCharacterLimbo *charLimbo, NSUInteger idx, BOOL *stop) {
        [[[self textColor] colorWithAlphaComponent:[charLimbo alpha]] setFill];
        NSString *s = [NSString stringWithFormat:@"%c", [charLimbo character]];
        [s drawInRect:[charLimbo rect] withFont:[[self font] fontWithSize:[charLimbo size]] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }];
}

@end

@implementation __RSMoriphingCharacterDiffResult

- (instancetype)initWithType:(__RSMoriphingCharacterDiffType)type moveOffset:(NSInteger)moveOffset isSkip:(BOOL)skip {
    if (self = [super init]) {
        _diffType = type;
        _moveOffset = moveOffset;
        _skip = skip;
    }
    return self;
}

+ (instancetype)resultWithType:(__RSMoriphingCharacterDiffType)type moveOffset:(NSInteger)moveOffset isSkip:(BOOL)skip {
    return [[self alloc] initWithType:type moveOffset:moveOffset isSkip:skip];
}

- (NSString *)description {
    switch (_diffType) {
        case __RSMoriphingCharacterDiffSameType:
            return @"The character is unchanged.";
        case __RSMoriphingCharacterDiffAddType:
            return @"A new character is ADDED.";
        case __RSMoriphingCharacterDiffDeleteType:
            return @"The character is DELETED.";
        case __RSMoriphingCharacterDiffMoveType:
            return [NSString stringWithFormat:@"The character is MOVED to %ld.", _moveOffset];
        case __RSMoriphingCharacterDiffMoveAndAddType:
            return [NSString stringWithFormat:@"The character is MOVED to %ld and a new character is ADDED.", _moveOffset];
        default:
            return @"The character is REPLACED with a new character.";
    }
    return @"";
}
@end


@implementation NSString (CharacterDiff)

- (NSArray *)__diffWithString:(NSString *)rhs {
    NSString *lhs = self;
    NSMutableArray *diffResults = [[NSMutableArray alloc] init];
    const NSUInteger lhsLenght = [lhs length];
    const NSUInteger rhsLenght = [rhs length];
    
    NSMutableArray *skipIndexes = [[NSMutableArray alloc] init]; // NSNumber
    const NSUInteger cnt = MAX(lhsLenght, rhsLenght) + 1;
    for (NSUInteger i = 0; i < cnt; i++) {
        __RSMoriphingCharacterDiffResult *result = [[__RSMoriphingCharacterDiffResult alloc] initWithType:__RSMoriphingCharacterDiffAddType moveOffset:0 isSkip:NO];
        if (i > lhsLenght - 1) {
            [result setDiffType:__RSMoriphingCharacterDiffAddType];
            [diffResults addObject:result];
            continue;
        }
        unichar leftChar = (^unichar (NSString *str) {
            NSUInteger length = [str length];
            for (NSUInteger j = 0; j < length; j++) {
                unichar character = [str characterAtIndex:j];
                if (i == j) {
                    return character;
                }
            }
            return (unichar)0;
        })(lhs);
        
        BOOL foundCharacterInRhs = NO;
        NSUInteger length = [rhs length];
        for (NSUInteger j = 0; j < length; j++) {
            unichar newChar = [rhs characterAtIndex:j];
            BOOL currentCharWouldBeReplaced = (^BOOL(NSInteger index){
                __block BOOL result = NO;
                [skipIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj integerValue] == index) {
                        result = YES;
                        *stop = YES;
                    }
                }];
                return result;
            })(j);
            if (currentCharWouldBeReplaced) {
                continue;
            }
            
            if (leftChar == newChar) {
                [skipIndexes addObject:[NSNumber numberWithInteger:j]];
                foundCharacterInRhs = YES;
                if (i == j) {
                    [result setDiffType:__RSMoriphingCharacterDiffSameType];
                } else {
                    [result setDiffType:__RSMoriphingCharacterDiffMoveType];
                    if (i <= rhsLenght - 1) {
                        [result setDiffType:__RSMoriphingCharacterDiffMoveAndAddType];
                    }
                    [result setMoveOffset: j - i];
                }
                break;
            }
        }
        
        if (!foundCharacterInRhs) {
            if (i < rhsLenght - 1) {
                [result setDiffType:__RSMoriphingCharacterDiffReplaceType];
            } else {
                [result setDiffType:__RSMoriphingCharacterDiffDeleteType];
            }
        }
        
        if (i > lhsLenght - 1) {
            [result setDiffType:__RSMoriphingCharacterDiffAddType];
        }
        [diffResults addObject:result];
    }
    
    [diffResults enumerateObjectsUsingBlock:^(__RSMoriphingCharacterDiffResult *obj, NSUInteger idx, BOOL *stop) {
        switch ([obj diffType]) {
            case __RSMoriphingCharacterDiffMoveType:
            case __RSMoriphingCharacterDiffMoveAndAddType:
                [diffResults[idx + [obj moveOffset]] setSkip:YES];
                break;
            default:
                break;
        }
    }];
    return diffResults;
}

@end