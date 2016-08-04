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
@end

@implementation SSJNewMemberHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.colorSelectView];
        [self addSubview:self.nameInput];
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
    [self ssj_relayoutBorder];
}

-(UITextField *)nameInput{
    if (!_nameInput) {
        _nameInput = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        _nameInput.font = [UIFont systemFontOfSize:18];
        _nameInput.textAlignment = NSTextAlignmentLeft;
        _nameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入成员名称" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _nameInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _nameInput;
}

-(UIView *)colorSelectView{
    if (!_colorSelectView) {
        _colorSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
        _colorSelectView.layer.cornerRadius = _colorSelectView.height / 2;
    }
    return _colorSelectView;
}

-(void)setSelectedColor:(NSString *)selectedColor{
    _selectedColor = selectedColor;
    _colorSelectView.backgroundColor = [UIColor ssj_colorWithHex:_selectedColor];
}

@end
