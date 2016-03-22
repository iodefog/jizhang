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

//  包涵本周期预算金额、据结算日天数的视图
@property (nonatomic, strong) UIView *topView;

//  包涵waveView、payMoneyLab、estimateMoneyLab、bottomLab的视图
@property (nonatomic, strong) UIView *bottomView;

//  顶部的本月预算标题
@property (nonatomic, strong) UILabel *budgetMoneyTitleLab;

//  顶部的本月预算金额
@property (nonatomic, strong) UILabel *budgetMoneyLab;

//  顶部的据结算日标题
@property (nonatomic, strong) UILabel *intervalTitleLab;

//  顶部的据结算日天数
@property (nonatomic, strong) UILabel *intervalLab;

//  波浪比例视图
@property (nonatomic, strong) SSJBudgetWaveScaleView *waveView;

//  已花费金额
@property (nonatomic, strong) UILabel *payMoneyLab;

//  预算金额（只在历史预算中显示）
@property (nonatomic, strong) UILabel *estimateMoneyLab;

//  每天可以花费金额、超支金额
@property (nonatomic, strong) UILabel *bottomLab;

//  时间格式
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

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = self.isHistory ? 152 : 295;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    CGFloat gap = 10;
    
    self.waveView.top = 15;
    self.waveView.centerX = self.width * 0.5;
    
    if (self.isHistory) {
        self.bottomView.frame = CGRectMake(0, 0, self.width, 200);
        
        self.payMoneyLab.width = MIN(self.payMoneyLab.width, (self.width - 80) * 0.5);
        self.estimateMoneyLab.width = MIN(self.estimateMoneyLab.width, (self.width - 80) * 0.5);
        self.payMoneyLab.top = self.estimateMoneyLab.top = self.waveView.bottom + 15;
        self.payMoneyLab.left = 30;
        self.estimateMoneyLab.right = self.width - 30;
    } else {
        self.topView.frame = CGRectMake(0, 0, self.width, 95);
        self.bottomView.frame = CGRectMake(0, self.topView.bottom, self.width, 200);
        
        CGFloat top1 = (self.topView.height - self.budgetMoneyTitleLab.height - self.budgetMoneyLab.height - gap) * 0.5;
        
        self.budgetMoneyLab.width = MIN(self.budgetMoneyLab.width, self.width * 0.5 - 20);
        self.budgetMoneyTitleLab.top = top1;
        self.budgetMoneyLab.top = self.budgetMoneyTitleLab.bottom + gap;
        self.budgetMoneyTitleLab.centerX = self.budgetMoneyLab.centerX = self.width * 0.25;
        
        self.intervalTitleLab.top = top1;
        self.intervalLab.top = self.intervalTitleLab.bottom + gap;
        self.intervalTitleLab.centerX = self.intervalLab.centerX = self.width * 0.75;
        
        self.payMoneyLab.width = MIN(self.payMoneyLab.width, self.width - 20);
        self.bottomLab.width = MIN(self.bottomLab.width, self.width - 20);
        self.payMoneyLab.top = self.waveView.bottom + 15;
        self.bottomLab.top = self.payMoneyLab.bottom + 13;
        self.payMoneyLab.centerX = self.bottomLab.centerX = self.width * 0.5;
    }
}

- (void)setIsHistory:(BOOL)isHistory {
    if (_isHistory != isHistory) {
        _isHistory = isHistory;
        
        self.topView.hidden = isHistory;
        self.estimateMoneyLab.hidden = !isHistory;
        self.bottomLab.hidden = isHistory;
        
        [self sizeToFit];
    }
}

