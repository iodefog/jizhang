

//
//  SSJDeleteBooksDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreditCardListDetailItem.h"
#import "SSJFundingDetailListItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentModel.h"

#import "SSJFundingDetailHelper.h"
#import "SSJFundingDetailListHeaderView.h"
#import "SSJCreditCardRepaymentViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJCreditCardStore.h"

#import "SSJFundingDetailCell.h"
#import "SSJFundingDetailListFirstLineCell.h"
#import "SSJFundingDailySumCell.h"
#import "SSJFundingDetailNoDataView.h"
#import "SSJCreditCardDetailHeader.h"
#import "SSJCreditCardListCell.h"
#import "SSJLoanChangeChargeSelectionControl.h"

#import "SSJLoanChargeDetailViewController.h"
#import "SSJLoanChargeAddOrEditViewController.h"
#import "SSJCreditCardRepaymentViewController.h"
#import "SSJDeleteBooksDetailViewController.h"
#import "SSJNewCreditCardViewController.h"
#import "SSJFundingTransferChargeDetailViewController.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJInstalmentEditeViewController.h"
#import "SSJInstalmentDetailViewController.h"
#import "SSJBalenceChangeDetailViewController.h"
#import "SSJNewFundingViewController.h"

#import "FMDB.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";
static NSString *const kFundingListFirstLineCellID = @"kFundingListFirstLineCellID";
static NSString *const kFundingListDailySumCellID = @"kFundingListDailySumCellID";
static NSString *const kFundingListHeaderViewID = @"kFundingListHeaderViewID";
static NSString *const kCreditCardListFirstLineCellID = @"kCreditCardListFirstLineCellID";

@interface SSJDeleteBooksDetailViewController ()

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property(nonatomic, strong)  NSMutableArray *listItems;

@end

