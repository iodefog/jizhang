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
#import "SSJFundingDetailCell.h"
#import "SSJBillingChargeHelper.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJUserTableManager.h"

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
    [self.tableView registerClass:[SSJFundingDetailCell class] forCellReuseIdentifier:kBillingChargeCellID];
    [self.tableView registerClass:[SSJBillingChargeHeaderView class] forHeaderFooterViewReuseIdentifier:kBillingChargeHeaderViewID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.tableView reloadData];
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
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
    SSJFundingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kBillingChargeCellID forIndexPath:indexPath];
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)indexPath.section];
    NSArray *datas = sectionInfo[SSJBillingChargeRecordKey];
    SSJBillingChargeCellItem *selectedItem = [datas ssj_safeObjectAtIndex:indexPath.row];
    cell.item = selectedItem;
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    SSJBillingChargeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kBillingChargeHeaderViewID];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        headerView.backgroundView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    } else {
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
    
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
    
    if (self.booksId.length) {
        [self enterCalenderDetailWithSelectedItem:selectedItem];
    } else {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            self.booksId = userItem.currentBooksId;
            [self enterCalenderDetailWithSelectedItem:selectedItem];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    view.tintColor = [UIColor redColor];
////    view.backgroundColor = [UIColor redColor];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)indexPath.section];
    NSArray *datas = sectionInfo[SSJBillingChargeRecordKey];
    SSJBillingChargeCellItem *selectedItem = [datas ssj_safeObjectAtIndex:indexPath.row];
    if (selectedItem.chargeMemo.length
        || selectedItem.chargeImage.length
        || selectedItem.memberNickname.length) {
        return 65;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - Private
- (void)reloadData {
    if ([self.booksId isEqualToString:SSJAllBooksIds]) {
        [self.view ssj_showLoadingIndicator];
        [SSJBillingChargeHelper queryAllBooksChargeListBillId:self.billId period:self.period success:^(NSArray<NSDictionary *> * _Nonnull result) {
            [self.view ssj_hideLoadingIndicator];
            self.datas = result;
            [self.tableView reloadData];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    } else if (self.billId) {
        [self.view ssj_showLoadingIndicator];
        [SSJBillingChargeHelper queryChargeListWithMemberId:self.memberId booksId:self.booksId billId:self.billId period:self.period success:^(NSArray<NSDictionary *> * _Nonnull result) {
            [self.view ssj_hideLoadingIndicator];
            self.datas = result;
            [self.tableView reloadData];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    } else {
        [self.view ssj_showLoadingIndicator];
        [SSJBillingChargeHelper queryChargeListWithMemberId:self.memberId booksId:self.booksId billName:self.billName billType:self.billType period:self.period success:^(NSArray<NSDictionary *> * _Nonnull result) {
            [self.view ssj_hideLoadingIndicator];
            self.datas = result;
            [self.tableView reloadData];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    }
}

- (void)reloadDataAfterSync {
    [self reloadData];
}

- (void)enterCalenderDetailWithSelectedItem:(SSJBillingChargeCellItem *)selectedItem {
    SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    calenderDetailVC.item = selectedItem;
    __weak typeof(self) wself = self;
    calenderDetailVC.deleteHandler = ^ {
        [SSJBillingChargeHelper queryTheRestChargeCountWithBillId:wself.billId memberId:wself.memberId booksId:wself.booksId period:wself.period success:^(int count) {
            if (count == 0) {
                [wself.navigationController popToRootViewControllerAnimated:YES];
            } else {
                [wself.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    };
    [self.navigationController pushViewController:calenderDetailVC animated:YES];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return _tableView;
}

@end
