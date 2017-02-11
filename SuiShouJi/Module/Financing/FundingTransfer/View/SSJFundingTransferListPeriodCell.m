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
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *purpleView = [[UIView alloc] init];
    purpleView.backgroundColor = [UIColor purpleColor];
    [self addSubview:purpleView];
    [purpleView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 在这个 block 里面，利用 make 对象创建约束
        make.size.mas_equalTo(@"");
        make.center.mas_equalTo(self);
    }];
}

- (void)setCellItem:(__kindof SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJFundingTransferListPeriodCellItem class]]) {
        return;
    }
    
    SSJFundingTransferListPeriodCellItem *item = cellItem;
    _fundLogo.image = item.fundLogo;
    _transferTitleLab.text = item.transferTitle;
    [_transferTitleLab sizeToFit];
    _cycleTitleLab.text = item.cycleTitle;
    [_cycleTitleLab sizeToFit];
    _memoLab.text = item.memo;
    _dateLab.text = item.date;
    _moneyLab.text = item.money;
    _switchCtrl.on = item.opened;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    
}

- (void)updateAppearance {
    _transferTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setUpConstraints {
    
}

#pragma mark - Event
- (void)switchAction {
    
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
        _transferTitleLab.font = [UIFont systemFontOfSize:16];
    }
    return _transferTitleLab;
}

- (UIImageView *)cycleLogo {
    if (!_cycleLogo) {
        _fundLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xuhuan_xuhuan"]];
    }
    return _cycleLogo;
}

- (UILabel *)cycleTitleLab {
    if (!_cycleTitleLab) {
        _cycleTitleLab = [[UILabel alloc] init];
        _cycleTitleLab.font = [UIFont systemFontOfSize:13];
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
        _memoLab.font = [UIFont systemFontOfSize:13];
    }
    return _memoLab;
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont systemFontOfSize:13];
    }
    return _dateLab;
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.font = [UIFont systemFontOfSize:16];
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
