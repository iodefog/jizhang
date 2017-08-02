//
//  SSJDataMergeSettingViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataMergeSettingViewController.h"
#import "SSJBooksMergeViewController.h"
#import "SSJFundingMergeViewController.h"

#import "SSJMineHomeTabelviewCell.h"



@interface SSJDataMergeSettingViewController ()

@property (nonatomic, strong) NSArray *titles;


@end

@implementation SSJDataMergeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SSJIsUserLogined()) {
        self.titles = @[@"数据合并",@"账本合并",@"资金合并"];
    } else {
        self.titles = @[@"账本合并",@"资金合并"];
    }

    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    
    if ([title isEqualToString:@"数据合并"]) {
        
    } else if ([title isEqualToString:@"资金合并"]) {
        SSJFundingMergeViewController *accountMerge = [[SSJFundingMergeViewController alloc] init];
        accountMerge.transferOutSelectable = YES;
        accountMerge.transferInSelectable = YES;
        accountMerge.transferType = SSJFundsTransferTypeAll;
        [self.navigationController pushViewController:accountMerge animated:YES];

    } else if ([title isEqualToString:@"账本合并"]) {
        SSJBooksMergeViewController *booksMergeVC = [[SSJBooksMergeViewController alloc] init];
        booksMergeVC.transferOutSelectable = YES;
        booksMergeVC.transferInSelectable = YES;
        
        [self.navigationController pushViewController:booksMergeVC animated:YES];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    
    mineHomeCell.cellTitle = title;
    
    mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return mineHomeCell;
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
