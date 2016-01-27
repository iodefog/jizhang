
//
//  SSJCalenderDetailViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailViewController.h"
#import "SSJBillingChargeCell.h"
#import "SSJCalenderDetailCell.h"
#import "SSJRecordMakingViewController.h"
#import "FMDB.h"

@interface SSJCalenderDetailViewController ()
@property (nonatomic,strong) UIView *footerView;
@end

@implementation SSJCalenderDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.colorValue] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:@"BillingChargeCell"];
    [self.tableView registerClass:[SSJCalenderDetailCell class] forCellReuseIdentifier:@"calenderDetailCellID"];

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
        SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillingChargeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellItem:self.item];
        return cell;
    }else if (indexPath.row == 1){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.detailLabel.text = self.item.billDate;
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"时间";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else{
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.detailLabel.text = [self getParentFundingNameWithParentfundingID:self.item.parent];
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"资金类型";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }
}

-(NSString*)getParentFundingNameWithParentfundingID:(NSString*)fundingID{
    NSString *fundingName;
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",fundingID];
    while ([rs next]) {
        fundingName = [rs stringForColumn:@"CACCTNAME"];
    }
    [db close];
    return fundingName;
}

#pragma mark - Getter
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 22, 40)];
        UIButton *editeButton = [[UIButton alloc]init];
        [editeButton setTitle:@"修改此记录" forState:UIControlStateNormal];
        [editeButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        editeButton.layer.borderWidth = 1.f;
        editeButton.layer.cornerRadius = 2.f;
        editeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        editeButton.center = CGPointMake(_footerView.height / 2, _footerView.width / 2);
        [editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerView;
}

#pragma mark - Private
-(void)editeButtonClicked:(id)sender{
    SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
    recordMakingVc.item = self.item;
    [self.navigationController pushViewController:recordMakingVc animated:YES];
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
