//
//  SSJRecycleListHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListHeaderView.h"

@interface SSJRecycleListHeaderView ()

@property (nonatomic, strong) UILabel *dateLab;

@end

@implementation SSJRecycleListHeaderView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.dateLab];
        [self updateCellAppearanceAfterThemeChanged];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateConstraints {
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(18);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    self.dateLab.textColor = SSJ_SECONDARY_COLOR;
}

- (void)setDateStr:(NSString *)dateStr {
    _dateStr = dateStr;
    self.dateLab.text = dateStr;
    [self setNeedsLayout];
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _dateLab;
}

@end
