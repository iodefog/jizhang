//
//  SSJFixedFinanceProductDetailViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductDetailViewController.h"
#import "SSJFixedFinanctAddViewController.h"
#import "SSJFixedFinanceRedemViewController.h"
#import "SSJFixedFinancesSettlementViewController.h"
#import "SSJAddOrEditFixedFinanceProductViewController.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductDetailItem.h"
#import "SSJFixedFinanceProductCompoundItem.h"
#import "SSJLoanDetailCellItem.h"
#import "SSJFixedFinanceDetailCellItem.h"

#import "SSJFixedFinanceProductDetailCell.h"
#import "SSJFixedFinanceDetailTableViewCell.h"

#import "SSJLoanDetailCell.h"
#import "SSJFinancingDetailHeadeView.h"
#import "SSJLoanDetailChargeChangeHeaderView.h"

#import "SSJLoanChangeChargeSelectionControl.h"

#import "SSJFixedFinanceProductStore.h"
#import "SSJFixedFinanceProductHelper.h"
#import "SSJDataSynchronizer.h"

static NSString *kSSJFinanceDetailCellID = @"kSSJFinanceDetailCellID";

@interface SSJFixedFinanceProductDetailViewController ()<UITableViewDataSource, UITableViewDelegate,SSJFinancingDetailHeadeViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *changeBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIBarButtonItem *editItem;

@property (nonatomic, strong) SSJFinancingDetailHeadeView *headerView;

@property (nonatomic, strong) SSJLoanDetailChargeChangeHeaderView *changeSectionHeaderView;

@property (nonatomic, strong) SSJLoanChangeChargeSelectionControl *changeChargeSelectionView;

@property (nonatomic, strong) NSArray *headerItems;
@property (nonatomic, strong) NSMutableArray <SSJLoanDetailCellItem *>*section1Items;

@property (nonatomic, strong) NSArray <SSJFixedFinanceProductChargeItem *>*section2Items;

@property (nonatomic, strong) SSJFixedFinanceProductItem *financeModel;

@property (nonatomic, strong) NSArray <SSJFixedFinanceProductChargeItem *>*chargeModels;

/**当前金额*/
@property (nonatomic, assign) double currentMoney;

@end

