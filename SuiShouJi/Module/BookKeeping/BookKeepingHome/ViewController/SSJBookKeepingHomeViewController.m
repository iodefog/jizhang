//
//  SJJBookKeepingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeViewController.h"
#import "SSJBookKeepingHeader.h"
#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalendarViewController.h"
#import "SSJHomeBarCalenderButton.h"
#import "SSJBookKeepingHomePopView.h"
#import "SSJLoginViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJBudgetListViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBooksTypeSelectViewController.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJBudgetModel.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJHomeBudgetButton.h"
#import "SSJBookKeepingButton.h"
#import "SSJBudgetModel.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "FMDB.h"
#import "SSJHomeReminderView.h"
#import "SSJBookKeepingHomeHelper.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJBookKeepingHomeNoDataHeader.h"
#import "UIViewController+SSJMotionPassword.h"
#import "SSJBookKeepingHomeBooksButton.h"
#import "SSJSearchingViewController.h"
#import "SSJBookKeepingHomeDateView.h"
#import "SSJMultiFunctionButtonView.h"
#import "SSJBookKeepingHomeBar.h"
#import "SSJBookKeepingHomeEvaluatePopView.h"
BOOL kHomeNeedLoginPop;

@interface SSJBookKeepingHomeViewController ()<SSJMultiFunctionButtonDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) SSJBookKeepingHeader *bookKeepingHeader;
@property (nonatomic,strong) SSJBudgetModel *lastBudgetModel;
@property (nonatomic,strong) SSJHomeReminderView *remindView;
@property(nonatomic, strong) SSJBookKeepingHomeBar *homeBar;
@property (nonatomic,strong) SSJBudgetModel *model;
@property (nonatomic,strong) UIView *clearView;
@property(nonatomic, strong) SSJBookKeepingButton *homeButton;
@property(nonatomic, strong) SSJBookKeepingHomeNoDataHeader *noDataHeader;
@property(nonatomic, strong) SSJBookKeepingHomeDateView *floatingDateView;
@property(nonatomic, strong) SSJMultiFunctionButtonView *mutiFunctionButton;
/**
 弹出好评弹框
 */
@property (nonatomic, strong) SSJBookKeepingHomeEvaluatePopView *evaluatePopView;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) NSIndexPath *selectIndex;
@property(nonatomic, strong) NSString *currentIncome;
@property(nonatomic, strong) NSString *currentExpenditure;
@property(nonatomic, strong) UIImageView *backImage;
@property(nonatomic, strong) NSMutableArray *newlyAddChargeArr;
@property(nonatomic, strong) NSMutableArray *newlyAddIndexArr;
@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;

// 保存用户哪个账本的预算提醒过 @{userId:@[booksType, ...], ...}
@property (nonatomic, strong) NSMutableDictionary *budgetRemindInfo;

@end

@implementation SSJBookKeepingHomeViewController{
    BOOL _isRefreshing;
    BOOL _dateViewHasDismiss;
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"首页";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _budgetRemindInfo = [NSMutableDictionary dictionary];
//        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.mm_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
        __strong typeof(weakSelf) sself = weakSelf;
        if (drawerController.openSide == MMDrawerSideNone) {
            [weakSelf getDateFromDatebase];
        }
        if (!sself->_dateViewHasDismiss) {
            [weakSelf.floatingDateView dismiss];
            [weakSelf.mutiFunctionButton dismiss];
            sself->_dateViewHasDismiss = YES;
        }
    }];
