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
@property (weak, nonatomic) IBOutlet UILabel *expenditureLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitLabel;
@property (weak, nonatomic) IBOutlet UILabel *expentureTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookKeepingButton;
@property (weak, nonatomic) IBOutlet UILabel *incomeTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroudview;
@end
@implementation SSJBookKeepingHeader

+ (id)BookKeepingHeader {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJBookKeepingHeader" owner:nil options:nil];
    return array[0];
}


- (void)awakeFromNib{
    
}

-(void)setIncome:(NSString *)income{
    _income = income;
    self.incomeLabel.text = _income;
}

-(void)setExpenditure:(NSString *)expenditure{
    _expenditure = expenditure;
    self.expenditureLabel.text = _expenditure;
    self.profitLabel.text =[NSString stringWithFormat:@"%.2f",[self.income doubleValue] - [self.expenditure doubleValue]];
}

-(void)setCurrentMonth:(long )currentMonth{
    _currentMonth = currentMonth;
    self.incomeTitleLabel.text = [NSString stringWithFormat:@"%ld月收入(元)",_currentMonth];
    self.expentureTitleLabel.text = [NSString stringWithFormat:@"%ld月支出(元)",_currentMonth];

}

@end