@implementation SSJFixedFinanceProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.closeOutBtn];
    [self updateAppearance];
    self.title = @"固收理财详情";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    //    self.headerView.separatorColor = [SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID] ? [UIColor whiteColor] : SSJ_CELL_SEPARATOR_COLOR;
    //    self.headerView.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
    //    [_changeSectionHeaderView updateAppearance];
    //    [_changeChargeSelectionView updateAppearance];
    
    _closeOutBtn.backgroundColor = _deleteBtn.backgroundColor  = _changeBtn.backgroundColor = SSJ_SECONDARY_FILL_COLOR;
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [_closeOutBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
    } else {
        [_closeOutBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    }
    
    [_changeBtn setTitleColor:SSJ_MAIN_COLOR forState:UIControlStateNormal];
    [_changeBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [_closeOutBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [_deleteBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section1Items.count;
    } else if (section == 1) {
        return self.section2Items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellId = @"cellId";
        SSJLoanDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[SSJLoanDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.cellItem = [self.section1Items ssj_safeObjectAtIndex:indexPath.row];
        return cell;
    } else if (indexPath.section == 1) {
        SSJFixedFinanceDetailTableViewCell *cell = [SSJFixedFinanceDetailTableViewCell cellWithTableView:tableView];
        cell.cellItem = [self.section2Items ssj_safeObjectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (!self.changeSectionHeaderView.expanded) {
            SSJFixedFinanceProductChargeItem *item = [self.section2Items ssj_safeObjectAtIndex:indexPath.row];
            return item.rowHeight;
        }
        return 0;
    }
    return 44;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.changeSectionHeaderView;
    }
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark - SSJSeparatorFormViewDataSource
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJFinancingDetailHeadeView *)view {
    return self.headerItems.count;
}

- (NSUInteger)separatorFormView:(SSJFinancingDetailHeadeView *)view numberOfCellsInRow:(NSUInteger)row {
    return [[self.headerItems ssj_safeObjectAtIndex:row] count];
}

- (SSJFinancingDetailHeadeViewCellItem *)separatorFormView:(SSJFinancingDetailHeadeView *)view itemForCellAtIndex:(NSIndexPath *)index {
    return [self.headerItems ssj_objectAtIndexPath:index];
}

#pragma mark - Private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    MJWeakSelf;
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJFixedFinanceProductStore queryForFixedFinanceProduceWithProductID:self.productID success:^(SSJFixedFinanceProductItem * _Nonnull model) {
            weakSelf.financeModel = model;
            [weakSelf.headerView reloadData];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJFixedFinanceProductStore queryFixedFinanceProductChargeListWithModel:weakSelf.financeModel success:^(NSArray<SSJFixedFinanceProductChargeItem *> * _Nonnull resultList) {
                //流水列表
                self.chargeModels = resultList;
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self reorganiseSection1Items:^{
                [self reorganiseSection2Items];
                [self organiseHeaderItems];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] subscribeError:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        [self.view ssj_hideLoadingIndicator];
        [self updateSubViewHidden];
        self.tableView.tableHeaderView = self.headerView;
        [self.tableView reloadData];
        [self.headerView reloadData];
        
        SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
        item.startColor = self.financeModel.startcolor;
        item.endColor = self.financeModel.endcolor;
        self.headerView.colorItem = item;
        
        self.changeSectionHeaderView.title = [NSString stringWithFormat:@"流水记录：%d条", (int)self.chargeModels.count];
    }];
}


- (void)reorganiseSection1Items:(void(^)())completion {
    [self.section1Items removeAllObjects];
    if (_financeModel.isend) {//结算
        if (!_financeModel.etargetfundid.length) {
            SSJPRINT(@"结算账户不能为空");
            return;
        }
        
        NSString *endAccountName = _financeModel.productName;
        NSString *etargetfundid = _financeModel.etargetfundid;
        NSString *startDateStr = _financeModel.startdate;
        NSString *endDateStr = _financeModel.enddate;
        NSString *memo = _financeModel.memo;
        NSString *fundName = [SSJFixedFinanceProductStore queryfundNameWithFundid:self.financeModel.etargetfundid];
        
            [self.section1Items addObjectsFromArray:
             @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"起息日期" subtitle:startDateStr bottomTitle:nil],
               [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"结算日期" subtitle:endDateStr bottomTitle:nil],
               [SSJLoanDetailCellItem itemWithImage:@"loan_closeOut" title:@"结算转入账户" subtitle:fundName bottomTitle:nil]]];
        
            if (_financeModel.memo.length) {
                [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"备注" subtitle:memo bottomTitle:nil]];
            }
            
            if (completion) {
                completion();
            }
    } else {
        
        NSString *endAccountName = _financeModel.productName;
        NSString *etargetfundid = _financeModel.etargetfundid;
        NSString *startDateStr = _financeModel.startdate;
        NSString *endDateStr = _financeModel.enddate;
        NSString *memo = _financeModel.memo;
        [self.section1Items addObjectsFromArray:
         @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"起息日期" subtitle:startDateStr bottomTitle:nil]]];
        if (_financeModel.remindid.length) {
            [self.section1Items addObject:
             [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"提醒日期" subtitle:endDateStr bottomTitle:nil]];
        }
        if (_financeModel.memo.length) {
            [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"备注" subtitle:memo bottomTitle:nil]];
        }
        
        if (completion) {
            completion();
        }
    }
}

