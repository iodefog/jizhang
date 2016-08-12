//
//  SSJBillingChargeViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeViewController.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJBillingChargeHeaderView.h"
#import "SSJBillingChargeCell.h"
#import "SSJBillingChargeHelper.h"

static NSString *const kBillingChargeCellID = @"kBillingChargeCellID";
static NSString *const kBillingChargeHeaderViewID = @"kBillingChargeHeaderViewID";

@interface SSJBillingChargeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation SSJBillingChargeViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"流水";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:kBillingChargeCellID];
    [self.tableView registerClass:[SSJBillingChargeHeaderView class] forHeaderFooterViewReuseIdentifier:kBillingChargeHeaderViewID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:self.color size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.datas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    NSArray *datas = sectionInfo[SSJBillingChargeRecordKey];
    return [datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kBillingChargeCellID forIndexPath:indexPath];
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)indexPath.section];
    NSArray *datas = sectionInfo[SSJBillingChargeRecordKey];
    [cell setCellItem:[datas ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    SSJBillingChargeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kBillingChargeHeaderViewID];
    headerView.textLabel.text = sectionInfo[SSJBillingChargeDateKey];
    headerView.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    NSString *sumStr = sectionInfo[SSJBillingChargeSumKey];
    sumStr = [NSString stringWithFormat:@"%.2f", [sumStr doubleValue]];
    headerView.sumLabel.text = sumStr;
    headerView.sumLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)indexPath.section];
    NSArray *datas = sectionInfo[SSJBillingChargeRecordKey];
    SSJBillingChargeCellItem *selectedItem = [datas ssj_safeObjectAtIndex:indexPath.row];
    SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    calenderDetailVC.item = selectedItem;
    [self.navigationController pushViewController:calenderDetailVC animated:YES];
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    view.tintColor = [UIColor redColor];
////    view.backgroundColor = [UIColor redColor];
//}

#pragma mark - Private
- (void)reloadData {
    if (_isMemberCharge) {
        [self.view ssj_showLoadingIndicator];
        [SSJBillingChargeHelper queryMemberChargeWithMemberID:_ID inPeriod:_period isPayment:_isPayment success:^(NSArray<NSDictionary *> *data) {
            [self.view ssj_hideLoadingIndicator];
            self.datas = data;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            NSString *message = [error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        }];
        
    } else {
        [self.view ssj_showLoadingIndicator];
        [SSJBillingChargeHelper queryDataWithBillTypeID:_ID inPeriod:_period success:^(NSArray<NSDictionary *> *data) {
            [self.view ssj_hideLoadingIndicator];
            self.datas = data;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            NSString *message = [error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        }];
    }
}

- (void)reloadDataAfterSync {
    [self reloadData];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        if (![[SSJThemeSetting currentThemeModel].ID isEqualToString:@"0"]) {
            _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:0.1];
        }
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.rowHeight = 90;
        _tableView.sectionHeaderHeight = 40;
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return _tableView;
}

@end
