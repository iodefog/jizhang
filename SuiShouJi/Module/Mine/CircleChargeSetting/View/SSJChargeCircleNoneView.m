//
//  SSJChargeCircleNoneView.m
//  SuiShouJi
//
//  Created by ricky on 16/6/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeCircleNoneView.h"

@interface SSJChargeCircleNoneView()
@property(nonatomic, strong) UIImageView *noneImage;
@property(nonatomic, strong) UIButton *makeChargeCircleButton;
@property(nonatomic, strong) UILabel *nodataLabel;
@property(nonatomic, strong) UIView *seperatorLine;
@end

@implementation SSJChargeCircleNoneView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.seperatorLine];
        [self addSubview:self.noneImage];
        [self addSubview:self.nodataLabel];
        [self addSubview:self.makeChargeCircleButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLine.size = CGSizeMake(self.width, 10);
    self.seperatorLine.leftTop = CGPointMake(0, 0);
    self.noneImage.bottom = self.height / 2 - 10;
    self.noneImage.centerX = self.width / 2;
    self.nodataLabel.top = self.noneImage.bottom + 5;
    self.nodataLabel.centerX = self.width / 2;
    self.makeChargeCircleButton.top = self.nodataLabel.bottom + 20;
    self.makeChargeCircleButton.centerX = self.width / 2;
}

-(UIImageView *)noneImage{
    if (!_noneImage) {
        _noneImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 188, 223)];
        _noneImage.image = [UIImage imageNamed:@"zhouqi_none"];
    }
    return _noneImage;
}

-(UIButton *)makeChargeCircleButton{
    if (!_makeChargeCircleButton) {
        _makeChargeCircleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width - 40, 40)];
        [_makeChargeCircleButton setTitle:@"添加周期记账" forState:UIControlStateNormal];
        _makeChargeCircleButton.layer.cornerRadius = 3.f;
        [_makeChargeCircleButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_makeChargeCircleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_makeChargeCircleButton addTarget:self action:@selector(makeChargeCircleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _makeChargeCircleButton;
}

-(UILabel *)nodataLabel{
    if (!_nodataLabel) {
        _nodataLabel = [[UILabel alloc]init];
        _nodataLabel.font = [UIFont systemFontOfSize:18];
        _nodataLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _nodataLabel.text = @"您暂时未设置任何周期记账哦~";
        [_nodataLabel sizeToFit];
    }
    return _nodataLabel;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]init];
        _seperatorLine.backgroundColor = [UIColor clearColor];
    }
    return _seperatorLine;
}

-(void)makeChargeCircleButtonClicked:(id)sender{
    if (self.makeChargeCircleBlock) {
        self.makeChargeCircleBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
