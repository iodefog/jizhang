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
    
    self.typeLab.center = CGPointMake(self.contentView.width * 0.5, 30);
    self.periodLab.center = CGPointMake(self.contentView.width * 0.5, 55);
    self.paymentLab.leftBottom = CGPointMake(10, self.contentView.height - 15);
    self.budgetLab.rightBottom = CGPointMake(self.contentView.width - 10, self.contentView.height - 15);
    self.waveView.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.56);
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBudgetListCellItem class]]) {
        return;
    }
    
    SSJBudgetListCellItem *item = (SSJBudgetListCellItem *)cellItem;
    self.typeLab.text = item.typeName;
    [self.typeLab sizeToFit];
    
    self.periodLab.text = item.period;
    [self.periodLab sizeToFit];
    
    NSMutableAttributedString *paymentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", item.payment]];
    [paymentStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
                                NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, paymentStr.length - 3)];
    self.paymentLab.attributedText = paymentStr;
    [self.paymentLab sizeToFit];
    
    NSMutableAttributedString *budgetStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"计划：%.2f", item.budget]];
    [budgetStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
                               NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, budgetStr.length - 3)];
    self.budgetLab.attributedText = budgetStr;
    [self.budgetLab sizeToFit];
    
    self.waveView.percent = (item.payment / item.budget);
    self.waveView.money = item.budget - item.payment;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.backgroundColor = [UIColor clearColor];
        _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLab.font = [UIFont systemFontOfSize:18];
    }
    return _typeLab;
}

- (UILabel *)periodLab {
    if (!_periodLab) {
        _periodLab = [[UILabel alloc] init];
        _periodLab.backgroundColor = [UIColor clearColor];
        _periodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _periodLab.font = [UIFont systemFontOfSize:13];
    }
    return _periodLab;
}

- (UILabel *)paymentLab {
    if (!_paymentLab) {
        _paymentLab = [[UILabel alloc] init];
        _paymentLab.backgroundColor = [UIColor clearColor];
        _paymentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _paymentLab.font = [UIFont systemFontOfSize:13];
    }
    return _paymentLab;
}

- (UILabel *)budgetLab {
    if (!_budgetLab) {
        _budgetLab = [[UILabel alloc] init];
        _budgetLab.backgroundColor = [UIColor clearColor];
        _budgetLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _budgetLab.font = [UIFont systemFontOfSize:13];
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
        _waveView.fullWaveAmplitude = 8;
        _waveView.fullWaveSpeed = 4;
        _waveView.fullWaveCycle = 4;
        _waveView.outerBorderWidth = 8;
        _waveView.showText = YES;
    }
    return _waveView;
}

@end
