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
#import "SSJFundingDetailCell.h"
#import "SSJFundingDetailListHeaderView.h"
#import "SSJReportFormsUtil.h"
#import "SSJModifyFundingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJFundingDetailListItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJFundingDetailListFirstLineCell.h"
#import "SSJFundingDailySumCell.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJFundingTransferEditeViewController.h"
#import "SSJFundingDetailNoDataView.h"
#import "SSJNewCreditCardViewController.h"
#import "SSJCreditCardStore.h"
#import "SSJCreditCardDetailHeader.h"
#import "SSJCreditCardListDetailItem.h"
#import "SSJCreditCardListCell.h"
#import "SSJInterestDetailViewController.h"

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
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        self.tableView.tableHeaderView = self.creditCardHeader;
    }else{
        self.tableView.tableHeaderView = self.header;
    }
    [self.view addSubview:self.noDataHeader];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        self.cardItem = (SSJCreditCardItem *)self.item;
        self.cardItem = [SSJCreditCardStore queryCreditCardDetailWithCardId:self.cardItem.cardId];
        self.creditCardHeader.item = self.cardItem;
    }else{
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
        _header.backgroundColor = [UIColor ssj_colorWithHex:financingItem.fundingColor];
    }
    if ([self.item isKindOfClass:[SSJCreditCardItem class]] && self.cardItem.settleAtRepaymentDay) {
        [SSJFundingDetailHelper queryDataWithCreditCardItem:self.cardItem success:^(NSMutableArray *data) {
            weakSelf.listItems = [NSMutableArray arrayWithArray:data];
            [weakSelf.tableView reloadData];
            [weakSelf.view ssj_hideLoadingIndicator];
            if (data.count == 0) {
                weakSelf.noDataHeader.hidden = NO;
            }else{
                weakSelf.noDataHeader.hidden = YES;
            }
        } failure:^(NSError *error) {
            [weakSelf.view ssj_hideLoadingIndicator];
        }];
    }else{
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:cardItem.cardId success:^(NSMutableArray *data) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }else{
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:financingItem.fundingID success:^(NSMutableArray *data) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }

    }
    [self getTotalIcomeAndExpence];
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
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJFundingDetailListHeaderView *headerView = [[SSJFundingDetailListHeaderView alloc]init];
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
            return 90;
        }else{
            return 30;
        }
    }
    SSJBaseItem *item = [self.listItems objectAtIndex:indexPath.section];
    if ([item isKindOfClass:[SSJCreditCardListDetailItem class]]) {
        return 65;
    }
    return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        SSJBaseItem *item = [((SSJFundingDetailListItem *)[self.listItems objectAtIndex:indexPath.section]).chargeArray objectAtIndex:indexPath.row - 1];
        if ([item isKindOfClass:[SSJBillingChargeCellItem class]]) {
            if ([((SSJBillingChargeCellItem*)item).billId integerValue] >= 1000 || ((SSJBillingChargeCellItem*)item).billId.length > 4) {
                SSJCalenderDetailViewController *calenderDetailVC = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                calenderDetailVC.item = (SSJBillingChargeCellItem *)item;
                [self.navigationController pushViewController:calenderDetailVC animated:YES];
            }
            if (([((SSJBillingChargeCellItem*)item).billId integerValue] == 3 || [((SSJBillingChargeCellItem*)item).billId integerValue] == 4) && ![((SSJBillingChargeCellItem*)item).transferSource isEqualToString:((SSJBillingChargeCellItem*)item).typeName]) {
                SSJFundingTransferEditeViewController *transferVc = [[SSJFundingTransferEditeViewController alloc] init];
                transferVc.chargeItem = (SSJBillingChargeCellItem*)item;
                [self.navigationController pushViewController:transferVc animated:YES];
            }
            if ([((SSJBillingChargeCellItem*)item).billId integerValue] == 6) {
                SSJInterestDetailViewController *interestVc = [[SSJInterestDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                interestVc.loanId = ((SSJBillingChargeCellItem*)item).loanId;
                [self.navigationController pushViewController:interestVc animated:YES];
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
            _noDataHeader = [[SSJFundingDetailNoDataView alloc]initWithFrame:CGRectMake(0, 297                           , self.view.width, self.view.height - 297)];
        }else{
            _noDataHeader = [[SSJFundingDetailNoDataView alloc]initWithFrame:CGRectMake(0, 171                           , self.view.width, self.view.height - 171)];
        }
    }
    return _noDataHeader;
}

-(SSJFundingDetailHeader *)header{
    if (!_header) {
        _header = [[SSJFundingDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 107)];
        [_header ssj_setBorderColor:[UIColor whiteColor]];
        [_header ssj_setBorderStyle:SSJBorderStyleTop];
        [_header ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
        if ([self.item isKindOfClass:[SSJFinancingHomeitem class]]) {
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
            _header.backgroundColor = [UIColor ssj_colorWithHex:financingItem.fundingColor];
        }
    }
    return _header;
}

-(SSJCreditCardDetailHeader *)creditCardHeader{
    if (!_creditCardHeader) {
        _creditCardHeader = [[SSJCreditCardDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 233)];
        _creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:self.cardItem.cardColor];
        [_creditCardHeader ssj_setBorderColor:[UIColor whiteColor]];
        [_creditCardHeader ssj_setBorderStyle:SSJBorderStyleTop];
        [_creditCardHeader ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
    }
    return _creditCardHeader;
}

-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
        _rightButton.tintColor = [UIColor whiteColor];
    }
    return _rightButton;
}

