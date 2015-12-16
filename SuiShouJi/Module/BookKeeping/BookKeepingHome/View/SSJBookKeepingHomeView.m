//
//  SSJBookKeepingHomeView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeView.h"

@interface SSJBookKeepingHomeView()
@property (nonatomic,strong) UIButton *categoryImageButton;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenditureLabel;
@end
@implementation SSJBookKeepingHomeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.expenditureLabel];
        [self addSubview:self.categoryImageButton];
    }
    return self;
}

-(void)layoutSubviews{
    self.categoryImageButton.bottom = self.height;
    self.categoryImageButton.centerX = self.centerX;
    self.expenditureLabel.rightBottom = CGPointMake(self.categoryImageButton.left - 5, self.height);
    self.expenditureLabel.centerY = self.categoryImageButton.centerY;
    self.incomeLabel.leftBottom = CGPointMake(self.categoryImageButton.right + 10, self.height);
    self.incomeLabel.centerY = self.categoryImageButton.centerY;

}

-(UILabel*)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _incomeLabel.font = [UIFont systemFontOfSize:13];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _incomeLabel.text = @"餐饮23.00";
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel*)expenditureLabel{
    if (!_expenditureLabel) {
        _expenditureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _expenditureLabel.font = [UIFont systemFontOfSize:13];
        _expenditureLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _expenditureLabel.text = @"餐饮补贴280.00";
        [_expenditureLabel sizeToFit];
    }
    return _expenditureLabel;
}

-(UIButton*)categoryImageButton{
    if (_categoryImageButton == nil) {
        _categoryImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _categoryImageButton.layer.cornerRadius = 15;
        _categoryImageButton.layer.masksToBounds = YES;
        [_categoryImageButton setImage:[UIImage imageNamed:@"餐饮 测试"] forState:UIControlStateNormal];
        [_categoryImageButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryImageButton;
}

-(void)buttonClicked{
    NSLog(@"编辑");
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.centerX, 0);
    CGContextAddLineToPoint(ctx, self.centerX, self.categoryImageButton.top);
    CGContextSetRGBStrokeColor(ctx, 204.0/225, 204.0/255, 204.0/255, 1.0);
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
}

@end