- (void)reorganiseSection2Items {
    if (!self.changeSectionHeaderView.expanded) {
        // 把流水列表按照billdate、writedate降序排序，优先级billdate>writedate
       NSArray *tempArr = [self.chargeModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            SSJFixedFinanceProductChargeItem *model1 = obj1;
            SSJFixedFinanceProductChargeItem *model2 = obj2;
            
            if ([model1.billDate compare:model2.billDate] == NSOrderedAscending) {
                return NSOrderedDescending;
            } else if ([model1.billDate compare:model2.billDate] == NSOrderedDescending) {
                return NSOrderedAscending;
            } else {
                if ([model1.writeDate compare:model2.writeDate] == NSOrderedAscending) {
                    return NSOrderedDescending;
                } else if ([model1.writeDate compare:model2.writeDate] == NSOrderedDescending) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        //对时间做处理
        SSJFixedFinanceProductChargeItem *lastItem;
        for (SSJFixedFinanceProductChargeItem *item in tempArr) {
            if ([lastItem.billDate isSameDay:item.billDate]) {
                item.isHiddenTime = YES;
            } else {
                item.isHiddenTime = NO;
            }
            lastItem = item;
        }
        self.section2Items = tempArr;
    } else {
        self.section2Items = [NSArray array];
    }
}

- (void)organiseHeaderItems {
    
    double surplus = 0;     // 当前余额、到账金额
    double rate = self.financeModel.rate;     // 年化收益率
    double interest = 0;    // 产生利息、利息收入
    double payment = 0;     // 预期利息、投资本金

    for (SSJFixedFinanceProductChargeItem *model in self.chargeModels) {
        switch (model.chargeType) {
            case SSJFixedFinCompoundChargeTypeCreate://新建
                surplus += model.money;
                break;
            case SSJFixedFinCompoundChargeTypeAdd://追加
                surplus += model.money;
                break;
            case SSJFixedFinCompoundChargeTypeRedemption://赎回
                surplus -= model.money;
                break;
            case SSJFixedFinCompoundChargeTypeBalanceIncrease://余额转入
                surplus += model.money;
                break;
            case SSJFixedFinCompoundChargeTypeBalanceDecrease://余额转出
                surplus -= model.money;
                break;
            case SSJFixedFinCompoundChargeTypeBalanceInterestIncrease://利息转入
                surplus += model.money;
                break;
            case SSJFixedFinCompoundChargeTypeBalanceInterestDecrease://利息转出
                surplus -= model.money;
                break;
            case SSJFixedFinCompoundChargeTypeInterest://固收理财派发利息流水
                surplus += model.money;
                break;
                
            case SSJFixedFinCompoundChargeTypeCloseOutInterest://结算利息
                surplus -= model.money;
                break;
            case SSJFixedFinCompoundChargeTypeCloseOut://结清
                break;
                surplus -= model.money;
            default:
                break;
        }
    }

    interest = self.financeModel.isend == 0 ?[SSJFixedFinanceProductStore queryForFixedFinanceProduceInterestiothWithProductID:self.financeModel.productid] : [SSJFixedFinanceProductStore queryForFixedFinanceProduceJieSuanInterestiothWithProductID:self.financeModel.productid];
    NSString *surplusTitle = self.financeModel.isend == 0 ? @"当前余额" : @"到账金额";
    NSString *surplusValue = self.financeModel.isend == 0 ? [NSString stringWithFormat:@"%.2f", surplus] : [NSString stringWithFormat:@"%.2f",[self.financeModel.money doubleValue]];
    self.currentMoney = surplus;//可赎回最大金额
    
   //总利息
    double totleIn = [SSJFixedFinanceProductStore queryForFixedFinanceProduceJieSuanInterestiothWithProductID:self.financeModel.productid];
    
    //所有手续费
   double totleSxf = [SSJFixedFinanceProductStore querySettmentInterestWithProductID:self.financeModel.productid];
    
    // 本金 = financeModel。money + 所有手续费 - 总利息
    double benJinMoney = [self.financeModel.money doubleValue] + totleSxf - totleIn;
    
    payment = self.financeModel.isend == 0 ? [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:self.financeModel.rate rateType:self.financeModel.ratetype time:self.financeModel.time timetype:self.financeModel.timetype money:[self.financeModel.money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:self.financeModel.startdate] objectForKey:@"interest"] doubleValue] : benJinMoney;//预期利息
    
    
    NSString *sumTitle = @"年化收益率";
    NSString *interestTitle = nil;
    NSString *paymentTitle = self.financeModel.isend == 0 ? @"已产生利息" : @"利息收入";
    NSString *lenderTitle = self.financeModel.isend == 0 ?  @"预期利息" : @"投资本金";
    UIColor *topTitleColor = nil;
    UIColor *bottomTitleColor = nil;
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        topTitleColor = [UIColor whiteColor];
        bottomTitleColor = [UIColor whiteColor];
    } else {
        topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha];
        bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
    }
    
    UIFont *topTitleFont = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
    UIFont *bottomTitleFont1 = [UIFont ssj_pingFangRegularFontOfSize:24];
    UIFont *bottomTitleFont2 = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    
    SSJFinancingDetailHeadeViewCellItem *surplusItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:surplusTitle
                                                                                                 bottomTitle:surplusValue
                                                                                               topTitleColor:topTitleColor
                                                                                            bottomTitleColor:bottomTitleColor
                                                                                                topTitleFont:topTitleFont
                                                                                             bottomTitleFont:bottomTitleFont1 contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    SSJFinancingDetailHeadeViewCellItem *sumItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:sumTitle
                                                                                             bottomTitle:[NSString stringWithFormat:@"%.1f%@", rate,@"%"]
                                                                                           topTitleColor:topTitleColor
                                                                                        bottomTitleColor:bottomTitleColor
                                                                                            topTitleFont:topTitleFont
                                                                                         bottomTitleFont:bottomTitleFont2
                                                                                           contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    SSJFinancingDetailHeadeViewCellItem *interestItem = nil;
