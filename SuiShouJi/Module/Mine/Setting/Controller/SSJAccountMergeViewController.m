//
//  SSJAccountMergeViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeViewController.h"

@interface SSJAccountMergeViewController ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UILabel *startLab;

@property (nonatomic, strong) UILabel *endLab;

@property (nonatomic, strong) UIButton *startButton;

@property (nonatomic, strong) UIButton *endButton;

@property (nonatomic, strong) UILabel *mergeTitleLab;

@property (nonatomic, strong) UILabel *hintLab;

@property (nonatomic, strong) UIImageView *warningImage;

@end

@implementation SSJAccountMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据合并";
    // Do any additional setup after loading the view.
}


#pragma mark - Getter


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
