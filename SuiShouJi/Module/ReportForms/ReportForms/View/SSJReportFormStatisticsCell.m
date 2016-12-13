//
//  SSJReportFormStatisticsCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormStatisticsCell.h"

@interface SSJReportFormStatisticsUnitCell : UIView

@property (nonatomic) CGFloat gapBetweenLabs;

@property (nonatomic, strong, readonly) UILabel *topTitleLab;

@property (nonatomic, strong, readonly) UILabel *bottomTitleLab;

- (void)relayoutContent;

@end

@interface SSJReportFormStatisticsUnitCell ()

@property (nonatomic, strong) UILabel *topTitleLab;

@property (nonatomic, strong) UILabel *bottomTitleLab;

@end

@implementation SSJReportFormStatisticsUnitCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _gapBetweenLabs = 5;
        [self addSubview:self.topTitleLab];
        [self addSubview:self.bottomTitleLab];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat top = (self.height - _topTitleLab.height - _bottomTitleLab.height - _gapBetweenLabs) * 0.5;
    _topTitleLab.top = top;
    _bottomTitleLab.top = _topTitleLab.bottom + _gapBetweenLabs;
    _topTitleLab.centerX = _bottomTitleLab.centerX = self.width * 0.5;
}

- (void)relayoutContent {
    [_topTitleLab sizeToFit];
    [_bottomTitleLab sizeToFit];
    [self setNeedsLayout];
}

- (UILabel *)topTitleLab {
    if (!_topTitleLab) {
        _topTitleLab = [[UILabel alloc] init];
        _topTitleLab.font = [UIFont systemFontOfSize:18];
    }
    return _topTitleLab;
}

- (UILabel *)bottomTitleLab {
    if (!_bottomTitleLab) {
        _bottomTitleLab = [[UILabel alloc] init];
        _bottomTitleLab.font = [UIFont systemFontOfSize:12];
    }
    return _bottomTitleLab;
}

@end

@interface SSJReportFormStatisticsCell ()

@property (nonatomic, strong) SSJReportFormStatisticsUnitCell *generalIncomeUnitCell;

@property (nonatomic, strong) SSJReportFormStatisticsUnitCell *generalPaymentUnitCell;

@property (nonatomic, strong) SSJReportFormStatisticsUnitCell *dailyCostUnitCell;

@end

@implementation SSJReportFormStatisticsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.generalIncomeUnitCell];
        [self.contentView addSubview:self.generalPaymentUnitCell];
        [self.contentView addSubview:self.dailyCostUnitCell];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat unitWidth = self.contentView.width * 0.333;
    _generalIncomeUnitCell.frame = CGRectMake(0, 0, unitWidth, self.contentView.height);
    _generalPaymentUnitCell.frame = CGRectMake(_generalIncomeUnitCell.right, 0, unitWidth, self.contentView.height);
    _dailyCostUnitCell.frame = CGRectMake(_generalPaymentUnitCell.right, 0, unitWidth, self.contentView.height);
    
    [_generalIncomeUnitCell relayoutContent];
    [_generalPaymentUnitCell relayoutContent];
    [_dailyCostUnitCell relayoutContent];
    
    [_generalIncomeUnitCell ssj_relayoutBorder];
    [_generalPaymentUnitCell ssj_relayoutBorder];
    [_dailyCostUnitCell ssj_relayoutBorder];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormStatisticsCellItem class]]) {
        return;
    }
    
    SSJReportFormStatisticsCellItem *item = (SSJReportFormStatisticsCellItem *)cellItem;
    
    _generalIncomeUnitCell.topTitleLab.text = item.generalIncome;
    _generalPaymentUnitCell.topTitleLab.text = item.generalPayment;
    _dailyCostUnitCell.topTitleLab.text = item.dailyCost;
    
    [_generalIncomeUnitCell relayoutContent];
    [_generalPaymentUnitCell relayoutContent];
    [_dailyCostUnitCell relayoutContent];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _generalIncomeUnitCell.topTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    _generalIncomeUnitCell.bottomTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [_generalIncomeUnitCell ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _generalPaymentUnitCell.topTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    _generalPaymentUnitCell.bottomTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [_generalPaymentUnitCell ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _dailyCostUnitCell.topTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dailyCostUnitCell.bottomTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Lazy
- (SSJReportFormStatisticsUnitCell *)generalIncomeUnitCell {
    if (!_generalIncomeUnitCell) {
        _generalIncomeUnitCell = [[SSJReportFormStatisticsUnitCell alloc] init];
        [_generalIncomeUnitCell ssj_setBorderWidth:1];
        [_generalIncomeUnitCell ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _generalIncomeUnitCell;
}

- (SSJReportFormStatisticsUnitCell *)generalPaymentUnitCell {
    if (!_generalPaymentUnitCell) {
        _generalPaymentUnitCell = [[SSJReportFormStatisticsUnitCell alloc] init];
        [_generalPaymentUnitCell ssj_setBorderWidth:1];
        [_generalPaymentUnitCell ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _generalPaymentUnitCell;
}

- (SSJReportFormStatisticsUnitCell *)dailyCostUnitCell {
    if (!_dailyCostUnitCell) {
        _dailyCostUnitCell = [[SSJReportFormStatisticsUnitCell alloc] init];
    }
    return _dailyCostUnitCell;
}

@end
