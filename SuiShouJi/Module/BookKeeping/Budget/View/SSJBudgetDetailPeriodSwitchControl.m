//
//  SSJBudgetDetailPeriodSwitchControl.m
//  SuiShouJi
//
//  Created by old lang on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailPeriodSwitchControl.h"

@interface SSJBudgetDetailPeriodSwitchControl ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *preButton;

@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation SSJBudgetDetailPeriodSwitchControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 150, 30)]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.preButton];
        [self addSubview:self.nextButton];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.centerX = self.width * 0.5;
    self.preButton.right = self.titleLabel.left - 5;
    self.nextButton.left = self.titleLabel.right + 5;
    self.titleLabel.centerY = self.preButton.centerY = self.nextButton.centerY = self.height * 0.5;
}

#pragma mark - Event
- (void)preButtonAction {
    switch (self.periodType) {
        case SSJBudgetPeriodTypeWeek:
            self.currentDate = [self.currentDate dateBySubtractingWeeks:1];
            break;
            
        case SSJBudgetPeriodTypeMonth:
            self.currentDate = [self.currentDate dateBySubtractingMonths:1];
            break;
            
        case SSJBudgetPeriodTypeYear:
            self.currentDate = [self.currentDate dateBySubtractingYears:1];
            break;
    }
    
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)nextButtonAction {
    switch (self.periodType) {
        case SSJBudgetPeriodTypeWeek:
            self.currentDate = [self.currentDate dateByAddingWeeks:1];
            break;
            
        case SSJBudgetPeriodTypeMonth:
            self.currentDate = [self.currentDate dateByAddingMonths:1];
            break;
            
        case SSJBudgetPeriodTypeYear:
            self.currentDate = [self.currentDate dateByAddingYears:1];
            break;
    }
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Private
- (void)updateButtonEnable {
    if (!self.lastDate || !self.currentDate) {
        return;
    }
    self.nextButton.enabled = [self.currentDate compare:self.lastDate] == NSOrderedAscending;
}

- (void)updateTitle {
    switch (self.periodType) {
        case SSJBudgetPeriodTypeWeek:
            self.titleLabel.text = @"周预算";
            self.preButton.hidden = YES;
            self.nextButton.hidden = YES;
            break;
            
        case SSJBudgetPeriodTypeMonth: {
            if (self.currentDate) {
                NSMutableString *title = [NSMutableString string];
                if ([[NSDate date] year] != [self.currentDate year]) {
                    [title appendFormat:@"%d年", [self.currentDate year]];
                }
                [title appendFormat:@"%d月预算", [self.currentDate month]];
                self.titleLabel.text = title;
                self.preButton.hidden = NO;
                self.nextButton.hidden = NO;
            }
        }
            break;
            
        case SSJBudgetPeriodTypeYear:
            self.titleLabel.text = @"年预算";
            self.preButton.hidden = YES;
            self.nextButton.hidden = YES;
            break;
    }
    
    [self.titleLabel sizeToFit];
    [self sizeToFit];
}

#pragma mark - Setter
- (void)setPeriodType:(SSJBudgetPeriodType)periodType {
    _periodType = periodType;
    [self updateTitle];
}

- (void)setLastDate:(NSDate *)lastDate {
    if (!_lastDate || [_lastDate compare:lastDate] != NSOrderedSame) {
        _lastDate = lastDate;
        [self updateButtonEnable];
    }
}

- (void)setCurrentDate:(NSDate *)currentDate {
    if (!_currentDate || [_currentDate compare:currentDate] != NSOrderedSame) {
        _currentDate = currentDate;
        [self updateButtonEnable];
        [self updateTitle];
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:21];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UIButton *)preButton {
    if (!_preButton) {
        _preButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preButton setImage:[UIImage imageNamed:@"budget_left"] forState:UIControlStateNormal];
        [_preButton setImage:[UIImage imageNamed:@"budget_left_disable"] forState:UIControlStateDisabled];
        [_preButton addTarget:self action:@selector(preButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_preButton sizeToFit];
    }
    return _preButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"budget_right"] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"budget_right_diable"] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton sizeToFit];
    }
    return _nextButton;
}

@end
