            //
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCreditCardListDetailItem.h"
#import "SSJFundingDetailListItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentModel.h"

#import "SSJFundingDetailHelper.h"
#import "SSJFundingDetailListHeaderView.h"
#import "SSJReportFormsUtil.h"
#import "SSJCreditCardRepaymentViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJCreditCardStore.h"

#import "SSJFundingDetailHeader.h"
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
#import "SSJFundingDetailsViewController.h"
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

@interface SSJFundingDetailsViewController ()
@property (nonatomic,strong) SSJFundingDetailHeader *header;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property(nonatomic, strong)  NSMutableArray *listItems;

@property(nonatomic, strong) SSJFundingDetailNoDataView *noDataHeader;

@property(nonatomic, strong) SSJCreditCardItem *cardItem;

@property(nonatomic, strong) SSJCreditCardDetailHeader *creditCardHeader;

@property(nonatomic, strong) SSJLoanChangeChargeSelectionControl *repaymentPopView;

@property(nonatomic, strong) UIButton *repaymentButton;
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
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.statisticsTitle = @"资金账户详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.rightButton;
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
        self.title = cardItem.cardName;
    }else{
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
        self.title = financingItem.fundingName;
    }
    self.tableView.sectionHeaderHeight = 40;
    [self.tableView registerClass:[SSJFundingDetailCell class] forCellReuseIdentifier:kFundingDetailCellID];
    [self.tableView registerClass:[SSJFundingDailySumCell class] forCellReuseIdentifier:kFundingListDailySumCellID];
    [self.tableView registerClass:[SSJCreditCardListCell class] forCellReuseIdentifier:kCreditCardListFirstLineCellID];
    [self.tableView registerClass:[SSJFundingDetailListFirstLineCell class] forCellReuseIdentifier:kFundingListFirstLineCellID];
    [self.tableView addSubview:self.noDataHeader];
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        [self.view addSubview:self.repaymentButton];
        self.tableView.tableHeaderView = self.creditCardHeader;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    }else{
        self.tableView.tableHeaderView = self.header;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        self.cardItem = (SSJCreditCardItem *)self.item;
        self.cardItem = [SSJCreditCardStore queryCreditCardDetailWithCardId:self.cardItem.cardId];
        self.creditCardHeader.item = self.cardItem;
    }
    if ([self.item isKindOfClass:[SSJCreditCardItem class]] && self.cardItem.settleAtRepaymentDay) {
        [SSJFundingDetailHelper queryDataWithCreditCardItem:self.cardItem success:^(NSMutableArray *data,SSJCreditCardItem *cardItem) {
            weakSelf.listItems = [NSMutableArray arrayWithArray:data];
            [weakSelf.tableView reloadData];
            [weakSelf.view ssj_hideLoadingIndicator];
            if (data.count == 0) {
                weakSelf.noDataHeader.hidden = NO;
            }else{
                weakSelf.noDataHeader.hidden = YES;
            }
            _totalIncome = cardItem.cardIncome;
            _totalExpence = cardItem.cardExpence;
            weakSelf.creditCardHeader.totalIncome = cardItem.cardIncome;
            weakSelf.creditCardHeader.totalExpence = cardItem.cardExpence;
            weakSelf.creditCardHeader.cardBalance = fabs(cardItem.cardIncome - cardItem.cardExpence);
            weakSelf.title = cardItem.cardName;
        } failure:^(NSError *error) {
            [weakSelf.view ssj_hideLoadingIndicator];
        }];
    }else{
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:cardItem.cardId success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
                _totalIncome = fundingItem.fundingIncome;
                _totalExpence = fundingItem.fundingExpence;
                weakSelf.creditCardHeader.totalIncome = fundingItem.fundingIncome;
                weakSelf.creditCardHeader.totalExpence = fundingItem.fundingExpence;
                weakSelf.creditCardHeader.cardBalance = fundingItem.fundingIncome - fundingItem.fundingExpence;
                weakSelf.title = cardItem.cardName;


            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }else{
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:financingItem.fundingID success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
                _totalIncome = fundingItem.fundingIncome;
                _totalExpence = fundingItem.fundingExpence;
                weakSelf.header.income = fundingItem.fundingIncome;
                weakSelf.header.expence = fundingItem.fundingExpence;
                SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
                item.startColor = fundingItem.startColor;
                item.endColor = fundingItem.endColor;
                weakSelf.header.item = item;
                weakSelf.title = fundingItem.fundingName;
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }

    }
