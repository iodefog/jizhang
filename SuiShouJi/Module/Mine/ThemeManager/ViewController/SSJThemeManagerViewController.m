//
//  SSJThemeManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeManagerViewController.h"

@interface SSJThemeManagerViewController ()

@end

@implementation SSJThemeManagerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"已下载皮肤";
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
