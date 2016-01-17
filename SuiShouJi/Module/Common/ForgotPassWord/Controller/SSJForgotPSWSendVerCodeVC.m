//
//  SSJForgotPSWSendVerCodeVC.m
//  YYDB
//
//  Created by cdd on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJForgotPSWSendVerCodeVC.h"

@interface SSJForgotPSWSendVerCodeVC ()

@end

@implementation SSJForgotPSWSendVerCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)serverDidFinished:(SSJBaseNetworkService *)service{
    [super serverDidFinished:service];
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error{
    [super server:service didFailLoadWithError:error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
