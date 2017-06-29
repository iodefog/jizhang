//
//  SSJTestViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTestViewController.h"
#import "SSJFinancingHomeSelectView.h"

@interface SSJTestViewController ()

@end

@implementation SSJTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SSJFinancingHomeSelectView *view = [[SSJFinancingHomeSelectView alloc] initWithFrame:CGRectMake(100, 100, 59, 3)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
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
