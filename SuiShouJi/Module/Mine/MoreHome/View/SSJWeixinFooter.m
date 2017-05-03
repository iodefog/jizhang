//
//  SSJWeixinFooter.m
//  SuiShouJi
//
//  Created by ricky on 16/8/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWeixinFooter.h"

@interface SSJWeixinFooter()
@property(nonatomic, strong) UIImageView *qrCodeImage;
@property(nonatomic, strong) UILabel *descLab;
@property(nonatomic, strong) UILabel *iconDesLab;
@end

@implementation SSJWeixinFooter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.qrCodeImage];
        [self addSubview:self.descLab];
        [self addSubview:self.iconDesLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.qrCodeImage.size = CGSizeMake(85, 85);
    self.qrCodeImage.leftTop = CGPointMake(10, 17);
    self.iconDesLab.top = self.qrCodeImage.bottom + 10;
    self.iconDesLab.centerX = self.qrCodeImage.centerX;
    self.descLab.width = self.width - self.qrCodeImage.right - 10;
    self.descLab.leftTop = CGPointMake(self.qrCodeImage.right + 10, self.qrCodeImage.top);
    [self.descLab sizeToFit];
}

-(UIImageView *)qrCodeImage{
    if (!_qrCodeImage) {
        _qrCodeImage = [[UIImageView alloc]init];
        _qrCodeImage.image = [UIImage imageNamed:@"qrcoddeImage.jpg"];
    }
    return _qrCodeImage;
}

-(UILabel *)descLab{
    if (!_descLab) {
        _descLab = [[UILabel alloc]init];
        _descLab.numberOfLines = 0;
        _descLab.text = @"关注公众号，了解有鱼记账最新资讯动态，学习记账理财知识，轻松理出“鱼”钱~";
        _descLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _descLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _descLab;
}

-(UILabel *)iconDesLab{
    if (!_iconDesLab) {
        _iconDesLab = [[UILabel alloc]init];
        _iconDesLab.text = @"有鱼记账本";
        _iconDesLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _iconDesLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        [_iconDesLab sizeToFit];                                                                                                                                                                                                                                               
    }
    return _iconDesLab;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
