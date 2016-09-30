//
//  SSJSearchingViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchingViewController.h"
#import "SSJChargeSearchingStore.h"
#import "SSJSearchBar.h"
#import "SSJSearchHistoryItem.h"
#import "SSJBillingChargeCell.h"
#import "SSJSearchResultItem.h"
#import "SSJSearchHistoryCell.h"
#import "SSJHistoryHeader.h"

static NSString *const kBillingChargeCellId = @"kBillingChargeCellId";

static NSString *const kSearchHistoryCellId = @"kSearchHistoryCellId";


@interface SSJSearchingViewController ()<UISearchBarDelegate>

@property(nonatomic, strong) SSJSearchBar *searchBar;

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) SSJHistoryHeader *historyHeader;

@end

@implementation SSJSearchingViewController{
#warning test
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.searchBar];
    [self.tableView registerClass:[SSJSearchHistoryCell class] forCellReuseIdentifier:kSearchHistoryCellId];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:kBillingChargeCellId];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchBar.searchTextInput becomeFirstResponder];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self getSearchHistory];
//#warning test
//    _startTime = CFAbsoluteTimeGetCurrent();
//    [SSJChargeSearchingStore searchForChargeListWithSearchContent:@"餐饮" ListOrder:SSJChargeListOrderMoneyAscending Success:^(NSArray<SSJSearchResultItem *> *result) {
//        _endTime = CFAbsoluteTimeGetCurrent();
//        NSLog(@"查询%ld条数据耗时%f",result.count,_endTime - _startTime);
//    } failure:^(NSError *error) {
//        
//    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchBar.searchTextInput becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.searchBar.bottom);
    self.tableView.top = self.searchBar.bottom + 10;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!searchBar.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入要查询的内容"];
        return;
    }
    [self.view endEditing:YES];
    [SSJChargeSearchingStore searchForChargeListWithSearchContent:searchBar.text ListOrder:SSJChargeListOrderDateAscending Success:^(NSArray<SSJSearchResultItem *> *result) {
        self.model = SSJSearchResultModel;
        self.items = [NSArray arrayWithArray:result];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.model == SSJSearchResultModel) {
        return 75;
    }else{
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        return nil;
    }else{
        return self.historyHeader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.model == SSJSearchResultModel) {
        return 37;
    }else{
        return 50;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.model == SSJSearchResultModel) {
        return self.items.count;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
        SSJBaseItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
        SSJSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchHistoryCellId forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        cell.deleteAction = ^(SSJSearchHistoryItem *item){
            [weakSelf getSearchHistory];
        };
        [cell setCellItem:item];
        return cell;
    }
    return nil;
}

#pragma mark - Getter
- (SSJSearchBar *)searchBar{
    if (!_searchBar) {
        __weak typeof(self) weakSelf = self;
        _searchBar = [[SSJSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 70)];
        _searchBar.searchTextInput.delegate = self;
        _searchBar.cancelAction = ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Private
- (void)getSearchHistory{
    __weak typeof(self) weakSelf = self;
    [self.tableView ssj_showLoadingIndicator];
    [SSJChargeSearchingStore querySearchHistoryWithSuccess:^(NSArray<SSJSearchHistoryItem *> *result) {
        weakSelf.items = [NSArray arrayWithArray:result];
        weakSelf.model = SSJSearchHistoryModel;
        [weakSelf.tableView reloadData];
        [self.tableView ssj_hideLoadingIndicator];
    } failure:^(NSError *error) {
        [self.tableView ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
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
