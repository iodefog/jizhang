//
//  SSJBudgetDetailHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetWaveWaterView.h"
#import "SSJBudgetProgressView.h"
#import "SSJBudgetModel.h"

static const CGFloat kTopViewHeight = 110;

static const CGFloat kCurrentMajorMiddleViewHeight = 265;

static const CGFloat kHistoryMajorMiddleViewHeight = 235;

static const CGFloat kSecondaryMiddleViewHeight = 188;

static const CGFloat kBottomViewHeight = 398;

@interface SSJBudgetDetailHeaderView ()

//  包涵本周期预算金额、据结算日天数的视图
@property (nonatomic, strong) UIView *topView;

//  包涵waveView、payMoneyLab、estimateMoneyLab、payOrOverrunLab的视图
@property (nonatomic, strong) UIView *middleView;

@property (nonatomic, strong) UIView *bottomView;

//  顶部的本月预算标题
@property (nonatomic, strong) UILabel *budgetMoneyTitleLab;

//  顶部的本月预算金额
@property (nonatomic, strong) UILabel *budgetMoneyLab;

//  顶部的据结算日标题
@property (nonatomic, strong) UILabel *intervalTitleLab;

//  顶部的据结算日天数
@property (nonatomic, strong) UILabel *intervalLab;

@property (nonatomic, strong) CAShapeLayer *dashLine;

//  波浪比例视图
@property (nonatomic, strong) SSJBudgetWaveWaterView *waveView;

@property (nonatomic, strong) SSJBudgetProgressView *progressView;

//  已花费金额
@property (nonatomic, strong) UILabel *payMoneyLab;

//  历史预算的已花费金额
@property (nonatomic, strong) UILabel *historyPaymentLab;

//  预算金额（只在历史预算中显示）
@property (nonatomic, strong) UILabel *estimateMoneyLab;

//  每天可以花费金额、超支金额
@property (nonatomic, strong) UILabel *payOrOverrunLab;

//  时间格式
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation SSJBudgetDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"yyyy-MM-dd";
        
        [self addSubview:self.topView];
        [self addSubview:self.middleView];
        self.backgroundColor = [UIColor clearColor];
        [self updateAppearance];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = 0;
    
    if (_item.isHistory) {
        height = _item.isMajor ? (kHistoryMajorMiddleViewHeight + kBottomViewHeight) : (kSecondaryMiddleViewHeight + kBottomViewHeight);
    } else {
        height = _item.isMajor ? (kCurrentMajorMiddleViewHeight + kBottomViewHeight) : (kSecondaryMiddleViewHeight + kBottomViewHeight);
    }
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    CGFloat gap = 10;
    
    self.waveView.top = 15;
    self.waveView.centerX = self.width * 0.5;
    
    [self.budgetMoneyTitleLab sizeToFit];
    [self.budgetMoneyLab sizeToFit];
    [self.intervalTitleLab sizeToFit];
    [self.intervalLab sizeToFit];
    [self.payMoneyLab sizeToFit];
    [self.historyPaymentLab sizeToFit];
    [self.estimateMoneyLab sizeToFit];
    [self.payOrOverrunLab sizeToFit];
    
    if (_item.isHistory) {
        self.middleView.frame = CGRectMake(0, 0, self.width, kHistoryMajorMiddleViewHeight);
        self.estimateMoneyLab.top = self.historyPaymentLab.top = self.waveView.bottom + 15;
        self.estimateMoneyLab.width = MIN(self.estimateMoneyLab.width, (self.width - 80) * 0.5);
        self.estimateMoneyLab.right = self.width - 10;
        self.historyPaymentLab.width = MIN(self.historyPaymentLab.width, (self.width - 80) * 0.5);
        self.historyPaymentLab.left = 10;
    } else {
        self.topView.frame = CGRectMake(0, 0, self.width, kTopViewHeight);
        [self.topView ssj_relayoutBorder];
        self.middleView.frame = CGRectMake(0, self.topView.bottom, self.width, kCurrentMajorMiddleViewHeight);
        
        CGFloat top1 = (self.topView.height - self.budgetMoneyTitleLab.height - self.budgetMoneyLab.height - gap) * 0.5;
        
        self.budgetMoneyLab.width = MIN(self.budgetMoneyLab.width, self.width * 0.5 - 20);
        self.budgetMoneyTitleLab.top = top1;
        self.budgetMoneyLab.top = self.budgetMoneyTitleLab.bottom + gap;
        self.budgetMoneyTitleLab.centerX = self.budgetMoneyLab.centerX = self.width * 0.25;
        
        self.intervalTitleLab.top = top1;
        self.intervalLab.top = self.intervalTitleLab.bottom + gap;
        self.intervalTitleLab.centerX = self.intervalLab.centerX = self.width * 0.75;
        
        self.payMoneyLab.width = MIN(self.payMoneyLab.width, self.width - 20);
        self.payOrOverrunLab.width = MIN(self.payOrOverrunLab.width, self.width - 20);
        self.payMoneyLab.top = self.waveView.bottom + 15;
        self.payOrOverrunLab.top = self.payMoneyLab.bottom + 13;
        self.payMoneyLab.centerX = self.payOrOverrunLab.centerX = self.width * 0.5;
        
        self.dashLine.left = self.topView.width * 0.5;
        self.dashLine.top = 30;
    }
}

