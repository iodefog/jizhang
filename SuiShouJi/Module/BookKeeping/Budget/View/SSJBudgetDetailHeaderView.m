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
#import "SSJPercentCircleView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJBudgetModel.h"

static const CGFloat kTopGap = 8;

static const CGFloat kTopViewHeight = 110;

static const CGFloat kCurrentMajorMiddleViewHeight = 265;

static const CGFloat kHistoryMajorMiddleViewHeight = 235;

static const CGFloat kCurrentSecondaryMiddleViewHeight = 180;

static const CGFloat kHistorySecondaryMiddleViewHeight = 140;

static const CGFloat kBottomViewHeight = 348;

@interface SSJBudgetDetailHeaderView () <SSJReportFormsPercentCircleDataSource>

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

//  预算类别
@property (nonatomic, strong) UILabel *billTypeLab;

@property (nonatomic, strong) SSJPercentCircleView *circleView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) NSArray <SSJPercentCircleViewItem *>*circleItems;

@end

@implementation SSJBudgetDetailHeaderView

#pragma mark -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.topView];
        [self addSubview:self.middleView];
        [self addSubview:self.bottomView];
        [self updateAppearance];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = 0;
    
    if (_item.isHistory) {
        height = _item.isMajor ? (kTopGap + kHistoryMajorMiddleViewHeight + kBottomViewHeight) : (kTopGap + kHistorySecondaryMiddleViewHeight + kBottomViewHeight);
    } else {
        height = _item.isMajor ? (kTopGap + kTopViewHeight + kCurrentMajorMiddleViewHeight + kBottomViewHeight) : (kTopGap + kTopViewHeight + kCurrentSecondaryMiddleViewHeight + kBottomViewHeight);
    }
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    CGFloat gap = 10;
    
    self.waveView.top = 15;
    self.waveView.centerX = self.width * 0.5;
    self.progressView.frame = CGRectMake(17, 30, self.width - 34, 34);
    
    [self.budgetMoneyTitleLab sizeToFit];
    [self.budgetMoneyLab sizeToFit];
    [self.intervalTitleLab sizeToFit];
    [self.intervalLab sizeToFit];
    [self.payMoneyLab sizeToFit];
    [self.historyPaymentLab sizeToFit];
    [self.estimateMoneyLab sizeToFit];
    [self.payOrOverrunLab sizeToFit];
    [self.billTypeLab sizeToFit];
    
    UIView *tmpView = _item.isMajor ? self.waveView : self.progressView;
    
    if (_item.isHistory) {
        
        CGFloat middleHeight = _item.isMajor ? kHistoryMajorMiddleViewHeight : kHistorySecondaryMiddleViewHeight;
        self.middleView.frame = CGRectMake(0, kTopGap, self.width, middleHeight);
        
        self.estimateMoneyLab.top = self.historyPaymentLab.top = tmpView.bottom + 15;
        self.estimateMoneyLab.width = MIN(self.estimateMoneyLab.width, (self.width - 80) * 0.5);
        self.estimateMoneyLab.right = self.width - 10;
        self.historyPaymentLab.width = MIN(self.historyPaymentLab.width, (self.width - 80) * 0.5);
        self.historyPaymentLab.left = 10;
        
    } else {
        
        self.topView.frame = CGRectMake(0, kTopGap, self.width, kTopViewHeight);
        
        CGFloat middleHeight = _item.isMajor ? kCurrentMajorMiddleViewHeight : kCurrentSecondaryMiddleViewHeight;
        self.middleView.frame = CGRectMake(0, self.topView.bottom, self.width, middleHeight);
        
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
        self.payMoneyLab.top = tmpView.bottom + 15;
        self.payOrOverrunLab.top = self.payMoneyLab.bottom + 13;
        self.payMoneyLab.centerX = self.payOrOverrunLab.centerX = self.width * 0.5;
        
        self.dashLine.left = self.topView.width * 0.5;
        self.dashLine.top = 30;
    }
    
    self.bottomView.frame = CGRectMake(0, self.middleView.bottom, self.width, kBottomViewHeight);
    [self.bottomView ssj_relayoutWatermark];
    
    self.billTypeLab.top = 26;
    self.billTypeLab.width = MIN(self.billTypeLab.width, self.bottomView.width - 48);
    if (_item.isMajor) {
        self.billTypeLab.centerX = self.bottomView.width * 0.5;
    } else {
        self.billTypeLab.left = 24;
    }
    
    self.circleView.frame = CGRectMake(0, 70, self.width, 270);
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle {
    return self.circleItems.count;
}

- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index {
    return [self.circleItems ssj_safeObjectAtIndex:index];
}

#pragma mark - Private
- (void)updateSubviewHidden {
    self.topView.hidden = _item.isHistory;
    self.payMoneyLab.hidden = _item.isHistory;
    self.estimateMoneyLab.hidden = !_item.isHistory;
    self.historyPaymentLab.hidden = !_item.isHistory;
    self.payOrOverrunLab.hidden = _item.isHistory;
    self.waveView.hidden = !_item.isMajor;
    self.progressView.hidden = _item.isMajor;
}

- (void)setCircleItems:(NSArray<SSJPercentCircleViewItem *> *)circleItems {
    if (![_circleItems isEqualToArray:circleItems]) {
        _circleItems = circleItems;
        [self.circleView reloadData];
        
        if (self.circleItems.count > 0) {
            self.billTypeLab.hidden = NO;
            [self.bottomView ssj_hideWatermark:YES];
        } else {
            self.billTypeLab.hidden = YES;
            [self.bottomView ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:NULL];
        }
    }
}

