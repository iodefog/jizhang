//
//  SSJClearDataCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJClearDataCell.h"

@implementation SSJClearDataCellItem

+ (instancetype)itemWithLeftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle {
    SSJClearDataCellItem *item = [[SSJClearDataCellItem alloc] init];
    item.leftTitle = leftTitle;
    item.rightTitle = rightTitle;
    return item;
}

@end

@interface SSJClearDataCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UILabel *rightLab;

@end

@implementation SSJClearDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        self.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.rightLab];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.rightLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJClearDataCellItem class]]) {
        return;
    }
    
    SSJClearDataCellItem *item = cellItem;
    [[RACObserve(item, leftTitle) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *text) {
        self.leftLab.text = text;
        [self setNeedsUpdateConstraints];
    }];
    
    [[RACObserve(item, rightTitle) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *text) {
        self.rightLab.text = text;
        [self setNeedsUpdateConstraints];
    }];
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
    self.rightLab.textColor = SSJ_MAIN_COLOR;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _rightLab;
}

@end
