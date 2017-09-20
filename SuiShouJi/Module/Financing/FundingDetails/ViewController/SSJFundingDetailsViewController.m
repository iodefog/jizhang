            //
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//


#import "SSJFundingDetailHelper.h"
#import "SSJFundingDetailListHeaderView.h"
#import "SSJDatabaseQueue.h"
#import "SSJCreditCardStore.h"

#import "SSJFundingDetailHeader.h"
#import "SSJFundingDetailCell.h"
#import "SSJFundingDetailListFirstLineCell.h"
#import "SSJFundingDailySumCell.h"
#import "SSJFundingDetailListFirstLineCell.h"
#import "SSJFundingDetailNoDataView.h"
#import "SSJCreditCardDetailHeader.h"

#import "SSJCreditCardListFirstLineItem.h"
#import "SSJCreditCardListDetailItem.h"
#import "SSJFundingDetailListItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJRepaymentModel.h"

#import "SSJLoanChargeDetailViewController.h"
#import "SSJLoanChargeAddOrEditViewController.h"
#import "SSJCreditCardRepaymentViewController.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJNewCreditCardViewController.h"
#import "SSJFundingTransferChargeDetailViewController.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJInstalmentEditeViewController.h"
#import "SSJInstalmentDetailViewController.h"
#import "SSJBalenceChangeDetailViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJDeleteBooksDetailViewController.h"
#import "SSJCreditCardRepaymentViewController.h"
#import "SSJLoanChangeChargeSelectionControl.h"
#import "SSJFixedFinanctAddViewController.h"
#import "SSJFixedFinanceRedemViewController.h"
#import "SSJFixedFinancesSettlementViewController.h"
#import "SSJEveryInverestDetailViewController.h"
#import "SSJRecordMakingViewController.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";
static NSString *const kFundingListFirstLineCellID = @"kFundingListFirstLineCellID";
static NSString *const kFundingListDailySumCellID = @"kFundingListDailySumCellID";
static NSString *const kFundingListHeaderViewID = @"kFundingListHeaderViewID";
static NSString *const kCreditCardListFirstLineCellID = @"kCreditCardListFirstLineCellID";

@interface SSJFundingDetailsViewController ()
@property (nonatomic,strong) SSJFundingDetailHeader *header;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property(nonatomic, strong)  NSMutableArray *listItems;

@property(nonatomic, strong) SSJFundingDetailNoDataView *noDataHeader;

@property(nonatomic, strong) SSJCreditCardDetailHeader *creditCardHeader;

@property(nonatomic, strong) SSJLoanChangeChargeSelectionControl *repaymentPopView;

@property(nonatomic, strong) UIButton *repaymentButton;

@property(nonatomic, strong) UIButton *recordButton;

@end

