//
//  SSJBudgetDetailBottomView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailBottomView.h"

@interface SSJBudgetDetailBottomView ()

@property (nonatomic, strong) SSJPercentCircleView *circleView;

@property (nonatomic, strong) UILabel *timeRangeLabel;

@property (nonatomic, strong) SSJBorderButton *button;

@end

@implementation SSJBudgetDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.circleView];
        [self addSubview:self.timeRangeLabel];
        [self addSubview:self.button];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.circleView.frame = CGRectMake(0, 0, self.width, 320);
    self.timeRangeLabel.frame = CGRectMake(0, self.circleView.bottom, self.width, 16);
    self.button.frame = CGRectMake(20, self.timeRangeLabel.bottom + 30, self.width - 40, 44);
}

- (SSJPercentCircleView *)circleView {
    if (!_circleView) {
        _circleView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
    }
    return _circleView;
}

- (UILabel *)timeRangeLabel {
    if (!_timeRangeLabel) {
        _timeRangeLabel = [[UILabel alloc] init];
        _timeRangeLabel.backgroundColor = [UIColor whiteColor];
        _timeRangeLabel.font = [UIFont systemFontOfSize:14];
        _timeRangeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeRangeLabel;
}

- (SSJBorderButton *)button {
    if (!_button) {
        _button = [[SSJBorderButton alloc] init];
        [_button setFontSize:21];
        [_button setTitle:@"编辑"];
        [_button setColor:[UIColor ssj_colorWithHex:@"47cfbe"]];
    }
    return _button;
}

@end
