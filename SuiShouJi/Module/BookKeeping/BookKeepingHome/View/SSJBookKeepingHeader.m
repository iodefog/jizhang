//
//  SJJBookKeepingHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHeader.h"
#import "SSJRecordMakingViewController.h"

@interface SSJBookKeepingHeader()
@property (strong, nonatomic) UIImageView *backgroudview;
@property(nonatomic,strong)SSJScrollTextView *expenditureView;
@property(nonatomic,strong)SSJScrollTextView *incomeView;
@end
@implementation SSJBookKeepingHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroudview];
        [self addSubview:self.incomeView];
        [self addSubview:self.incomeTitleLabel];
        [self addSubview:self.expenditureView];
        [self addSubview:self.expenditureTitleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroudview.frame = self.bounds;
    self.incomeView.centerX = self.width / 2 / 2;
    self.incomeView.bottom = self.height - 32;
    self.incomeTitleLabel.bottom = self.incomeView.top - 10;
    self.incomeTitleLabel.centerX = self.width / 2 / 2;
    self.expenditureView.centerX = self.width / 2 + self.width / 2 / 2;
    self.expenditureView.bottom = self.height - 32;
    self.expenditureTitleLabel.bottom = self.expenditureView.top - 10;
    self.expenditureTitleLabel.centerX = self.width / 2 + self.width / 2 / 2;
}

-(SSJScrollTextView *)expenditureView{
    if (!_expenditureView) {
        _expenditureView = [[SSJScrollTextView alloc]init];
        _expenditureView.textColor = [UIColor whiteColor];
        _expenditureView.textFont = 20;
        _expenditureView.totalAnimationDuration = 1.f;
    }
    return _expenditureView;
}

-(SSJScrollTextView *)incomeView{
    if (!_incomeView) {
        _incomeView = [[SSJScrollTextView alloc]init];
        _incomeView.textColor = [UIColor whiteColor];
        _incomeView.textFont = 20;
        _incomeView.totalAnimationDuration = 1.f;

    }
    return _incomeView;
}

-(UILabel *)expenditureTitleLabel{
    if (!_expenditureTitleLabel) {
        _expenditureTitleLabel = [[UILabel alloc]init];
        _expenditureTitleLabel.textColor = [UIColor whiteColor];
        _expenditureTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _expenditureTitleLabel;
}

-(UILabel *)incomeTitleLabel{
    if (!_incomeTitleLabel) {
        _incomeTitleLabel = [[UILabel alloc]init];
        _incomeTitleLabel.textColor = [UIColor whiteColor];
        _incomeTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _incomeTitleLabel;
}

-(UIImageView *)backgroudview{
    if (!_backgroudview) {
        _backgroudview = [[UIImageView alloc]init];
        _backgroudview.image = [UIImage imageNamed:@"home_background"];
    }
    return _backgroudview;
}

-(void)setCurrentMonth:(long )currentMonth{
    _currentMonth = currentMonth;
    self.incomeTitleLabel.text = [NSString stringWithFormat:@"%ld月收入(元)",_currentMonth];
    [self.incomeTitleLabel sizeToFit];
    self.expenditureTitleLabel.text = [NSString stringWithFormat:@"%ld月支出(元)",_currentMonth];
    [self.expenditureTitleLabel sizeToFit];
}

-(void)setIncome:(NSString *)income{
    _income = income;
    self.incomeView.string = _income;
    [self.incomeView sizeToFit];
    [self setNeedsLayout];
}

-(void)setExpenditure:(NSString *)expenditure{
    _expenditure = expenditure;
    self.expenditureView.string = _expenditure;
    [self.expenditureView sizeToFit];
    [self setNeedsLayout];
}

@end