//    if (interest > 0) {
        interestItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:paymentTitle
                                                                 bottomTitle:[NSString stringWithFormat:@"%.2f", interest]
                                                               topTitleColor:topTitleColor
                                                            bottomTitleColor:bottomTitleColor
                                                                topTitleFont:topTitleFont
                                                             bottomTitleFont:bottomTitleFont2
                                                               contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    SSJFinancingDetailHeadeViewCellItem *lenderItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:lenderTitle
                                                                                                bottomTitle:[NSString stringWithFormat:@"%.2f",payment]
                                                                                              topTitleColor:topTitleColor
                                                                                           bottomTitleColor:bottomTitleColor
                                                                                               topTitleFont:topTitleFont
                                                                                            bottomTitleFont:bottomTitleFont2
                                                                                              contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    _headerItems = @[@[surplusItem], @[sumItem, interestItem, lenderItem]];
}

- (void)updateSubViewHidden {
    if (_financeModel.isend) {
        self.changeBtn.hidden = YES;
        self.closeOutBtn.hidden = YES;
        self.deleteBtn.hidden = NO;
//        self.stampView.hidden = NO;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        self.changeBtn.hidden = NO;
        self.closeOutBtn.hidden = NO;
        self.deleteBtn.hidden = YES;
//        self.stampView.hidden = YES;
        [self.navigationItem setRightBarButtonItem:self.editItem animated:YES];
    }
}


#pragma mark - Event
- (void)editAction {
    SSJAddOrEditFixedFinanceProductViewController *editFinanceVC = [[SSJAddOrEditFixedFinanceProductViewController alloc] init];
    editFinanceVC.model = self.financeModel;
    editFinanceVC.edited = YES;
//    editFinanceVC.chargeModels = self.chargeModels;
    [self.navigationController pushViewController:editFinanceVC animated:YES];
}

- (void)closeOutBtnAction {
    SSJFixedFinancesSettlementViewController *closeOutVC = [[SSJFixedFinancesSettlementViewController alloc] init];
    closeOutVC.productid = self.productID;
    [self.navigationController pushViewController:closeOutVC animated:YES];
}

- (void)changeBtnAction {
    [self.changeChargeSelectionView show];
}

