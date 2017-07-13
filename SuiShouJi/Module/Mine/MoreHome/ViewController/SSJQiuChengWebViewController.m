//
//  SSJQiuChengWebViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJQiuChengWebViewController.h"
#import "SSJUserTableManager.h"

@interface SSJQiuChengWebViewController ()

@end

@implementation SSJQiuChengWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCurrentUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCurrentUrl {
    @weakify(self);
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        @strongify(self);
        
        NSMutableString *url = [NSMutableString stringWithFormat:@"%@",SSJURLWithAPI(@"/chargebook/partner/qiuchengPage.go?")];
        
        [url appendFormat:@"%@=%@",@"cuserId",SSJUSERID()];
        
        [url appendFormat:@"%@=%@",@"&client_type",@"IOS"];
        
        [url appendFormat:@"%@=%@",@"&client_code",[UIDevice currentDevice].identifierForVendor.UUIDString];
        
        [url appendFormat:@"%@=%@",@"&mobile",userItem.mobileNo ? : @""];
        
        [self loadURL:[NSURL URLWithString:url]];
    } failure:NULL];

    
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
