//
//  SSJSearchingViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchingViewController.h"
#import "SSJChargeSearchingStore.h"

@interface SSJSearchingViewController ()

@end

@implementation SSJSearchingViewController{
#warning test
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _startTime = CFAbsoluteTimeGetCurrent();
    [SSJChargeSearchingStore searchForChargeListWithSearchContent:@"餐饮" ListOrder:SSJChargeListOrderMoneyAscending Success:^(NSArray<SSJSearchResultItem *> *result) {
        _endTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"查询%ld条数据耗时%f",result.count,_endTime - _startTime);
    } failure:^(NSError *error) {
        
    }];
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
