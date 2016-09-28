
//
//  SSJSearchBar.m
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchBar.h"

@interface SSJSearchBar()

@property(nonatomic, strong) UIButton *cancelButton;

@end


@implementation SSJSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];
        [self addSubview:self.cancelButton];
        [self addSubview:self.searchTextInput];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cancelButton.centerY = self.height / 2;
    self.cancelButton.right = self.width - 10;
    self.searchTextInput.size = CGSizeMake(self.width - 80, 30);
    self.searchTextInput.layer.cornerRadius = 15;
    self.searchTextInput.centerY = self.height / 2;
    self.searchTextInput.left = 15;
}

- (UITextField *)searchTextInput{
    if (!_searchTextInput) {
        _searchTextInput = [[UITextField alloc]init];
        _searchTextInput.backgroundColor = [UIColor clearColor];
        _searchTextInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _searchTextInput.font = [UIFont systemFontOfSize:15];
        _searchTextInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextInput.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor].CGColor;
        _searchTextInput.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        _searchTextInput.returnKeyType = UIReturnKeySearch;
    }
    return _searchTextInput;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTitleColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)cancelButtonClicked:(id)sender{
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)updateAfterThemeChange{
    [self.cancelButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTitleColor] forState:UIControlStateNormal];
    self.searchTextInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
