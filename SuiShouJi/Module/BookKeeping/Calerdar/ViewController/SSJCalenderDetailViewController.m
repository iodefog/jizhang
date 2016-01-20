
//
//  SSJCalenderDetailViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailViewController.h"
#import "SSJBillingChargeCell.h"

@interface SSJCalenderDetailViewController ()

@end

@implementation SSJCalenderDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.colorValue] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:@"calenderDetailCellID"];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 55;
    }
    return 50;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellItem:self.item];
        return cell;
    }
    return nil;
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
