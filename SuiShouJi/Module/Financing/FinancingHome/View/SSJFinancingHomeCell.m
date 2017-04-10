//
//  SSJFinancingHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeCell.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJCreditCardStore.h"
#import "SSJDatabaseQueue.h"

static const CGFloat kRadius = 8.f;

@interface SSJFinancingHomeCell()
@property(nonatomic, strong) UILabel *fundingNameLabel;
@property(nonatomic, strong) UILabel *fundingMemoLabel;
@property(nonatomic, strong) UIImageView *fundingImage;
@property(nonatomic, strong) UILabel *cardMemoLabel;
@property(nonatomic, strong) UILabel *cardLimitLabel;
@property(nonatomic, strong) UILabel *cardBillingDayLabel;
@property(nonatomic, strong) CAGradientLayer *backLayer;
@property(nonatomic, strong) UIButton *deleteButton;
@end

@implementation SSJFinancingHomeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView.layer addSublayer:self.backLayer];
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.fundingImage];
        [self.contentView addSubview:self.fundingBalanceLabel];
        [self.contentView addSubview:self.fundingNameLabel];
        [self.contentView addSubview:self.fundingMemoLabel];
        [self.contentView addSubview:self.cardMemoLabel];
        [self.contentView addSubview:self.cardBillingDayLabel];
        [self addObserver];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

