//
//  SSJBooksHeadeCollectionrReusableView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksHeadeCollectionrReusableView.h"

@interface SSJBooksHeadeCollectionrReusableView()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation SSJBooksHeadeCollectionrReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self updateAppearance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearance) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLab.left = 20;
    self.titleLab.centerY = self.centerY;
    self.titleLab.bottom = self.height - 10;
}

#pragma mark - Setter
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    self.titleLab.text = titleStr;
    [self.titleLab sizeToFit];
}

#pragma mark - Lazy
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (void)updateAppearance {
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

@end
