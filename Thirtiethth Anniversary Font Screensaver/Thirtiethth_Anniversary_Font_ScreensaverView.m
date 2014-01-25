//
//  Thirtiethth_Anniversary_Font_ScreensaverView.m
//  Thirtiethth Anniversary Font Screensaver
//
//  Created by Mark Aufflick on 25/01/2014.
//  Copyright (c) 2014 The High Technology Group. All rights reserved.
//

#import "Thirtiethth_Anniversary_Font_ScreensaverView.h"
#import <QuartzCore/QuartzCore.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

NSString * characters = @"";

@interface Thirtiethth_Anniversary_Font_ScreensaverView ()
{
    NSArray * charactersArray;
    NSInteger maxCharacterIndex;
    NSTimer * moveTimer;
    CATextLayer * currentLayer;
    CGSize maxSize;
    NSInteger currentIndex;
}

@property (nonatomic, strong) CATextLayer * textLayer1;
@property (nonatomic, strong) CATextLayer * textLayer2;
@property (nonatomic) CGFontRef fontRef;

- (CGPoint)randomPoint;
- (CGSize)boundingSizeForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString;


@end

@implementation Thirtiethth_Anniversary_Font_ScreensaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview]) == nil)
        return self;
    
    maxCharacterIndex = [characters length] - 1;
    
    self.fontRef = [self fontFromBundle:@"mac-icon-standard"];
    
    self.wantsLayer = YES;
    self.textLayer1 = [self aTextLayer];
    self.textLayer2 = [self aTextLayer];

    self.foregroundColour = [NSColor blackColor];
    self.backgroundColour = [NSColor whiteColor];
    self.fontSize = @128;
    self.swapTimeInterval = @3;
    self.fadeTimeInterval = @1;

    return self;
}

- (void)dealloc
{
    CGFontRelease(_fontRef);
}

- (CATextLayer *)aTextLayer
{
    CATextLayer * layer = [CATextLayer layer];
    layer.font = self.fontRef;
    layer.anchorPoint = (CGPoint){ 0, 0 };
    [self.layer addSublayer:layer];
    return layer;
}

- (void)setForegroundColour:(NSColor *)foregroundColour
{
    _foregroundColour = foregroundColour;
    self.textLayer1.foregroundColor = [foregroundColour CGColor];
    self.textLayer2.foregroundColor = [foregroundColour CGColor];
}

- (void)setFontSize:(NSNumber *)fontSize
{
    _fontSize = fontSize;
    
    CTFontRef fontCore = CTFontCreateWithGraphicsFont(self.fontRef, [self.fontSize doubleValue], NULL, NULL);

    maxSize = CGSizeZero;
    
    for (NSInteger i=0; i <= maxCharacterIndex; i++)
    {
        NSMutableAttributedString * attributedCharacterString = [[NSMutableAttributedString alloc] initWithString:[characters substringWithRange:NSMakeRange(i, 1)]
                                                                                                       attributes:@{(__bridge id)kCTForegroundColorAttributeName: (__bridge id)[self.foregroundColour CGColor],
                                                                                                                    (__bridge id)kCTFontAttributeName: (__bridge id)fontCore,
                                                                                                                    (__bridge id)kCTFontSizeAttribute: fontSize}];
        
        CGSize size = [self boundingSizeForWidth:self.bounds.size.width withAttributedString:attributedCharacterString];
        maxSize.width = MAX(maxSize.width, size.width);
        maxSize.height = MAX(maxSize.height, size.height);
    }
    
    CFRelease(fontCore);
    
    self.textLayer1.fontSize = [fontSize doubleValue];
    self.textLayer2.fontSize = [fontSize doubleValue];
    self.textLayer1.bounds = (CGRect){ CGPointZero, maxSize };
    self.textLayer2.bounds = (CGRect){ CGPointZero, maxSize };
}

