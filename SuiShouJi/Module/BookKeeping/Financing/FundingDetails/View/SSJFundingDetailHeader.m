//
//  SSJFundingDetailHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailHeader.h"

@interface SSJFundingDetailHeader()
@property (nonatomic,strong) UIView *seperatorView;
@property (nonatomic,strong) UILabel *incomeLabel;
@property (nonatomic,strong) UILabel *expenceLabel;
@end

@implementation SSJFundingDetailHeader
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.incomeLabel];
        [self addSubview:self.totalIncomeLabel];
        [self addSubview:self.seperatorView];
        [self addSubview:self.expenceLabel];
        [self addSubview:self.totalExpenceLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.incomeLabel.centerX = self.width / 2 / 2;
    self.incomeLabel.top = 22;
    self.totalIncomeLabel.centerX = self.width / 2 / 2;
    self.totalIncomeLabel.top = self.incomeLabel.bottom + 15;
    self.seperatorView.size = CGSizeMake(1, 67);
    self.seperatorView.center = CGPointMake(self.width / 2, self.height / 2);
    self.expenceLabel.centerX = self.width / 2  + self.width / 2 / 2;
    self.expenceLabel.top = 22;
    self.totalExpenceLabel.centerX = self.width / 2  + self.width / 2 / 2;
    self.totalExpenceLabel.top = self.incomeLabel.bottom + 15;
}

-(UIView *)seperatorView{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc]init];
        _seperatorView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    }
    return _seperatorView;
}

-(UILabel *)expenceLabel{
    if (!_expenceLabel) {
        _expenceLabel = [[UILabel alloc]init];
        _expenceLabel.textColor = [UIColor whiteColor];
        _expenceLabel.font = [UIFont systemFontOfSize:15];
        _expenceLabel.textAlignment = NSTextAlignmentCenter;
        _expenceLabel.text = @"累计支出";
        [_expenceLabel sizeToFit];
    }
    return _expenceLabel;
}

-(UILabel *)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]init];
        _incomeLabel.textColor = [UIColor whiteColor];
        _incomeLabel.font = [UIFont systemFontOfSize:15];
        _incomeLabel.textAlignment = NSTextAlignmentCenter;
        _incomeLabel.text = @"累计收入";
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel *)totalExpenceLabel{
    if (!_totalExpenceLabel) {
        _totalExpenceLabel = [[UILabel alloc]init];
        _totalExpenceLabel.font = [UIFont systemFontOfSize:24];
        _totalExpenceLabel.textColor = [UIColor whiteColor];
        _totalExpenceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalExpenceLabel;
}


-(UILabel *)totalIncomeLabel{
    if (!_totalIncomeLabel) {
        _totalIncomeLabel = [[UILabel alloc]init];
        _totalIncomeLabel.font = [UIFont systemFontOfSize:24];
        _totalIncomeLabel.textColor = [UIColor whiteColor];
        _totalIncomeLabel.textAlignment = NSTextAlignmentCenter;

    }
    return _totalIncomeLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
