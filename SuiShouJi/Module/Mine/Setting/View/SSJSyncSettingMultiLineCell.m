//
//  SSJSyncSettingMultiLineCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingMultiLineCell.h"

@interface SSJSyncSettingMultiLineCell ()

@property (nonatomic, strong) UILabel *topLab;

@property (nonatomic, strong) UILabel *bottomLab;

@end

@implementation SSJSyncSettingMultiLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.topLab];
        [self.contentView addSubview:self.bottomLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.topLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(13);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(20);
    }];
    [self.bottomLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLab.mas_bottom).offset(7);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(13);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.topLab.textColor = SSJ_MAIN_COLOR;
    self.bottomLab.textColor = SSJ_SECONDARY_COLOR;
}

- (UILabel *)topLab {
    if (!_topLab) {
        _topLab = [[UILabel alloc] init];
        _topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _topLab;
}

- (UILabel *)bottomLab {
    if (!_bottomLab) {
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _bottomLab;
}

@end