- (void)startAnimation
{
    srand((unsigned int)time(0));
    
    currentLayer = self.textLayer1;
    [self changeCharacterInLayer:self.textLayer1];

    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    self.textLayer1.opacity = 0;
    self.textLayer2.opacity = 0;
    currentLayer.position = [self randomPoint];
    [CATransaction commit];
    
    [super startAnimation];

    //TODO: animate initial fade in
    self.textLayer1.opacity = 1;

    moveTimer = [NSTimer scheduledTimerWithTimeInterval:[self.swapTimeInterval doubleValue] target:self selector:@selector(swapLayers) userInfo:nil repeats:YES];
}

- (void)swapLayers
{
    CATextLayer * prevLayer = currentLayer;
    CATextLayer * nextLayer = currentLayer == self.textLayer1 ? self.textLayer2 : self.textLayer1;

    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];

    [self changeCharacterInLayer:nextLayer];
    nextLayer.position = [self randomPoint];
    
    while (CGRectIntersectsRect(nextLayer.frame, prevLayer.frame))
        nextLayer.position = [self randomPoint];
    
    [CATransaction commit];
    
    prevLayer.opacity = 0;
    nextLayer.opacity = 1;
    
    [prevLayer removeAllAnimations];
    [nextLayer removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:[self.fadeTimeInterval doubleValue]];
    
    CABasicAnimation * fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @1;
    fadeOut.toValue = @0;
    //fadeOut.removedOnCompletion = NO;
    [prevLayer addAnimation:fadeOut forKey:@"SwapLayersAnimation"];
    
    CABasicAnimation * fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @0;
    fadeIn.toValue = @1;
    //fadeIn.removedOnCompletion = NO;
    [nextLayer addAnimation:fadeIn forKey:@"SwapLayersAnimation"];

    //todo: customise timing
    [CATransaction commit];
    
    currentLayer = nextLayer;
}

- (NSInteger)randomIndex
{
    NSInteger index = round((rand() * maxCharacterIndex) / RAND_MAX);
    NSAssert(index <= maxCharacterIndex, @"oops");
    if (index == maxCharacterIndex)
        NSLog(@"*** HIT INDEX!");

    return index;
}

- (void)changeCharacterInLayer:(CATextLayer *)textLayer
{
    NSInteger index = currentIndex;
    while (index == currentIndex)
        index = [self randomIndex];

    NSString * characterString = [characters substringWithRange:NSMakeRange(index, 1)];
    textLayer.string = characterString;
}

- (CGSize)boundingSizeForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) attributedString);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(inWidth, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);

    return (CGSize){ suggestedSize.width + 5, suggestedSize.height + 5 }; // we don't care too much here, and definitely don't want to clip
}

    
- (CGPoint)randomPoint
{
    CGRect bounds = self.bounds;
    
    NSInteger xRange = floor(bounds.size.width - maxSize.width);
    NSInteger yRange = floor(bounds.size.height - maxSize.height);
    
    return (CGPoint){ floor((rand() * xRange) / RAND_MAX), floor((rand() * yRange) / RAND_MAX) };
}

- (void)stopAnimation
{
    [moveTimer invalidate];
    moveTimer = nil;
    
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    CGRect bounds = [self bounds];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetFillColorWithColor(ctx, [self.backgroundColour CGColor]);
    CGContextFillRect(ctx, bounds);
}

- (void)animateOneFrame
{
    
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (CGFontRef)fontFromBundle : (NSString*) fontName
{
    // Get the path to our custom font and create a data provider.
    NSString* fontPath = [[NSBundle bundleForClass:[self class]] pathForResource:fontName ofType:@"ttf" ];
    if (nil==fontPath)
        return NULL;
    
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithFilename ([fontPath UTF8String]);
    if (NULL==dataProvider)
        return NULL;
    
    // Create the font with the data provider, then release the data provider.
    CGFontRef fontRef = CGFontCreateWithDataProvider ( dataProvider );
    if ( NULL == fontRef )
    {
        CGDataProviderRelease ( dataProvider );
        return NULL;
    }
    
    return fontRef;
}


@end


