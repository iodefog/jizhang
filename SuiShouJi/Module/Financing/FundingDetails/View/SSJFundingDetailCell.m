//
//  SSJFundingDetailCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailCell.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentStore.h"
#import "SSJRepaymentModel.h"

@interface SSJFundingDetailCell()

@property(nonatomic, strong) UIImageView *memoImage;

@property(nonatomic, strong) UIImageView *haveImage;

@property(nonatomic, strong) UILabel *typeLabel;

@property(nonatomic, strong) UILabel *memoLabel;

@property(nonatomic, strong) UILabel *memberLabel;

@property(nonatomic, strong) UIView *seperator1;

@property(nonatomic, strong) UIView *seperator2;

@end

@implementation SSJFundingDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [self.contentView addSubview:self.moneyLab];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.memberLabel];
        [self.contentView addSubview:self.haveImage];
        [self.contentView addSubview:self.memoLabel];
        [self.contentView addSubview:self.seperator1];
        [self.contentView addSubview:self.seperator2];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 26;
    
    if ([_item.billId integerValue] >= 1000 || _item.billId.length > 4) {
        self.imageView.layer.borderWidth = 2 / [UIScreen mainScreen].scale;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
    } else {
        self.imageView.layer.borderWidth = 0;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    if (_item.chargeMemo.length == 0
        && _item.chargeImage.length == 0
        && _item.memberNickname.length == 0){
        self.memoLabel.hidden = YES;
        self.imageView.left = 15;
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.leftTop = CGPointMake(15, (self.contentView.height - imageDiam) * 0.5);
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.centerY = self.height * 0.5;
        self.seperator1.hidden = YES;
        self.seperator2.hidden = YES;
    } else {
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.left = 15;
        self.imageView.centerY = self.height / 2;
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.bottom = self.height / 2 - 5;
        
        CGFloat gap = 12; // 成员昵称、流水图片、备注之间的间隙
        CGFloat left = self.typeLabel.left;
        CGFloat centerY = self.height * 0.5 + 9;
        
        int visibleCount = 0;
        
        if (!self.memberLabel.hidden) {
            self.memberLabel.left = left;
            self.memberLabel.centerY = centerY;
            left = self.memberLabel.right + gap;
            visibleCount ++;
        }
        
        if (!self.haveImage.hidden) {
            self.haveImage.size = CGSizeMake(12, 12);
            self.haveImage.left = left;
            self.haveImage.centerY = centerY;
            left = self.haveImage.right + gap;
            visibleCount ++;
        }
        
        if (!self.memoLabel.hidden) {
            self.memoLabel.left = left;
            self.memoLabel.centerY = centerY;
            left = self.memoLabel.right + gap;
            visibleCount ++;
        }
        
        if (visibleCount == 3) {
            self.seperator1.hidden = NO;
            self.seperator1.size = CGSizeMake(2 / [UIScreen mainScreen].scale, 9);
            self.seperator1.left = self.memberLabel.right + gap * 0.5;
            self.seperator1.centerY = centerY;
            
            self.seperator2.hidden = NO;
            self.seperator2.size = CGSizeMake(2 / [UIScreen mainScreen].scale, 9);
            self.seperator2.left = self.haveImage.right + gap * 0.5;
            self.seperator2.centerY = centerY;
        } else if (visibleCount == 2) {
            self.seperator1.size = CGSizeMake(2 / [UIScreen mainScreen].scale, 9);
            self.seperator1.left = (self.memberLabel.hidden ? self.haveImage.right : self.memberLabel.right) + gap * 0.5;
            self.seperator1.centerY = centerY;
            self.seperator1.hidden = NO;
            self.seperator2.hidden = YES;
        } else {
            self.seperator1.hidden = YES;
            self.seperator2.hidden = YES;
        }
    }
    
    self.moneyLab.right = self.contentView.width - 15;
    
    self.moneyLab.centerY = self.height / 2;
    
    self.memoLabel.width = self.moneyLab.left - self.memoLabel.left - 10;
    
    self.typeLabel.width = self.moneyLab.left - self.imageView.right - 20;
}

