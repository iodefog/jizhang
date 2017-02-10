//
//  SSJFundingTransferDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferDetailViewController.h"
#import "SSJFundingTransferStore.h"
#import "SSJFundingTransferDetailCell.h"
#import "SSJFundingTransferDetailItem.h"
#import "SSJTransferDetailHeader.h"
#import "SSJFundingTransferEditeViewController.h"

static NSString * SSJTransferDetailCellIdentifier = @"transferDetailCell";
static NSString * SSJTransferDetailHeaderIdentifier = @"transferDetailHeader";


@interface SSJFundingTransferDetailViewController ()
@property(nonatomic, strong) NSArray *datas;
@end

@implementation SSJFundingTransferDetailViewController
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账记录";
        self.hidesBottomBarWhenPushed = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJFundingTransferDetailCell class] forCellReuseIdentifier:SSJTransferDetailCellIdentifier];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SSJFundingTransferStore queryForFundingTransferListWithSuccess:^(NSArray <NSDictionary *>*result) {
        if (result.count) {
            [self.tableView ssj_hideWatermark:YES];
        }else{
            [self.tableView ssj_showWatermarkWithImageName:@"founds_transfer_none" animated:NO target:self action:NULL];
        }
        weakSelf.datas = result;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:indexPath.section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    
    SSJFundingTransferDetailItem *item = [items ssj_safeObjectAtIndex:indexPath.row];
    SSJFundingTransferEditeViewController *transferEditeVc = [[SSJFundingTransferEditeViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    transferEditeVc.item = item;
    [self.navigationController pushViewController:transferEditeVc animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    return items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:indexPath.section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    SSJFundingTransferDetailItem *item = [items ssj_safeObjectAtIndex:indexPath.row];
    
    SSJFundingTransferDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJTransferDetailCellIdentifier forIndexPath:indexPath];
    cell.item = item;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:section];
    SSJTransferDetailHeader *header = [[SSJTransferDetailHeader alloc] init];
    header.date = [monthInfo objectForKey:SSJFundingTransferStoreMonthKey];
    return header;
}

@end