@implementation SSJFundingDetailsViewController{
    double _totalIncome;
    double _totalExpence;
}

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
    self.navigationItem.rightBarButtonItem = self.rightButton;
    self.title = self.item.fundingName;
    self.tableView.sectionHeaderHeight = 40;
    [self.tableView registerClass:[SSJFundingDetailCell class] forCellReuseIdentifier:kFundingDetailCellID];
    [self.tableView registerClass:[SSJFundingDailySumCell class] forCellReuseIdentifier:kFundingListDailySumCellID];
    [self.tableView registerClass:[SSJFundingDetailListFirstLineCell class] forCellReuseIdentifier:kCreditCardListFirstLineCellID];
    [self.tableView addSubview:self.noDataHeader];
    [self.view addSubview:self.repaymentButton];
    [self.view addSubview:self.recordButton];
    [self.recordButton ssj_setBorderStyle:SSJBorderStyleTop];
    if (self.item.cardItem) {
        self.tableView.tableHeaderView = self.creditCardHeader;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        self.recordButton.width = self.repaymentButton.width = self.view.width / 2;
        self.repaymentButton.right = self.view.width;
        [self.repaymentButton ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleLeft];
    }else{
        self.recordButton.width = self.view.width;
        self.repaymentButton.hidden = YES;
        self.tableView.tableHeaderView = self.header;
    }


}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [self reloadCurrentFundData];
    //    [self getTotalIcomeAndExpence];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (((SSJFundingDetailListItem *)[self.listItems objectAtIndex:section]).isExpand) {
        return [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:section]).chargeArray count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item;
    item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray ssj_safeObjectAtIndex:indexPath.row];
    if ([item isKindOfClass:[SSJFundingListDayItem class]]) {
        SSJFundingDailySumCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingListDailySumCellID forIndexPath:indexPath];
        cell.item = [((SSJFundingDetailListItem *) [self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row];
        return cell;
    } else if ([item isKindOfClass:[SSJBillingChargeCellItem class]]) {
        SSJFundingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingDetailCellID forIndexPath:indexPath];
        cell.item = [((SSJFundingDetailListItem *) [self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row];
        if (indexPath.row
            < [[((SSJFundingDetailListItem *) [self.listItems objectAtIndex:indexPath.section]) chargeArray] count]) {
            SSJBaseCellItem *nextItem = [((SSJFundingDetailListItem *) [self.listItems objectAtIndex:indexPath.section]).chargeArray ssj_safeObjectAtIndex:indexPath.row];
            if ([nextItem isKindOfClass:[SSJFundingListDayItem class]]) {
                cell.separatorInset = UIEdgeInsetsMake(0 , 0 , 0 , 0);
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0 , 15 , 0 , 15);
            }
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0 , 0 , 0 , 0);
        }
        return cell;
    } else if ([item isKindOfClass:[SSJCreditCardListFirstLineItem class]]) {
        SSJFundingDetailListFirstLineCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreditCardListFirstLineCellID forIndexPath:indexPath];
        cell.item = [((SSJFundingDetailListItem *) [self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row];
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
    SSJBaseCellItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row];
    if (item.rowHeight) {
        return item.rowHeight;
    } else {
        return 35;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBaseCellItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row];
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
        } else if (cellItem.idType == SSJChargeIdTypeFixedFinance) {
            [SSJFundingDetailHelper queryfixedFinanceDateWithChargeItem:cellItem success:^(SSJFixedFinanceProductItem *productItem, SSJFixedFinanceProductChargeItem *chargeItem) {
                chargeItem.chargeType = cellItem.fixedFinanceChargeType;
                if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeCloseOut) {
                    SSJFixedFinancesSettlementViewController *addvc = [[SSJFixedFinancesSettlementViewController alloc] init];
                    addvc.financeModel = productItem;
                    addvc.chargeItem = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                } else if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeCreate) {
                    SSJEveryInverestDetailViewController *addvc = [[SSJEveryInverestDetailViewController alloc] init];
                    addvc.productItem = productItem;
                    addvc.chargeItem = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                } else if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeRedemption) {
                    SSJFixedFinanceRedemViewController *addvc = [[SSJFixedFinanceRedemViewController alloc] init];
                    addvc.financeModel = productItem;
                    addvc.chargeModel = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                } else if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeAdd) {
                    SSJFixedFinanctAddViewController *addvc = [[SSJFixedFinanctAddViewController alloc] init];
                    addvc.financeModel = productItem;
                    addvc.chargeItem = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                } else if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeBalanceInterestIncrease) {
                    SSJFixedFinancesSettlementViewController *addvc = [[SSJFixedFinancesSettlementViewController alloc] init];
                    addvc.financeModel = productItem;
                    addvc.chargeItem = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                } else if (cellItem.fixedFinanceChargeType == SSJFixedFinCompoundChargeTypeCloseOutInterest) {
                    SSJFixedFinancesSettlementViewController *addvc = [[SSJFixedFinancesSettlementViewController alloc] init];
                    addvc.financeModel = productItem;
                    addvc.chargeItem = chargeItem;
                    [self.navigationController pushViewController:addvc animated:YES];
                }
                
            } failure:NULL];

        } else if(cellItem.idType == SSJChargeIdTypeRepayment) {
            if (billId == 3 || billId == 4) {
                // 如果是转账,则是还款,跳转到还款页面
                SSJCreditCardRepaymentViewController *repaymentVc = [[SSJCreditCardRepaymentViewController alloc]init];
                repaymentVc.chargeItem = cellItem;
                [self.navigationController pushViewController:repaymentVc animated:YES];
            } else {
                SSJInstalmentDetailViewController *instalmentDetailVc = [[SSJInstalmentDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                instalmentDetailVc.chargeItem = cellItem;
                [self.navigationController pushViewController:instalmentDetailVc animated:YES];
            }
        } else if (cellItem.billId.length < 4) {
            if (billId == 1 || billId == 2) {
                SSJBalenceChangeDetailViewController *balanceChangeVc = [[SSJBalenceChangeDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                balanceChangeVc.chargeItem = (SSJBillingChargeCellItem *)item;
                balanceChangeVc.fundItem = self.item;
                [self.navigationController pushViewController:balanceChangeVc animated:YES];
            } else if (billId == 3 || billId == 4) {
                SSJFundingTransferChargeDetailViewController *transferVc = [[SSJFundingTransferChargeDetailViewController alloc] init];
                transferVc.chargeItem = (SSJBillingChargeCellItem*)item;
                [self.navigationController pushViewController:transferVc animated:YES];
            } else if (billId == 13 || billId == 14) {
                SSJDeleteBooksDetailViewController *deleteBooksVc = [[SSJDeleteBooksDetailViewController alloc] init];
                deleteBooksVc.booksId = ((SSJBillingChargeCellItem*)item).booksId;
                deleteBooksVc.fundId = ((SSJBillingChargeCellItem*)item).fundId;
                deleteBooksVc.booksName = ((SSJBillingChargeCellItem*)item).chargeMemo;
                [self.navigationController pushViewController:deleteBooksVc animated:YES];
            } else {
                SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                calenderDetailVC.item = (SSJBillingChargeCellItem *)item;
                [self.navigationController pushViewController:calenderDetailVC animated:YES];
            }
        } else {
            SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
            calenderDetailVC.item = (SSJBillingChargeCellItem *)item;
            [self.navigationController pushViewController:calenderDetailVC animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 75;
}

#pragma mark - Getter
-(SSJFundingDetailNoDataView *)noDataHeader{
    if (!_noDataHeader) {
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            _noDataHeader = [[SSJFundingDetailNoDataView alloc]initWithFrame:CGRectMake(0, 173 , self.view.width, self.view.height - 173 - SSJ_NAVIBAR_BOTTOM - 50)];
        }else{
            _noDataHeader = [[SSJFundingDetailNoDataView alloc]initWithFrame:CGRectMake(0, 173 , self.view.width, self.view.height - 173 - SSJ_NAVIBAR_BOTTOM)];
        }
        _noDataHeader.hidden = YES;
    }
    return _noDataHeader;
}

-(SSJFundingDetailHeader *)header{
    if (!_header) {
        _header = [[SSJFundingDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 173)];
        [_header ssj_setBorderColor:[UIColor whiteColor]];
        [_header ssj_setBorderStyle:SSJBorderStyleTop];
        [_header ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
        _header.item = self.item;
    }
    return _header;
}

-(SSJCreditCardDetailHeader *)creditCardHeader{
    if (!_creditCardHeader) {
        _creditCardHeader = [[SSJCreditCardDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 173)];
        [_creditCardHeader ssj_setBorderColor:[UIColor whiteColor]];
        [_creditCardHeader ssj_setBorderStyle:SSJBorderStyleTop];
        [_creditCardHeader ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
        _creditCardHeader.item = self.item;
    }
    return _creditCardHeader;
}

-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    }
    return _rightButton;
}

- (UIButton *)repaymentButton{
    if (!_repaymentButton) {
        _repaymentButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 50)];
        [_repaymentButton setTitle:@"还款" forState:UIControlStateNormal];
        if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
            [_repaymentButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        } else {
            [_repaymentButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
        }
        _repaymentButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_repaymentButton ssj_setBorderWidth:1];
        [_repaymentButton ssj_setBorderStyle:SSJBorderStyleTop];
        
        [_repaymentButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_repaymentButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_repaymentButton addTarget:self action:@selector(repaymentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repaymentButton;
}

- (UIButton *)recordButton{
    if (!_recordButton) {
        _recordButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.height - 50, self.view.width, 50)];
        [_recordButton setTitle:@"记一笔" forState:UIControlStateNormal];
        if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
            [_recordButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        } else {
            [_recordButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
        }
        _recordButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_recordButton ssj_setBorderWidth:1];
        
        [_recordButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_recordButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (SSJLoanChangeChargeSelectionControl *)repaymentPopView {
    if (!_repaymentPopView) {
        __weak typeof(self) wself = self;
        _repaymentPopView = [[SSJLoanChangeChargeSelectionControl alloc] initWithTitles:@[@[@"还款",@"分期还款\n(仅支持账单分期)"],@[@"取消"]]];
        NSString *originalStr = @"分期还款\n(仅支持账单分期)";
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:[originalStr rangeOfString:@"(仅支持账单分期)"]];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[originalStr rangeOfString:@"分期还款"]];

        [attributedStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:[originalStr rangeOfString:@"(仅支持账单分期)"]];
        [_repaymentPopView setAttributtedText:attributedStr forIndex:1];
        _repaymentPopView.selectionHandle = ^(NSString * title){
            if ([title isEqualToString:@"还款"]) {
                [SSJAnaliyticsManager event:@"credit_quick_repayment"];
                [wself enterRepaymentVc];
            } else {
                [wself enterInstalmentVc];
            }
        };
    }
    return _repaymentPopView;
}

#pragma mark - Event
-(void)rightButtonClicked:(id)sender{
    if (self.item.cardItem) {
        SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
        creditCardVc.financingItem = self.item;
        [self.navigationController pushViewController:creditCardVc animated:YES];
    }else{
        SSJFinancingHomeitem *financingItem = self.item;
        SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc]init];
        newFundingVC.item = financingItem;
        [self.navigationController pushViewController:newFundingVC animated:YES];
        [SSJAnaliyticsManager event:@"fund_edit"];
    }
}

-(void)repaymentButtonClicked:(id)sender{
    [self.repaymentPopView show];
}

- (void)recordButtonClicked:(id)sender {
    SSJRecordMakingViewController *recordVc = [[SSJRecordMakingViewController alloc] init];
    recordVc.selectFundId = self.item.fundingID;
    [self.navigationController pushViewController:recordVc animated:YES];
}

#pragma mark - Private
-(void)reloadDataAfterSync{
    __weak typeof(self) weakSelf = self;
    [self reloadCurrentFundData];
//    [self getTotalIcomeAndExpence];
}

- (void)reloadCurrentFundData {
    @weakify(self);
    [self.view ssj_showLoadingIndicator];
    if (self.item.cardItem && self.item.cardItem.settleAtRepaymentDay) {
        @strongify(self);
        [SSJFundingDetailHelper queryDataWithCreditCardId:self.item.fundingID success:^(NSMutableArray *data,SSJFinancingHomeitem *cardItem) {
            self.listItems = [NSMutableArray arrayWithArray:data];
            [self.tableView reloadData];
            [self.view ssj_hideLoadingIndicator];
            if (data.count == 0) {
                self.noDataHeader.hidden = NO;
            }else{
                self.noDataHeader.hidden = YES;
            }
            self.item = cardItem;
            self.creditCardHeader.item = cardItem;
            self.title = cardItem.fundingName;
            [self.view ssj_hideLoadingIndicator];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
            [self.view ssj_hideLoadingIndicator];
        }];
    }else{
        @weakify (self);
        if (self.item.cardItem) {
            [SSJFundingDetailHelper queryDataWithFundTypeID:self.item.fundingID success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                @strongify (self);
//                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
//                [weakSelf.tableView reloadData];
                [self array:self.listItems isEqualToAnotherArray:data];
                [self.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    self.noDataHeader.hidden = NO;
                }else{
                    self.noDataHeader.hidden = YES;
                }
                self.creditCardHeader.item = fundingItem;
                self.item = fundingItem;
                self.title = fundingItem.fundingName;
                [self.view ssj_hideLoadingIndicator];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
                [self.view ssj_hideLoadingIndicator];
            }];
        }else{
            [SSJFundingDetailHelper queryDataWithFundTypeID:self.item.fundingID success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                @strongify (self);
                [self array:self.listItems isEqualToAnotherArray:data];
                [self.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    self.noDataHeader.hidden = NO;
                }else{
                    self.noDataHeader.hidden = YES;
                }
                self.item = fundingItem;
                self.header.item = fundingItem;
                self.title = fundingItem.fundingName;
                [self.view ssj_hideLoadingIndicator];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
                [self.view ssj_hideLoadingIndicator];
            }];
        }
    }
}

