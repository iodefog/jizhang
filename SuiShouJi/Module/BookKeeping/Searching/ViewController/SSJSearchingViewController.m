//
//  SSJSearchingViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchingViewController.h"
#import "SSJNavigationController.h"
#import "SSJChargeSearchingStore.h"
#import "SSJSearchBar.h"
#import "SSJSearchHistoryItem.h"
#import "SSJBillingChargeCell.h"
#import "SSJSearchResultItem.h"
#import "SSJSearchHistoryCell.h"
#import "SSJHistoryHeader.h"
#import "SSJSearchResultHeader.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJSearchResultOrderHeader.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJSearchResultSummaryItem.h"

static NSString *const khasSearchByMoney = @"khasSearchByMoney";

static NSString *const kBillingChargeCellId = @"kBillingChargeCellId";

static NSString *const kSearchHistoryCellId = @"kSearchHistoryCellId";

static NSString *const kSearchSearchResultHeaderId = @"kSearchSearchResultHeaderId";

@interface SSJSearchingViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) SSJSearchBar *searchBar;

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) SSJHistoryHeader *historyHeader;

@property(nonatomic, strong) SSJBudgetNodataRemindView *noHistoryHeader;

@property(nonatomic, strong) SSJBudgetNodataRemindView *noResultHeader;

@property(nonatomic, strong) SSJSearchResultOrderHeader *resultOrderHeader;

@property(nonatomic, strong) UIView *clearHistoryFooterView;

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@end

@implementation SSJSearchingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesBottomBarWhenPushed = YES;
        self.hidesNavigationBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.searchBar];
    [self getSearchHistory];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJSearchHistoryCell class] forCellReuseIdentifier:kSearchHistoryCellId];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:kBillingChargeCellId];
    [self.tableView registerClass:[SSJSearchResultHeader class] forHeaderFooterViewReuseIdentifier:kSearchSearchResultHeaderId];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.model == SSJSearchResultModel) {
        [self searchForContent:self.searchBar.searchTextInput.text listOrder:self.resultOrderHeader.order];
    }else{
        [self.searchBar.searchTextInput becomeFirstResponder];
    }
//#warning test
//    _startTime = CFAbsoluteTimeGetCurrent();
//    [SSJChargeSearchingStore searchForChargeListWithSearchContent:@"餐饮" ListOrder:SSJChargeListOrderMoneyAscending Success:^(NSArray<SSJSearchResultItem *> *result) {
//        _endTime = CFAbsoluteTimeGetCurrent();
//        SSJPRINT(@"查询%ld条数据耗时%f",result.count,_endTime - _startTime);
//    } failure:^(NSError *error) {
//        
//    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchBar.searchTextInput resignFirstResponder];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.searchBar.bottom - 10);
    self.tableView.top = self.searchBar.bottom + 10;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!searchBar.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入要查询的内容"];
        return;
    }
    [self searchForContent:searchBar.text listOrder:SSJChargeListOrderDateDescending];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    if (self.model == SSJSearchResultModel) {
        [self getSearchHistory];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.model == SSJSearchResultModel) {
        [SSJAnaliyticsManager event:@"search_click_result"];
        SSJSearchResultItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
        SSJBillingChargeCellItem *billItem = [item.chargeList ssj_safeObjectAtIndex:indexPath.row];
        SSJCalenderDetailViewController *billDetailVc = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        billDetailVc.item = billItem;
        [self.navigationController pushViewController:billDetailVc animated:YES];
    }else{
        SSJSearchHistoryItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
        self.searchBar.searchTextInput.text = item.searchHistory;
        [SSJAnaliyticsManager event:@"search_pick_history"];
        [self searchForContent:item.searchHistory listOrder:SSJChargeListOrderDateDescending];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.model == SSJSearchResultModel) {
        return 90;
    }else{
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        SSJSearchResultItem *resultItem = [self.items ssj_safeObjectAtIndex:section];
        SSJSearchResultHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSearchSearchResultHeaderId];
        headerView.item = resultItem;
        return headerView;
    }else{
        return self.historyHeader;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        return 37;
    }else{
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.model == SSJSearchHistoryModel && self.items.count) {
        return 50;
    }
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.model == SSJSearchHistoryModel && self.items.count) {
        return self.clearHistoryFooterView;
    }
    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.model == SSJSearchResultModel) {
        return self.items.count;
    }else{
        if (self.items.count) {
            return 1;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        SSJSearchResultItem *item = [self.items ssj_safeObjectAtIndex:section];
        return item.chargeList.count;
    }else{
        return self.items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model == SSJSearchResultModel) {
        SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kBillingChargeCellId forIndexPath:indexPath];
        SSJSearchResultItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
        SSJBillingChargeCellItem *billItem = [item.chargeList ssj_safeObjectAtIndex:indexPath.row];
        [cell setCellItem:billItem];
        return cell;
    }else{
        SSJBaseCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
        SSJSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchHistoryCellId forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        cell.deleteAction = ^(SSJSearchHistoryItem *item){
            [SSJAnaliyticsManager event:@"search_delete_history"];
            [weakSelf getSearchHistory];
        };
        [cell setCellItem:item];
        return cell;
    }
    return nil;
}

