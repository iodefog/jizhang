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

@property (nonatomic, strong) SSJBorderButton *button;

@end

@implementation SSJBudgetDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.circleView];
        [self addSubview:self.button];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return self;
}

- (void)layoutSubviews {
    self.circleView.frame = CGRectMake(0, 0, self.width, 320);
    self.button.frame = CGRectMake(20, self.circleView.bottom + 30, self.width - 40, 44);
}

- (SSJPercentCircleView *)circleView {
    if (!_circleView) {
        _circleView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        _circleView.backgroundColor = [UIColor clearColor];
    }
    return _circleView;
}

- (SSJBorderButton *)button {
    if (!_button) {
        _button = [[SSJBorderButton alloc] init];
        [_button setFontSize:21];
        [_button setTitle:@"编辑" forState:SSJBorderButtonStateNormal];
        [_button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:SSJBorderButtonStateHighlighted];
        [_button setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateNormal];
        [_button setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_button setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateHighlighted];
    }
    return _button;
}

@end
