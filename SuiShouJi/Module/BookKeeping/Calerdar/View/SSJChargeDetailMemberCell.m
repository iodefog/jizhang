//
//  SSJChargeDetailMemberCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeDetailMemberCell.h"

@interface SSJChargeDetailMemberCell()

@property(nonatomic, strong) UILabel *memberIcon;

@property(nonatomic, strong) UILabel *memberNameLab;

@property(nonatomic, strong) UILabel *moneyLab;
@end

@implementation SSJChargeDetailMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.memberIcon];
        [self.contentView addSubview:self.memberNameLab];
        [self.contentView addSubview:self.moneyLab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.memberIcon.left = 10;
    self.memberIcon.centerY = self.height / 2;
    self.memberNameLab.left = self.memberIcon.right + 10;
    self.memberNameLab.centerY = self.height / 2;
    self.moneyLab.right = self.width - 10;
    self.moneyLab.centerY = self.height / 2;
}

-(UILabel *)memberIcon{
    if (!_memberIcon) {
        _memberIcon = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _memberIcon.layer.cornerRadius = _memberIcon.width / 2;
        _memberIcon.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _memberIcon.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _memberIcon.textAlignment = NSTextAlignmentCenter;
    }
    return _memberIcon;
}

-(UILabel *)memberNameLab{
    if (!_memberNameLab) {
        _memberNameLab = [[UILabel alloc]init];
        _memberNameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _memberNameLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _memberNameLab;
}

-(UILabel *)moneyLab{
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc]init];
        _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _moneyLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _moneyLab;
}

-(void)setMemberItem:(SSJChargeMemberItem *)memberItem{
    _memberItem = memberItem;
    self.memberIcon.text = [_memberItem.memberName substringToIndex:1];
    self.memberIcon.textColor = [UIColor ssj_colorWithHex:_memberItem.memberColor];
    self.memberIcon.layer.borderColor = [UIColor ssj_colorWithHex:_memberItem.memberColor].CGColor;
    self.memberNameLab.text = _memberItem.memberName;
    [self.memberNameLab sizeToFit];
}

-(void)setMemberMoney:(NSString *)memberMoney{
    _memberMoney = memberMoney;
    float money = [_memberMoney floatValue];
    self.moneyLab.text = [NSString stringWithFormat:@"%.2f",money];
    [self.moneyLab sizeToFit];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
