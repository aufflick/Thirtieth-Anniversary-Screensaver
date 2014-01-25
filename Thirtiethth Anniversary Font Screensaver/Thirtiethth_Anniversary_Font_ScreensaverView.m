//
//  Thirtiethth_Anniversary_Font_ScreensaverView.m
//  Thirtiethth Anniversary Font Screensaver
//
//  Created by Mark Aufflick on 25/01/2014.
//  Copyright (c) 2014 The High Technology Group. All rights reserved.
//

#import "Thirtiethth_Anniversary_Font_ScreensaverView.h"
#import <QuartzCore/QuartzCore.h>

@interface Thirtiethth_Anniversary_Font_ScreensaverView ()

@property (nonatomic, strong) CATextLayer * textLayer;
@property (nonatomic) CGSize textLayerSize;

- (CGPoint)randomOrigin;
- (void)changeCharacter;

@end

@implementation Thirtiethth_Anniversary_Font_ScreensaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview]) == nil)
        return self;
    
    self.wantsLayer = YES;
    self.textLayer = [CATextLayer layer];
    self.fontSizeDivisor = 8;

    self.textLayer.foregroundColor = [[NSColor blackColor] CGColor]; // setting?
    
    [self.layer addSublayer:self.textLayer];

    return self;
}

- (void)setFontSizeDivisor:(CGFloat)fontSizeDivisor
{
    _fontSizeDivisor = fontSizeDivisor;
    
    self.textLayerSize = (CGSize){ self.bounds.size.width / self.fontSizeDivisor, self.bounds.size.height / self.fontSizeDivisor };
}

- (void)startAnimation
{
    [super startAnimation];
    
    NSNumber * prevActionDisable = [CATransaction valueForKey:kCATransactionDisableActions];
    
    [CATransaction begin];
    [CATransaction setValue:@YES
                     forKey:kCATransactionDisableActions];

    self.textLayer.frame = (CGRect){ [self randomOrigin], self.textLayerSize };
    
    [CATransaction commit];
    [CATransaction setValue:prevActionDisable forKey:kCATransactionDisableActions];

    [self changeCharacter];
}

- (void)changeCharacter
{
    NSString * character = @"A";

    //TODO: want a setting to adjust cross-fade time
    self.textLayer.string = character;
}
    
- (CGPoint)randomOrigin
{
    return (CGPoint){ 0, 0 };
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    CGRect bounds = [self bounds];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetFillColorWithColor(ctx, [[NSColor whiteColor] CGColor]);
    CGContextFillRect(ctx, bounds);
}

- (void)animateOneFrame
{
    // smoothly move layer and swap character every so often (setting)
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
