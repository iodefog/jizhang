//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailsViewController.h"
#import "SSJFundingDetailHeader.h"
#import "SSJFundingDetailHelper.h"
#import "SSJBillingChargeCell.h"
#import "SSJFundingDetailDateHeader.h"
#import "SSJReportFormsUtil.h"

#import "FMDB.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";
static NSString *const kFundingDetailHeaderViewID = @"kFundingDetailHeaderViewID";

@interface SSJFundingDetailsViewController ()
@property (nonatomic,strong) SSJFundingDetailHeader *header;
@property (nonatomic, strong) NSArray *datas;
@end

@implementation SSJFundingDetailsViewController{
    double _totalIncome;
    double _totalExpence;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.item.fundingName;
    self.tableView.rowHeight = 55;
    self.tableView.sectionHeaderHeight = 40;
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:kFundingDetailCellID];
    [self.tableView registerClass:[SSJFundingDetailDateHeader class] forHeaderFooterViewReuseIdentifier:kFundingDetailHeaderViewID];
    self.tableView.tableHeaderView = self.header;
    [self getTotalIcomeAndExpence];
    [SSJFundingDetailHelper queryDataWithFundTypeID:self.item.fundingID InYear:2016 month:0 success:^(NSArray<NSDictionary *> *data) {
        self.datas = data;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.datas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    NSArray *datas = sectionInfo[SSJFundingDetailRecordKey];
    return [datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingDetailCellID forIndexPath:indexPath];
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)indexPath.section];
    NSArray *datas = sectionInfo[SSJFundingDetailRecordKey];
    [cell setCellItem:[datas ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    SSJFundingDetailDateHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kFundingDetailHeaderViewID];
    headerView.dateLabel.text = [NSString stringWithFormat:@"%@",sectionInfo[SSJFundingDetailDateKey]];
    [headerView.dateLabel sizeToFit];
    headerView.balanceLabel.text = [NSString stringWithFormat:@"%@",sectionInfo[SSJFundingDetailSumKey]];
    [headerView.balanceLabel sizeToFit];
    return headerView;
}

#pragma mark - Getter
-(SSJFundingDetailHeader *)header{
    if (!_header) {
        _header = [[SSJFundingDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 107)];
        _header.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
        [_header ssj_setBorderColor:[UIColor whiteColor]];
        [_header ssj_setBorderStyle:SSJBorderStyleTop];
        [_header ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
    }
    return _header;
}

#pragma mark - Private
-(void)getTotalIcomeAndExpence{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    _totalIncome = [db doubleForQuery:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = ? AND A.IFID = ?",[NSNumber numberWithInt:0],self.item.fundingID];
    self.header.totalIncomeLabel.text = [NSString stringWithFormat:@"%.2f",_totalIncome];
    [self.header.totalIncomeLabel sizeToFit];
    _totalExpence = [db doubleForQuery:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = ? AND A.IFID = ?",[NSNumber numberWithInt:1],self.item.fundingID];
    self.header.totalExpenceLabel.text = [NSString stringWithFormat:@"%.2f",_totalExpence];
    [self.header.totalExpenceLabel sizeToFit];
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