//    [self getTotalIcomeAndExpence];
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
    SSJBaseItem *item;
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
            SSJBaseItem *nextItem = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray ssj_safeObjectAtIndex:indexPath.row];
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
        SSJBaseItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
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
    SSJBaseItem *item = [self.listItems ssj_safeObjectAtIndex:indexPath.section];
    if ([item isKindOfClass:[SSJCreditCardListDetailItem class]]) {
        return 65;
    }
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        SSJBaseItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
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
                        balanceChangeVc.fundItem = self.item;
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

#pragma mark - Getter
-(SSJFundingDetailNoDataView *)noDataHeader{
    if (!_noDataHeader) {
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            _noDataHeader = [[SSJFundingDetailNoDataView alloc]initWithFrame:CGRectMake(0, 213 , self.view.width, self.view.height - 213 - SSJ_NAVIBAR_BOTTOM - 50)];
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
        if ([_item isKindOfClass:[SSJFinancingHomeitem class]]) {
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)_item;
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            colorItem.startColor = financingItem.startColor;
            colorItem.endColor = financingItem.endColor;
            _header.item = colorItem;
        }
    }
    return _header;
}

-(SSJCreditCardDetailHeader *)creditCardHeader{
    if (!_creditCardHeader) {
        _creditCardHeader = [[SSJCreditCardDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 213)];
        [_creditCardHeader ssj_setBorderColor:[UIColor whiteColor]];
        [_creditCardHeader ssj_setBorderStyle:SSJBorderStyleTop];
        [_creditCardHeader ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
        if ([_item isKindOfClass:[SSJCreditCardItem class]]) {
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)_item;
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            colorItem.startColor = cardItem.startColor;
            colorItem.endColor = cardItem.endColor;
            _creditCardHeader.colorItem = colorItem;
        }
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
        _repaymentButton.titleLabel.font = [UIFont systemFontOfSize:19];
        [_repaymentButton ssj_setBorderWidth:1];
        [_repaymentButton ssj_setBorderStyle:SSJBorderStyleTop];
        
        [_repaymentButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_repaymentButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_repaymentButton addTarget:self action:@selector(repaymentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repaymentButton;
}

- (SSJLoanChangeChargeSelectionControl *)repaymentPopView {
    if (!_repaymentPopView) {
        __weak typeof(self) wself = self;
        _repaymentPopView = [[SSJLoanChangeChargeSelectionControl alloc] initWithTitles:@[@[@"还款",@"分期还款\n(仅支持账单分期)"],@[@"取消"]]];
        NSString *originalStr = @"分期还款\n(仅支持账单分期)";
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:[originalStr rangeOfString:@"(仅支持账单分期)"]];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[originalStr rangeOfString:@"分期还款"]];

        [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:[originalStr rangeOfString:@"(仅支持账单分期)"]];
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
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
        creditCardVc.cardId = cardItem.cardId;
        [self.navigationController pushViewController:creditCardVc animated:YES];
    }else{
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
        SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc]init];
        financingItem.fundingAmount = _totalIncome - _totalExpence;
        newFundingVC.item = financingItem;
        [self.navigationController pushViewController:newFundingVC animated:YES];
        [SSJAnaliyticsManager event:@"fund_edit"];
    }
}

-(void)repaymentButtonClicked:(id)sender{
    [self.repaymentPopView show];
}

