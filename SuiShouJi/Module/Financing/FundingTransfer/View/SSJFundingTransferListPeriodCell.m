//
//  SSJFundingTransferListPeriodCell.m
//  SuiShouJi
//
//  Created by old lang on 17/2/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferListPeriodCell.h"
#import "SSJFundingTransferListPeriodCellItem.h"
#import "Masonry.h"

@interface SSJFundingTransferListPeriodCell ()

@property (nonatomic, strong) UIImageView *fundLogo;

@property (nonatomic, strong) UILabel *transferTitleLab;

@property (nonatomic, strong) UIImageView *cycleLogo;

@property (nonatomic, strong) UILabel *cycleTitleLab;

@property (nonatomic, strong) UIView *separator;

@property (nonatomic, strong) UILabel *memoLab;

@property (nonatomic, strong) UILabel *dateLab;

@property (nonatomic, strong) UILabel *moneyLab;

@property (nonatomic, strong) UISwitch *switchCtrl;

@end

@implementation SSJFundingTransferListPeriodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.fundLogo];
        [self.contentView addSubview:self.transferTitleLab];
        [self.contentView addSubview:self.cycleLogo];
        [self.contentView addSubview:self.cycleTitleLab];
        [self.contentView addSubview:self.separator];
        [self.contentView addSubview:self.memoLab];
        [self.contentView addSubview:self.dateLab];
        [self.contentView addSubview:self.moneyLab];
        [self.contentView addSubview:self.switchCtrl];
        [self updateAppearance];
        [self setUpConstraints];
    }
    return self;
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJFundingTransferListPeriodCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    
    SSJFundingTransferListPeriodCellItem *item = cellItem;
    _fundLogo.image = item.fundLogo;
    _transferTitleLab.text = item.transferTitle;
    [_transferTitleLab sizeToFit];
    _cycleTitleLab.text = item.cycleTitle;
    [_cycleTitleLab sizeToFit];
    _memoLab.text = item.memo;
    _separator.hidden = !(item.memo.length > 0);
    _dateLab.text = item.date;
    _moneyLab.text = [NSString stringWithFormat:@"%.2f", [item.money doubleValue]];
    _switchCtrl.on = item.opened;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _transferTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _cycleLogo.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _cycleTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _separator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setUpConstraints {
    [_fundLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.mas_equalTo(self.contentView).offset(25);
        make.left.mas_equalTo(self.contentView).offset(15);
    }];
    [_transferTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        // 在这个 block 里面，利用 make 对象创建约束
        make.width.mas_lessThanOrEqualTo(205);
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(_fundLogo.mas_right).offset(10);
    }];
    [_moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_transferTitleLab);
        make.left.mas_equalTo(_transferTitleLab.mas_right).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
    }];
    [_cycleLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_transferTitleLab);
        make.top.mas_equalTo(_transferTitleLab.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    }];
    [_cycleTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_cycleLogo.mas_right).offset(5);
        make.right.mas_lessThanOrEqualTo(_switchCtrl.mas_left).offset(-10);
        make.centerY.mas_equalTo(_cycleLogo);
    }];
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(0.5, 13));
        make.left.mas_equalTo(_cycleTitleLab.mas_right).offset(10);
        make.right.mas_lessThanOrEqualTo(_switchCtrl.mas_left).offset(-10);
        make.centerY.mas_equalTo(_cycleTitleLab);
    }];
    [_memoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_separator.mas_right).offset(10);
        make.centerY.mas_equalTo(_separator);
        make.right.mas_lessThanOrEqualTo(_switchCtrl.mas_left).offset(-10);
    }];
    [_switchCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(54, 30));
        make.top.mas_equalTo(_moneyLab.mas_bottom).offset(10);
        make.right.mas_equalTo(_moneyLab);
    }];
    [_dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_cycleLogo);
        make.top.mas_equalTo(_cycleLogo.mas_bottom).offset(10);
    }];
}

#pragma mark - Event
- (void)switchAction {
    if (_switchCtrlAction) {
        _switchCtrlAction(_switchCtrl.on, self);
    }
}

#pragma mark - LazyLoading
- (UIImageView *)fundLogo {
    if (!_fundLogo) {
        _fundLogo = [[UIImageView alloc] init];
    }
    return _fundLogo;
}

- (UILabel *)transferTitleLab {
    if (!_transferTitleLab) {
        _transferTitleLab = [[UILabel alloc] init];
        _transferTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _transferTitleLab;
}

- (UIImageView *)cycleLogo {
    if (!_cycleLogo) {
        _cycleLogo = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"xuhuan_xuhuan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _cycleLogo;
}

- (UILabel *)cycleTitleLab {
    if (!_cycleTitleLab) {
        _cycleTitleLab = [[UILabel alloc] init];
        _cycleTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _cycleTitleLab;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
    }
    return _separator;
}

- (UILabel *)memoLab {
    if (!_memoLab) {
        _memoLab = [[UILabel alloc] init];
        _memoLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memoLab;
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _dateLab;
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _moneyLab.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLab;
}

- (UISwitch *)switchCtrl {
    if (!_switchCtrl) {
        _switchCtrl = [[UISwitch alloc] init];
        [_switchCtrl addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _switchCtrl;
}

@end
