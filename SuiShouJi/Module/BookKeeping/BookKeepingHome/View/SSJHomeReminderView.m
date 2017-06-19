//
//  SSJHomeReminderView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeReminderView.h"
#import "SSJDatabaseQueue.h"
#import "UIView+SSJViewAnimatioin.h"
#import "SSJBookKeepingHomeHelper.h"

@interface SSJHomeReminderView()
@property (nonatomic,strong) UIImageView *remindImage;
@property (nonatomic,strong) UILabel *remindLabel;
@property (nonatomic,strong) UIButton *closeButton;
@end
@implementation SSJHomeReminderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.remindImage];
        [self addSubview:self.remindLabel];
        [self addSubview:self.closeButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.remindImage.center = CGPointMake(self.width / 2, self.height / 2);
    self.remindLabel.width = self.remindImage.width - 70;
    self.remindLabel.bottom = self.remindImage.bottom - 70;
    self.remindLabel.centerX = self.width / 2;
    self.closeButton.centerX = self.width / 2;
    self.closeButton.top = self.remindLabel.bottom + 15;
}

- (void)show {
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
    [self setBudgetHasRemind];
}

-(UIImageView *)remindImage{
    if (!_remindImage) {
        _remindImage = [[UIImageView alloc]init];
        _remindImage.size = CGSizeMake(320 , 425);
        _remindImage.image = [UIImage imageNamed:@"home_remind"];
    }
    return _remindImage;
}

-(UILabel *)remindLabel{
    if (!_remindLabel) {
        _remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, MAXFLOAT)];
        _remindLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _remindLabel.textColor = [UIColor whiteColor];
        _remindLabel.numberOfLines = 0;
        _remindLabel.textAlignment = NSTextAlignmentLeft;
        _remindLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _remindLabel;
}

-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 130, 40)];
        _closeButton.layer.cornerRadius = 20;
        _closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _closeButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_closeButton setTitle:@"知道了" forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeButtonClicked:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });
}

-(void)setModel:(SSJBudgetModel *)model{
    _model = model;
    if ([_model.billIds isEqualToArray:@[SSJAllBillTypeId]]) {
        
        NSString *typeStr;
        switch (_model.type) {
            case SSJBudgetPeriodTypeWeek:
                typeStr = @"本周";
                break;
            case SSJBudgetPeriodTypeMonth:
                typeStr = @"这个月";
                break;
            case SSJBudgetPeriodTypeYear:
                typeStr = @"今年";
                break;
            default:
                break;
        }
        
        NSString *moneyStr = nil;
        NSMutableAttributedString *attriString = nil;
        UIColor *highlightedColor = nil;
        
        if (_model.budgetMoney < _model.payMoney) {
            highlightedColor = [UIColor ssj_colorWithHex:SSJOverrunRedColorValue];
            moneyStr = [NSString stringWithFormat:@"%.2f元",_model.payMoney - _model.budgetMoney];
            attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，%@您已经超支%@预算了。\n养鱼要蓄水，省点花钱吧", typeStr, moneyStr]];
        } else {
            highlightedColor = [UIColor ssj_colorWithHex:@"45fffd"];
            moneyStr = [NSString stringWithFormat:@"%.2f元",_model.budgetMoney - _model.payMoney];
            attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，%@您只剩下%@预算了。\n养鱼要蓄水，省点花钱吧", typeStr, moneyStr]];
        }
        
        NSRange range = [attriString.string rangeOfString:moneyStr];
        [attriString addAttribute:NSForegroundColorAttributeName
                            value:highlightedColor
                            range:range];
        self.remindLabel.attributedText = attriString;
        [self.remindLabel sizeToFit];
    } else {
        
        NSString *typeStr;
        switch (_model.type) {
            case SSJBudgetPeriodTypeWeek:
                typeStr = @"周";
                break;
            case SSJBudgetPeriodTypeMonth:
                typeStr = @"月";
                break;
            case SSJBudgetPeriodTypeYear:
                typeStr = @"年";
                break;
            default:
                break;
        }
        
        NSString *billNames = nil;
        if (_model.billIds.count > 2) {
            billNames = [SSJBookKeepingHomeHelper queryBillNameForBillIds:[_model.billIds subarrayWithRange:NSMakeRange(0, 2)]];
            billNames = [NSString stringWithFormat:@"%@等", billNames];
        } else {
            billNames = [SSJBookKeepingHomeHelper queryBillNameForBillIds:_model.billIds];
        }
        
        NSString *moneyStr = nil;
        NSMutableAttributedString *attriString = nil;
        UIColor *highlightedColor = nil;
        
        if (_model.budgetMoney < _model.payMoney) {
            highlightedColor = [UIColor ssj_colorWithHex:SSJOverrunRedColorValue];
            moneyStr = [NSString stringWithFormat:@"%.2f元",_model.payMoney - _model.budgetMoney];
            attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您的%@分类预算-%@已经超支%@了。\n养鱼要蓄水，省点花钱吧！", typeStr, billNames, moneyStr]];
        } else {
            highlightedColor = [UIColor ssj_colorWithHex:@"45fffd"];
            moneyStr = [NSString stringWithFormat:@"%.2f元",_model.budgetMoney - _model.payMoney];
            attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您的%@分类预算-%@只剩下%@了。\n养鱼要蓄水，省点花钱吧！", typeStr, billNames, moneyStr]];
        }
        
        NSRange range = [attriString.string rangeOfString:moneyStr];
        [attriString addAttribute:NSForegroundColorAttributeName
                            value:highlightedColor
                            range:range];
        self.remindLabel.attributedText = attriString;
        [self.remindLabel sizeToFit];
    }

}

-(void)setBudgetHasRemind{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update BK_USER_BUDGET set ihasremind = 1, cwritedate = ?, iversion = ?, operatortype = 1 where IBID = ? and CUSERID = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), self.model.ID, SSJUSERID()];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
