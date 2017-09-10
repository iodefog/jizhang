//
//  SSJNewUserStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewUserFirstStartViewController.h"

@interface SSJNewUserFirstStartViewController ()

@property (nonatomic, strong) YYAnimatedImageView *gifImageView;

@property (nonatomic, strong) YYImage *gifImage;

@end

@implementation SSJNewUserFirstStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.gifImageView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
- (YYAnimatedImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[YYAnimatedImageView alloc] initWithImage:self.gifImage];
    }
    return _gifImageView;
}

- (YYImage *)gifImage {
    if (!_gifImage) {
        _gifImage = [YYImage imageNamed:@"newuserguide1.gif"];
    }
    return _gifImage;
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