//#pragma mark - @protocol YYKeyboardObserver
//- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
//    CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
//    if (transition.toVisible) {
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbFrame.size.height, 0);
//    }else{
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    }
////    [UIView animateWithDuration:transition.animationCurve delay:0 options:transition.animationOption animations:^{
////        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.superview];
////        CGRect popframe = self.frame;
////        popframe.origin.y = kbFrame.origin.y - popframe.size.height - 20;
////        self.frame = popframe;
////    } completion:^(BOOL finished) {
////        
////    }];
//}

#pragma mark - Getter
-(TPKeyboardAvoidingTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return _tableView;
}

- (SSJSearchBar *)searchBar{
    if (!_searchBar) {
        __weak typeof(self) weakSelf = self;
        _searchBar = [[SSJSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 70)];
        _searchBar.searchTextInput.delegate = self;
        _searchBar.searchAction = ^(){
            if (!weakSelf.searchBar.searchTextInput.text.length) {
                [CDAutoHideMessageHUD showMessage:@"请输入要查询的内容"];
                return;
            }
            [weakSelf searchForContent:weakSelf.searchBar.searchTextInput.text listOrder:SSJChargeListOrderDateAscending];
        };
        _searchBar.backAction = ^(){
            [weakSelf goBackAction];
        };
    }
    return _searchBar;
}

