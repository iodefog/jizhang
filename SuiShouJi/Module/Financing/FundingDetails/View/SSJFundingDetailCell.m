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

@property(nonatomic, strong) UIView *seperatorLine;

@end

@implementation SSJFundingDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.imageView.contentMode = UIViewContentModeCenter;
    
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.typeLabel];
        
        [self.contentView addSubview:self.haveImage];
        
        [self.contentView addSubview:self.memoLabel];
        
        [self.contentView addSubview:self.seperatorLine];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 26;
    
    self.memoLabel.width = 200;
    
    
    if ([_item.billId integerValue] > 1000 || _item.billId.length > 4) {
        self.imageView.layer.borderWidth = 2 / [UIScreen mainScreen].scale;
        self.imageView.contentMode = UIViewContentModeCenter;
    } else {
        self.imageView.layer.borderWidth = 0;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    if (_item.chargeMemo.length == 0 && _item.chargeImage.length == 0){
        self.memoLabel.hidden = YES;
        self.imageView.left = 15;
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.leftTop = CGPointMake(15, (self.contentView.height - imageDiam) * 0.5);
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        if (!self.item.loanId.length) {
            self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
        }
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.centerY = self.height * 0.5;
    } else {
        self.memoLabel.hidden = NO;
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.left = 15;
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        if (!self.item.loanId.length) {
            self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
        }
        self.haveImage.size = CGSizeMake(12, 12);
        
        self.seperatorLine.size = CGSizeMake(2 / [UIScreen mainScreen].scale, 9);
        
        self.typeLabel.left = self.imageView.right + 10;
        
        self.typeLabel.bottom = self.height / 2 - 5;
        
        self.imageView.centerY = self.height / 2;
        
        self.haveImage.top = self.imageView.centerY + 3;
        
        self.haveImage.hidden = !_item.chargeImage.length;

        self.seperatorLine.hidden = !_item.chargeImage.length || !_item.chargeMemo.length;

        self.haveImage.top = self.height / 2 + 3;
        
        self.seperatorLine.centerY = self.haveImage.centerY;

        self.memoLabel.centerY = self.haveImage.centerY;
        
        self.haveImage.left = self.typeLabel.left;
        
        self.seperatorLine.left = self.haveImage.right + 6;
        
        if (_item.chargeImage.length) {
            
            self.memoLabel.left = self.seperatorLine.right + 12;
            
        } else {
            
            self.memoLabel.left = self.typeLabel.left;
            
        }
        
        self.memoLabel.width = self.memoLabel.left - self.moneyLab.left;
        
        if (_item.chargeImage.length) {
            
            self.memoLabel.left = self.seperatorLine.right + 12;
            
        } else {
            
            self.memoLabel.left = self.typeLabel.left;
            
        }
        
    }
    
    self.moneyLab.right = self.contentView.width - 15;
    
    self.moneyLab.centerY = self.height / 2;
    
    self.typeLabel.width = self.moneyLab.left - self.imageView.right - 20;
}

- (void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    // 如果是信用卡还款有关的
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
            if ([item.typeName isEqualToString:@"平账收入"] || [item.typeName isEqualToString:@"平账支出"]) {
                self.typeLabel.text = [NSString stringWithFormat:@"余额变更(%@)",item.typeName];
            }else if([item.typeName isEqualToString:@"转入"]){
                self.typeLabel.text = [NSString stringWithFormat:@"由%@转入",item.transferSource];
            }else if([item.typeName isEqualToString:@"转出"]){
                self.typeLabel.text = [NSString stringWithFormat:@"转出至%@",item.transferSource];
            }else{
                self.typeLabel.text = item.typeName;
            }
            [self.typeLabel sizeToFit];
        }

    }
    if (item.chargeMemo.length != 0) {
        self.memoImage.hidden = NO;
        self.memoLabel.hidden = NO;
        self.memoLabel.text = _item.chargeMemo;
        [self.memoLabel sizeToFit];
    }else{
        self.memoImage.hidden = YES;
        self.memoLabel.hidden = NO;
    }
    if (item.chargeImage.length != 0) {
        self.haveImage.hidden = NO;
    }else{
        self.haveImage.hidden = YES;
    }
    [self.textLabel sizeToFit];
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@",item.money];
    [self.moneyLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor clearColor];
        _moneyLab.font = [UIFont systemFontOfSize:16];
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
        _typeLabel.font = [UIFont systemFontOfSize:15];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _typeLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _memoLabel;
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2 / [UIScreen mainScreen].scale, 9)];
        _seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _seperatorLine;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _memoLabel.font = [UIFont systemFontOfSize:13];
    _seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