#pragma mark - Private
-(void)getTotalIcomeAndExpence{
    __weak typeof(self) weakSelf = self;
    __block NSString *titleStr;
    if ([self.item isKindOfClass:[SSJFinancingHomeitem class]]) {
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
            NSString *userid = SSJUSERID();
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)weakSelf.item;
            _totalIncome = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = 0 AND A.IFUNSID = '%@' AND A.OPERATORTYPE != 2 and A.cuserid = '%@' and A.CBILLDATE <= '%@'",financingItem.fundingID,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]];
            _totalExpence = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = 1 AND A.IFUNSID = '%@' AND A.OPERATORTYPE != 2 and A.cuserid = '%@' and A.CBILLDATE <= '%@'",financingItem.fundingID,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]];
            financingItem.fundingColor = [db stringForQuery:@"SELECT CCOLOR FROM BK_FUND_INFO WHERE CFUNDID = ?",financingItem.fundingID];
            titleStr = [db stringForQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",financingItem.fundingID];
            dispatch_async(dispatch_get_main_queue(), ^(){
//                if ([weakSelf.item.fundingParent isEqualToString:@"3"]) {
//                    weakSelf.creditCardHeader.totalIncome = _totalIncome;
//                    weakSelf.creditCardHeader.totalExpence = _totalExpence;
//                    weakSelf.title = titleStr;
//                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:weakSelf.item.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
//                    weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
//                }else{
                weakSelf.header.totalIncomeLabel.text = [NSString stringWithFormat:@"%.2f",_totalIncome];
                [weakSelf.header.totalIncomeLabel sizeToFit];
                weakSelf.header.totalExpenceLabel.text = [NSString stringWithFormat:@"%.2f",_totalExpence];
                [weakSelf.header.totalExpenceLabel sizeToFit];
                weakSelf.title = titleStr;
                [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:financingItem.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                weakSelf.header.backgroundColor = [UIColor ssj_colorWithHex:financingItem.fundingColor];
            });
        }];
    }else{
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
            NSString *userid = SSJUSERID();
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)weakSelf.item;
            _totalIncome = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = 0 AND A.IFUNSID = '%@' AND A.OPERATORTYPE != 2 and A.cuserid = '%@' and A.CBILLDATE <= '%@'",cardItem.cardId,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]];
            _totalExpence = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(IMONEY) FROM BK_USER_CHARGE A , BK_BILL_TYPE B WHERE A.IBILLID = B.ID AND B.ITYPE = 1 AND A.IFUNSID = '%@' AND A.OPERATORTYPE != 2 and A.cuserid = '%@' and A.CBILLDATE <= '%@'",cardItem.cardId,userid,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]];
            cardItem.cardColor = [db stringForQuery:@"SELECT CCOLOR FROM BK_FUND_INFO WHERE CFUNDID = ?",cardItem.cardId];
            titleStr = [db stringForQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",cardItem.cardId];
            dispatch_async(dispatch_get_main_queue(), ^(){
                //                if ([weakSelf.item.fundingParent isEqualToString:@"3"]) {
                //                    weakSelf.creditCardHeader.totalIncome = _totalIncome;
                //                    weakSelf.creditCardHeader.totalExpence = _totalExpence;
                //                    weakSelf.title = titleStr;
                //                    [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:weakSelf.item.fundingColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                //                    weakSelf.creditCardHeader.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
                //                }else
                weakSelf.creditCardHeader.totalIncome = _totalIncome;
                weakSelf.creditCardHeader.totalExpence = _totalExpence;
                weakSelf.creditCardHeader.cardBalance = _totalIncome - _totalExpence;
                weakSelf.title = titleStr;
                [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:cardItem.cardColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
                weakSelf.header.backgroundColor = [UIColor ssj_colorWithHex:cardItem.cardColor];
            });
        }];
    }

}

-(void)rightButtonClicked:(id)sender{
    if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
        SSJNewCreditCardViewController *creditCardVc = [[SSJNewCreditCardViewController alloc]init];
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
        creditCardVc.cardId = cardItem.cardId;
        [self.navigationController pushViewController:creditCardVc animated:YES];
    }else{
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
        SSJModifyFundingViewController *newFundingVC = [[SSJModifyFundingViewController alloc]init];
        financingItem.fundingAmount = _totalIncome - _totalExpence;
        newFundingVC.item = financingItem;
        [self.navigationController pushViewController:newFundingVC animated:YES];
        [MobClick event:@"fund_edit"];
    }
}

-(void)reloadDataAfterSync{
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    if ([self.item isKindOfClass:[SSJCreditCardItem class]] && self.cardItem.settleAtRepaymentDay) {
        [SSJFundingDetailHelper queryDataWithCreditCardItem:self.cardItem success:^(NSMutableArray *data) {
            weakSelf.listItems = [NSMutableArray arrayWithArray:data];
            [weakSelf.tableView reloadData];
            [weakSelf.view ssj_hideLoadingIndicator];
            if (data.count == 0) {
                weakSelf.noDataHeader.hidden = NO;
            }else{
                weakSelf.noDataHeader.hidden = YES;
            }
        } failure:^(NSError *error) {
            [weakSelf.view ssj_hideLoadingIndicator];
        }];
    }else{
        if ([self.item isKindOfClass:[SSJCreditCardItem class]]) {
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:cardItem.cardId success:^(NSMutableArray *data) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }else{
            SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.item;
            [SSJFundingDetailHelper queryDataWithFundTypeID:financingItem.fundingID success:^(NSMutableArray *data) {
                weakSelf.listItems = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
                [weakSelf.view ssj_hideLoadingIndicator];
                if (data.count == 0) {
                    weakSelf.noDataHeader.hidden = NO;
                }else{
                    weakSelf.noDataHeader.hidden = YES;
                }
            } failure:^(NSError *error) {
                [weakSelf.view ssj_hideLoadingIndicator];
            }];
        }
    }
    [self getTotalIcomeAndExpence];
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
