
//
//  SSJSearchBar.m
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchBar.h"
#import "SSJSearchBarAddition.h"

@interface SSJSearchBar()

@property(nonatomic, strong) UIButton *cancelButton;

@end


@implementation SSJSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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

- (UISearchBar *)searchTextInput{
    if (!_searchTextInput) {
        _searchTextInput = [[UISearchBar alloc]init];
//        _searchTextInput.backgroundColor = [UIColor clearColor];
//        _searchTextInput.backgroundColor = [UIColor clearColor];
        _searchTextInput.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
//        _searchTextInput.font = [UIFont systemFontOfSize:15];
//        _searchTextInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIImage *clearImage = [UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(self.width - 80  , 30)];
        [_searchTextInput setSearchFieldBackgroundImage:clearImage forState:UIControlStateNormal];
        _searchTextInput.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor].CGColor;
        _searchTextInput.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        _searchTextInput.layer.cornerRadius = 15.f;
        _searchTextInput.searchBarStyle = UISearchBarStyleMinimal;
        [_searchTextInput searchTextFieldView].font = [UIFont systemFontOfSize:15];
        [_searchTextInput searchTextFieldView].textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_searchTextInput searchTextFieldView].attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"搜索" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
//        [_searchTextInput setScopeBarButtonTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} forState:UIControlStateNormal];
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
    [self.cancelButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor] forState:UIControlStateNormal];
    self.searchTextInput.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];
    [self.searchTextInput searchTextFieldView].font = [UIFont systemFontOfSize:15];
    [self.searchTextInput searchTextFieldView].textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.searchTextInput searchTextFieldView].attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"搜索" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