#pragma mark - Public
- (void)setItem:(SSJBudgetDetailHeaderViewItem *)item {
    _item = item;
    [self sizeToFit];
    [self setNeedsLayout];
    
    self.budgetMoneyTitleLab.text = item.budgetMoneyTitle;
    self.budgetMoneyLab.text = item.budgetMoneyValue;
    
    self.intervalTitleLab.text = item.intervalTitle;
    self.intervalLab.text = item.intervalValue;
    
    self.waveView.budgetMoney = item.budgetMoney;
    self.waveView.expendMoney = item.expendMoney;
    
    self.progressView.budgetMoney = item.budgetMoney;
    self.progressView.expendMoney = item.expendMoney;
    
    [self.progressView setProgressColor:[UIColor ssj_colorWithHex:item.progressColorValue]];
    [self.progressView setOverrunProgressColor:[UIColor ssj_colorWithHex:@"ff654c"]];
    
    self.payMoneyLab.text = item.payment;
    
    self.historyPaymentLab.attributedText = item.historyPayment;
    self.estimateMoneyLab.attributedText = item.historyBudget;
    self.payOrOverrunLab.attributedText = item.payOrOverrun;
    self.billTypeLab.text = item.billTypeNames;
    
    self.circleItems = item.circleItems;
    
    [self updateAppearance];
    [self updateSubviewHidden];
}

- (void)updateAppearance {
    _budgetMoneyTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _budgetMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _intervalTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _intervalLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    _payMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _historyPaymentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _estimateMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _billTypeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    _topView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _middleView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_middleView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _dashLine.strokeColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    
    _circleView.addtionTextColor = SSJ_SECONDARY_COLOR;
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        [_topView addSubview:self.budgetMoneyTitleLab];
        [_topView addSubview:self.budgetMoneyLab];
        [_topView addSubview:self.intervalTitleLab];
        [_topView addSubview:self.intervalLab];
        [_topView.layer addSublayer:self.dashLine];
        [_topView ssj_setBorderWidth:2];
        [_topView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
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
        [_middleView ssj_setBorderInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_middleView ssj_setBorderWidth:2];
        [_middleView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _middleView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView addSubview:self.billTypeLab];
        [_bottomView addSubview:self.circleView];
        [_bottomView ssj_setBorderWidth:2];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _bottomView;
}

- (UILabel *)budgetMoneyTitleLab {
    if (!_budgetMoneyTitleLab) {
        _budgetMoneyTitleLab = [[UILabel alloc] init];
        _budgetMoneyTitleLab.backgroundColor = [UIColor clearColor];
        _budgetMoneyTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _budgetMoneyTitleLab;
}

- (UILabel *)budgetMoneyLab {
    if (!_budgetMoneyLab) {
        _budgetMoneyLab = [[UILabel alloc] init];
        _budgetMoneyLab.backgroundColor = [UIColor clearColor];
        _budgetMoneyLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_1];
        _budgetMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _budgetMoneyLab;
}

- (UILabel *)intervalTitleLab {
    if (!_intervalTitleLab) {
        _intervalTitleLab = [[UILabel alloc] init];
        _intervalTitleLab.backgroundColor = [UIColor clearColor];
        _intervalTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _intervalTitleLab.text = @"距结算日";
        [_intervalTitleLab sizeToFit];
    }
    return _intervalTitleLab;
}

- (UILabel *)intervalLab {
    if (!_intervalLab) {
        _intervalLab = [[UILabel alloc] init];
        _intervalLab.backgroundColor = [UIColor clearColor];
        _intervalLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_1];
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
        _dashLine.lineWidth = 1;
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
        _waveView.outerBorderWidth = 8;
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
        _payMoneyLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_2];
        _payMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _payMoneyLab;
}

- (UILabel *)historyPaymentLab {
    if (!_historyPaymentLab) {
        _historyPaymentLab = [[UILabel alloc] init];
        _historyPaymentLab.backgroundColor = [UIColor clearColor];
        _historyPaymentLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _historyPaymentLab.adjustsFontSizeToFitWidth = YES;
    }
    return _historyPaymentLab;
}

- (UILabel *)estimateMoneyLab {
    if (!_estimateMoneyLab) {
        _estimateMoneyLab = [[UILabel alloc] init];
        _estimateMoneyLab.backgroundColor = [UIColor clearColor];
        _estimateMoneyLab.textAlignment = NSTextAlignmentRight;
        _estimateMoneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _estimateMoneyLab.adjustsFontSizeToFitWidth = YES;
    }
    return _estimateMoneyLab;
}

- (UILabel *)payOrOverrunLab {
    if (!_payOrOverrunLab) {
        _payOrOverrunLab = [[UILabel alloc] init];
        _payOrOverrunLab.backgroundColor = [UIColor clearColor];
        _payOrOverrunLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _payOrOverrunLab;
}

- (UILabel *)billTypeLab {
    if (!_billTypeLab) {
        _billTypeLab = [[UILabel alloc] init];
        _billTypeLab.backgroundColor = [UIColor clearColor];
        _billTypeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _billTypeLab.adjustsFontSizeToFitWidth = YES;
    }
    return _billTypeLab;
}

- (SSJPercentCircleView *)circleView {
    if (!_circleView) {
        _circleView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero radius:80 thickness:20 lineLength1:15 lineLength2:10];
        _circleView.backgroundColor = [UIColor clearColor];
        _circleView.dataSource = self;
    }
    return _circleView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] init];
        _noDataRemindView.image = @"loan_noDataRemind";
        _noDataRemindView.title = @"NO，小主居然忘记记账了！";
    }
    return _noDataRemindView;
}

@end
