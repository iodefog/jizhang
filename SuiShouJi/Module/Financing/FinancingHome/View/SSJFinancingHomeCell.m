//
//  SSJFinancingHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeCell.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"
#import "SSJCreditCardStore.h"
#import "SSJDatabaseQueue.h"

static const CGFloat kRadius = 12.f;

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
        //        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.fundingImage];
        [self.contentView addSubview:self.fundingBalanceLabel];
        [self.contentView addSubview:self.fundingNameLabel];
        [self.contentView addSubview:self.fundingMemoLabel];
        [self.contentView addSubview:self.cardMemoLabel];
        [self.contentView addSubview:self.cardBillingDayLabel];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.fundingImage.left = 20;
    self.fundingImage.centerY = self.contentView.height / 2 + 5;
    self.deleteButton.size = CGSizeMake(30, 30);
    self.deleteButton.rightTop = CGPointMake(self.contentView.width, -5);
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundItem = (SSJFinancingHomeitem *)_item;
        self.fundingBalanceLabel.centerY = self.fundingImage.centerY;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        if (!fundItem.fundingMemo.length) {
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
        SSJCreditCardItem *carditem = (SSJCreditCardItem *)_item;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        self.fundingNameLabel.bottom = self.fundingImage.centerY - 3;
        self.fundingNameLabel.left = self.fundingImage.right + 10;
        self.fundingMemoLabel.top = self.fundingImage.centerY + 3;
        self.fundingMemoLabel.left = self.fundingImage.right + 10;
        if (carditem.cardRepaymentDay == 0 && carditem.cardBillingDay == 0) {
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
//        _backLayer.shadowRadius = kRadius;
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = [self drawPathInRect:CGRectMake(5, 10, self.width - 10, self.height - 10)].CGPath;
//        maskLayer.shadowPath = [self drawPathInRect:CGRectMake(0, 6, self.width, self.height - 6)].CGPath;
//        maskLayer.shadowOpacity = 0.2;
//        maskLayer.shadowOffset = CGSizeMake(0, 0);
        _backLayer.mask = maskLayer;
    }
    return _backLayer;
}


-(UILabel *)fundingNameLabel {
    if (!_fundingNameLabel) {
        _fundingNameLabel = [[UILabel alloc]init];
        _fundingNameLabel.textColor = [UIColor whiteColor];
        _fundingNameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _fundingNameLabel;
}

-(UILabel *)fundingBalanceLabel {
    if (!_fundingBalanceLabel) {
        _fundingBalanceLabel = [[UILabel alloc]init];
        _fundingBalanceLabel.textColor = [UIColor whiteColor];
        _fundingBalanceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _fundingBalanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _fundingBalanceLabel;
}

-(UILabel *)fundingMemoLabel {
    if (!_fundingMemoLabel) {
        _fundingMemoLabel = [[UILabel alloc]init];
        _fundingMemoLabel.textColor = [UIColor whiteColor];
        _fundingMemoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _fundingMemoLabel;
}

- (UILabel *)cardMemoLabel {
    if (!_cardMemoLabel) {
        _cardMemoLabel = [[UILabel alloc]init];
        _cardMemoLabel.textColor = [UIColor whiteColor];
        _cardMemoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _cardMemoLabel;
}

- (UILabel *)cardLimitLabel {
    if (!_cardLimitLabel) {
        _cardLimitLabel = [[UILabel alloc]init];
        _cardLimitLabel.textColor = [UIColor whiteColor];
        _cardLimitLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _cardLimitLabel;
}

- (UILabel *)cardBillingDayLabel {
    if (!_cardBillingDayLabel) {
        _cardBillingDayLabel = [[UILabel alloc]init];
        _cardBillingDayLabel.textColor = [UIColor whiteColor];
        _cardBillingDayLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
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

-(void)setItem:(SSJBaseCellItem *)item {
    _item = item;
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *item = (SSJFinancingHomeitem *)_item;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor];
//        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:item.startColor].CGColor;
        [CATransaction commit];
        
        self.fundingNameLabel.text = item.fundingName;
        [self.fundingNameLabel sizeToFit];
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",item.fundingAmount];
        [self.fundingBalanceLabel sizeToFit];
        self.fundingMemoLabel.text = item.fundingMemo;
        [self.fundingMemoLabel sizeToFit];
        self.fundingImage.image = [[UIImage imageNamed:item.fundingIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.cardMemoLabel.text = @"";
        [self.cardMemoLabel sizeToFit];
        self.cardBillingDayLabel.text = @"";
        [self.cardBillingDayLabel sizeToFit];
        self.cardLimitLabel.text = @"";
        [self.cardLimitLabel sizeToFit];
    }else if([_item isKindOfClass:[SSJCreditCardItem class]]){
        SSJCreditCardItem *item = (SSJCreditCardItem *)_item;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor];
//        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:item.startColor].CGColor;
        [CATransaction commit];
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",item.cardBalance];
        [self.fundingBalanceLabel sizeToFit];
        self.fundingImage.image = [[UIImage imageNamed:@"ft_creditcard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fundingNameLabel.text = item.cardName;
        [self.fundingNameLabel sizeToFit];
        if (item.cardMemo.length) {
            self.cardMemoLabel.text = [NSString stringWithFormat:@"| %@",item.cardMemo];
        } else {
            self.cardMemoLabel.text = @"";
        }
        [self.cardMemoLabel sizeToFit];
        if (item.cardBillingDay != 0 && item.cardRepaymentDay != 0) {
            NSDate *billDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:item.cardBillingDay];
            NSDate *repaymentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:item.cardRepaymentDay];
            if ([repaymentDate isEarlierThanOrEqualTo:[NSDate date]] && [billDate isEarlierThanOrEqualTo:[NSDate date]]) {
                repaymentDate = [repaymentDate dateByAddingMonths:1];
                billDate = [billDate dateByAddingMonths:1];
            }
            NSInteger daysFromBill = [billDate daysFrom:[NSDate date]];
            NSInteger daysFromRepayment = [repaymentDate daysFrom:[NSDate date]];
            NSInteger mostRecentDay = MIN(daysFromBill, daysFromRepayment);
            if (billDate.day == [NSDate date].day) {
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日:%ld天",(long)daysFromRepayment + 1];
            }else if(repaymentDate.day == [NSDate date].day){
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日:%ld天",(long)daysFromBill + 1];
            }else{
                if (mostRecentDay == daysFromBill) {
                    if (daysFromBill > 0 ) {
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日%ld天",(long)mostRecentDay + 1];
                    }else{
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日%ld天",(long)daysFromRepayment + 1];
                    }
                }else if (mostRecentDay == daysFromRepayment){
                    if (daysFromRepayment < 0 ) {
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日日%ld天",(long)daysFromBill + 1];
                    }else{
                        self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日%ld天",(long)mostRecentDay + 1];
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
            self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",item.cardLimit];
            //            }
            [self.fundingMemoLabel sizeToFit];
        }else{
            self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",item.cardLimit];
            self.cardBillingDayLabel.text = @"";
            [self.fundingMemoLabel sizeToFit];
        }
    }
    
    [self setNeedsLayout];
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
    //    self.deleteButton.hidden = !_editeModel;
}


-(void)deleteButtonClicked:(id)sender{
    NSInteger chargeCount = 0;
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        chargeCount = ((SSJCreditCardItem *)self.item).chargeCount;
    }else{
        chargeCount = ((SSJFinancingHomeitem *)self.item).chargeCount;
    }
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock(self,chargeCount);
    };
}

- (UIBezierPath *)drawPathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(kRadius, kRadius)];
    return path;
}

@end
