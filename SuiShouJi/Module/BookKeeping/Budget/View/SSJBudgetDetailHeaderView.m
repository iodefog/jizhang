//
//  SSJBudgetDetailHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetWaveScaleView.h"
#import "SSJBudgetModel.h"

@interface SSJBudgetDetailHeaderView ()

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *budgetMoneyTitleLab;

@property (nonatomic, strong) UILabel *budgetMoneyLab;

@property (nonatomic, strong) SSJBudgetWaveScaleView *waveView;

@property (nonatomic, strong) UILabel *intervalTitleLab;

@property (nonatomic, strong) UILabel *intervalLab;

@property (nonatomic, strong) UILabel *payMoneyLab;

@property (nonatomic, strong) UILabel *balanceLab;

@property (nonatomic, strong) UILabel *bottomLab;

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation SSJBudgetDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"yyyy-MM-dd";
        
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
    }
    return self;
}

- (void)layoutSubviews {
    self.topView.frame = CGRectMake(0, 0, self.width, 95);
    CGFloat gap = 10;
    CGFloat top1 = (self.topView.height - self.budgetMoneyTitleLab.height - self.budgetMoneyLab.height - gap) * 0.5;
    
    self.budgetMoneyTitleLab.centerX = self.budgetMoneyLab.centerX = self.width * 0.5;
    self.budgetMoneyTitleLab.top = top1;
    self.budgetMoneyLab.top = self.budgetMoneyTitleLab.bottom + gap;
    
    self.intervalTitleLab.centerX = self.intervalLab.centerX = self.width * 1.5;
    self.intervalTitleLab.top = top1;
    self.intervalLab.top = self.intervalTitleLab.bottom + gap;
    
    self.bottomView.frame = CGRectMake(0, self.topView.bottom, self.width, 170);
    self.payMoneyLab.leftTop = CGPointMake(15, 95);
    self.balanceLab.rightTop = CGPointMake(self.width - 15, 95);
    self.bottomLab.leftTop = CGPointMake(15, 128);
    self.waveView.frame = CGRectMake((self.width - 90) * 0.5, 16, 90, 90);
}

- (void)setBudgetModel:(SSJBudgetModel *)model {
    switch (model.type) {
        case 0:
            self.budgetMoneyTitleLab.text = @"本周预算";
            break;
            
        case 1:
            self.budgetMoneyTitleLab.text = @"本月预算";
            break;
            
        case 2:
            self.budgetMoneyTitleLab.text = @"本年预算";
            break;
    }
    [self.budgetMoneyTitleLab sizeToFit];
    
    self.budgetMoneyLab.text = [NSString stringWithFormat:@"￥%f", model.budgetMoney];
    [self.budgetMoneyLab sizeToFit];
    
    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [self.formatter dateFromString:dateString];
    NSDate *endDate = [self.formatter dateFromString:model.endDate];
    int interval = [endDate timeIntervalSinceDate:currentDate] / (24 * 60 * 60);
    self.intervalLab.text = [NSString stringWithFormat:@"%d天", interval];
    [self.intervalLab sizeToFit];
    
    self.payMoneyLab.text = [NSString stringWithFormat:@"已花：%f", model.payMoney];
    [self.payMoneyLab sizeToFit];
    
    if (model.payMoney <= model.budgetMoney) {
        [self.waveView setScale:(model.payMoney / model.budgetMoney)];
        [self.waveView setTopTitle:nil];
        [self.waveView setBottomTitle:[NSString stringWithFormat:@"%.0f％", (model.payMoney / model.budgetMoney * 100)]];
    } else {
        [self.waveView setScale:0.7];
        [self.waveView setTopTitle:@"超支"];
        [self.waveView setBottomTitle:[NSString stringWithFormat:@"%f", model.payMoney - model.budgetMoney]];
    }
    
    double balance = model.budgetMoney - model.payMoney;
    self.balanceLab.text = [NSString stringWithFormat:@"剩余：%f", balance];
    [self.balanceLab sizeToFit];
    
    if (balance >= 0) {
        self.bottomLab.text = [NSString stringWithFormat:@"距结算日前，您每天还可花%f元哦", balance / interval];
        [self.bottomLab sizeToFit];
    } else {
        self.bottomLab.text = [NSString stringWithFormat:@"亲爱的小主，您目前已超支%f元喽", ABS(balance)];
        [self.bottomLab sizeToFit];
    }
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        [_topView addSubview:self.budgetMoneyTitleLab];
        [_topView addSubview:self.budgetMoneyLab];
        [_topView addSubview:self.intervalTitleLab];
        [_topView addSubview:self.intervalLab];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:self.payMoneyLab];
        [_bottomView addSubview:self.balanceLab];
        [_bottomView addSubview:self.bottomLab];
        [_bottomLab addSubview:self.waveView];
    }
    return _bottomView;
}

- (UILabel *)budgetMoneyTitleLab {
    if (!_budgetMoneyTitleLab) {
        _budgetMoneyTitleLab = [[UILabel alloc] init];
        _budgetMoneyTitleLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _budgetMoneyTitleLab.textColor = [UIColor whiteColor];
        _budgetMoneyTitleLab.font = [UIFont systemFontOfSize:16];
    }
    return _budgetMoneyTitleLab;
}

- (UILabel *)budgetMoneyLab {
    if (!_budgetMoneyLab) {
        _budgetMoneyLab = [[UILabel alloc] init];
        _budgetMoneyLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _budgetMoneyLab.textColor = [UIColor whiteColor];
        _budgetMoneyLab.font = [UIFont systemFontOfSize:24];
    }
    return _budgetMoneyLab;
}

- (SSJBudgetWaveScaleView *)waveView {
    if (!_waveView) {
        _waveView = [[SSJBudgetWaveScaleView alloc] init];
    }
    return _waveView;
}

- (UILabel *)intervalTitleLab {
    if (!_intervalTitleLab) {
        _intervalTitleLab = [[UILabel alloc] init];
        _intervalTitleLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _intervalTitleLab.textColor = [UIColor whiteColor];
        _intervalTitleLab.font = [UIFont systemFontOfSize:16];
        _intervalTitleLab.text = @"据结算日";
        [_intervalTitleLab sizeToFit];
    }
    return _intervalTitleLab;
}

- (UILabel *)intervalLab {
    if (!_intervalLab) {
        _intervalLab = [[UILabel alloc] init];
        _intervalLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _intervalLab.textColor = [UIColor whiteColor];
        _intervalLab.font = [UIFont systemFontOfSize:24];
    }
    return _intervalLab;
}

- (UILabel *)payMoneyLab {
    if (!_payMoneyLab) {
        _payMoneyLab = [[UILabel alloc] init];
        _payMoneyLab.backgroundColor = [UIColor whiteColor];
        _payMoneyLab.textColor = [UIColor blackColor];
        _payMoneyLab.font = [UIFont systemFontOfSize:16];
    }
    return _payMoneyLab;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.backgroundColor = [UIColor whiteColor];
        _balanceLab.textColor = [UIColor blackColor];
        _balanceLab.font = [UIFont systemFontOfSize:16];
    }
    return _balanceLab;
}

- (UILabel *)bottomLab {
    if (!_bottomLab) {
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.backgroundColor = [UIColor whiteColor];
        _bottomLab.textColor = [UIColor blackColor];
        _bottomLab.font = [UIFont systemFontOfSize:16];
    }
    return _bottomLab;
}

@end