-(SSJHistoryHeader *)historyHeader{
    if (!_historyHeader) {
        _historyHeader = [[SSJHistoryHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    }
    return _historyHeader;
}

- (SSJBudgetNodataRemindView *)noHistoryHeader{
    if (!_noHistoryHeader) {
        _noHistoryHeader = [[SSJBudgetNodataRemindView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noHistoryHeader.title = @"开启第一次神奇的搜索吧";
        _noHistoryHeader.image = @"search_none";
    }
    return _noHistoryHeader;
}

- (SSJBudgetNodataRemindView *)noResultHeader{
    if (!_noResultHeader) {
        _noResultHeader = [[SSJBudgetNodataRemindView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noResultHeader.image = @"calendar_norecord";
    }
    return _noResultHeader;
}

- (SSJSearchResultOrderHeader *)resultOrderHeader{
    if (!_resultOrderHeader) {
        _resultOrderHeader = [[SSJSearchResultOrderHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 78)];
        _resultOrderHeader.order = SSJChargeListOrderDateDescending;
        __weak typeof(self) weakSelf = self;
        _resultOrderHeader.orderSelectBlock = ^(SSJChargeListOrder order){
            BOOL hasSearchByMoney = [[NSUserDefaults standardUserDefaults] boolForKey:khasSearchByMoney];
            if (!hasSearchByMoney) {
                if (order == SSJChargeListOrderMoneyDescending || order == SSJChargeListOrderMoneyAscending) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:khasSearchByMoney];
                    [CDAutoHideMessageHUD showMessage:@"已收支类别的具体金额数目排序，不区分正负数"];
                }
            }
            [weakSelf searchForContent:weakSelf.searchBar.searchTextInput.text listOrder:order];
        };
    }
    return _resultOrderHeader;
}

-(UIView *)clearHistoryFooterView{
    if (_clearHistoryFooterView == nil) {
        _clearHistoryFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _clearHistoryFooterView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [_clearHistoryFooterView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_clearHistoryFooterView ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleBottom];
        UIButton *clearButton = [[UIButton alloc]initWithFrame:_clearHistoryFooterView.bounds];
        [clearButton setTitle:@"清空所有历史搜索" forState:UIControlStateNormal];
        [clearButton setImage:[[UIImage imageNamed:@"search_clear"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        clearButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        clearButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [clearButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clearButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        clearButton.center = CGPointMake(_clearHistoryFooterView.width / 2, _clearHistoryFooterView.height / 2);
        [_clearHistoryFooterView addSubview:clearButton];
    }
    return _clearHistoryFooterView;
}

#pragma mark - Event
- (void)clearButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"search_clear_history"];
    if ([SSJChargeSearchingStore clearAllSearchHistoryWitherror:NULL]) {
        [self getSearchHistory];
    }
}

#pragma mark - Private
- (void)getSearchHistory{
    __weak typeof(self) weakSelf = self;
    [self.tableView ssj_showLoadingIndicator];
    [SSJChargeSearchingStore querySearchHistoryWithSuccess:^(NSArray<SSJSearchHistoryItem *> *result) {
        [weakSelf.tableView ssj_hideLoadingIndicator];

        
        weakSelf.model = SSJSearchHistoryModel;
        weakSelf.items = [NSArray arrayWithArray:result];
        if (!result.count) {
//            [self.tableView ssj_showWatermarkWithCustomView:self.noHistoryHeader animated:NO target:self action:NULL];
            self.noHistoryHeader.height = self.view.height - self.searchBar.height;
            self.tableView.tableHeaderView = self.noHistoryHeader;
        }else{
            UIView *noneView = [[UIView alloc]init];
            noneView.height = 0.1;
            weakSelf.tableView.tableHeaderView = noneView;
        }
        [weakSelf.tableView reloadData];

    } failure:^(NSError *error) {
        [self.tableView ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)searchForContent:(NSString *)content listOrder:(SSJChargeListOrder)order{
    [self.view endEditing:YES];
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    [SSJChargeSearchingStore searchForChargeListWithSearchContent:content ListOrder:order Success:^(NSArray<SSJSearchResultItem *> *result , SSJSearchResultSummaryItem *sumItem) {
        weakSelf.model = SSJSearchResultModel;
        [weakSelf.tableView ssj_hideLoadingIndicator];
        weakSelf.items = [NSArray arrayWithArray:result];
//#ifdef DEBUG
//        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"查询%ld条数据耗时%f",chargeCount,_endTime - _startTime] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],NULL];
//#endif
        if (result.count) {
            [weakSelf.tableView ssj_hideWatermark:YES];
            weakSelf.resultOrderHeader.sumItem = sumItem;
            if (sumItem.resultIncome && sumItem.resultExpenture) {
                weakSelf.resultOrderHeader.height = 113;
            }else{
                weakSelf.resultOrderHeader.height = 78;
            }
            weakSelf.tableView.tableHeaderView = weakSelf.resultOrderHeader;
        }else{
            self.noResultHeader.height = self.view.height - self.searchBar.height;
            self.tableView.tableHeaderView = self.noResultHeader;
            weakSelf.noResultHeader.title = [NSString stringWithFormat:@"没有搜索到与\"%@\"相关的流水哦,\n换个搜索词再试试吧~",content];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [weakSelf.tableView ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self.resultOrderHeader updateCellAppearanceAfterThemeChanged];
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