//    _hasLoad = YES;
    [self popIfNeeded];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self getCurrentDate];
    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20]};
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
//    self.navigationItem.leftBarButtonItem = leftButton;
//    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace  target:nil action:nil];
//    rightSpace.width = -15;
////    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace  target:nil action:nil];
////    leftSpace.width = -10;
////    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
//    self.navigationItem.titleView = self.budgetButton;
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBarButton];
//    self.navigationItem.rightBarButtonItems = @[rightSpace, rightItem];
    
    //  数据库初始化完成后再查询数据
    if (self.isDatabaseInitFinished) {
        [self getDateFromDatebase];
        [self reloadBudgetData];
        NSString *booksid = SSJGetCurrentBooksType();
        SSJBooksTypeItem *currentBooksItem = [SSJBooksTypeStore queryCurrentBooksTypeForBooksId:booksid];
        self.homeBar.leftButton.item = currentBooksItem;
        self.homeBar.leftButton.tintColor = [UIColor ssj_colorWithHex:currentBooksItem.booksColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self ssj_remindUserToSetMotionPasswordIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.homeBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bookKeepingHeader];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:self.statusLabel];
    self.tableView.frame = self.view.frame;
//    self.newlyAddChargeArr = [[NSMutableArray alloc]init];
//    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterBooksTypeChange) name:SSJBooksTypeDidChangeNotification object:nil];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.selectIndex = nil;
    [self getCurrentDate];
    [self.tableView reloadData];
    [self.floatingDateView removeFromSuperview];
    [self.mutiFunctionButton removeFromSuperview];
    _dateViewHasDismiss = YES;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.homeBar.leftTop = CGPointMake(0, 0);
    self.bookKeepingHeader.size = CGSizeMake(self.view.width, 136);
    self.bookKeepingHeader.top = self.homeBar.bottom;
    if (!SSJ_CURRENT_THEME.tabBarBackgroundImage.length) {
        self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - SSJ_TABBAR_HEIGHT);
    }else{
        self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom);
    }
    self.tableView.top = self.bookKeepingHeader.bottom;
    self.clearView.frame = self.view.frame;
    self.homeButton.size = CGSizeMake(106, 106);
    self.homeButton.top = self.bookKeepingHeader.bottom - 60;
    self.homeButton.centerX = self.view.width / 2;
    self.statusLabel.height = 21;
    self.statusLabel.top = self.homeButton.bottom;
    self.statusLabel.centerX = self.view.width / 2;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBookKeepingHomeTableViewCell * currentCell = (SSJBookKeepingHomeTableViewCell *)cell;
    SSJBillingChargeCellItem *item = currentCell.item;
    if ([self.newlyAddIndexArr containsObject:@(indexPath.row)]) {
        if (item.operatorType == 0) {
            currentCell.categoryImageButton.transform = CGAffineTransformMakeTranslation(0,  - currentCell.height / 2);
            currentCell.expenditureLabel.alpha = 0;
            currentCell.expentureMemoLabel.alpha = 0;
            currentCell.incomeLabel.alpha = 0;
            currentCell.incomeMemoLabel.alpha = 0;
            if (item.incomeOrExpence) {
                currentCell.expenditureLabel.transform = CGAffineTransformMakeScale(0, 0);
                currentCell.expentureMemoLabel.transform = CGAffineTransformMakeScale(0, 0);
                currentCell.expentureImage.layer.transform = CATransform3DMakeRotation(degreesToRadians(90) , 1, -1, 0);
            }else{
                currentCell.incomeLabel.transform = CGAffineTransformMakeScale(0, 0);
                currentCell.incomeMemoLabel.transform = CGAffineTransformMakeScale(0, 0);
                currentCell.IncomeImage.layer.transform = CATransform3DMakeRotation(degreesToRadians(90) , -1, -1, 0);
            }
            [UIView animateWithDuration:0.7 animations:^{
                currentCell.expenditureLabel.alpha = 1;
                currentCell.expentureMemoLabel.alpha = 1;
                currentCell.incomeLabel.alpha = 1;
                currentCell.incomeMemoLabel.alpha = 1;
                currentCell.categoryImageButton.transform = CGAffineTransformIdentity;
                currentCell.expenditureLabel.transform = CGAffineTransformIdentity;
                currentCell.incomeLabel.transform = CGAffineTransformIdentity;
                currentCell.expentureMemoLabel.transform = CGAffineTransformIdentity;
                currentCell.incomeMemoLabel.transform = CGAffineTransformIdentity;
                currentCell.expentureImage.layer.transform = CATransform3DIdentity;
                currentCell.IncomeImage.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                [currentCell shake];
            }];
        }else{
            [currentCell shake];
        }
        [self.newlyAddIndexArr removeObject:@(indexPath.row)];
    }else{
        if (!self.hasLoad) {
            __weak typeof(self) weakSelf = self;
            [currentCell animatedShowCellWithDistance:self.view.height + indexPath.row * 130 delay:0.2 * (indexPath.row + 1) completion:^{
                weakSelf.hasLoad = YES;
            }];

        }
    }
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.homeButton stopLoading];
    if (scrollView.contentOffset.y < - 80) {
        _isRefreshing = NO;
        
        [MobClick event:@"pull_add_record"];

        __weak typeof(self) weakSelf = self;
        SSJRecordMakingViewController *recordmakingVC = [[SSJRecordMakingViewController alloc]init];
        recordmakingVC.addNewChargeBlock = ^(NSArray *chargeIdArr){
            weakSelf.newlyAddChargeArr = [NSMutableArray arrayWithArray:chargeIdArr];
        };
        UINavigationController *recordNav = [[UINavigationController alloc]initWithRootViewController:recordmakingVC];
        [weakSelf presentViewController:recordNav animated:YES completion:NULL];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= -46) {
        [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
            self.homeBar.budgetButton.model = [result firstObject];
            self.homeBar.budgetButton.button.enabled = YES;
        } failure:^(NSError * _Nullable error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    if (scrollView.contentOffset.y < - 46) {
        if (!_dateViewHasDismiss) {
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
        self.tableView.lineHeight = - scrollView.contentOffset.y;
        if (self.items.count == 0) {
            self.tableView.hasData = NO;
        }else{
            self.tableView.hasData = YES;
        }
        if (!scrollView.decelerating && !_isRefreshing) {
            [self.homeButton startAnimating];
            
            _isRefreshing = YES;
        }

    }else {
        if (scrollView.contentOffset.y > - 20 && self.items.count != 0)  {
            [self.floatingDateView show];
            [self.mutiFunctionButton show];
        }
        CGPoint currentPostion = [self.view convertPoint:CGPointMake(self.view.width / 2, self.view.height / 2) toView:self.tableView];
        NSInteger currentRow = [self.tableView indexPathForRowAtPoint:currentPostion].row;
        if (currentRow <= self.items.count && self.items.count) {
            SSJBillingChargeCellItem *item = [self.items ssj_safeObjectAtIndex:currentRow];
            self.floatingDateView.currentDate = item.billDate;
            _isRefreshing = NO;
            if (self.items.count == 0) {
                self.homeBar.budgetButton.button.enabled = YES;
                return;
            }else{
                self.homeBar.budgetButton.button.enabled = NO;
                CGPoint currentPostion = CGPointMake(self.view.frame.size.width / 2, scrollView.contentOffset.y + 46);
                NSInteger currentRow = [self.tableView indexPathForRowAtPoint:currentPostion].row;
                SSJBillingChargeCellItem *item = [self.items ssj_safeObjectAtIndex:currentRow];
                NSInteger currentMonth = [[item.billDate substringWithRange:NSMakeRange(5, 2)] integerValue];
                NSInteger currentYear = [[item.billDate substringWithRange:NSMakeRange(0, 4)] integerValue];
                if (currentMonth != self.currentMonth || currentYear != self.currentYear) {
                    self.currentYear = currentYear;
                    self.currentMonth = currentMonth;
                    [self reloadCurrentMonthData];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= -46) {
        if (!_dateViewHasDismiss) {
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.items.count == 0) {
        return;
    }else{
        [self reloadCurrentMonthData];
    }
}

#pragma mark - SSJMultiFunctionButtonDelegate
- (void)multiFunctionButtonView:(SSJMultiFunctionButtonView *)buttonView willSelectButtonAtIndex:(NSUInteger)index{
    if (index == 1) {
        [MobClick event:@"main_to_top"];
        [self.tableView setContentOffset:CGPointMake(0, -46) animated:YES];
        [self.floatingDateView dismiss];
        [self.mutiFunctionButton dismiss];
    }else if (index == 2){
        [MobClick event:@"main_search"];
        SSJSearchingViewController *searchVC = [[SSJSearchingViewController alloc]init];
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJBookKeepingCell";
    SSJBookKeepingHomeTableViewCell *bookKeepingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!bookKeepingCell) {
        bookKeepingCell = [[SSJBookKeepingHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    bookKeepingCell.isEdite = ([indexPath compare:self.selectIndex] == NSOrderedSame);
    if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {
        bookKeepingCell.isLastRowOrNot = NO;
    }else{
        bookKeepingCell.isLastRowOrNot = YES;
    }
    bookKeepingCell.item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    bookKeepingCell.beginEditeBtnClickBlock = ^(SSJBookKeepingHomeTableViewCell *cell){
        if (weakSelf.selectIndex == nil) {
            weakSelf.selectIndex = [tableView indexPathForCell:cell];
            [weakSelf.tableView reloadData];
        }else{
            weakSelf.selectIndex = nil;
            [weakSelf.tableView reloadData];
        }
//        cell.isEdite = YES;
    };
    bookKeepingCell.editeBtnClickBlock = ^(SSJBookKeepingHomeTableViewCell *cell)
    {
        [MobClick event:@"main_record_delete"];

        SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
        recordMakingVc.item = cell.item;
        recordMakingVc.addNewChargeBlock = ^(NSArray *chargeIdArr){
            weakSelf.newlyAddChargeArr = [NSMutableArray arrayWithArray:chargeIdArr];
        };
        UINavigationController *recordNav = [[UINavigationController alloc]initWithRootViewController:recordMakingVc];
        [weakSelf presentViewController:recordNav animated:YES completion:NULL];
    };
    bookKeepingCell.imageClickBlock = ^(SSJBillingChargeCellItem *item){
        SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
        imageBrowserVC.type = SSJImageBrowseVcTypeBrowse;
        imageBrowserVC.item = item;
        [weakSelf.navigationController pushViewController:imageBrowserVC animated:YES];
    };
    bookKeepingCell.deleteButtonClickBlock = ^{
        [MobClick event:@"main_record_edit"];
        weakSelf.selectIndex = nil;
        [weakSelf getDateFromDatebase];
        [weakSelf.tableView reloadData];
        [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
            self.homeBar.budgetButton.model = [result firstObject];
        } failure:^(NSError * _Nullable error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    };
    return bookKeepingCell;
}

#pragma mark - Getter
//-(UIImageView *)backImage{
//    if (!_backImage) {
//        _backImage = [[UIImageView alloc]init];
//        _backImage.image = [UIImage imageNamed:@"home_line"];
//    }
//    return _backImage;
//}

-(SSJHomeTableView *)tableView{
    if (!_tableView) {
        _tableView = [[SSJHomeTableView alloc]init];
        if (!SSJ_CURRENT_THEME.tabBarBackgroundImage.length) {
            _tableView.contentInset = UIEdgeInsetsMake(46, 0, 0, 0);
        }else{
            _tableView.contentInset = UIEdgeInsetsMake(46, 0, SSJ_TABBAR_HEIGHT, 0);
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        __weak typeof(self) weakSelf = self;
        _tableView.tableViewClickBlock = ^(){
            weakSelf.selectIndex = nil;
            [weakSelf.tableView reloadData];
        };
    }
    return _tableView;
}

//-(SSJHomeBarCalenderButton*)rightBarButton{
//    if (!_rightBarButton) {
//        _rightBarButton = [[SSJHomeBarCalenderButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
////        buttonView.layer.borderColor = [UIColor redColor].CGColor;
////        buttonView.layer.borderWidth = 1;
//        _rightBarButton.currentDay = _currentDay;
//        [_rightBarButton.btn addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _rightBarButton;
//}

-(SSJHomeReminderView *)remindView{
    if (!_remindView) {
        _remindView = [[SSJHomeReminderView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _remindView;
}

-(SSJBookKeepingHeader *)bookKeepingHeader{
    if (!_bookKeepingHeader) {
        _bookKeepingHeader = [[SSJBookKeepingHeader alloc]init];
        _bookKeepingHeader.frame = CGRectMake(0, 0, self.view.width, 132);
    }
    return _bookKeepingHeader;
}



-(SSJBookKeepingButton *)homeButton{
    if (!_homeButton) {
        _homeButton = [[SSJBookKeepingButton alloc]initWithFrame:CGRectMake(0, 0, 106, 106)];
        _homeButton.layer.cornerRadius = 53.f;
        __weak typeof(self) weakSelf = self;
        _homeButton.recordMakingClickBlock = ^(){
            SSJRecordMakingViewController *recordmakingVC = [[SSJRecordMakingViewController alloc]init];
            recordmakingVC.addNewChargeBlock = ^(NSArray *chargeIdArr){
                weakSelf.newlyAddChargeArr = [NSMutableArray arrayWithArray:chargeIdArr];
            };
            UINavigationController *recordNav = [[UINavigationController alloc]initWithRootViewController:recordmakingVC];
            [weakSelf presentViewController:recordNav animated:YES completion:NULL];
        };
    }
    return _homeButton;
}

-(SSJBookKeepingHomeNoDataHeader *)noDataHeader{
    if (!_noDataHeader) {
        _noDataHeader = [[SSJBookKeepingHomeNoDataHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
    }
    return _noDataHeader;
}

- (SSJBookKeepingHomeDateView *)floatingDateView{
    if (!_floatingDateView) {
        _floatingDateView = [[SSJBookKeepingHomeDateView alloc]init];
        _floatingDateView.dismissBlock = ^(){

        };
        _floatingDateView.showBlock = ^(){
            _dateViewHasDismiss = NO;
        };
    }
    return _floatingDateView;
}

- (SSJMultiFunctionButtonView *)mutiFunctionButton{
    if (!_mutiFunctionButton) {
        _mutiFunctionButton = [[SSJMultiFunctionButtonView alloc]init];
        _mutiFunctionButton.customDelegate = self;
        _mutiFunctionButton.images = @[@"home_plus",@"home_backtotop",@"home_search"];
        _mutiFunctionButton.mainButtonNormalColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor];
        _mutiFunctionButton.secondaryButtonNormalColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor];
        _mutiFunctionButton.mainButtonSelectedColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonNormalColor];
    }
    return _mutiFunctionButton;
}

- (SSJBookKeepingHomeBar *)homeBar{
    if (!_homeBar) {
        _homeBar = [[SSJBookKeepingHomeBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
        __weak typeof(self) weakSelf = self;
        _homeBar.budgetButton.budgetButtonClickBlock = ^(SSJBudgetModel *model){
            if (model == nil) {
                SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc]init];
                SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc] init];
                NSMutableArray *viewControllers = [weakSelf.navigationController.viewControllers mutableCopy];
                [viewControllers addObject:budgetListVC];
                [viewControllers addObject:budgetEditVC];
                [weakSelf.navigationController setViewControllers:viewControllers animated:YES];
            }else{
                SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc]init];
                [weakSelf.navigationController pushViewController:budgetListVC animated:YES];
            }
        };
        _homeBar.rightBarButton.currentDay = _currentDay;
        [_homeBar.rightBarButton.btn addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_homeBar.leftButton.button addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _homeBar;
}

- (SSJBookKeepingHomeEvaluatePopView *)evaluatePopView
{
    if (!_evaluatePopView) {
        _evaluatePopView = [[SSJBookKeepingHomeEvaluatePopView alloc] initWithFrame:self.view.bounds];
//        //好评
//        _evaluatePopView.favorableReceptionBtnClickBlock = ^{
//        
//        };
//        //稍后再说
//        _evaluatePopView.laterBtnClickBlock = ^{
//        
//        };
//        //不在显示
//        _evaluatePopView.notShowAgainBtnClickBlock = ^{
//            
//        };
    }
    return _evaluatePopView;
}

#pragma mark - Event
-(void)rightBarButtonClicked{
    SSJCalendarViewController *calendarVC = [[SSJCalendarViewController alloc]init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

-(void)leftBarButtonClicked:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        if (!_dateViewHasDismiss) {
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
    }];
}

#pragma mark - Private
-(void)popIfNeeded{
    __weak typeof(self) weakSelf = self;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:SSJLastLoggedUserItemKey] && !SSJIsUserLogined() && kHomeNeedLoginPop) {
        kHomeNeedLoginPop = NO;
        
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"当前未登录，请登录后再去记账吧~" action:[SSJAlertViewAction actionWithTitle:@"关闭" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即登录" handler:^(SSJAlertViewAction * _Nonnull action) {
            SSJLoginViewController *loginVc = [[SSJLoginViewController alloc]init];
            [weakSelf.navigationController pushViewController:loginVc animated:YES];
        }], nil];
    }
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveLoginOrRegistKey]) {
        NSDate *currentDate = [NSDate date];
        NSDate *lastPopTime = [[NSUserDefaults standardUserDefaults]objectForKey:SSJLastPopTimeKey];
        NSTimeInterval time=[currentDate timeIntervalSinceDate:lastPopTime];
        int days=((int)time)/(3600*24);
        if (days >= 1) {
            SSJBookKeepingHomePopView *popView = [SSJBookKeepingHomePopView BookKeepingHomePopView];
            popView.frame = [UIScreen mainScreen].bounds;
            popView.loginBtnClickBlock = ^(){
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
                loginVC.backController = weakSelf;
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
            };
            popView.registerBtnClickBlock = ^(){
                SSJRegistGetVerViewController *registerVC = [[SSJRegistGetVerViewController alloc]init];
                registerVC.backController = weakSelf;
                [weakSelf.navigationController pushViewController:registerVC animated:YES];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:popView];
            [[NSUserDefaults standardUserDefaults]setObject:currentDate forKey:SSJLastPopTimeKey];
        }
    }

}

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self.bookKeepingHeader updateAfterThemeChange];
    [self.tableView updateAfterThemeChange];
    [self.homeButton updateAfterThemeChange];
    [self.homeBar.budgetButton updateAfterThemeChange];
    [self.homeBar.rightBarButton updateAfterThemeChange];
    [self.noDataHeader updateAfterThemeChanged];
    [self.floatingDateView updateAfterThemeChange];
    self.mutiFunctionButton.mainButtonNormalColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor];
    self.mutiFunctionButton.secondaryButtonNormalColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor];
    self.mutiFunctionButton.mainButtonSelectedColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonNormalColor];
    if (!SSJ_CURRENT_THEME.tabBarBackgroundImage.length) {
        self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - SSJ_TABBAR_HEIGHT);
        self.tableView.contentInset = UIEdgeInsetsMake(46, 0, 0, 0);
    }else{
        self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom);
        self.tableView.contentInset = UIEdgeInsetsMake(46, 0, SSJ_TABBAR_HEIGHT, 0);
    }
}

