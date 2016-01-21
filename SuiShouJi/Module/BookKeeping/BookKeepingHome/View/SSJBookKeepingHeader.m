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
@property (weak, nonatomic) IBOutlet UIButton *bookKeepingButton;
@property (weak, nonatomic) IBOutlet UIView *backgroudview;

- (IBAction)bookKeeping:(id)sender;
@end
@implementation SSJBookKeepingHeader

+ (id)BookKeepingHeader {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJBookKeepingHeader" owner:nil options:nil];
    return array[0];
}

+ (CGFloat)viewHeight{
    return 202;
}

- (void)awakeFromNib{
    [self.bookKeepingButton setBackgroundColor:[UIColor whiteColor]];
    [self.bookKeepingButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    [self.bookKeepingButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateHighlighted];
    self.bookKeepingButton.layer.cornerRadius = 49.0f;
    [self.backgroudview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg"]]];
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

- (IBAction)bookKeeping:(id)sender {
    if (self.BtnClickBlock) {
        self.BtnClickBlock();
    }
}
@end
