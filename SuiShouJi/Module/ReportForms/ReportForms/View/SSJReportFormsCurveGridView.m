//
//  SSJReportFormsCurveGridView.m
//  SuiShouJi
//
//  Created by old lang on 16/6/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveGridView.h"

@interface SSJReportFormsCurveGridCell : UIView

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SSJReportFormsCurveGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont systemFontOfSize:12];
        _topLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [self addSubview:_topLabel];
        
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:22];
        [self addSubview:_bottomLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [_topLabel sizeToFit];
    [_bottomLabel sizeToFit];
    CGFloat top = (self.height - _topLabel.height - _bottomLabel.height - 10) * 0.5;
    _topLabel.top = top;
    _bottomLabel.top = _topLabel.bottom + 10;
    _topLabel.centerX = _bottomLabel.centerX = self.width * 0.5;
}

@end

@interface SSJReportFormsCurveGridView ()

@property (nonatomic, strong) SSJReportFormsCurveGridCell *incomeCell;

@property (nonatomic, strong) SSJReportFormsCurveGridCell *paymentCell;

@property (nonatomic, strong) SSJReportFormsCurveGridCell *surplusCell;

@property (nonatomic, strong) SSJReportFormsCurveGridCell *dailyPaymentCell;

@end

@implementation SSJReportFormsCurveGridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        
        UIColor *borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        
        _incomeCell = [[SSJReportFormsCurveGridCell alloc] init];
        _incomeCell.topLabel.text = @"期间收入（元）";
        _incomeCell.bottomLabel.text = @"0.00";
        _incomeCell.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
        [_incomeCell ssj_setBorderWidth:1];
        [_incomeCell ssj_setBorderColor:borderColor];
        [_incomeCell ssj_setBorderStyle:(SSJBorderStyleBottom | SSJBorderStyleRight)];
        [self addSubview:_incomeCell];
        
        _paymentCell = [[SSJReportFormsCurveGridCell alloc] init];
        _paymentCell.topLabel.text = @"期间支出（元）";
        _paymentCell.bottomLabel.text = @"0.00";
        _paymentCell.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
        [_paymentCell ssj_setBorderWidth:1];
        [_paymentCell ssj_setBorderColor:borderColor];
        [_paymentCell ssj_setBorderStyle:SSJBorderStyleBottom];
        [self addSubview:_paymentCell];
        
        _surplusCell = [[SSJReportFormsCurveGridCell alloc] init];
        _surplusCell.topLabel.text = @"期间结余（元）";
        _surplusCell.bottomLabel.text = @"0.00";
        _surplusCell.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_surplusCell ssj_setBorderWidth:1];
        [_surplusCell ssj_setBorderColor:borderColor];
        [_surplusCell ssj_setBorderStyle:SSJBorderStyleRight];
        [self addSubview:_surplusCell];
        
        _dailyPaymentCell = [[SSJReportFormsCurveGridCell alloc] init];
        _dailyPaymentCell.topLabel.text = @"日均花费（元）";
        _dailyPaymentCell.bottomLabel.text = @"0.00";
        _dailyPaymentCell.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [self addSubview:_dailyPaymentCell];
    }
    return self;
}

- (void)layoutSubviews {
    _incomeCell.frame = CGRectMake(0, 0, self.width * 0.5, self.height * 0.5);
    _paymentCell.frame = CGRectMake(self.width * 0.5, 0, self.width * 0.5, self.height * 0.5);
    _surplusCell.frame = CGRectMake(0, self.height * 0.5, self.width * 0.5, self.height * 0.5);
    _dailyPaymentCell.frame = CGRectMake(self.width * 0.5, self.height * 0.5, self.width * 0.5, self.height * 0.5);
    
    [_incomeCell ssj_relayoutBorder];
    [_paymentCell ssj_relayoutBorder];
    [_surplusCell ssj_relayoutBorder];
}

- (void)setIncome:(double)income {
    if (_income != income) {
        _income = income;
        _incomeCell.bottomLabel.text = [NSString stringWithFormat:@"%.2f", _income];
        [_incomeCell setNeedsLayout];
    }
}

- (void)setPayment:(double)payment {
    if (_payment != payment) {
        _payment = payment;
        _paymentCell.bottomLabel.text = [NSString stringWithFormat:@"%.2f", _payment];
        [_paymentCell setNeedsLayout];
    }
}

- (void)setSurplus:(double)surplus {
    if (_surplus != surplus) {
        _surplus = surplus;
        _surplusCell.bottomLabel.text = [NSString stringWithFormat:@"%.2f", _surplus];
        [_surplusCell setNeedsLayout];
    }
}

- (void)setDailyPayment:(double)dailyPayment {
    if (_dailyPayment != dailyPayment) {
        _dailyPayment = dailyPayment;
        _dailyPaymentCell.bottomLabel.text = [NSString stringWithFormat:@"%.2f", _dailyPayment];
        [_dailyPaymentCell setNeedsLayout];
    }
}

@end