-(void)getDateFromDatebase{
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    if (self.allowRefresh) {
        [SSJBookKeepingHomeHelper queryForIncomeAndExpentureSumWithMonth:_currentMonth Year:_currentYear Success:^(NSDictionary *result) {
            if (weakSelf.hasLoad) {
                weakSelf.bookKeepingHeader.incomeView.scrollAble = NO;
                weakSelf.bookKeepingHeader.expenditureView.scrollAble = NO;
                weakSelf.bookKeepingHeader.income = [NSString stringWithFormat:@"%.2f",[result[SSJIncomeSumlKey] doubleValue]];
                weakSelf.bookKeepingHeader.expenditure = [NSString stringWithFormat:@"%.2f",[result[SSJExpentureSumKey] doubleValue]];
            }else{
                weakSelf.bookKeepingHeader.incomeView.scrollAble = YES;
                weakSelf.bookKeepingHeader.expenditureView.scrollAble = YES;
                weakSelf.bookKeepingHeader.incomeView.alpha = 0;
                weakSelf.bookKeepingHeader.expenditureView.alpha = 0;
                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    weakSelf.bookKeepingHeader.incomeView.alpha = 1;
                    weakSelf.bookKeepingHeader.expenditureView.alpha = 1;
                    weakSelf.bookKeepingHeader.income = [NSString stringWithFormat:@"%.2f",[result[SSJIncomeSumlKey] doubleValue]];
                    weakSelf.bookKeepingHeader.expenditure = [NSString stringWithFormat:@"%.2f",[result[SSJExpentureSumKey] doubleValue]];
                    weakSelf.hasLoad = YES;
                });
            }
            
        } failure:^(NSError *error) {
            
        }];
        _startTime = CFAbsoluteTimeGetCurrent();
        [SSJBookKeepingHomeHelper queryForChargeListExceptNewCharge:self.newlyAddChargeArr Success:^(NSDictionary *result) {
//            _endTime = CFAbsoluteTimeGetCurrent();
//            NSLog(@"查询%ld条数据耗时%f秒",((NSArray *)[result objectForKey:SSJOrginalChargeArrKey]).count,_endTime - _startTime);
//            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"查询%ld条数据耗时%f",((NSArray *)[result objectForKey:SSJOrginalChargeArrKey]).count,_endTime - _startTime] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],NULL];

            if (!((NSArray *)[result objectForKey:SSJNewAddChargeArrKey]).count) {
                weakSelf.items = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJOrginalChargeArrKey]];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView ssj_hideLoadingIndicator];
                if (((NSArray *)[result objectForKey:SSJOrginalChargeArrKey]).count == 0) {
                    weakSelf.tableView.tableHeaderView = self.noDataHeader;
                }else{
                    weakSelf.tableView.tableHeaderView = nil;
                }
            }else{
                weakSelf.tableView.tableHeaderView = nil;
                weakSelf.items = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJOrginalChargeArrKey]];
                NSMutableArray *newAddArr = [NSMutableArray arrayWithArray:[result objectForKey:SSJNewAddChargeArrKey]];
                NSMutableDictionary *sumDic = [NSMutableDictionary dictionaryWithDictionary:[result objectForKey:SSJChargeCountSummaryKey]];
                NSMutableDictionary *startIndex = [NSMutableDictionary dictionaryWithDictionary:[result objectForKey:SSJDateStartIndexDicKey]];
                if (weakSelf.items.count == [weakSelf.tableView numberOfRowsInSection:0] + newAddArr.count || weakSelf.items.count == [weakSelf.tableView numberOfRowsInSection:0] + newAddArr.count + 1) {
                    for (int i = 0; i < newAddArr.count; i++) {
                        weakSelf.newlyAddIndexArr = [NSMutableArray arrayWithCapacity:0];
                        SSJBillingChargeCellItem *item = [newAddArr objectAtIndex:i];
                        [weakSelf.newlyAddIndexArr addObject:@(item.chargeIndex)];
                        if (item.operatorType == 0) {
                            [weakSelf.tableView beginUpdates];
                            if ([[sumDic valueForKey:item.billDate] intValue] == 0) {
                                [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:item.chargeIndex - 1 inSection:0],[NSIndexPath indexPathForRow:item.chargeIndex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                            }else{
                                [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:item.chargeIndex inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                            }
                            [weakSelf.tableView endUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[startIndex objectForKey:item.billDate] integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            if (item.chargeIndex == weakSelf.items.count - 1) {
                                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:item.chargeIndex - 2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }else{
                            weakSelf.items = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJOrginalChargeArrKey]];
                            [weakSelf.tableView reloadData];
                        }
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:item.chargeIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }

                }else{
                    [weakSelf.tableView reloadData];
                }
                [weakSelf.newlyAddChargeArr removeAllObjects];
                
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

-(void)reloadCurrentMonthData{
    __weak typeof(self) weakSelf = self;
    [SSJBookKeepingHomeHelper queryForIncomeAndExpentureSumWithMonth:_currentMonth Year:_currentYear Success:^(NSDictionary *result) {
        self.bookKeepingHeader.currentMonth = self.currentMonth;
        weakSelf.bookKeepingHeader.incomeView.scrollAble = NO;
        weakSelf.bookKeepingHeader.expenditureView.scrollAble = NO;
        weakSelf.bookKeepingHeader.income = [NSString stringWithFormat:@"%.2f",[result[SSJIncomeSumlKey] doubleValue]];
        weakSelf.bookKeepingHeader.expenditure = [NSString stringWithFormat:@"%.2f",[result[SSJExpentureSumKey] doubleValue]];
        self.homeBar.budgetButton.currentMonth = self.currentMonth;
        weakSelf.homeBar.budgetButton.currentBalance = [result[SSJIncomeSumlKey] doubleValue] - [result[SSJExpentureSumKey] doubleValue];
    } failure:^(NSError *error) {
        
    }];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    _currentYear= now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
    self.bookKeepingHeader.currentMonth = self.currentMonth;
    self.homeBar.rightBarButton.currentDay = self.currentDay;
}

-(void)reloadDataAfterSync{
    // 防止数据同步在动画完成前，导致动画重复执行
    if (!self.hasLoad) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDateFromDatebase];
        });
    } else {
        [self getDateFromDatebase];
    }
    
    [self reloadBudgetData];
    NSString *booksid = SSJGetCurrentBooksType();
    SSJBooksTypeItem *currentBooksItem = [SSJBooksTypeStore queryCurrentBooksTypeForBooksId:booksid];
    self.homeBar.leftButton.item = currentBooksItem;
}

