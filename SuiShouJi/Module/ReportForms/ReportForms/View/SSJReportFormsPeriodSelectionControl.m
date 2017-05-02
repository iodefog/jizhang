//
//  SSJReportFormsPeriodSelectionControl.m
//  SuiShouJi
//
//  Created by old lang on 17/3/23.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJReportFormsPeriodSelectionControl.h"
#import "SSJReportFormsScaleAxisView.h"
#import "SSJDatePeriod.h"

@interface SSJReportFormsPeriodSelectionControl () <SSJReportFormsScaleAxisViewDelegate>

// 切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

// 自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

// 编辑自定义时间按钮
@property (nonatomic, strong) UIButton *addCustomPeriodBtn;

// 删除自定义时间按钮
@property (nonatomic, strong) UIButton *clearCustomPeriodBtn;

@end

@implementation SSJReportFormsPeriodSelectionControl

#pragma mark - Public
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.dateAxisView];
        [self addSubview:self.customPeriodBtn];
        [self addSubview:self.addCustomPeriodBtn];
        [self addSubview:self.clearCustomPeriodBtn];
        
        [self updateViewsHidden];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.width > 0) {
        self.dateAxisView.subscriptPosition = self.width * 0.5 / self.dateAxisView.width;
    }
}

- (void)updateConstraints {
    [self.customPeriodBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGSize textSize = [self.customPeriodBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_customPeriodBtn.titleLabel.font}];
        make.width.mas_equalTo(textSize.width);
        make.height.mas_equalTo(25);
        make.center.mas_equalTo(self);
    }];
    [self.dateAxisView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.right.mas_equalTo(self.addCustomPeriodBtn.mas_left);
        make.height.mas_equalTo(self);
    }];
    [self.addCustomPeriodBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(self);
    }];
    [self.clearCustomPeriodBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.customPeriodBtn.mas_right);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [super updateConstraints];
}

- (void)setPeriods:(NSArray<SSJDatePeriod *> *)periods {
    _periods = periods;
    [self.dateAxisView reloadData];
    if (_selectedPeriod) {
        NSUInteger index = [_periods indexOfObject:_selectedPeriod];
        if (index != NSNotFound) {
            self.dateAxisView.selectedIndex = index;
        }
    }
}

- (void)setSelectedPeriod:(SSJDatePeriod *)selectedPeriod {
    if (!_selectedPeriod || [_selectedPeriod compareWithPeriod:selectedPeriod] != SSJDatePeriodComparisonResultSame) {
        NSUInteger index = [_periods indexOfObject:selectedPeriod];
        if (index != NSNotFound) {
            _selectedPeriod = selectedPeriod;
            self.dateAxisView.selectedIndex = index;
        }
    }
}

- (void)setCustomPeriod:(SSJDatePeriod *)customPeriod {
    _customPeriod = customPeriod;
    [self updateCustomPeriodBtnTitle];
    [self updateViewsHidden];
    [self setNeedsUpdateConstraints];
}

- (SSJDatePeriod *)currentPeriod {
    return _customPeriod ?: _selectedPeriod;
}

- (void)updateAppearance {
    [self.dateAxisView updateConstraints];
    [self.customPeriodBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
}

#pragma mark - SSJReportFormsScaleAxisViewDelegate
- (NSUInteger)numberOfAxisInScaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView {
    return _periods.count;
}

- (NSString *)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView titleForAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    if (period.periodType == SSJDatePeriodTypeMonth) {
        return [NSString stringWithFormat:@"%d月", (int)period.startDate.month];
    } else if (period.periodType == SSJDatePeriodTypeYear) {
        return [NSString stringWithFormat:@"%d年", (int)period.startDate.year];
    } else if (period.periodType == SSJDatePeriodTypeCustom) {
        return @"合计";
    } else {
        return nil;
    }
}

- (CGFloat)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView heightForAxisAtIndex:(NSUInteger)index {
    return 12;
}

- (void)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView didSelectedScaleAxisAtIndex:(NSUInteger)index {
    _selectedPeriod = [_periods ssj_safeObjectAtIndex:index];
    if (_periodChangeHandler) {
        _periodChangeHandler(self);
    }
}

#pragma mark - Event
- (void)clearCustomPeriod {
    self.customPeriod = nil;
    if (_clearCustomPeriodHandler) {
        _clearCustomPeriodHandler(self);
    }
}

- (void)addCustomPeriod {
    if (_addCustomPeriodHandler) {
        _addCustomPeriodHandler(self);
    }
}

#pragma mark - Private
- (void)updateViewsHidden {
    if (_customPeriod) {
        self.dateAxisView.hidden = YES;
        self.addCustomPeriodBtn.hidden = YES;
        self.customPeriodBtn.hidden = NO;
        self.clearCustomPeriodBtn.hidden = NO;
    } else {
        self.dateAxisView.hidden = NO;
        self.addCustomPeriodBtn.hidden = NO;
        self.customPeriodBtn.hidden = YES;
        self.clearCustomPeriodBtn.hidden = YES;
    }
}

- (void)updateCustomPeriodBtnTitle {
    NSString *startDateStr = [_customPeriod.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [_customPeriod.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *title = [NSString stringWithFormat:@"%@——%@", startDateStr, endDateStr];
    [_customPeriodBtn setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] init];
        _dateAxisView.fillColor = [UIColor clearColor];
        _dateAxisView.delegate = self;
    }
    return _dateAxisView;
}

- (UIButton *)customPeriodBtn {
    if (!_customPeriodBtn) {
        _customPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _customPeriodBtn.titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        [_customPeriodBtn addTarget:self action:@selector(addCustomPeriod) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customPeriodBtn;
}

- (UIButton *)addCustomPeriodBtn {
    if (!_addCustomPeriodBtn) {
        _addCustomPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addCustomPeriodBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 20);
        [_addCustomPeriodBtn addTarget:self action:@selector(addCustomPeriod) forControlEvents:UIControlEventTouchUpInside];
        [_addCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    }
    return _addCustomPeriodBtn;
}

- (UIButton *)clearCustomPeriodBtn {
    if (!_clearCustomPeriodBtn) {
        _clearCustomPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearCustomPeriodBtn addTarget:self action:@selector(clearCustomPeriod) forControlEvents:UIControlEventTouchUpInside];
        [_clearCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    }
    return _clearCustomPeriodBtn;
}

@end
