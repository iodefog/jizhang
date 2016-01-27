//
//  SSJBillingChargeViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeViewController.h"
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
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJBillingChargeHelper queryDataWithBillTypeID:self.billTypeID InYear:self.year month:self.month success:^(NSArray<NSDictionary *> *data) {
        [self.view ssj_hideLoadingIndicator];
        self.datas = data;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        
        NSString *message = [error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = self.color;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    
    NSString *sumStr = sectionInfo[SSJBillingChargeSumKey];
    sumStr = [NSString stringWithFormat:@"%.2f", [sumStr doubleValue]];
    headerView.sumLabel.text = sumStr;
    
    return headerView;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 40;
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return _tableView;
}

@end
