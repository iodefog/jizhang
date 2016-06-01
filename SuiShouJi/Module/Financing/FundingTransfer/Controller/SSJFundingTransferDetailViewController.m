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
@property(nonatomic, strong) NSDictionary *datas;
@end

@implementation SSJFundingTransferDetailViewController
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账记录";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJFundingTransferDetailCell class] forCellReuseIdentifier:SSJTransferDetailCellIdentifier];
    [self.tableView registerClass:[SSJTransferDetailHeader class] forHeaderFooterViewReuseIdentifier:SSJTransferDetailHeaderIdentifier];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SSJFundingTransferStore queryForFundingTransferListWithSuccess:^(NSMutableDictionary *result) {
        weakSelf.datas = [NSDictionary dictionaryWithDictionary:result];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
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
    NSArray *items = [self.datas objectForKey:[[self.datas allKeys] objectAtIndex:indexPath.section]];
    SSJFundingTransferDetailItem *item = [items objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFundingTransferEditeViewController *transferEditeVc = [[SSJFundingTransferEditeViewController alloc]init];
    transferEditeVc.item = item;
    [self.navigationController pushViewController:transferEditeVc animated:YES];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *items = [self.datas objectForKey:[[self.datas allKeys] objectAtIndex:section]];
    return items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.datas allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = [self.datas objectForKey:[[self.datas allKeys] objectAtIndex:indexPath.section]];
    SSJFundingTransferDetailItem *item = [items objectAtIndex:indexPath.row];
    SSJFundingTransferDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJTransferDetailCellIdentifier forIndexPath:indexPath];
    cell.item = item;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SSJTransferDetailHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SSJTransferDetailHeaderIdentifier];
    header.currentMonth = [[self.datas allKeys] objectAtIndex:section];
    return header;
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
