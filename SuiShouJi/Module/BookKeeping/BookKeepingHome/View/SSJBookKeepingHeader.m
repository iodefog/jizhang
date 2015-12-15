//
//  SJJBookKeepingHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHeader.h"

@interface SSJBookKeepingHeader()
@property (weak, nonatomic) IBOutlet UILabel *expenditureLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *profitLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookKeepingButton;
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
    self.bookKeepingButton.layer.cornerRadius = 51.0f;
    self.bookKeepingButton.layer.masksToBounds = YES;
    self.bookKeepingButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bookKeepingButton.layer.borderWidth = 5;
    self.backgroundColor = [UIColor clearColor];
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
    NSLog(@"记一笔");
}
@end
