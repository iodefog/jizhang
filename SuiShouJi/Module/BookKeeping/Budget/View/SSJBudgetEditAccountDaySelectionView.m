//
//  SSJBudgetEditAccountDaySelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/7/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditAccountDaySelectionView.h"
#import "SSJDatePeriod.h"

@interface SSJBudgetEditAccountDaySelectionView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSDate *accountDay;

@end

@implementation SSJBudgetEditAccountDaySelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_cancelBtn setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_sureBtn setImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sureBtn];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.text = @"结算日";
        [_titleLab sizeToFit];
        [self addSubview:_titleLab];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        
        _pickerView.layer.borderColor = [UIColor redColor].CGColor;
        _pickerView.layer.borderWidth = 1;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    return CGSizeMake(keyWindow.width, 44 + _pickerView.height);
}

- (void)layoutSubviews {
    [_cancelBtn sizeToFit];
    _cancelBtn.leftTop = CGPointZero;
    
    [_sureBtn sizeToFit];
    _sureBtn.rightTop = CGPointMake(self.width, 0);
    
    _titleLab.centerX = self.width * 0.5;
    
    _pickerView.top = 44;
    _pickerView.size = CGSizeMake(self.width, self.height - 44);
}

- (void)setPeriodType:(SSJBudgetPeriodType)periodType {
    _periodType = periodType;
    [_pickerView reloadAllComponents];
    [self updateAccountDay];
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(sureBtnAction) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (_periodType) {
        case SSJBudgetPeriodTypeWeek:
        case SSJBudgetPeriodTypeMonth:
            return 1;
            
        case SSJBudgetPeriodTypeYear:
            return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (_periodType) {
        case SSJBudgetPeriodTypeWeek:
            return 7;
            
        case SSJBudgetPeriodTypeMonth:
            return 29;
            
        case SSJBudgetPeriodTypeYear:
            if (component == 0) {
                return 12;
            } else if (component == 1) {
                NSInteger selectedMonth = [pickerView selectedRowInComponent:0] + 1;
                if (selectedMonth == 2) {
                    return 29;
                } else {
                    NSDate *tDate = [NSDate dateWithYear:[[NSDate date] year] month:selectedMonth day:1];
                    return [tDate ssj_numberOfDaysInCurrentMonth];
                }
            } else {
                return 0;
            }
    }
}

#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (_periodType) {
        case SSJBudgetPeriodTypeWeek:
            return [self stringForWeekday:row + 1];
            
        case SSJBudgetPeriodTypeMonth:
            if (row == 28) {
                return @"月末";
            } else {
                return [NSString stringWithFormat:@"%d日", (int)row + 1];
            }
            
        case SSJBudgetPeriodTypeYear:
            if (component == 0) {
                return [NSString stringWithFormat:@"%d月", (int)row + 1];
            } else if (component == 1) {
                NSInteger selectedMonth = [pickerView selectedRowInComponent:0] + 1;
                if (selectedMonth == 2 && row == 28) {
                    return @"月末";
                } else {
                    return [NSString stringWithFormat:@"%d日", (int)row + 1];
                }
            } else {
                return nil;
            }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_periodType == SSJBudgetPeriodTypeYear && component == 0) {
        [pickerView reloadComponent:1];
    }
    
    [self updateAccountDay];
}

#pragma mark - Event
- (void)cancelBtnAction {
    [self dismiss];
}

- (void)sureBtnAction {
    [self dismiss];
    if (_sureAction) {
        _sureAction(self);
    }
}

- (NSString *)stringForWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1:     return @"周一";
        case 2:     return @"周二";
        case 3:     return @"周三";
        case 4:     return @"周四";
        case 5:     return @"周五";
        case 6:     return @"周六";
        case 7:     return @"周日";
        default:    return @"";
    }
}

- (void)updateAccountDay {
    NSDate *currentDate = [NSDate date];
    
    switch (_periodType) {
        case SSJBudgetPeriodTypeWeek: {
            NSInteger selectedWeekday = [_pickerView selectedRowInComponent:0] + 1;
            
            if (selectedWeekday >= currentDate.weekday) {
                _accountDay = [currentDate dateByAddingDays:selectedWeekday - currentDate.weekday];
            } else {
                _accountDay = [currentDate dateByAddingDays:selectedWeekday - currentDate.weekday + 7];
            }
        }
            break;
            
        case SSJBudgetPeriodTypeMonth: {
            NSInteger selectedDay = [_pickerView selectedRowInComponent:0] + 1;
            if (selectedDay >= currentDate.day) {
                _accountDay = [currentDate dateByAddingDays:selectedDay - currentDate.weekday];
            } else {
                NSDate *selectedDate = [currentDate dateByAddingDays:selectedDay - currentDate.weekday];
                _accountDay = [selectedDate dateByAddingMonths:1];
            }
        }
            break;
            
        case SSJBudgetPeriodTypeYear: {
            NSInteger selectedMonth = [_pickerView selectedRowInComponent:0] + 1;
            NSInteger selectedDay = [_pickerView selectedRowInComponent:1] + 1;
            NSDate *selectedDate = [NSDate dateWithYear:currentDate.year month:selectedMonth day:selectedDay];
            
            if ([selectedDate compare:currentDate] == NSOrderedAscending) {
                _accountDay = [selectedDate dateByAddingYears:1];
            } else {
                _accountDay = selectedDate;
            }
        }
            break;
    }
}

@end