- (void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    // 如果是信用卡还款有关的
    NSInteger billid = [item.billId integerValue];
    if (item.idType == SSJChargeIdTypeRepayment) {
        self.imageView.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
        self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        SSJRepaymentModel *repaymentModel = [SSJRepaymentStore queryRepaymentModelWithChargeItem:item];
        if ([item.billId isEqualToString:@"3"] || [item.billId isEqualToString:@"4"]) {
            // 如果是信用卡还款
            if ([item.fundParent isEqualToString:@"3"]) {
                self.typeLabel.text = [NSString stringWithFormat:@"%ld月账单还款",(long)repaymentModel.repaymentMonth.month];
            } else {
                self.typeLabel.text = [NSString stringWithFormat:@"%@还款—%ld月账单还款",repaymentModel.cardName,(long)repaymentModel.repaymentMonth.month];
            }
            [self.typeLabel sizeToFit];
        }else if([item.billId isEqualToString:@"11"]) {
            // 如果是信用卡分期本金
            self.typeLabel.text = [NSString stringWithFormat:@"%ld月账单分期本金 %ld/%ld期",(long)repaymentModel.repaymentMonth.month,(long)repaymentModel.currentInstalmentCout,(long)repaymentModel.instalmentCout];
            [self.typeLabel sizeToFit];
        }else if([item.billId isEqualToString:@"12"]) {
            // 如果是信用卡分期手续费
            self.typeLabel.text = [NSString stringWithFormat:@"%ld月账单分期手续费 %ld/%ld期",(long)repaymentModel.repaymentMonth.month,(long)repaymentModel.currentInstalmentCout,(long)repaymentModel.instalmentCout];
            [self.typeLabel sizeToFit];
        }
    }else{
        if (item.idType == SSJChargeIdTypeLoan) {
            if (item.loanType == SSJLoanTypeLend) {
                // 借出
                switch (item.loanChargeType) {
                    case SSJLoanCompoundChargeTypeCreate:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#4ab0e5"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_lend"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#4ab0e5"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"借出款-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeBalanceIncrease:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#4ab0e5"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_balance"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#4ab0e5"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"借出款余额变更-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        
                        break;
                        
                    case SSJLoanCompoundChargeTypeRepayment:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#f1658c"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_receipt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#f1658c"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"收款-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeAdd:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#4ab0e5"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_append"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#4ab0e5"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"追加借出-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeCloseOut:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#4ab0e5"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_lend"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#4ab0e5" ].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"借出款结清-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeInterest:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#32c68c"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_interest_charge"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#32c68c" ].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"利息收入-被%@借",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    default:
                        break;
                }
            }else{
                // 借入
                switch (item.loanChargeType) {
                    case SSJLoanCompoundChargeTypeCreate:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#5a98de"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_debt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#5a98de"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"欠款-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeBalanceIncrease:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#5a98de"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_balance"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#5a98de"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"欠款余额变更-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        
                        break;
                        
                    case SSJLoanCompoundChargeTypeRepayment:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#5a98de"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_repayment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#5a98de"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"还款-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeAdd:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#5a98de"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_append"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#5a98de"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"追加欠款-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeCloseOut:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#5a98de"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_debt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#5a98de"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"欠款结清-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    case SSJLoanCompoundChargeTypeInterest:{
                        self.imageView.tintColor = [UIColor ssj_colorWithHex:@"#32c68c"];
                        self.imageView.image = [[UIImage imageNamed:@"loan_interest_charge"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"#32c68c"].CGColor;
                        self.typeLabel.text = [NSString stringWithFormat:@"利息支出-欠%@钱款",item.loanSource];
                        [self.typeLabel sizeToFit];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }else{
            self.imageView.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
            self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
            if (item.billId.length <= 4) {
                if (billid == 1 || billid == 2) {
                    self.typeLabel.text = [NSString stringWithFormat:@"余额变更(%@)",item.typeName];
                }else if (billid == 3) {
                    self.typeLabel.text = [NSString stringWithFormat:@"由%@转入",item.transferSource];
                }else if (billid == 4) {
                    self.typeLabel.text = [NSString stringWithFormat:@"转出至%@",item.transferSource];
                } else if (billid == 13 || billid == 14) {
                    self.typeLabel.text = [NSString stringWithFormat:@"%@",item.chargeMemo];
                } else {
                    self.typeLabel.text = item.typeName;
                }

            } else {
                self.typeLabel.text = item.typeName;
            }
            [self.typeLabel sizeToFit];
        }

    }
    
    self.memberLabel.text = _item.memberNickname;
    [self.memberLabel sizeToFit];
    self.memberLabel.hidden = _item.memberNickname.length == 0;
    
    self.haveImage.hidden = _item.chargeImage.length == 0;
    
    self.memoLabel.hidden = _item.chargeMemo.length == 0;
    if (item.chargeMemo.length != 0) {
        self.memoImage.hidden = NO;
        if (billid == 13 || billid == 14) {
            self.memoLabel.text = @"共享账本流水";
        } else {
            self.memoLabel.text = _item.chargeMemo;
        }
        [self.memoLabel sizeToFit];
    }
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@",item.money];
    [self.moneyLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor clearColor];
        _moneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _moneyLab;
}

-(UIImageView *)memoImage {
    if (!_memoImage) {
        _memoImage = [[UIImageView alloc]init];
        _memoImage.image = [UIImage imageNamed:@"mark_jilu"];
    }
    return _memoImage;
}

-(UIImageView *)haveImage {
    if (!_haveImage) {
        _haveImage = [[UIImageView alloc]init];
        _haveImage.image = [UIImage imageNamed:@"mark_pic"];
    }
    return _haveImage;
}

-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _typeLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memoLabel;
}

-(UILabel *)memberLabel{
    if (!_memberLabel) {
        _memberLabel = [[UILabel alloc]init];
        _memberLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memberLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memberLabel;
}

- (UIView *)seperator1 {
    if (!_seperator1) {
        _seperator1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 / [UIScreen mainScreen].scale, 9)];
        _seperator1.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _seperator1;
}

- (UIView *)seperator2 {
    if (!_seperator2) {
        _seperator2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 / [UIScreen mainScreen].scale, 9)];
        _seperator2.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _seperator2;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _memoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    _seperator1.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _seperator2.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
