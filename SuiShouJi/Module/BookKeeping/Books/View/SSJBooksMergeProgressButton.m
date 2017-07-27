//
//  SSJBooksMergeProgressButton.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksMergeProgressButton.h"

@interface SSJBooksMergeProgressButton()

@property (nonatomic, strong) UILabel  *titleLab;

@property (nonatomic, strong) UIColor *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@end


@implementation SSJBooksMergeProgressButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        
    }
    return _titleLab;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    UIColor *color = [UIColor redColor];
    [color set]; //设置线条颜色

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0,self.height / 2)];
    [bezierPath addCurveToPoint:CGPointMake(self.width, self.height / 2)
                  controlPoint1:CGPointMake(self.width / 4, self.height / 2 - 30)
                  controlPoint2:CGPointMake(self.width / 4 * 3, self.height / 2 + 30)];
    bezierPath.lineCapStyle = kCGLineCapRound; //线条拐角
    [bezierPath setLineWidth:3];
    [bezierPath stroke];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
