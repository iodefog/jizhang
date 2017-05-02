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

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

//  自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

@property (nonatomic, strong) UIView *customPeriodBtnContainer;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *addOrDeleteCustomPeriodBtn;

@end

@implementation SSJReportFormsPeriodSelectionControl

#pragma mark - Public
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.customPeriodBtnContainer];
        [self addSubview:self.dateAxisView];
        [self addSubview:self.addOrDeleteCustomPeriodBtn];
        
        [self updateViewsHidden];
        [self updateAddOrDeleteCustomPeriodBtnImage];
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
    [self.customPeriodBtnContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.customPeriodBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGSize textSize = [self.customPeriodBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:_customPeriodBtn.titleLabel.font}];
        make.width.mas_equalTo(textSize.width + 56);
        make.height.mas_equalTo(25);
        make.center.mas_equalTo(self);
    }];
    [self.dateAxisView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.right.mas_equalTo(self.addOrDeleteCustomPeriodBtn.mas_left);
        make.height.mas_equalTo(self);
    }];
    [self.addOrDeleteCustomPeriodBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(self);
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
    [self updateAddOrDeleteCustomPeriodBtnImage];
    [self updateViewsHidden];
    [self setNeedsUpdateConstraints];
}

- (SSJDatePeriod *)currentPeriod {
    return _customPeriod ?: _selectedPeriod;
}

- (void)updateAppearance {
    self.dateAxisView.fillColor = SSJ_CONTROL_BACKGROUND_COLOR;
    self.dateAxisView.scaleColor = SSJ_SUBTITLE_COLOR;
    self.dateAxisView.selectedScaleColor = SSJ_THEME_COLOR;
    self.dateAxisView.bottomLineColor = SSJ_BORDER_COLOR;
    
    [self.customPeriodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.customPeriodBtn ssj_setBackgroundColor:SSJ_THEME_COLOR forState:UIControlStateNormal];
    
    self.customPeriodBtnContainer.backgroundColor = SSJ_CONTROL_BACKGROUND_COLOR;
    [self.customPeriodBtnContainer ssj_setBorderColor:SSJ_BORDER_COLOR];
    
    self.addOrDeleteCustomPeriodBtn.backgroundColor = SSJ_CONTROL_BACKGROUND_COLOR;
    [self.addOrDeleteCustomPeriodBtn ssj_setBorderColor:SSJ_BORDER_COLOR];
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
    return 8;
}

- (void)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView didSelectedScaleAxisAtIndex:(NSUInteger)index {
    _selectedPeriod = [_periods ssj_safeObjectAtIndex:index];
    if (_periodChangeHandler) {
        _periodChangeHandler(self);
    }
}

#pragma mark - Event
- (void)addOrDeleteCustomPeriodAction {
    if (_customPeriod) {
        [self clearCustomPeriod];
    } else {
        [self addCustomPeriod];
    }
}

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
        self.customPeriodBtn.hidden = NO;
        self.customPeriodBtnContainer.hidden = NO;
    } else {
        self.dateAxisView.hidden = NO;
        self.customPeriodBtn.hidden = YES;
        self.customPeriodBtnContainer.hidden = YES;
    }
}

- (void)updateCustomPeriodBtnTitle {
    NSString *startDateStr = [_customPeriod.startDate formattedDateWithFormat:@"yyyy.MM.dd"];
    NSString *endDateStr = [_customPeriod.endDate formattedDateWithFormat:@"yyyy.MM.dd"];
    NSString *title = [NSString stringWithFormat:@"%@ —— %@", startDateStr, endDateStr];
    [_customPeriodBtn setTitle:title forState:UIControlStateNormal];
}

- (void)updateAddOrDeleteCustomPeriodBtnImage {
    if (_customPeriod) {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_clear_filter"] forState:UIControlStateNormal];
    } else {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_time_filter"] forState:UIControlStateNormal];
    }
}

#pragma mark - Lazy
- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] init];
        _dateAxisView.delegate = self;
    }
    return _dateAxisView;
}

- (UIButton *)customPeriodBtn {
    if (!_customPeriodBtn) {
        _customPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _customPeriodBtn.titleLabel.font = SSJ_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_6);
        _customPeriodBtn.layer.cornerRadius = 12.5;
        _customPeriodBtn.clipsToBounds = YES;
        _customPeriodBtn.hidden = YES;
        [_customPeriodBtn addTarget:self action:@selector(addCustomPeriod) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customPeriodBtn;
}

- (UIView *)customPeriodBtnContainer {
    if (!_customPeriodBtnContainer) {
        _customPeriodBtnContainer = [[UIView alloc] init];
        [_customPeriodBtnContainer addSubview:self.customPeriodBtn];
        [_customPeriodBtnContainer ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _customPeriodBtnContainer;
}

- (UIButton *)addOrDeleteCustomPeriodBtn {
    if (!_addOrDeleteCustomPeriodBtn) {
        _addOrDeleteCustomPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addOrDeleteCustomPeriodBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 20);
        [_addOrDeleteCustomPeriodBtn addTarget:self action:@selector(addOrDeleteCustomPeriodAction) forControlEvents:UIControlEventTouchUpInside];
        [_addOrDeleteCustomPeriodBtn ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _addOrDeleteCustomPeriodBtn;
}


@end
