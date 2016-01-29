//
//  SSJFinancingHomePopView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomePopView.h"
@interface SSJFinancingHomePopView()
@property (weak, nonatomic) IBOutlet UIImageView *cashImage;
@property (weak, nonatomic) IBOutlet UIImageView *addImage;
@property (weak, nonatomic) IBOutlet UIButton *knowButton;
@end

@implementation SSJFinancingHomePopView

-(void)awakeFromNib{
    self.cashImage.image = [[UIImage imageNamed:@"ft_cash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.addImage.image = [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.knowButton.layer.cornerRadius = 3.f;
    self.knowButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.knowButton.layer.borderWidth = 1.f;
}


- (IBAction)knowButtonClicked:(id)sender {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
