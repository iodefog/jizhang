//
//  SSJBookKeepingHomePopView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomePopView.h"

@interface SSJBookKeepingHomePopView()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation SSJBookKeepingHomePopView

+ (id)BookKeepingHomePopView {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SSJBookKeepingHomePopView" owner:nil options:nil];
    return array[0];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.registerButton.layer.cornerRadius = 3.0f;
    self.registerButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
    self.registerButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.cornerRadius = 3.0f;
}

- (IBAction)registerButtonClicked:(id)sender {
    [self removeFromSuperview];
    if (self.registerBtnClickBlock) {
        self.registerBtnClickBlock();
    }
}

- (IBAction)loginButtonClicked:(id)sender {
    [self removeFromSuperview];
    if (self.loginBtnClickBlock) {
        self.loginBtnClickBlock();
    }
}

- (IBAction)closeButtonClicked:(id)sender {
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
