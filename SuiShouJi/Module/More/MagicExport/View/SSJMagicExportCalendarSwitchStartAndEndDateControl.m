//
//  SSJMagicExportCalendarSwitchStartAndEndDateControl.m
//  SuiShouJi
//
//  Created by old lang on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarSwitchStartAndEndDateControl.h"

@interface SSJMagicExportCalendarSwitchDateButton : UIControl

@property (nonatomic, copy) NSString *topTitle;

@property (nonatomic, copy) NSString *bottomTitle;

@end

@interface SSJMagicExportCalendarSwitchDateButton ()

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SSJMagicExportCalendarSwitchDateButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont systemFontOfSize:18];
        _topLabel.textColor = [UIColor ssj_colorWithHex:@"EB4A64"];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLabel];
        
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:18];
        _bottomLabel.textColor = [UIColor ssj_colorWithHex:@"3F3F3F"];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.top = self.height;
        [self addSubview:_bottomLabel];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateLayout];
}

- (void)setTopTitle:(NSString *)topTitle {
    _topLabel.text = topTitle;
    [self setNeedsLayout];
}

- (void)setBottomTitle:(NSString *)bottomTitle {
    _bottomLabel.text = bottomTitle;
    [_bottomLabel sizeToFit];
    _bottomLabel.top = self.height;
    _topLabel.centerX = _bottomLabel.centerX = self.width * 0.5;
    
    CGFloat verticalGap = 0;
    if (bottomTitle.length) {
        verticalGap = (self.height - _topLabel.height - _bottomLabel.height) * 0.33;
    } else {
        verticalGap = (self.height - _topLabel.height) * 0.5;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _topLabel.font = [UIFont systemFontOfSize:14];
        [_topLabel sizeToFit];
        _topLabel.top = verticalGap;
        _bottomLabel.top = _topLabel.bottom + verticalGap;
    }];
}

- (void)updateLayout {
    if (_bottomLabel.text.length) {
        _topLabel.font = [UIFont systemFontOfSize:14];
        [_topLabel sizeToFit];
        
        [_bottomLabel sizeToFit];
        
        CGFloat verticalGap = (self.height - _topLabel.height - _bottomLabel.height) * 0.33;
        _topLabel.top = verticalGap;
        _bottomLabel.top = _topLabel.bottom + verticalGap;
        _topLabel.centerX = _bottomLabel.centerX = self.width * 0.5;
    } else {
        _topLabel.font = [UIFont systemFontOfSize:18];
        [_topLabel sizeToFit];
        _topLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
}

@end

@interface SSJMagicExportCalendarSwitchStartAndEndDateControl ()

@property (nonatomic, strong) SSJMagicExportCalendarSwitchDateButton *beginDateButton;

@property (nonatomic, strong) SSJMagicExportCalendarSwitchDateButton *endDateButton;

@property (nonatomic, strong) UIView *tabView;

@end

@implementation SSJMagicExportCalendarSwitchStartAndEndDateControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _beginDateButton = [[SSJMagicExportCalendarSwitchDateButton alloc] init];
        _beginDateButton.topTitle = @"起始日期";
        [_beginDateButton addTarget:self action:@selector(beginDateButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_beginDateButton];
        
        _endDateButton = [[SSJMagicExportCalendarSwitchDateButton alloc] init];
        _endDateButton.topTitle = @"结束日期";
        [_endDateButton addTarget:self action:@selector(endDateButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_endDateButton];
        
        _tabView = [[UIView alloc] init];
        _tabView.backgroundColor = [UIColor ssj_colorWithHex:@"EB4A64"];
        [self addSubview:_tabView];
    }
    return self;
}

- (void)layoutSubviews {
    _beginDateButton.frame = CGRectMake(0, 0, self.width * 0.5, self.height);
    _endDateButton.frame = CGRectMake(self.width * 0.5, 0, self.width * 0.5, self.height);
    _tabView.frame = CGRectMake(_selectedIndex * self.width * 0.5, self.height - 2, self.width * 0.5, 2);
}

- (void)beginDateButtonAction {
    if (_shouldSelectAction) {
        BOOL shouldSelect = _shouldSelectAction(0);
        if (!shouldSelect) {
            return;
        }
    }
    
    self.selectedIndex = 0;
    
    if (_didSelectAction) {
        _didSelectAction(0);
    }
}

- (void)endDateButtonAction {
    if (_shouldSelectAction) {
        BOOL shouldSelect = _shouldSelectAction(1);
        if (!shouldSelect) {
            return;
        }
    }
    
    self.selectedIndex = 1;
    
    if (_didSelectAction) {
        _didSelectAction(1);
    }
}

- (void)setBeginDate:(NSString *)beginDate {
    _beginDateButton.bottomTitle = beginDate;
}

- (void)setEndDate:(NSString *)endDate {
    _endDateButton.bottomTitle = endDate;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [UIView animateWithDuration:0.25 animations:^{
            _tabView.left = self.width * 0.5 * _selectedIndex;
        }];
    }
}

@end
