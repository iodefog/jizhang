//
//  SSJHistoryHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHistoryHeader.h"

@implementation SSJHistoryHeader

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        self.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
        [self addSubview:self.historyLab];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.historyLab.centerY = self.height / 2;
    self.historyLab.left = 10;
}

- (UILabel *)historyLab{
    if (!_historyLab) {
        _historyLab = [[UILabel alloc]init];
        _historyLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _historyLab.text = @"搜索历史";
        _historyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [_historyLab sizeToFit];
    }
    return _historyLab;
}

- (void)updateCellAppearanceAfterThemeChanged {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.historyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
