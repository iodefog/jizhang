//
//  SSJCalenderDetailHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/8/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailHeader.h"

@interface SSJCalenderDetailHeader()

@property(nonatomic, strong) UILabel *headerLab;

@end

@implementation SSJCalenderDetailHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.headerLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.headerLab.left = 10;
    self.headerLab.centerY = self.height / 2;
}

-(UILabel *)headerLab{
    if (!_headerLab) {
        _headerLab = [[UILabel alloc]init];
        _headerLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _headerLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _headerLab;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    if (item.membersItem.count - 1 != 1) {
        self.headerLab.text = [NSString stringWithFormat:@"%ld位成员 | 人均",item.membersItem.count - 1];
        [self.headerLab sizeToFit];
    }else{
        self.headerLab.text = @"成员";
        [self.headerLab sizeToFit];
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