- (void)updateSubviewHidden {
    self.topView.hidden = _item.isHistory;
    self.payMoneyLab.hidden = _item.isHistory;
    self.estimateMoneyLab.hidden = !_item.isHistory;
    self.historyPaymentLab.hidden = !_item.isHistory;
    self.payOrOverrunLab.hidden = _item.isHistory;
}

- (void)setItem:(SSJBudgetDetailHeaderViewItem *)item {
    _item = item;
    [self setNeedsLayout];
    
    self.budgetMoneyTitleLab.text = item.budgetMoneyTitle;
    self.budgetMoneyLab.text = item.budgetMoneyValue;
    
    self.intervalTitleLab.text = item.intervalTitle;
    self.intervalLab.text = item.intervalValue;
    
    self.waveView.percent = item.waveViewPercent;
    self.waveView.money = item.waveViewMoney;
    
    self.progressView.progress = item.progressViewPercent;
    self.progressView.budget = item.progressViewMoney;
    [self.progressView setProgressColor:[UIColor ssj_colorWithHex:item.progressColorValue]];
    
    self.payMoneyLab.text = item.payment;
    
    self.historyPaymentLab.attributedText = item.historyPayment;
    self.estimateMoneyLab.attributedText = item.historyBudget;
    self.payOrOverrunLab.attributedText = item.payOrOverrun;
    
    [self updateAppearance];
    [self updateSubviewHidden];
    [self sizeToFit];
}

//- (void)setBudgetModel:(SSJBudgetModel *)budgetModel {
//    [self setNeedsLayout];
//    _budgetModel = budgetModel;
//    
//    NSString *budgetType = @"";
//    
//    switch (_budgetModel.type) {
//        case SSJBudgetPeriodTypeWeek:
//            budgetType = @"周";
//            self.budgetMoneyTitleLab.text = @"周预算金额";
//            break;
//            
//        case SSJBudgetPeriodTypeMonth:
//            budgetType = @"月";
//            self.budgetMoneyTitleLab.text = @"月预算金额";
//            break;
//            
//        case SSJBudgetPeriodTypeYear:
//            budgetType = @"年";
//            
//            break;
//    }
//    
//    self.budgetMoneyTitleLab.text = [NSString stringWithFormat:@"%@预算", budgetType];
//    [self.budgetMoneyTitleLab sizeToFit];
//    
//    self.budgetMoneyLab.text = [NSString stringWithFormat:@"￥%.2f", _budgetModel.budgetMoney];
//    [self.budgetMoneyLab sizeToFit];
//    
//    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
//    NSDate *currentDate = [self.formatter dateFromString:dateString];
//    NSDate *endDate = [self.formatter dateFromString:_budgetModel.endDate];
//    int interval = [endDate timeIntervalSinceDate:currentDate] / (24 * 60 * 60);
//    self.intervalLab.text = [NSString stringWithFormat:@"%d天", interval];
//    [self.intervalLab sizeToFit];
//    
//    self.waveView.percent = (_budgetModel.payMoney / _budgetModel.budgetMoney);
//    self.waveView.money = _budgetModel.budgetMoney - _budgetModel.payMoney;
//    
//    self.payMoneyLab.text = [NSString stringWithFormat:@"已花：%.2f", _budgetModel.payMoney];
//    [self.payMoneyLab sizeToFit];
//    
//    NSMutableAttributedString *paymentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", _budgetModel.payMoney]];
//    [paymentStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
//                                NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, paymentStr.length - 3)];
//    self.historyPaymentLab.attributedText = paymentStr;
//    [self.historyPaymentLab sizeToFit];
//    
//    NSMutableAttributedString *budgetStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@预算：%.2f", budgetType, _budgetModel.budgetMoney]];
//    [budgetStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
//                                NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(4, budgetStr.length - 4)];
//    self.estimateMoneyLab.attributedText = budgetStr;
//    [self.estimateMoneyLab sizeToFit];
//    
//    double balance = _budgetModel.budgetMoney - _budgetModel.payMoney;
//    if (balance >= 0) {
//        NSString *money = [NSString stringWithFormat:@"%.2f", balance / interval];
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"距结算日前，您每天还可花%@元哦", money]];
//        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(12, money.length)];
//        self.payOrOverrunLab.attributedText = text;
//        [self.payOrOverrunLab sizeToFit];
//    } else {
//        NSString *money = [NSString stringWithFormat:@"%.2f", ABS(balance)];
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您目前已超支%@元喽", money]];
//        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(12, money.length)];
//        self.payOrOverrunLab.attributedText = text;
//        [self.payOrOverrunLab sizeToFit];
//    }
//    
//    [self updateAppearance];
//}

