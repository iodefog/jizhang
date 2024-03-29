//
//  SSJRecordMakingBillTypeSelectionCellLabel.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/5/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeSelectionCellLabel.h"

@implementation SSJRecordMakingBillTypeSelectionCellLabel

+ (Class)layerClass {
    return [CATextLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentLeft;
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor blueColor];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_text sizeWithAttributes:@{NSFontAttributeName:_font}];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    self.textLayer.font = CGFontCreateWithFontName(fontName);
    self.textLayer.fontSize = font.pointSize;
}

- (CATextLayer *)textLayer {
    return (CATextLayer *)self.layer;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    CATextLayer *layer = (CATextLayer *)self.layer;
    switch (_textAlignment) {
        case NSTextAlignmentLeft:
            layer.alignmentMode = kCAAlignmentLeft;
            break;
        case NSTextAlignmentRight:
            layer.alignmentMode = kCAAlignmentRight;
            break;
        case NSTextAlignmentCenter:
            layer.alignmentMode = kCAAlignmentCenter;
            break;
        case NSTextAlignmentJustified:
            layer.alignmentMode = kCAAlignmentJustified;
            break;
        case NSTextAlignmentNatural:
            layer.alignmentMode = kCAAlignmentNatural;
            break;
    }
}

- (void)setText:(NSString *)text {
    _text = text;
    CATextLayer *layer = (CATextLayer *)self.layer;
    layer.string = text;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    CATextLayer *layer = (CATextLayer *)self.layer;
    layer.foregroundColor = _textColor.CGColor;
}

@end
