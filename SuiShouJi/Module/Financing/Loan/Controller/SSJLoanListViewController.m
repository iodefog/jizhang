//
//  SSJLoanListViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListViewController.h"
#import "SSJAddOrEditLoanViewController.h"
#import "SSJLoanDetailViewController.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJLoanListSectionHeaderAmountView.h"
#import "SSJLoanListCell.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJLoanHelper.h"
#import "SSJFinancingHomeHelper.h"

static NSString *const kLoanListCellId = @"kLoanListCellId";

@interface SSJLoanListViewController () <UITableViewDataSource, UITableViewDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) SCYSlidePagingHeaderView *headerSegmentView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJLoanListSectionHeaderAmountView *amountView;

@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

@end

@implementation SSJLoanListViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _item.fundingName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    
    [self.view addSubview:self.headerSegmentView];
//    [self.view addSubview:self.amountView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addBtn];
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 如果是push到此页面，先查询未结清的数据，如果没有再查询所有数据
//    if ([self isMovingToParentViewController]) {
//        [self loadAllDataIfHasNoUnclearedData];
//    } else {
//        [self reloadDataAccordingToHeaderViewIndex];
//    }
    
    [self reloadDataAccordingToHeaderViewIndex];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJLoanListCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoanListCellId forIndexPath:indexPath];
    cell.cellItem = [SSJLoanListCellItem itemWithLoanModel:[self.list ssj_safeObjectAtIndex:indexPath.section]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    } else {
        return 10;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.amountView;
    } else {
        return [[UIView alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJLoanModel *model = [_list ssj_safeObjectAtIndex:indexPath.section];
    [SSJLoanHelper queryForFundColorWithID:model.fundID completion:^(NSString * _Nonnull color) {
        SSJLoanDetailViewController *loanDetailVC = [[SSJLoanDetailViewController alloc] init];
        loanDetailVC.loanID = model.ID;
        loanDetailVC.fundColor = color;
        [self.navigationController pushViewController:loanDetailVC animated:YES];
    }];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDataAccordingToHeaderViewIndex];
    
    if (index == 0) {
        if ([_item.fundingID isEqualToString:@"10"]) {
            [SSJAnaliyticsManager event:@"loan_tab_no_end"];
        } else if ([_item.fundingID isEqualToString:@"11"]) {
            [SSJAnaliyticsManager event:@"owed_tab_no_end"];
        }
    } else if (index == 1) {
        if ([_item.fundingID isEqualToString:@"10"]) {
            [SSJAnaliyticsManager event:@"loan_tab_end"];
        } else if ([_item.fundingID isEqualToString:@"11"]) {
            [SSJAnaliyticsManager event:@"owed_tab_end"];
        }
    } else if (index == 2) {
        if ([_item.fundingID isEqualToString:@"10"]) {
            [SSJAnaliyticsManager event:@"loan_tab_all"];
        } else if ([_item.fundingID isEqualToString:@"11"]) {
            [SSJAnaliyticsManager event:@"owed_tab_all"];
        }
    }
}

#pragma mark - Event
- (void)deleteAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除该资金账户吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.authCodeAlertView show];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)addAction {
    SSJAddOrEditLoanViewController *addLoanVC = [[SSJAddOrEditLoanViewController alloc] init];
    if ([_item.fundingParent isEqualToString:@"10"]) {
        addLoanVC.type = SSJLoanTypeLend;
        [SSJAnaliyticsManager event:@"add_loan"];
    } else if ([_item.fundingParent isEqualToString:@"11"]) {
        addLoanVC.type = SSJLoanTypeBorrow;
        [SSJAnaliyticsManager event:@"add_owed"];
    }
    
    [self.navigationController pushViewController:addLoanVC animated:YES];
}

