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
        self.layer.cornerRadius = 8.f;
        [self.contentView addSubview:self.deleteButton];
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
    self.fundingImage.left = 10;
    self.fundingImage.centerY = self.contentView.height / 2;
    self.deleteButton.size = CGSizeMake(50, 50);
    self.deleteButton.center = CGPointMake(self.width - 10, 5);
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *item = (SSJFinancingHomeitem *)_item;
        self.fundingBalanceLabel.centerY = self.contentView.height / 2;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        if (!item.fundingMemo.length) {
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingNameLabel.centerY = self.contentView.height / 2;
        }else{
            self.fundingNameLabel.bottom = self.contentView.height / 2 - 3;
            self.fundingNameLabel.left = self.fundingImage.right + 10;
            self.fundingMemoLabel.top = self.contentView.height / 2 + 3;
            self.fundingMemoLabel.left = self.fundingImage.right + 10;
        }
    }else{
        self.fundingNameLabel.bottom = self.contentView.height / 2 - 3;
        self.fundingNameLabel.left = self.fundingImage.right + 10;
        self.fundingMemoLabel.top = self.contentView.height / 2 + 3;
        self.fundingMemoLabel.left = self.fundingImage.right + 10;
        self.fundingBalanceLabel.centerY = self.fundingNameLabel.centerY;
        self.fundingBalanceLabel.right = self.contentView.width - 10;
        self.cardMemoLabel.width = self.fundingBalanceLabel.left - self.fundingNameLabel.right - 10;
        self.cardMemoLabel.left = self.fundingNameLabel.right + 10;
        self.cardMemoLabel.centerY = self.fundingNameLabel.centerY;
        self.cardBillingDayLabel.right = self.contentView.width - 10;
        self.cardBillingDayLabel.centerY = self.fundingMemoLabel.centerY;
    }
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.borderWidth = 1;
        _backView.layer.cornerRadius = 2;
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
        self.backgroundColor = [UIColor ssj_colorWithHex:item.fundingColor];
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
        self.backgroundColor = [UIColor ssj_colorWithHex:item.cardColor];
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
            if ([billDate isEarlierThan:[NSDate date]]) {
                billDate = [billDate dateByAddingMonths:1];
            }
            NSDate *repaymentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:item.cardRepaymentDay];
            if ([repaymentDate isEarlierThan:[NSDate date]]) {
                repaymentDate = [repaymentDate dateByAddingMonths:1];
            }
            NSInteger daysFromBill = [billDate daysFrom:[NSDate date]];
            NSInteger daysFromRepayment = [repaymentDate daysFrom:[NSDate date]];
            NSInteger mostRecentDay = MIN(daysFromBill, daysFromRepayment);
            if (mostRecentDay == daysFromBill) {
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距账单日%ld天",mostRecentDay];
            }else{
                self.cardBillingDayLabel.text = [NSString stringWithFormat:@"距还款日%ld天",mostRecentDay];
            }
            [self.cardBillingDayLabel sizeToFit];
            if ([repaymentDate isEarlierThan:billDate]) {
                repaymentDate = [repaymentDate dateByAddingMonths:1];
            }
            if ([[NSDate date] isEarlierThan:billDate]) {
                float sumAmount = [SSJCreditCardStore queryCreditCardBalanceForTheMonth:[NSDate date].month billingDay:item.cardBillingDay WithCardId:item.cardId];
                self.fundingMemoLabel.text = [NSString stringWithFormat:@"%ld月账单%.2f",[NSDate date].month,sumAmount];
            }else{
                self.fundingMemoLabel.text = [NSString stringWithFormat:@"信用卡额度%.2f",item.cardLimit];
            }
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
    [MobClick event:@"fund_delete"];
    if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *item = (SSJFinancingHomeitem *)_item;
        [SSJFinancingHomeHelper deleteFundingWithFundingItem:item];
    }else{
        __weak typeof(self) weakSelf = self;
        [SSJCreditCardStore deleteCreditCardWithCardItem:(SSJCreditCardItem *)self.item Success:^{
            if (weakSelf.deleteButtonClickBlock) {
                weakSelf.deleteButtonClickBlock(weakSelf);
            }
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:@"删除失败"];
        }];
    }
}

@end
