//
//  Thirtiethth_Anniversary_Font_ScreensaverView.m
//  Thirtiethth Anniversary Font Screensaver
//
//  Created by Mark Aufflick on 25/01/2014.
//  Copyright (c) 2014 The High Technology Group. All rights reserved.
//

#import "Thirtiethth_Anniversary_Font_ScreensaverView.h"
#import <QuartzCore/QuartzCore.h>

NSString * characters = @"";

@interface Thirtiethth_Anniversary_Font_ScreensaverView ()

@property (nonatomic, strong) CATextLayer * textLayer;
@property (nonatomic) CGFontRef fontRef;

- (CGPoint)randomOrigin;
- (void)changeCharacter;
- (CGSize)boundingSizeForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString;


@end

@implementation Thirtiethth_Anniversary_Font_ScreensaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if ((self = [super initWithFrame:frame isPreview:isPreview]) == nil)
        return self;
    
    self.fontRef = [self fontFromBundle:@"mac-icon-standard"];
    
    self.wantsLayer = YES;
    self.textLayer = [CATextLayer layer];
    self.textLayer.font = self.fontRef;
    [self.layer addSublayer:self.textLayer];

    self.fontSize = @(128);
    self.foregroundColour = [NSColor blackColor];
    self.backgroundColour = [NSColor whiteColor];

    return self;
}

- (void)dealloc
{
    CGFontRelease(_fontRef);
}

- (void)setForegroundColour:(NSColor *)foregroundColour
{
    _foregroundColour = foregroundColour;
    self.textLayer.foregroundColor = [foregroundColour CGColor];
}

- (void)setFontSize:(NSNumber *)fontSize
{
    _fontSize = fontSize;
    self.textLayer.fontSize = [fontSize doubleValue];
}

- (void)startAnimation
{
    [super startAnimation];
    
    NSNumber * prevActionDisable = [CATransaction valueForKey:kCATransactionDisableActions];
    
    /*[CATransaction begin];
    [CATransaction setValue:@YES
                     forKey:kCATransactionDisableActions];

    [CATransaction commit];
    [CATransaction setValue:prevActionDisable forKey:kCATransactionDisableActions];*/

    [self changeCharacter];
}

- (void)changeCharacter
{
    NSString * characterString = [characters substringWithRange:NSMakeRange(0, 1)];
    self.textLayer.string = characterString;
    
    CTFontRef fontCore = CTFontCreateWithGraphicsFont(self.fontRef, [self.fontSize doubleValue], NULL, NULL);

    NSMutableAttributedString * attributedCharacterString = [[NSMutableAttributedString alloc] initWithString:characterString
                                                                                                   attributes:@{(__bridge id)kCTForegroundColorAttributeName: (__bridge id)[self.foregroundColour CGColor],
                                                                                                                (__bridge id)kCTFontAttributeName: (__bridge id)fontCore,
                                                                                                                (__bridge id)kCTFontSizeAttribute: self.fontSize}];
    
    CGRect frame = (CGRect){ [self randomOrigin], [self boundingSizeForWidth:self.bounds.size.width withAttributedString:attributedCharacterString] };
    
    CFRelease(fontCore);
    self.textLayer.frame = frame;
}

- (CGSize)boundingSizeForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) attributedString);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(inWidth, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    return suggestedSize;
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
    
    CGContextSetFillColorWithColor(ctx, [self.backgroundColour CGColor]);
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


