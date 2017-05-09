//
//  SSJBudgetProgressView.m
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetProgressView.h"
#import "UICountingLabel.h"

@interface SSJBudgetProgressView ()

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UILabel *surplusLab;

@property (nonatomic, strong) UICountingLabel *surplusValueLab;

@end

@implementation SSJBudgetProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"cacaca"];
        self.clipsToBounds = YES;
        
        _progressView = [[UIView alloc] init];
        [self addSubview:_progressView];
        
        _surplusLab = [[UILabel alloc] init];
        _surplusLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _surplusLab.textColor = [UIColor ssj_colorWithHex:@"#FFFFFF"];
        [self addSubview:_surplusLab];
        
        _surplusValueLab = [[UICountingLabel alloc] init];
        _surplusValueLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _surplusValueLab.textColor = [UIColor ssj_colorWithHex:@"#FFFFFF"];
        _surplusValueLab.format = @"%.2f";
        _surplusValueLab.method = UILabelCountingMethodEaseOut;
        [self addSubview:_surplusValueLab];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.cornerRadius = self.height * 0.5;
    
    CGFloat left = (self.width - _surplusLab.width - _surplusValueLab.width) * 0.5;
    _surplusLab.left = left;
    _surplusValueLab.left = _surplusLab.right;
    _surplusLab.centerY = _surplusValueLab.centerY = self.height * 0.5;
    _progressView.size = CGSizeMake(self.width, self.height);
    _progressView.right = self.width * [self progress];
}

- (void)setBudgetMoney:(CGFloat)budgetMoney {
    if (budgetMoney <= 0) {
        SSJPRINT(@"预算金额必须大于0");
        return;
    }
    
    if (_budgetMoney != budgetMoney) {
        _budgetMoney = budgetMoney;
        [self updateMoney];
        [self updateProgress];
        [self updateProgressColor];
    }
}

- (void)setExpendMoney:(CGFloat)expendMoney {
    if (expendMoney < 0) {
        SSJPRINT(@"支出金额不小于0");
        return;
    }
    
    if (_expendMoney != expendMoney) {
        _expendMoney = expendMoney;
        [self updateMoney];
        [self updateProgress];
        [self updateProgressColor];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self updateProgressColor];
}

- (void)setOverrunProgressColor:(UIColor *)overrunProgressColor {
    _overrunProgressColor = overrunProgressColor;
    [self updateProgressColor];
}

- (void)updateMoney {
    [self setNeedsLayout];
    
    if (_budgetMoney >= _expendMoney) {
        _surplusLab.text = @"剩余：";
        [_surplusValueLab countFrom:_budgetMoney to:_budgetMoney - _expendMoney withDuration:[self duration]];
        CGSize formSize = [[NSString stringWithFormat:@"%.2f", _budgetMoney] sizeWithAttributes:@{NSFontAttributeName:_surplusValueLab.font}];
        CGSize toSize = [[NSString stringWithFormat:@"%.2f", _budgetMoney - _expendMoney] sizeWithAttributes:@{NSFontAttributeName:_surplusValueLab.font}];
        _surplusValueLab.size = CGSizeMake(MAX(formSize.width, toSize.width), MAX(formSize.height, toSize.height));
    } else {
        [_surplusValueLab stopCounting];
        _surplusLab.text = @"超支：";
        _surplusValueLab.text = [NSString stringWithFormat:@"%.2f", _budgetMoney - _expendMoney];
        [_surplusValueLab sizeToFit];
    }
    [_surplusLab sizeToFit];
}

- (void)updateProgress {
    if (_budgetMoney <= 0 || _expendMoney < 0) {
        return;
    }
    
    if (!CGRectIsEmpty(self.bounds)) {
        CGFloat progress = [self progress];
        _progressView.right = self.width;
        [UIView animateWithDuration:[self duration] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _progressView.right = self.width * progress;
        } completion:NULL];
    }
}

- (CGFloat)progress {
    if (_budgetMoney == 0) {
        return 0;
    }
    
    if (_budgetMoney >= _expendMoney) {
        return 1 - (_expendMoney / _budgetMoney);
    } else {
        return 1;
    }
}

- (NSTimeInterval)duration {
    return MAX((_expendMoney / _budgetMoney) * 1.5, 1.5);
}

- (void)updateProgressColor {
    _progressView.backgroundColor = _expendMoney > _budgetMoney ? _overrunProgressColor : _progressColor;
}

@end
