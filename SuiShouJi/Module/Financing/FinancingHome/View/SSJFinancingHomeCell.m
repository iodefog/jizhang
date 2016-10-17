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

@interface SSJFinancingHomeCell()
@property(nonatomic, strong) UILabel *fundingNameLabel;
@property(nonatomic, strong) UILabel *fundingMemoLabel;
@property(nonatomic, strong) UIImageView *fundingImage;
@property(nonatomic, strong) UILabel *cardMemoLabel;
@property(nonatomic, strong) UILabel *cardLimitLabel;
@property(nonatomic, strong) UILabel *cardBillingDayLabel;
@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) UIButton *deleteButton;
@end

@implementation SSJFinancingHomeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.backView];
        [self.backView addSubview:self.deleteButton];
        [self.backView addSubview:self.fundingImage];
        [self.backView addSubview:self.fundingBalanceLabel];
        [self.backView addSubview:self.fundingNameLabel];
        [self.backView addSubview:self.fundingMemoLabel];
        [self.backView addSubview:self.cardMemoLabel];
        [self.backView addSubview:self.cardBillingDayLabel];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.backView.size = CGSizeMake(self.width, self.height - 10);
    self.backView.centerX = self.contentView.width / 2;
    self.backView.top = 5;
    self.fundingImage.left = 10;
    self.fundingImage.centerY = self.backView.height / 2;
    self.deleteButton.size = CGSizeMake(30, 30);
    self.deleteButton.rightTop = CGPointMake(self.contentView.width, -5);
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundItem = (SSJFinancingHomeitem *)_item;
        self.fundingBalanceLabel.centerY = self.backView.height / 2;
        self.fundingBalanceLabel.right = self.backView.width - 10;
        if (!fundItem.fundingMemo.length) {
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingNameLabel.centerY = self.backView.height / 2;
        }else{
            self.fundingNameLabel.bottom = self.backView.height / 2 - 3;
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingMemoLabel.top = self.backView.height / 2 + 3;
            self.fundingMemoLabel.left = self.fundingImage.right + 10;
        }
    }else{
        SSJCreditCardItem *carditem = (SSJCreditCardItem *)_item;
        self.fundingNameLabel.bottom = self.backView.height / 2 - 3;
        self.fundingNameLabel.left = self.fundingImage.right + 10;
        self.fundingMemoLabel.top = self.backView.height / 2 + 3;
        self.fundingMemoLabel.left = self.fundingImage.right + 10;
        if (carditem.cardRepaymentDay == 0 && carditem.cardBillingDay == 0) {
            self.fundingBalanceLabel.centerY = self.backView.height / 2;
        }else{
            self.fundingBalanceLabel.centerY = self.fundingNameLabel.centerY;
        }
        self.fundingBalanceLabel.right = self.backView.width - 10;
        self.cardMemoLabel.width = self.fundingBalanceLabel.left - self.fundingNameLabel.right - 10;
        self.cardMemoLabel.left = self.fundingNameLabel.right + 10;
        self.cardMemoLabel.centerY = self.fundingNameLabel.centerY;
        self.cardBillingDayLabel.right = self.backView.width - 10;
        self.cardBillingDayLabel.centerY = self.fundingMemoLabel.centerY;
    }
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.layer.cornerRadius = 8.f;
    }
    return _backView;
}


-(UILabel *)fundingNameLabel{
    if (!_fundingNameLabel) {
        _fundingNameLabel = [[UILabel alloc]init];
        _fundingNameLabel.textColor = [UIColor whiteColor];
        _fundingNameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _fundingNameLabel;
}

-(UILabel *)fundingBalanceLabel{
    if (!_fundingBalanceLabel) {
        _fundingBalanceLabel = [[UILabel alloc]init];
        _fundingBalanceLabel.textColor = [UIColor whiteColor];
        _fundingBalanceLabel.font = [UIFont systemFontOfSize:22];
    }
    return _fundingBalanceLabel;
}

-(UILabel *)fundingMemoLabel{
    if (!_fundingMemoLabel) {
        _fundingMemoLabel = [[UILabel alloc]init];
        _fundingMemoLabel.textColor = [UIColor whiteColor];
        _fundingMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _fundingMemoLabel;
}

- (UILabel *)cardMemoLabel{
    if (!_cardMemoLabel) {
        _cardMemoLabel = [[UILabel alloc]init];
        _cardMemoLabel.textColor = [UIColor whiteColor];
        _cardMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardMemoLabel;
}

- (UILabel *)cardLimitLabel{
    if (!_cardLimitLabel) {
        _cardLimitLabel = [[UILabel alloc]init];
        _cardLimitLabel.textColor = [UIColor whiteColor];
        _cardLimitLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardLimitLabel;
}

- (UILabel *)cardBillingDayLabel{
    if (!_cardBillingDayLabel) {
        _cardBillingDayLabel = [[UILabel alloc]init];
        _cardBillingDayLabel.textColor = [UIColor whiteColor];
        _cardBillingDayLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardBillingDayLabel;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setImage:[UIImage imageNamed:@"ft_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


-(UIImageView *)fundingImage{
    if (!_fundingImage) {
        _fundingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        _fundingImage.tintColor = [UIColor whiteColor];
    }
    return _fundingImage;
}

-(void)setItem:(SSJBaseItem *)item{
    _item = item;
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *item = (SSJFinancingHomeitem *)_item;
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:item.fundingColor];
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
        [self setNeedsLayout];
    }else if([_item isKindOfClass:[SSJCreditCardItem class]]){
        SSJCreditCardItem *item = (SSJCreditCardItem *)_item;
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:item.cardColor];
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",item.cardBalance];
        [self.fundingBalanceLabel sizeToFit];
        self.fundingImage.image = [[UIImage imageNamed:@"ft_creditcard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fundingNameLabel.text = item.cardName;
        [self.fundingNameLabel sizeToFit];
        if (item.cardMemo.length) {
            self.cardMemoLabel.text = [NSString stringWithFormat:@"| %@",item.cardMemo];
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
            if ([billDate isEarlierThanOrEqualTo:[NSDate date]] && [[NSDate date] isEarlierThanOrEqualTo:repaymentDate]) {
                float sumAmount = [SSJCreditCardStore queryCreditCardBalanceForTheMonth:billDate.month billingDay:item.cardBillingDay WithCardId:item.cardId];
                self.fundingMemoLabel.text = [NSString stringWithFormat:@"%ld月账单金额%.2f",billDate.month,sumAmount];
            }else{
                self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",item.cardLimit];
            }
            [self.fundingMemoLabel sizeToFit];
        }else{
            self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",item.cardLimit];
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
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock(self);
    };
}

@end
