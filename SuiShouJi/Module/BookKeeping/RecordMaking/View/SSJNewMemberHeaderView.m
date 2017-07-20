//
//  SSJNewMemberHeaderCollectionReusableView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewMemberHeaderView.h"

@interface SSJNewMemberHeaderView()
@property(nonatomic, strong) UIView *colorSelectView;
@property(nonatomic, strong) UILabel *nameLab;
@end

@implementation SSJNewMemberHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.colorSelectView];
        [self addSubview:self.nameInput];
        [self addSubview:self.nameLab];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.colorSelectView.left = 10;
    self.colorSelectView.centerY = self.height / 2;
    self.nameInput.centerY = self.height / 2;
    self.nameInput.left = self.colorSelectView.right + 10;
    self.nameLab.center = self.colorSelectView.center;
}

-(UITextField *)nameInput{
    if (!_nameInput) {
        _nameInput = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        _nameInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _nameInput.textAlignment = NSTextAlignmentLeft;
        _nameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入成员名称" attributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _nameInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _nameInput.returnKeyType = UIReturnKeyDone;
    }
    return _nameInput;
}

-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc]init];
        _nameLab.textColor = [UIColor whiteColor];
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_8];
    }
    return _nameLab;
}

-(UIView *)colorSelectView{
    if (!_colorSelectView) {
        _colorSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
        _colorSelectView.layer.cornerRadius = _colorSelectView.height / 2;
    }
    return _colorSelectView;
}

-(void)setFirstWord:(NSString *)firstWord{
    _firstWord = firstWord;
    self.nameLab.text = firstWord;
    [self.nameLab sizeToFit];
    [self setNeedsLayout];
}

-(void)setSelectedColor:(NSString *)selectedColor{
    _selectedColor = selectedColor;
    _colorSelectView.backgroundColor = [UIColor ssj_colorWithHex:_selectedColor];
}

@end
