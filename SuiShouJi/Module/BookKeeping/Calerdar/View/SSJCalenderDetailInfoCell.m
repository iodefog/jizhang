//
//  SSJCalenderDetailInfoCell.m
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailInfoCell.h"

@implementation SSJCalenderDetailInfoCellItem

@end

@interface SSJCalenderDetailInfoCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UILabel *rightLab;

@end

@implementation SSJCalenderDetailInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.rightLab];
        [self setNeedsUpdateConstraints];
        [self updateAppearance];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo([self.leftLab.text sizeWithAttributes:@{NSFontAttributeName:self.leftLab.font}]);
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.rightLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLab.mas_right).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJCalenderDetailInfoCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    SSJCalenderDetailInfoCellItem *item = cellItem;
    self.leftLab.text = item.leftText;
    self.rightLab.text = item.rightText;
    [self setNeedsUpdateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
    self.rightLab.textColor = SSJ_MAIN_COLOR;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rightLab.textAlignment = NSTextAlignmentRight;
    }
    return _rightLab;
}

@end