- (void)reloadDataAfterInitDatabase {
    [self getDateFromDatebase];
    
    [self reloadBudgetData];
    
    NSString *booksid = SSJGetCurrentBooksType();
    SSJBooksTypeItem *currentBooksItem = [SSJBooksTypeStore queryCurrentBooksTypeForBooksId:booksid];
    self.homeBar.leftButton.item = currentBooksItem;
}

- (void)reloadAfterBooksTypeChange{
    [self getDateFromDatebase];
    
    [self reloadBudgetData];
    
    NSString *booksid = SSJGetCurrentBooksType();
    SSJBooksTypeItem *currentBooksItem = [SSJBooksTypeStore queryCurrentBooksTypeForBooksId:booksid];
    self.homeBar.leftButton.item = currentBooksItem;
}

- (void)reloadBudgetData {
    [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
        self.homeBar.budgetButton.model = [result firstObject];
        for (int i = 0; i < result.count; i++) {
            SSJBudgetModel *model = [result objectAtIndex:i];
            NSArray *remindedBookTypes = _budgetRemindInfo[SSJUSERID()];
            NSString *booksType = SSJGetCurrentBooksType();
            
            if (model.isRemind
                && !model.isAlreadyReminded
                && ![remindedBookTypes containsObject:booksType]
                && model.remindMoney >= model.budgetMoney - model.payMoney) {
                
                self.remindView.model = model;
                [self.remindView show];
                
                NSMutableArray *tmpRemindBookTypes = [remindedBookTypes mutableCopy];
                if (!tmpRemindBookTypes) {
                    tmpRemindBookTypes = [NSMutableArray array];
                }
                [tmpRemindBookTypes addObject:booksType];
                [_budgetRemindInfo setObject:tmpRemindBookTypes forKey:SSJUSERID()];
                
                break;
            }
        }
    } failure:^(NSError * _Nullable error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void)reloadWithAnimation{
    self.allowRefresh = YES;
    self.hasLoad = NO;
    [self getDateFromDatebase];
}

- (void)showEvaluatePopView
{
    if (!SSJIsFirstLaunchForCurrentVersion()) {//当前版本不是第一次启动
        //当前版本是否显示过弹框()
        
    }
}

@end
