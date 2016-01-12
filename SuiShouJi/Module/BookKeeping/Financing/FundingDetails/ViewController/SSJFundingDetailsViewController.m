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
#import "SSJModifyFundingViewController.h"

#import "FMDB.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";
static NSString *const kFundingDetailHeaderViewID = @"kFundingDetailHeaderViewID";

@interface SSJFundingDetailsViewController ()
@property (nonatomic,strong) SSJFundingDetailHeader *header;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic,strong) UIBarButtonItem *rightButton;
@end

@implementation SSJFundingDetailsViewController{
    double _totalIncome;
    double _totalExpence;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.rightButton;
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
    [self getTotalIcomeAndExpence];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    _header.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
    [SSJFundingDetailHelper queryDataWithFundTypeID:self.item.fundingID InYear:2016 month:0 success:^(NSArray<NSDictionary *> *data) {
        self.datas = data;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
    [self getTotalIcomeAndExpence];
    [self.tableView reloadData];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if ([sectionInfo[SSJFundingDetailSumKey] doubleValue] > 0) {
        headerView.balanceLabel.text = [NSString stringWithFormat:@"+%@",sectionInfo[SSJFundingDetailSumKey]];
    }else{
        headerView.balanceLabel.text = [NSString stringWithFormat:@"%@",sectionInfo[SSJFundingDetailSumKey]];
    }
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

-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClicked:)];
    }
    return _rightButton;
}

#pragma mark - Private
-(void)getTotalIcomeAndExpence{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    _totalIncome = [db doubleForQuery:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = ? AND A.IFID = ? AND A.OPERATORTYPE != 2",[NSNumber numberWithInt:0],self.item.fundingID];
    self.header.totalIncomeLabel.text = [NSString stringWithFormat:@"%.2f",_totalIncome];
    [self.header.totalIncomeLabel sizeToFit];
    _totalExpence = [db doubleForQuery:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = ? AND A.IFID = ? AND A.OPERATORTYPE != 2",[NSNumber numberWithInt:1],self.item.fundingID];
    self.header.totalExpenceLabel.text = [NSString stringWithFormat:@"%.2f",_totalExpence];
    [self.header.totalExpenceLabel sizeToFit];
    self.title = [db stringForQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",self.item.fundingID];
    self.item.fundingColor = [db stringForQuery:@"SELECT CCOLOR FROM BK_FUND_INFO WHERE CFUNDID = ?",self.item.fundingID];
}

-(void)rightButtonClicked:(id)sender{
    SSJModifyFundingViewController *newFundingVC = [[SSJModifyFundingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    self.item.fundingAmount = _totalIncome - _totalExpence;
    newFundingVC.item = self.item;
    [self.navigationController pushViewController:newFundingVC animated:YES];
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