#pragma mark - Private
-(void)reloadDataAfterSync{
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    if ([self.item isKindOfClass:[SSJCreditCardItem class]] && self.cardItem.settleAtRepaymentDay) {
        [SSJFundingDetailHelper queryDataWithCreditCardItem:self.cardItem success:^(NSMutableArray *data,SSJCreditCardItem *cardItem) {
            weakSelf.listItems = [NSMutableArray arrayWithArray:data];
            [weakSelf.tableView reloadData];
            [weakSelf.view ssj_hideLoadingIndicator];
            if (data.count == 0) {
                weakSelf.noDataHeader.hidden = NO;
            }else{
                weakSelf.noDataHeader.hidden = YES;
            }
            _totalIncome = cardItem.cardIncome;
            _totalExpence = cardItem.cardExpence;
            weakSelf.creditCardHeader.totalIncome = cardItem.cardIncome;
            weakSelf.creditCardHeader.totalExpence = cardItem.cardExpence;
            weakSelf.creditCardHeader.cardBalance = fabs(cardItem.cardIncome - cardItem.cardExpence);
            weakSelf.title = cardItem.cardName;
            if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID] || !SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
                [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:cardItem.cardColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:cardItem.cardColor];
            } else {
                [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
            }
        } failure:^(NSError *error) {
            [weakSelf.view ssj_hideLoadingIndicator];
        }];
    }else{
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:cardItem.cardId success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
                _totalIncome = cardItem.cardIncome;
                _totalExpence = cardItem.cardExpence;
                weakSelf.creditCardHeader.totalIncome = cardItem.cardIncome;
                weakSelf.creditCardHeader.totalExpence = cardItem.cardExpence;
                weakSelf.creditCardHeader.cardBalance = fabs(cardItem.cardIncome - cardItem.cardExpence);
                weakSelf.title = cardItem.cardName;
                if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID] || !SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:cardItem.cardColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                    weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:cardItem.cardColor];
                } else {
                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                    weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }else{
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:financingItem.fundingID success:^(NSMutableArray *data,SSJFinancingHomeitem *fundingItem) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
                _totalIncome = fundingItem.fundingIncome;
                _totalExpence = fundingItem.fundingExpence;
                weakSelf.header.income = fundingItem.fundingIncome;
                weakSelf.header.expence = fundingItem.fundingExpence;
                SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
                item.startColor = fundingItem.startColor;
                item.endColor = fundingItem.endColor;
                weakSelf.header.item = item;
                weakSelf.title = fundingItem.fundingName;
                if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID] || !SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:fundingItem.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                    weakSelf.header.backgroundColor = [UIColor ssj_colorWithHex:fundingItem.fundingColor];
                } else {
                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                    weakSelf.header.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }
    }
//    [self getTotalIcomeAndExpence];
}

- (void)enterInstalmentVc {
    if (self.cardItem.cardBillingDay == 0 && self.cardItem.cardRepaymentDay == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先去设置账单日和还款日哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.cardId = self.cardItem.cardId;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    if (!self.cardItem.settleAtRepaymentDay) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"使用分期付款需信用卡设置为以账单日结算哦!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.cardId = self.cardItem.cardId;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    SSJInstalmentEditeViewController *instalmentVc = [[SSJInstalmentEditeViewController alloc]init];
    SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    model.cardId = self.cardItem.cardId;
    model.cardName = self.cardItem.cardName;
    model.cardBillingDay = self.cardItem.cardBillingDay;
    model.cardRepaymentDay = self.cardItem.cardRepaymentDay;
    //mzl
//    SSJFundingDetailListItem *item = (SSJFundingDetailListItem *)[self.listItems ssj_safeObjectAtIndex:0];
//    if (item) {
//        model.totalArrears = item.income - item.expenture > 0 ? 0 :item.expenture - item.income;
//    }
    [SSJAnaliyticsManager event:@"credit_stages_repayment"];
    instalmentVc.repaymentModel = model;
    [self.navigationController pushViewController:instalmentVc animated:YES];
}

- (void)enterRepaymentVc {
    if (self.cardItem.cardBillingDay == 0 && self.cardItem.cardRepaymentDay == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先去设置账单日和还款日哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.cardId = self.cardItem.cardId;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    if (!self.cardItem.settleAtRepaymentDay) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"使用分期付款需信用卡设置为以账单日结算哦!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
            creditCardVc.cardId = self.cardItem.cardId;
            [weakSelf.navigationController pushViewController:creditCardVc animated:YES];
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    }
    SSJCreditCardRepaymentViewController *repaymentVC = [[SSJCreditCardRepaymentViewController alloc]init];
    SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    SSJCreditCardItem *item = (SSJCreditCardItem *)self.item;
    model.cardId = item.cardId;
    model.cardName = item.cardName;
    model.cardBillingDay = item.cardBillingDay;
    model.cardRepaymentDay = item.cardRepaymentDay;
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
