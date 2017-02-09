//
//  SSJLoanDateSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDateSelectionView.h"

@interface SSJLoanDateSelectionView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation SSJLoanDateSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.sureBtn];
        [self addSubview:self.datePicker];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLab.text = _title;
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    _datePicker.date = selectedDate;
}

- (void)setLeftButtonItem:(SSJLoanDateSelectionButtonItem *)leftButtonItem {
    _leftButtonItem = leftButtonItem;
    [self updateButton:self.cancelBtn buttonItem:self.leftButtonItem];
}

- (void)setRightButtonItem:(SSJLoanDateSelectionButtonItem *)rightButtonItem {
    _rightButtonItem = rightButtonItem;
    [self updateButton:self.sureBtn buttonItem:self.rightButtonItem];
}

- (void)updateButton:(UIButton *)button buttonItem:(SSJLoanDateSelectionButtonItem *)item {
    [button setTitle:item.title forState:UIControlStateNormal];
    [button setTitleColor:item.color forState:UIControlStateNormal];
    [button setImage:item.image forState:UIControlStateNormal];
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
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

#pragma mark - Event
- (void)cancelButtonClicked {
    if (self.leftButtonItem.action) {
        self.leftButtonItem.action();
        return;
    }
    
    [self dismiss];
}

- (void)sureButtonClicked {
    if (self.rightButtonItem.action) {
        self.rightButtonItem.action();
        return;
    }
    
    BOOL shouldSelect = YES;
    NSDate *selectedDate = [NSDate dateWithYear:_datePicker.date.year month:_datePicker.date.month day:_datePicker.date.day];
    if (_shouldSelectDateAction) {
        shouldSelect = _shouldSelectDateAction(self, selectedDate);
    }
    
    if (!shouldSelect) {
        _datePicker.date = _selectedDate;
        return;
    }
    
    [self dismiss];
    _selectedDate = selectedDate;
    if (_selectDateAction) {
        _selectDateAction(self);
    }
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, self.width - 88, 44)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _titleLab;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 44, 0, 44, 44)];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sureBtn setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, self.width, self.height - 44)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.backgroundColor = [UIColor whiteColor];
    }
    return _datePicker;
}

@end


@implementation SSJLoanDateSelectionButtonItem

+ (instancetype)buttonItemWithTitle:(NSString *)title
                              image:(UIImage *)image
                              color:(UIColor *)color
                             action:(SSJLoanDateSelectionButtonItemAction)action {
    
    SSJLoanDateSelectionButtonItem *item = [[SSJLoanDateSelectionButtonItem alloc] init];
    item.title = title;
    item.image = image;
    item.color = color;
    item.action = action;
    return item;
}

@end
