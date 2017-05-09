
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

@property(nonatomic, strong) UIButton *searchButton;

@property(nonatomic, strong) UIButton *backButton;

@end


@implementation SSJSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.backButton];
        [self addSubview:self.searchButton];
        [self addSubview:self.searchTextInput];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backButton.centerY = self.height / 2;
    self.backButton.left = 10;
    self.searchButton.centerY = self.height / 2;
    self.searchButton.right = self.width - 10;
    self.searchTextInput.size = CGSizeMake(self.width - 100 - self.backButton.left, 30);
    self.searchTextInput.layer.cornerRadius = 15;
    self.searchTextInput.centerY = self.height / 2;
    self.searchTextInput.left = self.backButton.right + 10;
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
        [_searchTextInput searchTextFieldView].font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_searchTextInput searchTextFieldView].textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_searchTextInput searchTextFieldView].attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"可搜索收支类别,备注" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    }
    return _searchTextInput;
}

- (UIButton *)searchButton{
    if (!_searchButton) {
        _searchButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        _searchButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_searchButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTitleColor] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_backButton setImage:[[UIImage imageNamed:@"navigation_backOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)searchButtonClicked:(id)sender{
    if (self.searchAction) {
        self.searchAction();
    }
}

- (void)backButtonClicked:(id)sender{
    if (self.backAction) {
        self.backAction();
    }
}

- (void)updateAfterThemeChange{
    [self.searchButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor] forState:UIControlStateNormal];
    self.searchTextInput.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor];
    [self.searchTextInput searchTextFieldView].font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    [self.searchTextInput searchTextFieldView].textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.searchTextInput searchTextFieldView].attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"搜索" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    self.backButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