- (void)updateAppearance {
    _budgetMoneyTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _budgetMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _intervalTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _intervalLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    _payMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _historyPaymentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _estimateMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _payOrOverrunLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _dashLine.strokeColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        [_topView addSubview:self.budgetMoneyTitleLab];
        [_topView addSubview:self.budgetMoneyLab];
        [_topView addSubview:self.intervalTitleLab];
        [_topView addSubview:self.intervalLab];
        [_topView.layer addSublayer:self.dashLine];
        [_topView ssj_setBorderWidth:1];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _topView;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView = [[UIView alloc] init];
        [_middleView addSubview:self.waveView];
        [_middleView addSubview:self.progressView];
        [_middleView addSubview:self.payMoneyLab];
        [_middleView addSubview:self.payOrOverrunLab];
        [_middleView addSubview:self.historyPaymentLab];
        [_middleView addSubview:self.estimateMoneyLab];
    }
    return _middleView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        
    }
    return _bottomView;
}

- (UILabel *)budgetMoneyTitleLab {
    if (!_budgetMoneyTitleLab) {
        _budgetMoneyTitleLab = [[UILabel alloc] init];
        _budgetMoneyTitleLab.backgroundColor = [UIColor clearColor];
        _budgetMoneyTitleLab.font = [UIFont systemFontOfSize:13];
    }
    return _budgetMoneyTitleLab;
}

- (UILabel *)budgetMoneyLab {
    if (!_budgetMoneyLab) {
        _budgetMoneyLab = [[UILabel alloc] init];
        _budgetMoneyLab.backgroundColor = [UIColor clearColor];
        _budgetMoneyLab.font = [UIFont systemFontOfSize:22];
        _budgetMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _budgetMoneyLab;
}

- (UILabel *)intervalTitleLab {
    if (!_intervalTitleLab) {
        _intervalTitleLab = [[UILabel alloc] init];
        _intervalTitleLab.backgroundColor = [UIColor clearColor];
        _intervalTitleLab.font = [UIFont systemFontOfSize:13];
        _intervalTitleLab.text = @"距结算日";
        [_intervalTitleLab sizeToFit];
    }
    return _intervalTitleLab;
}

- (UILabel *)intervalLab {
    if (!_intervalLab) {
        _intervalLab = [[UILabel alloc] init];
        _intervalLab.backgroundColor = [UIColor clearColor];
        _intervalLab.font = [UIFont systemFontOfSize:22];
    }
    return _intervalLab;
}

- (CAShapeLayer *)dashLine {
    if (!_dashLine) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(0, 52)];
        
        _dashLine = [CAShapeLayer layer];
//        _dashLine.lineDashPattern = @[@4, @4];
        _dashLine.lineWidth = 1 / [UIScreen mainScreen].scale;
        _dashLine.fillColor = [UIColor whiteColor].CGColor;
        _dashLine.path = path.CGPath;
    }
    return _dashLine;
}

- (SSJBudgetWaveWaterView *)waveView {
    if (!_waveView) {
        _waveView = [[SSJBudgetWaveWaterView alloc] initWithRadius:160];
        _waveView.waveAmplitude = 12;
        _waveView.waveSpeed = 5;
        _waveView.waveCycle = 1;
        _waveView.waveGrowth = 3;
        _waveView.waveOffset = 60;
        _waveView.fullWaveAmplitude = 8;
        _waveView.fullWaveSpeed = 4;
        _waveView.fullWaveCycle = 4;
        _waveView.outerBorderWidth = 8;
        _waveView.showText = YES;
    }
    return _waveView;
}

- (SSJBudgetProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[SSJBudgetProgressView alloc] init];
    }
    return _progressView;
}

- (UILabel *)payMoneyLab {
    if (!_payMoneyLab) {
        _payMoneyLab = [[UILabel alloc] init];
        _payMoneyLab.backgroundColor = [UIColor clearColor];
        _payMoneyLab.font = [UIFont systemFontOfSize:20];
        _payMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _payMoneyLab;
}

- (UILabel *)historyPaymentLab {
    if (!_historyPaymentLab) {
        _historyPaymentLab = [[UILabel alloc] init];
        _historyPaymentLab.backgroundColor = [UIColor clearColor];
        _historyPaymentLab.font = [UIFont systemFontOfSize:13];
        _historyPaymentLab.adjustsFontSizeToFitWidth = YES;
    }
    return _historyPaymentLab;
}

- (UILabel *)estimateMoneyLab {
    if (!_estimateMoneyLab) {
        _estimateMoneyLab = [[UILabel alloc] init];
        _estimateMoneyLab.backgroundColor = [UIColor clearColor];
        _estimateMoneyLab.textAlignment = NSTextAlignmentRight;
        _estimateMoneyLab.font = [UIFont systemFontOfSize:13];
        _estimateMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _estimateMoneyLab;
}

- (UILabel *)payOrOverrunLab {
    if (!_payOrOverrunLab) {
        _payOrOverrunLab = [[UILabel alloc] init];
        _payOrOverrunLab.backgroundColor = [UIColor clearColor];
        _payOrOverrunLab.font = [UIFont systemFontOfSize:13];
    }
    return _payOrOverrunLab;
}

@end