- (void)enterInstalmentVc {
    if (self.item.cardItem.cardBillingDay == 0 && self.item.cardItem.cardRepaymentDay == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先去设置账单日和还款日哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.financingItem = self.item;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    if (!self.item.cardItem.settleAtRepaymentDay) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"使用分期付款需信用卡设置为以账单日结算哦!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.financingItem = self.item;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    SSJInstalmentEditeViewController *instalmentVc = [[SSJInstalmentEditeViewController alloc]init];
    SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    model.cardId = self.item.fundingID;
    model.cardName = self.item.fundingName;
    model.cardBillingDay = self.item.cardItem.cardBillingDay;
    model.cardRepaymentDay = self.item.cardItem.cardRepaymentDay;
    [SSJAnaliyticsManager event:@"credit_stages_repayment"];
    instalmentVc.repaymentModel = model;
    [self.navigationController pushViewController:instalmentVc animated:YES];
}

- (void)enterRepaymentVc {
    if (self.item.cardItem.cardBillingDay == 0 && self.item.cardItem.cardRepaymentDay == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先去设置账单日和还款日哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.financingItem = self.item;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    if (!self.item.cardItem.settleAtRepaymentDay) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"使用分期付款需信用卡设置为以账单日结算哦!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.financingItem = self.item;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    SSJCreditCardRepaymentViewController *repaymentVC = [[SSJCreditCardRepaymentViewController alloc]init];
    SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    model.cardId = self.item.fundingID;
    model.cardName = self.item.fundingName;
    model.cardBillingDay = self.item.cardItem.cardBillingDay;
    model.cardRepaymentDay = self.item.cardItem.cardRepaymentDay;
    repaymentVC.repaymentModel = model;
    [self.navigationController pushViewController:repaymentVC animated:YES];
}

- (void)updateAppearanceAfterThemeChanged {
    [self.creditCardHeader updateAfterThemeChange];
    [self.header updateAfterThemeChange];
    if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
        [_repaymentButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
    } else {
        [_repaymentButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
    }
    
    [_repaymentButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_repaymentButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];

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
        for (id tempItem in anotherArr) {
            for (id oldItem in array) {
                NSString *tempDate;
                BOOL tempExpand;
                if ([tempItem isKindOfClass:[SSJFundingDetailListItem class]]) {
                    tempDate = ((SSJFundingDetailListItem *)tempItem).date;
                    tempExpand = ((SSJFundingDetailListItem *)tempItem).isExpand;
                } else if ([tempItem isKindOfClass:[SSJCreditCardListDetailItem class]]) {
                    tempDate = ((SSJCreditCardListDetailItem *)tempItem).month;
                    tempExpand = ((SSJCreditCardListDetailItem *)tempItem).isExpand;
                }
                
                NSString *oldDate;
                BOOL oldExpand = NO;
                if ([oldItem isKindOfClass:[SSJFundingDetailListItem class]]) {
                    oldDate = ((SSJFundingDetailListItem *)oldItem).date;
                    oldExpand = ((SSJFundingDetailListItem *)oldItem).isExpand;
                } else if ([oldItem isKindOfClass:[SSJCreditCardListDetailItem class]]) {
                    oldDate = ((SSJCreditCardListDetailItem *)oldItem).month;
                    oldExpand = ((SSJCreditCardListDetailItem *)oldItem).isExpand;
                }
                if ([tempDate isEqualToString:oldDate]) {//通过时间判断是哪个
                    tempExpand = oldExpand;
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
