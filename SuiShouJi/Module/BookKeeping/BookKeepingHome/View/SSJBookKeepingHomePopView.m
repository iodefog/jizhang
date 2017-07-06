//
//  SSJBookKeepingHomePopView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomePopView.h"
#import "SSJLoginVerifyPhoneViewController.h"
//#import "SSJRegistGetVerViewController.h"
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
    self.registerButton.layer.borderColor = [UIColor ssj_colorWithHex:@"eb4a64"].CGColor;
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

- (BOOL)popLoginViewWithNav:(UINavigationController *)nav backController:(UIViewController *)backVC{
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveLoginOrRegistKey]) {
        NSDate *currentDate = [NSDate date];
        NSDate *lastPopTime = [[NSUserDefaults standardUserDefaults]objectForKey:SSJLastPopTimeKey];
        NSTimeInterval time=[currentDate timeIntervalSinceDate:lastPopTime];
        int days=((int)time)/(3600*24);
        if (days >= 1) {
            
            self.frame = [UIScreen mainScreen].bounds;
            self.loginBtnClickBlock = ^(){
                SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc]init];
                loginVC.backController = backVC;
                [nav pushViewController:loginVC animated:YES];
            };
            self.registerBtnClickBlock = ^(){
//                SSJRegistGetVerViewController *registerVC = [[SSJRegistGetVerViewController alloc]init];
//                registerVC.backController = backVC;
//                [nav pushViewController:registerVC animated:YES];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [[NSUserDefaults standardUserDefaults]setObject:currentDate forKey:SSJLastPopTimeKey];
            return YES;
        }
    }
    return NO;
}


@end