- (void)setBudgetModel:(SSJBudgetModel *)model {
    [self setNeedsLayout];
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
    
    self.budgetMoneyLab.text = [NSString stringWithFormat:@"￥%.2f", model.budgetMoney];
    [self.budgetMoneyLab sizeToFit];
    
    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [self.formatter dateFromString:dateString];
    NSDate *endDate = [self.formatter dateFromString:model.endDate];
    int interval = [endDate timeIntervalSinceDate:currentDate] / (24 * 60 * 60) + 1;
    self.intervalLab.text = [NSString stringWithFormat:@"%d天", interval];
    [self.intervalLab sizeToFit];
    
    self.waveView.title = model.payMoney <= model.budgetMoney ? @"剩余" : @"超支";
    [self.waveView setScale:(model.payMoney / model.budgetMoney)];
    [self.waveView setSubtitlle:[NSString stringWithFormat:@"%.2f", model.budgetMoney - model.payMoney]];
    
    self.payMoneyLab.text = [NSString stringWithFormat:@"已花：%.2f", model.payMoney];
    [self.payMoneyLab sizeToFit];
    
    self.estimateMoneyLab.text = [NSString stringWithFormat:@"预算：%.2f", model.budgetMoney];
    [self.estimateMoneyLab sizeToFit];
    
    double balance = model.budgetMoney - model.payMoney;
    if (balance >= 0) {
        NSString *money = [NSString stringWithFormat:@"%.2f", balance / interval];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"距结算日前，您每天还可花%@元哦", money]];
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"47cfbe"]} range:NSMakeRange(12, money.length)];
        self.bottomLab.attributedText = text;
        [self.bottomLab sizeToFit];
    } else {
        NSString *money = [NSString stringWithFormat:@"%.2f", ABS(balance)];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您目前已超支%@元喽", money]];
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(12, money.length)];
        self.bottomLab.attributedText = text;
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
        [_bottomView addSubview:self.waveView];
        [_bottomView addSubview:self.payMoneyLab];
        [_bottomView addSubview:self.bottomLab];
        [_bottomView addSubview:self.estimateMoneyLab];
    }
    return _bottomView;
}

- (UILabel *)budgetMoneyTitleLab {
    if (!_budgetMoneyTitleLab) {
        _budgetMoneyTitleLab = [[UILabel alloc] init];
        _budgetMoneyTitleLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _budgetMoneyTitleLab.textColor = [UIColor whiteColor];
        _budgetMoneyTitleLab.font = [UIFont systemFontOfSize:12];
    }
    return _budgetMoneyTitleLab;
}

- (UILabel *)budgetMoneyLab {
    if (!_budgetMoneyLab) {
        _budgetMoneyLab = [[UILabel alloc] init];
        _budgetMoneyLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _budgetMoneyLab.textColor = [UIColor whiteColor];
        _budgetMoneyLab.font = [UIFont systemFontOfSize:18];
    }
    return _budgetMoneyLab;
}

- (SSJBudgetWaveScaleView *)waveView {
    if (!_waveView) {
        _waveView = [[SSJBudgetWaveScaleView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    }
    return _waveView;
}

- (UILabel *)intervalTitleLab {
    if (!_intervalTitleLab) {
        _intervalTitleLab = [[UILabel alloc] init];
        _intervalTitleLab.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        _intervalTitleLab.textColor = [UIColor whiteColor];
        _intervalTitleLab.font = [UIFont systemFontOfSize:12];
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
        _intervalLab.font = [UIFont systemFontOfSize:18];
    }
    return _intervalLab;
}

- (UILabel *)payMoneyLab {
    if (!_payMoneyLab) {
        _payMoneyLab = [[UILabel alloc] init];
        _payMoneyLab.backgroundColor = [UIColor whiteColor];
        _payMoneyLab.textColor = [UIColor blackColor];
        _payMoneyLab.font = [UIFont systemFontOfSize:14];
    }
    return _payMoneyLab;
}

- (UILabel *)estimateMoneyLab {
    if (!_estimateMoneyLab) {
        _estimateMoneyLab = [[UILabel alloc] init];
        _estimateMoneyLab.backgroundColor = [UIColor whiteColor];
        _estimateMoneyLab.textColor = [UIColor blackColor];
        _estimateMoneyLab.font = [UIFont systemFontOfSize:14];
    }
    return _payMoneyLab;
}

- (UILabel *)bottomLab {
    if (!_bottomLab) {
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.backgroundColor = [UIColor whiteColor];
        _bottomLab.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _bottomLab.font = [UIFont systemFontOfSize:12];
    }
    return _bottomLab;
}

@end