- (void)addObserver {
    [self addObserver:_financingItem forKeyPath:@"fundingName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"fundingColor" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"fundingIcon" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"fundingParent" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"fundingBalance" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"fundingMemo" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_creditItem forKeyPath:@"cardId" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentId" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"cardBillingDay" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"cardRepaymentDay" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"cardName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"applyDate" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentMonth" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentSourceFoundId" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentSourceFoundName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentSourceFoundImage" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentMoney" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"repaymentChargeId" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"sourceChargeId" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"instalmentCout" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"currentInstalmentCout" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"poundageRate" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:_financingItem forKeyPath:@"memo" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver {
    [self removeObserver:_financingItem forKeyPath:@"fundingName"];
    [self removeObserver:_financingItem forKeyPath:@"fundingColor"];
    [self removeObserver:_financingItem forKeyPath:@"fundingIcon"];
    [self removeObserver:_financingItem forKeyPath:@"fundingParent"];
    [self removeObserver:_financingItem forKeyPath:@"fundingBalance"];
    [self removeObserver:_financingItem forKeyPath:@"fundingMemo"];
    [self removeObserver:_creditItem forKeyPath:@"cardId"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentId"];
    [self removeObserver:_financingItem forKeyPath:@"cardBillingDay"];
    [self removeObserver:_financingItem forKeyPath:@"cardRepaymentDay"];
    [self removeObserver:_financingItem forKeyPath:@"cardName"];
    [self removeObserver:_financingItem forKeyPath:@"applyDate"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentMonth"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentSourceFoundId"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentSourceFoundName"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentSourceFoundImage"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentMoney"];
    [self removeObserver:_financingItem forKeyPath:@"repaymentChargeId"];
    [self removeObserver:_financingItem forKeyPath:@"sourceChargeId"];
    [self removeObserver:_financingItem forKeyPath:@"instalmentCout"];
    [self removeObserver:_financingItem forKeyPath:@"currentInstalmentCout"];
    [self removeObserver:_financingItem forKeyPath:@"poundageRate"];
    [self removeObserver:_financingItem forKeyPath:@"memo"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.fundingImage.left = 20;
    self.fundingImage.centerY = self.contentView.height / 2 + 5;
    self.deleteButton.size = CGSizeMake(30, 30);
    self.deleteButton.rightTop = CGPointMake(self.contentView.width, -5);
    if (_financingItem) {
        self.fundingBalanceLabel.centerY = self.fundingImage.centerY;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        if (!_financingItem.fundingMemo.length) {
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingNameLabel.centerY = self.fundingImage.centerY;
        }else{
            self.fundingNameLabel.bottom = self.fundingImage.centerY - 3;
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingMemoLabel.top = self.fundingImage.centerY + 3;
            self.fundingMemoLabel.left = self.fundingImage.right + 10;
        }
        if (self.fundingNameLabel.right > self.fundingBalanceLabel.left) {
            self.fundingNameLabel.width = self.fundingBalanceLabel.left - self.fundingNameLabel.left - 20;
        }
        if (self.fundingMemoLabel.right > self.fundingBalanceLabel.left) {
            self.fundingMemoLabel.width = self.fundingBalanceLabel.left - self.fundingMemoLabel.left - 20;
        }
    }else{
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        self.fundingNameLabel.bottom = self.fundingImage.centerY - 3;
        self.fundingNameLabel.left = self.fundingImage.right + 10;
        self.fundingMemoLabel.top = self.fundingImage.centerY + 3;
        self.fundingMemoLabel.left = self.fundingImage.right + 10;
        if (_creditItem.cardRepaymentDay == 0 && _creditItem.cardBillingDay == 0) {
            self.fundingBalanceLabel.centerY = self.fundingImage.centerY;
        }else{
            self.fundingBalanceLabel.centerY = self.fundingNameLabel.centerY;
        }
        self.cardMemoLabel.width = self.fundingBalanceLabel.left - self.fundingNameLabel.right - 10;
        self.cardMemoLabel.left = self.fundingNameLabel.right + 10;
        self.cardMemoLabel.centerY = self.fundingNameLabel.centerY;
        self.cardBillingDayLabel.right = self.contentView.width - 10;
        self.cardBillingDayLabel.centerY = self.fundingMemoLabel.centerY;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        if (self.fundingNameLabel.right > self.fundingBalanceLabel.left) {
            self.fundingNameLabel.width = self.fundingBalanceLabel.left - self.fundingNameLabel.left - 20;
        }
        if (self.fundingMemoLabel.right > self.fundingBalanceLabel.left) {
            self.fundingMemoLabel.width = self.fundingBalanceLabel.left - self.fundingMemoLabel.left - 20;
        }
    }
}

-(CAGradientLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAGradientLayer layer];
        _backLayer.frame = self.bounds;
        _backLayer.startPoint = CGPointMake(0, 0.5);
        _backLayer.endPoint = CGPointMake(1, 0.5);
        _backLayer.shadowRadius = 8;
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [self drawPathInRect:CGRectMake(5, 10, self.width - 10, self.height - 10)].CGPath;
        maskLayer.shadowPath = [self drawPathInRect:CGRectMake(0, 8, self.width, self.height - 8)].CGPath;
        maskLayer.shadowOpacity = 0.3;
        _backLayer.mask = maskLayer;
    }
    return _backLayer;
}


-(UILabel *)fundingNameLabel {
    if (!_fundingNameLabel) {
        _fundingNameLabel = [[UILabel alloc]init];
        _fundingNameLabel.textColor = [UIColor whiteColor];
        _fundingNameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _fundingNameLabel;
}

-(UILabel *)fundingBalanceLabel {
    if (!_fundingBalanceLabel) {
        _fundingBalanceLabel = [[UILabel alloc]init];
        _fundingBalanceLabel.textColor = [UIColor whiteColor];
        _fundingBalanceLabel.font = [UIFont systemFontOfSize:20];
        _fundingBalanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _fundingBalanceLabel;
}

-(UILabel *)fundingMemoLabel {
    if (!_fundingMemoLabel) {
        _fundingMemoLabel = [[UILabel alloc]init];
        _fundingMemoLabel.textColor = [UIColor whiteColor];
        _fundingMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _fundingMemoLabel;
}

- (UILabel *)cardMemoLabel {
    if (!_cardMemoLabel) {
        _cardMemoLabel = [[UILabel alloc]init];
        _cardMemoLabel.textColor = [UIColor whiteColor];
        _cardMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardMemoLabel;
}

- (UILabel *)cardLimitLabel {
    if (!_cardLimitLabel) {
        _cardLimitLabel = [[UILabel alloc]init];
        _cardLimitLabel.textColor = [UIColor whiteColor];
        _cardLimitLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardLimitLabel;
}

- (UILabel *)cardBillingDayLabel {
    if (!_cardBillingDayLabel) {
        _cardBillingDayLabel = [[UILabel alloc]init];
        _cardBillingDayLabel.textColor = [UIColor whiteColor];
        _cardBillingDayLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardBillingDayLabel;
}

-(UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setImage:[UIImage imageNamed:@"ft_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


-(UIImageView *)fundingImage {
    if (!_fundingImage) {
        _fundingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        _fundingImage.tintColor = [UIColor whiteColor];
    }
    return _fundingImage;
}

-(void)updateAppearance {
    if (_financingItem) {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_financingItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_financingItem.endColor].CGColor];
        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:_financingItem.startColor].CGColor;
        self.fundingNameLabel.text = _financingItem.fundingName;
        [self.fundingNameLabel sizeToFit];
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_financingItem.fundingAmount];
        [self.fundingBalanceLabel sizeToFit];
        self.fundingMemoLabel.text = _financingItem.fundingMemo;
        [self.fundingMemoLabel sizeToFit];
        self.fundingImage.image = [[UIImage imageNamed:_financingItem.fundingIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.cardMemoLabel.text = @"";
        [self.cardMemoLabel sizeToFit];
        self.cardBillingDayLabel.text = @"";
        [self.cardBillingDayLabel sizeToFit];
        self.cardLimitLabel.text = @"";
        [self.cardLimitLabel sizeToFit];
    } else {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_creditItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_creditItem.endColor].CGColor];
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_creditItem.cardBalance];
        [self.fundingBalanceLabel sizeToFit];
        self.fundingImage.image = [[UIImage imageNamed:@"ft_creditcard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fundingNameLabel.text = _creditItem.cardName;
        [self.fundingNameLabel sizeToFit];
        if (_creditItem.cardMemo.length) {
            self.cardMemoLabel.text = [NSString stringWithFormat:@"| %@",_creditItem.cardMemo];
        } else {
            self.cardMemoLabel.text = @"";
        }
        [self.cardMemoLabel sizeToFit];
        if (_creditItem.cardBillingDay != 0 && _creditItem.cardRepaymentDay != 0) {
            NSDate *billDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:_creditItem.cardBillingDay];
            NSDate *repaymentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:_creditItem.cardRepaymentDay];
            if ([repaymentDate isEarlierThanOrEqualTo:[NSDate date]] && [billDate isEarlierThanOrEqualTo:[NSDate date]]) {
                repaymentDate = [repaymentDate dateByAddingMonths:1];
                billDate = [billDate dateByAddingMonths:1];
            }
            NSInteger daysFromBill = [billDate daysFrom:[NSDate date]];
            NSInteger daysFromRepayment = [repaymentDate daysFrom:[NSDate date]];
            NSInteger mostRecentDay = MIN(daysFromBill, daysFromRepayment);
            if (billDate.day == [NSDate date].day) {
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日:%ld天",daysFromRepayment + 1];
            }else if(repaymentDate.day == [NSDate date].day){
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日:%ld天",daysFromBill + 1];
            }else{
                if (mostRecentDay == daysFromBill) {
                    if (daysFromBill > 0 ) {
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日%ld天",mostRecentDay + 1];
                    }else{
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日%ld天",daysFromRepayment + 1];
                    }
                }else if (mostRecentDay == daysFromRepayment){
                    if (daysFromRepayment < 0 ) {
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日日%ld天",daysFromBill + 1];
                    }else{
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日%ld天",mostRecentDay + 1];
                    }
                }
            }
            
            [self.cardBillingDayLabel sizeToFit];
            if ([repaymentDate isEarlierThan:billDate]) {
                repaymentDate = [repaymentDate dateByAddingMonths:1];
            }
            if ([[NSDate date] isEarlierThan:repaymentDate] && [[NSDate date] isEarlierThan:billDate]) {
                repaymentDate = [repaymentDate dateBySubtractingMonths:1];
                billDate = [billDate dateBySubtractingMonths:1];
            }
//            if ([billDate isEarlierThanOrEqualTo:[NSDate date]] && [[NSDate date] isEarlierThanOrEqualTo:repaymentDate]) {
//                float sumAmount = [SSJCreditCardStore queryCreditCardBalanceForTheMonth:billDate.month billingDay:item.cardBillingDay WithCardId:item.cardId];
//                self.fundingMemoLabel.text = [NSString stringWithFormat:@"%ld月账单金额%.2f",billDate.month,sumAmount];
//            }else{
            self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",_creditItem.cardLimit];
//            }
            [self.fundingMemoLabel sizeToFit];
        }else{
            self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",_creditItem.cardLimit];
            self.cardBillingDayLabel.text = @"";
            [self.fundingMemoLabel sizeToFit];
        }
    }
    
    [self setNeedsLayout];
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
    self.deleteButton.hidden = !_editeModel;
}


-(void)deleteButtonClicked:(id)sender{
    NSInteger chargeCount = 0;
    if (self.financingItem) {
        chargeCount = self.financingItem.chargeCount;
    }else{
        chargeCount = self.creditItem.chargeCount;
    }
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock(self, chargeCount);
    };
}

- (UIBezierPath *)drawPathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(kRadius, kRadius)];
    return path;
}

- (void)setCreditItem:(SSJCreditCardItem *)creditItem {
    _creditItem = creditItem;
    [self updateAppearance];
}

- (void)setFinancingItem:(SSJFinancingHomeitem *)financingItem {
    _financingItem = financingItem;
    [self updateAppearance];
}

@end