@implementation SSJDeleteBooksDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.hidesBottomBarWhenPushed = YES;
        self.statisticsTitle = @"资金账户详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.booksName;
    self.navigationItem.rightBarButtonItem = self.rightButton;
    self.tableView.sectionHeaderHeight = 40;
    [self.tableView registerClass:[SSJFundingDetailCell class] forCellReuseIdentifier:kFundingDetailCellID];
    [self.tableView registerClass:[SSJFundingDailySumCell class] forCellReuseIdentifier:kFundingListDailySumCellID];
    [self.tableView registerClass:[SSJCreditCardListCell class] forCellReuseIdentifier:kCreditCardListFirstLineCellID];
    [self.tableView registerClass:[SSJFundingDetailListFirstLineCell class] forCellReuseIdentifier:kFundingListFirstLineCellID];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view ssj_showLoadingIndicator];
    [self getDataFromDb];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (((SSJFundingDetailListItem *)[self.listItems objectAtIndex:section]).isExpand) {
        return [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:section]).chargeArray count] + 1;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item;
    if (indexPath.row >= 1) {
        item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray ssj_safeObjectAtIndex:indexPath.row - 1];
    }
    if (indexPath.row == 0) {
        if ([[self.listItems objectAtIndex:indexPath.section] isKindOfClass:[SSJCreditCardListDetailItem class]]) {
            SSJCreditCardListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreditCardListFirstLineCellID forIndexPath:indexPath];
            cell.item = [self.listItems objectAtIndex:indexPath.section];
            return cell;
        }else{
            SSJFundingDetailListFirstLineCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingListFirstLineCellID forIndexPath:indexPath];
            cell.item = [self.listItems objectAtIndex:indexPath.section];
            return cell;
        }
    }else if ([item isKindOfClass:[SSJFundingListDayItem class]]){
        SSJFundingDailySumCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingListDailySumCellID forIndexPath:indexPath];
        cell.item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
        return cell;
    }else if([item isKindOfClass:[SSJBillingChargeCellItem class]]){
        SSJFundingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingDetailCellID forIndexPath:indexPath];
        cell.item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
        if (indexPath.row < [[((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]) chargeArray] count]) {
            SSJBaseCellItem *nextItem = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray ssj_safeObjectAtIndex:indexPath.row];
            if ([nextItem isKindOfClass:[SSJFundingListDayItem class]]) {
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
            }
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJFundingDetailListHeaderView *headerView = [[SSJFundingDetailListHeaderView alloc]init];
    headerView.layer.shadowOffset = CGSizeMake(0, 1);
    headerView.layer.shadowOpacity = 0.08;
    headerView.layer.shadowColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor].CGColor;
    headerView.clipsToBounds = NO;
    headerView.item = [self.listItems objectAtIndex:section];
    __weak typeof(self) weakSelf = self;
    headerView.SectionHeaderClickedBlock = ^(){
        ((SSJFundingDetailListItem *)[weakSelf.listItems objectAtIndex:section]).isExpand = !((SSJFundingDetailListItem *)[weakSelf.listItems objectAtIndex:section]).isExpand;
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.tableView endUpdates];
    };
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        SSJBaseCellItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
        if ([item isKindOfClass:[SSJBillingChargeCellItem class]]) {
            SSJBillingChargeCellItem *billingItem = (SSJBillingChargeCellItem *)item;
            if (billingItem.chargeImage.length || billingItem.chargeMemo.length) {
                return 65;
            }
            return 50;
        }else{
            return 30;
        }
    }
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        SSJBaseCellItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
        if ([item isKindOfClass:[SSJBillingChargeCellItem class]]) {
            
            SSJBillingChargeCellItem *cellItem = (SSJBillingChargeCellItem *)item;
            int billId = [cellItem.billId intValue];
            
            if (cellItem.idType == SSJChargeIdTypeLoan) {
                // 满足以下条件跳转详情页面，否则跳转编辑页面
                // 1.借贷已结清 2.流水类别是转入／转出，只有创建借贷或结清时才回生成这两种流水 3.余额变更
                BOOL closeOut = [SSJFundingDetailHelper queryCloseOutStateWithLoanId:cellItem.sundryId];
                if (closeOut || billId == 3 || billId == 4 || billId == 9 || billId == 10) {
                    SSJLoanChargeDetailViewController *detailController = [[SSJLoanChargeDetailViewController alloc] init];
                    detailController.chargeId = cellItem.ID;
                    [self.navigationController pushViewController:detailController animated:YES];
                } else {
                    SSJLoanChargeAddOrEditViewController *editController = [[SSJLoanChargeAddOrEditViewController alloc] init];
                    editController.edited = YES;
                    editController.chargeId = cellItem.ID;
                    [self.navigationController pushViewController:editController animated:YES];
                }
            } else if(cellItem.idType == SSJChargeIdTypeRepayment) {
                if (billId == 3 || billId == 4) {
                    // 如果是转账,则是还款,跳转到还款页面
                    SSJCreditCardRepaymentViewController *repaymentVc = [[SSJCreditCardRepaymentViewController alloc]init];
                    repaymentVc.chargeItem = cellItem;
                    [self.navigationController pushViewController:repaymentVc animated:YES];
                }else {
                    SSJInstalmentDetailViewController *instalmentDetailVc = [[SSJInstalmentDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                    instalmentDetailVc.chargeItem = cellItem;
                    [self.navigationController pushViewController:instalmentDetailVc animated:YES];
                }
            } else {
                if (billId == 3 || billId == 4) {
                    SSJFundingTransferChargeDetailViewController *transferVc = [[SSJFundingTransferChargeDetailViewController alloc] init];
                    transferVc.chargeItem = (SSJBillingChargeCellItem*)item;
                    [self.navigationController pushViewController:transferVc animated:YES];
                } else {
                    if (billId != 1 && billId != 2) {
                        SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                        calenderDetailVC.item = (SSJBillingChargeCellItem *)item;
                        [self.navigationController pushViewController:calenderDetailVC animated:YES];
                        
                    } else {
                        SSJBalenceChangeDetailViewController *balanceChangeVc = [[SSJBalenceChangeDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                        balanceChangeVc.chargeItem = (SSJBillingChargeCellItem *)item;
//                        balanceChangeVc.fundItem = self.item;
                        [self.navigationController pushViewController:balanceChangeVc animated:YES];
                    }
                }
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

#pragma mark - Private
-(void)reloadDataAfterSync{
    [self.view ssj_showLoadingIndicator];
    [self getDataFromDb];
}


- (void)getDataFromDb {
    @weakify(self);
    [SSJFundingDetailHelper queryDataWithBooksId:self.booksId FundTypeID:self.fundId success:^(NSMutableArray *data) {
        @strongify(self);
        [self array:self.listItems isEqualToAnotherArray:data];
        self.listItems = [NSMutableArray arrayWithArray:data];
        [self.tableView reloadData];
        [self.view ssj_hideLoadingIndicator];

    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
    }];

}


//anotherArr 新
- (void)array:(NSMutableArray <SSJFundingDetailListItem *> *)array  isEqualToAnotherArray:(NSMutableArray <SSJFundingDetailListItem *> *)anotherArr {
    if (array.count == anotherArr.count) {
        for (int i = 0; i < anotherArr.count; i++) {
            if ([[array ssj_safeObjectAtIndex:i] isEqual:[anotherArr ssj_safeObjectAtIndex:i]]) {
                self.listItems = anotherArr;
            } else {
                //保存最新model,展开状态
                ((SSJFundingDetailListItem *)[anotherArr ssj_safeObjectAtIndex:i]).isExpand = ((SSJFundingDetailListItem *)[array ssj_safeObjectAtIndex:i]).isExpand;
                self.listItems = anotherArr;
                //刷新表格
            }
        }
    } else if(anotherArr.count < array.count){ // 删除
        //保存最新model,展开状态
        for (SSJFundingDetailListItem *tempItem in anotherArr) {
            for (SSJFundingDetailListItem *oldItem in array) {
                if ([oldItem.date isEqualToString:tempItem.date]) {//通过时间判断是哪个
                    tempItem.isExpand = oldItem.isExpand;
                    break;
                }
            }
        }
        self.listItems = anotherArr;
    } else if (anotherArr.count > array.count) { //开始加载数据
        self.listItems = anotherArr;
    }
    [self.tableView reloadData];
}


@end

