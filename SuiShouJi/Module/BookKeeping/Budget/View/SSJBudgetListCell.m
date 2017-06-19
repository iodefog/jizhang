//
//  SSJBudgetListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListCell.h"
#import "SSJBudgetWaveWaterView.h"

@interface SSJBudgetListCell ()

//  预算周期类型
@property (nonatomic, strong) UILabel *typeLab;

//  预算周期
@property (nonatomic, strong) UILabel *periodLab;

//  已花金额
@property (nonatomic, strong) UILabel *paymentLab;

//  计划金额
@property (nonatomic, strong) UILabel *budgetLab;

//  百分比波浪进度
@property (nonatomic, strong) SSJBudgetWaveWaterView *waveView;

@end

@implementation SSJBudgetListCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    return 314;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.typeLab];
        [self.contentView addSubview:self.periodLab];
        [self.contentView addSubview:self.paymentLab];
        [self.contentView addSubview:self.budgetLab];
        [self.contentView addSubview:self.waveView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.typeLab sizeToFit];
    [self.periodLab sizeToFit];
    [self.paymentLab sizeToFit];
    [self.budgetLab sizeToFit];
    
    self.typeLab.center = CGPointMake(self.contentView.width * 0.5, 30);
    self.periodLab.center = CGPointMake(self.contentView.width * 0.5, 55);
    
    self.waveView.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.56);
    
    if (self.paymentLab.width + self.budgetLab.width > self.contentView.width - 20) {
        CGFloat reduction = (self.paymentLab.width + self.budgetLab.width - (self.contentView.width - 20)) * 0.5;
        self.paymentLab.width -= reduction;
        self.budgetLab.width -= reduction;
    }
    
    self.paymentLab.leftBottom = CGPointMake(10, self.contentView.height - 15);
    self.budgetLab.rightBottom = CGPointMake(self.contentView.width - 10, self.contentView.height - 15);
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBudgetListCellItem class]]) {
        return;
    }
    
    SSJBudgetListCellItem *item = (SSJBudgetListCellItem *)cellItem;
    self.typeLab.text = item.title;
    self.periodLab.text = item.period;
    self.paymentLab.attributedText = item.expend;
    self.budgetLab.attributedText = item.budget;
    self.waveView.budgetMoney = item.budgetValue;
    self.waveView.expendMoney = item.expendValue;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.backgroundColor = [UIColor clearColor];
        _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _typeLab;
}

- (UILabel *)periodLab {
    if (!_periodLab) {
        _periodLab = [[UILabel alloc] init];
        _periodLab.backgroundColor = [UIColor clearColor];
        _periodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _periodLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _periodLab;
}

- (UILabel *)paymentLab {
    if (!_paymentLab) {
        _paymentLab = [[UILabel alloc] init];
        _paymentLab.backgroundColor = [UIColor clearColor];
        _paymentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _paymentLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _paymentLab;
}

- (UILabel *)budgetLab {
    if (!_budgetLab) {
        _budgetLab = [[UILabel alloc] init];
        _budgetLab.backgroundColor = [UIColor clearColor];
        _budgetLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _budgetLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _budgetLab;
}

- (SSJBudgetWaveWaterView *)waveView {
    if (!_waveView) {
        _waveView = [[SSJBudgetWaveWaterView alloc] initWithRadius:160];
        _waveView.waveAmplitude = 12;
        _waveView.waveSpeed = 5;
        _waveView.waveCycle = 1;
        _waveView.waveGrowth = 3;
        _waveView.waveOffset = 60;
        _waveView.outerBorderWidth = 8;
    }
    return _waveView;
}

@end
