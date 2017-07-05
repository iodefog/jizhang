//
//  SSJAboutUsFooterView.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/5.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAboutUsFooterView.h"

@interface SSJAboutUsFooterView()

@property (nonatomic, strong) UIButton *descriptionButton;

@property (nonatomic, strong) UIButton *userAgreementButton;

@end


@implementation SSJAboutUsFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.descriptionButton];
        [self addSubview:self.userAgreementButton];
        self.backgroundColor = [UIColor clearColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConstraints {
    
    [self.descriptionButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.mas_centerX).offset(-40);
    }];
    
    [self.userAgreementButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.mas_centerX).offset(40);
    }];
    
    [super updateConstraints];
}

- (UIButton *)descriptionButton {
    if (!_descriptionButton) {
        _descriptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_descriptionButton setTitle:@"团队介绍" forState:UIControlStateNormal];
        _descriptionButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_descriptionButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        [_descriptionButton ssj_setBorderStyle:SSJBorderStyleBottom];
        [_descriptionButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
        [_descriptionButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _descriptionButton;
}

- (UIButton *)userAgreementButton {
    if (!_userAgreementButton) {
        _userAgreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userAgreementButton setTitle:@"用户协议" forState:UIControlStateNormal];
        _userAgreementButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_userAgreementButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        [_userAgreementButton ssj_setBorderStyle:SSJBorderStyleBottom];
        [_userAgreementButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
        [_userAgreementButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userAgreementButton;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [_descriptionButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
    [_descriptionButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
    [_userAgreementButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
    [_userAgreementButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
}

- (void)buttonClicked:(UIButton *)button {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(button.titleLabel.text);
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