- (void)deleteBtnAction {
    MJWeakSelf;
    [SSJFixedFinanceProductStore deleteFixedFinanceProductWithModel:self.financeModel success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
//    + (void)deleteFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model success:(void (^)(void))success
//failure:(void (^)(NSError *error))failure;
//    __weak typeof(self) wself = self;
//    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"删除该项目后相关的账户流水数据(含转账、利息）将被彻底删除哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
//        [wself deleteLoanModel];
//    }], nil];
//    

}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 54) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJFixedFinanceProductDetailCell class] forCellReuseIdentifier:kSSJFinanceDetailCellID];
        _tableView.sectionFooterHeight = 0;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
//        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width * 0.6, 50);
        _changeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_changeBtn setTitle:@"变更" forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _changeBtn.hidden = YES;
        [_changeBtn ssj_setBorderWidth:1];
        [_changeBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _changeBtn;
}

- (UIButton *)closeOutBtn {
    if (!_closeOutBtn) {
        _closeOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeOutBtn.frame = CGRectMake(self.view.width * 0.6, self.view.height - 54, self.view.width * 0.4, 50);
        _closeOutBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_closeOutBtn setTitle:@"结算" forState:UIControlStateNormal];
        [_closeOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeOutBtn addTarget:self action:@selector(closeOutBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _closeOutBtn.hidden = YES;
        [_closeOutBtn ssj_setBorderWidth:1];
        [_closeOutBtn ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleLeft];
    }
    return _closeOutBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width, 54);
        _deleteBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.hidden = YES;
        [_deleteBtn ssj_setBorderWidth:1];
        [_deleteBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _deleteBtn;
}

- (UIBarButtonItem *)editItem {
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    }
    return _editItem;
}

- (SSJFinancingDetailHeadeView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJFinancingDetailHeadeView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 174)];
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.horizontalSeparatorInset = UIEdgeInsetsMake(0, 42, 0, 42);
        _headerView.verticalSeparatorInset = UIEdgeInsetsMake(22, 0, 22, 0);
        _headerView.dataSource = self;
    }
    return _headerView;
}


- (NSMutableArray<SSJLoanDetailCellItem *> *)section1Items {
    if (!_section1Items) {
        _section1Items = [[NSMutableArray alloc] init];
    }
    return _section1Items;
}

- (SSJLoanChangeChargeSelectionControl *)changeChargeSelectionView {
    if (!_changeChargeSelectionView) {
        __weak typeof(self) wself = self;
        NSArray *titles =  @[@[@"追加本金", @"部分赎回"], @[@"取消"]];
        _changeChargeSelectionView = [[SSJLoanChangeChargeSelectionControl alloc] initWithTitles:titles];
        MJWeakSelf;
        _changeChargeSelectionView.selectionHandle = ^(NSString * title){
            if ([title isEqualToString:[[titles ssj_safeObjectAtIndex:0] ssj_safeObjectAtIndex:0]]) {
                SSJFixedFinanctAddViewController *addVC = [[SSJFixedFinanctAddViewController alloc] init];
                //            addVC.edited = NO;
                addVC.productid = wself.productID;
                
                [wself.navigationController pushViewController:addVC animated:YES];
            } else if ([title isEqualToString:[[titles ssj_safeObjectAtIndex:0] ssj_safeObjectAtIndex:1]]){
                SSJFixedFinanceRedemViewController *redVC = [[SSJFixedFinanceRedemViewController alloc] init];
                redVC.productid = weakSelf.productID;
                redVC.canRedemMoney = weakSelf.currentMoney;
                [wself.navigationController pushViewController:redVC animated:YES];
            }
        };
    }
    return _changeChargeSelectionView;
}


- (SSJLoanDetailChargeChangeHeaderView *)changeSectionHeaderView {
    if (!_changeSectionHeaderView) {
        __weak typeof(self) wself = self;
        _changeSectionHeaderView = [[SSJLoanDetailChargeChangeHeaderView alloc] init];
        _changeSectionHeaderView.expanded = YES;
        _changeSectionHeaderView.tapHandle = ^(SSJLoanDetailChargeChangeHeaderView *view) {
            [wself reorganiseSection2Items];
            [wself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _changeSectionHeaderView;
}

@end
