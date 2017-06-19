//
//  SSJReportFormsSurplusCell.m
//  SuiShouJi
//
//  Created by old lang on 17/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJReportFormsSurplusCell.h"

@interface SSJReportFormsSurplusCellContainerView : UIView

@property (nonatomic, strong) UILabel *topLab;

@property (nonatomic, strong) UILabel *bottomLab;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation SSJReportFormsSurplusCellContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.topLab];
        [self.containerView addSubview:self.bottomLab];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(self).offset(-20).priorityLow();
    }];
    [self.topLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.containerView);
    }];
    [self.bottomLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLab.mas_bottom).offset(2);
        make.left.and.right.and.bottom.mas_equalTo(self.containerView);
    }];
    [super updateConstraints];
}

- (UILabel *)topLab {
    if (!_topLab) {
        _topLab = [[UILabel alloc] init];
        _topLab.text = @"总结余";
        _topLab.textAlignment = NSTextAlignmentCenter;
        _topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
    }
    return _topLab;
}

- (UILabel *)bottomLab {
    if (!_bottomLab) {
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.textAlignment = NSTextAlignmentCenter;
        _bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _bottomLab;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

@end

@implementation SSJReportFormsSurplusCellItem

- (CGFloat)rowHeight {
    return 170;
}

@end

@interface SSJReportFormsSurplusCell ()

@property (nonatomic, strong) SSJReportFormsSurplusCellContainerView *surplusView;

@property (nonatomic, strong) SSJReportFormsSurplusCellContainerView *incomeView;

@property (nonatomic, strong) SSJReportFormsSurplusCellContainerView *paymentView;

@end

@implementation SSJReportFormsSurplusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.surplusView];
        [self.contentView addSubview:self.incomeView];
        [self.contentView addSubview:self.paymentView];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.surplusView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.mas_equalTo(self.contentView);
    }];
    [self.incomeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.surplusView.mas_bottom);
        make.left.mas_equalTo(self.surplusView);
    }];
    [self.paymentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.surplusView.mas_bottom);
        make.left.mas_equalTo(self.incomeView.mas_right);
        make.width.and.height.mas_equalTo(self.incomeView);
        make.right.and.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.surplusView);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormsSurplusCellItem class]]) {
        return;
    }
    [super setCellItem:cellItem];
    SSJReportFormsSurplusCellItem *item = cellItem;
    self.surplusView.topLab.text = item.title;
    self.surplusView.bottomLab.text = [NSString stringWithFormat:@"%.2f", item.income - item.payment];
    self.incomeView.bottomLab.text = [NSString stringWithFormat:@"%.2f", item.income];
    self.paymentView.bottomLab.text = [NSString stringWithFormat:@"%.2f", item.payment];
    [self updateAppearance];
}

- (SSJReportFormsSurplusCellItem *)item {
    return (SSJReportFormsSurplusCellItem *)self.cellItem;
}

- (void)updateAppearance {
    self.surplusView.topLab.textColor = SSJ_SECONDARY_COLOR;
    NSString *colorValue = self.item.income > self.item.payment ? SSJ_CURRENT_THEME.reportFormsCurveIncomeColor : SSJ_CURRENT_THEME.reportFormsCurvePaymentColor;
    self.surplusView.bottomLab.textColor = [UIColor ssj_colorWithHex:colorValue];
    self.incomeView.topLab.textColor = SSJ_SECONDARY_COLOR;
    self.incomeView.bottomLab.textColor = SSJ_MAIN_COLOR;
    self.paymentView.topLab.textColor = SSJ_SECONDARY_COLOR;
    self.paymentView.bottomLab.textColor = SSJ_MAIN_COLOR;
    [self.surplusView ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [self.incomeView ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}

- (SSJReportFormsSurplusCellContainerView *)surplusView {
    if (!_surplusView) {
        _surplusView = [[SSJReportFormsSurplusCellContainerView alloc] init];
        _surplusView.topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _surplusView.bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_surplusView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _surplusView;
}

- (SSJReportFormsSurplusCellContainerView *)incomeView {
    if (!_incomeView) {
        _incomeView = [[SSJReportFormsSurplusCellContainerView alloc] init];
        _incomeView.topLab.text = @"收入";
        _incomeView.topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _incomeView.bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_incomeView ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _incomeView;
}

- (SSJReportFormsSurplusCellContainerView *)paymentView {
    if (!_paymentView) {
        _paymentView = [[SSJReportFormsSurplusCellContainerView alloc] init];
        _paymentView.topLab.text = @"支出";
        _paymentView.topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _paymentView.bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _paymentView;
}

@end
