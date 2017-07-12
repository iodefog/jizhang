//
//  SSJQiuChengWebViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJQiuChengWebViewController.h"

@interface SSJQiuChengWebViewController ()

@end

@implementation SSJQiuChengWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCurrentUrl {
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@",SSJURLWithAPI(@"/chargebook/partner/qiuchengPage.go?")];
    
    [url appendFormat:@"%@:%@",@"cuserId",SSJUSERID()];
    
    [url appendFormat:@"%@:%@",@"client_type",@"IOS"];

    [url appendFormat:@"%@:%@",@"client_code",SSJUSERID()];

    [url appendFormat:@"%@:%@",@"mobile",SSJUSERID()];

    
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
