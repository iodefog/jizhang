//
//  SSJScrollTextView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJScrollTextView.h"
#import "SSJScrollTextLayer.h"

@interface SSJScrollTextView()
@property(nonatomic, strong) NSMutableArray *layerArr;
@end

@implementation SSJScrollTextView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layerArr = [NSMutableArray arrayWithCapacity:0];
        self.textFont = 15;
        self.textColor = [UIColor blackColor];
        self.totalAnimationDuration = 1.f;
        self.scrollAble = YES;
        self.clipsToBounds = NO;
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return [self.string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.textFont]}];
}

- (void)ajustFontWithSize:(CGSize)size {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    lab.adjustsFontSizeToFitWidth = YES;
    lab.text = self.string;
    self.textFont = [lab.font pointSize];
}

-(void)setString:(NSString *)string{
    _string = string;
    int validNumCount = 0;
    for (int i = 0; i < self.layerArr.count; i ++) {
        [[self.layerArr objectAtIndex:i] removeFromSuperlayer];
    }
    float totalStrWidth = 0;
    float siglestringHeight = [@"0" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.textFont]}].height;
    for (int i = 0; i < _string.length; i ++) {
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+$"];
        NSString *tempStr = [_string substringWithRange:NSMakeRange(i, 1)];
        float strWidth = [tempStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.textFont]}].width;
        if (![numberPre evaluateWithObject:tempStr] || !self.scrollAble) {
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            textLayer.frame = CGRectMake(totalStrWidth, 0, strWidth, siglestringHeight);
            textLayer.fontSize = self.textFont;
            textLayer.foregroundColor = self.textColor.CGColor;
            textLayer.string = tempStr;
            [self.layer addSublayer:textLayer];
            totalStrWidth += strWidth;
            [self.layerArr addObject:textLayer];
        }else{
            SSJScrollTextLayer *textLayer = [SSJScrollTextLayer layer];
            textLayer.textFont = self.textFont;
            textLayer.frame = CGRectMake(totalStrWidth, 0, strWidth, siglestringHeight);
            textLayer.textColor = self.textColor;
            textLayer.animationDuration = self.totalAnimationDuration / (1 + (validNumCount + 1)*0.3);
            textLayer.numStr = tempStr;
            [self.layer addSublayer:textLayer];
            totalStrWidth += strWidth;
            [self.layerArr addObject:textLayer];
            validNumCount ++;
        }
    }
    [self sizeToFit];
}

-(void)setTextFont:(int)textFont{
    _textFont = textFont;
}

-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
}

-(void)setTotalAnimationDuration:(float)totalAnimationDuration{
    _totalAnimationDuration = totalAnimationDuration;
}

-(void)setScrollAble:(BOOL)scrollAble{
    _scrollAble = scrollAble;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