#pragma mark - Private
- (void)updateAppearance {
    _headerSegmentView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _headerSegmentView.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _headerSegmentView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_headerSegmentView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [_amountView updateAppearance];
    _addBtn.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    [_addBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_addBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

//// 如果没有未结清数据就加载全部数据
//- (void)loadAllDataIfHasNoUnclearedData {
//    [self.view ssj_showLoadingIndicator];
//    [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:0 success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
//        if (list.count == 0) {
//            [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:2 success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
//                [self.view ssj_hideLoadingIndicator];
//                self.list = list;
//                [self.tableView reloadData];
//                [self updateAmount];
//                
//                if (list.count == 0) {
//                    [self.view ssj_showWatermarkWithImageName:@"" animated:YES target:nil action:NULL];
//                } else {
//                    [self.view ssj_hideWatermark:YES];
//                }
//            } failure:^(NSError * _Nonnull error) {
//                [self.view ssj_hideLoadingIndicator];
//                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
//            }];
//        } else {
//            [self.view ssj_hideLoadingIndicator];
//            self.list = list;
//            [self.tableView reloadData];
//            [self updateAmount];
//        }
//    } failure:^(NSError * _Nonnull error) {
//        [self.view ssj_hideLoadingIndicator];
//        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
//    }];
//}

- (void)reloadDataAccordingToHeaderViewIndex {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:(int)_headerSegmentView.selectedIndex success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
        [self.view ssj_hideLoadingIndicator];
        self.list = list;
        [self.tableView reloadData];
        [self updateAmount];
        
        if (self.list.count == 0) {
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            [self.view ssj_hideWatermark:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)updateAmount {
    double amount = [[self.list valueForKeyPath:@"@sum.jMoney"] doubleValue];
    if ([_item.fundingParent isEqualToString:@"10"]) {
        self.amountView.amount = [NSString stringWithFormat:@"+%.2f", amount];
    } else if ([_item.fundingParent isEqualToString:@"11"]) {
        self.amountView.amount = [NSString stringWithFormat:@"-%.2f", amount];
    }
}

#pragma mark - Getter
- (SCYSlidePagingHeaderView *)headerSegmentView {
    if (!_headerSegmentView) {
        _headerSegmentView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 36)];
        _headerSegmentView.customDelegate = self;
        _headerSegmentView.buttonClickAnimated = YES;
        _headerSegmentView.titles = @[@"未结清", @"已结清", @"全部"];
        [_headerSegmentView setTabSize:CGSizeMake(_headerSegmentView.width / _headerSegmentView.titles.count, 3)];
        [_headerSegmentView ssj_setBorderWidth:1];
        [_headerSegmentView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _headerSegmentView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, self.view.height - self.headerSegmentView.bottom - self.addBtn.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJLoanListCell class] forCellReuseIdentifier:kLoanListCellId];
        _tableView.rowHeight = 90;
    }
    return _tableView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"loan_noDataRemind";
        _noDataRemindView.title = @"暂无记录哦";
    }
    return _noDataRemindView;
}

- (SSJLoanListSectionHeaderAmountView *)amountView {
    if (!_amountView) {
        _amountView = [[SSJLoanListSectionHeaderAmountView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, 40)];
        if ([_item.fundingParent isEqualToString:@"10"]) {
            _amountView.title = @"累计借出款";
        } else if ([_item.fundingParent isEqualToString:@"11"]) {
            _amountView.title = @"累计欠款";
        } else {
            SSJPRINT(@"警告：借贷父账户ID错误：_item.fundingParent，有效值只能为10、11");
        }
    }
    return _amountView;
}

- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _addBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
        [_addBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _addBtn;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)authCodeAlertView {
    if (!_authCodeAlertView) {
        __weak typeof(self) wself = self;
        _authCodeAlertView = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        _authCodeAlertView.finishVerification = ^{
            [SSJFinancingHomeHelper deleteFundingWithFundingItem:wself.item deleteType:1 Success:^{
                [wself.navigationController popToRootViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
        };
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        style.alignment = NSTextAlignmentCenter;
        _authCodeAlertView.message = [[NSAttributedString alloc] initWithString:@"删除后将难以恢复\n仍然删除，请输入下列验证码" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _authCodeAlertView;
}

@end
