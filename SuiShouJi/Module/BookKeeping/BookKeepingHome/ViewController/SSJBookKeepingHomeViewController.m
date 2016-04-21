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
#import "SSJHomeBarButton.h"
#import "SSJBookKeepingHomePopView.h"
#import "SSJLoginViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJBudgetListViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJBudgetModel.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJHomeBudgetButton.h"
#import "SSJBookKeepingButton.h"
#import "SSJBudgetModel.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"
#import "SSJHomeReminderView.h"
#import "SSJBookKeepingHomeHelper.h"
#import "SSJHomeTableView.h"

@interface SSJBookKeepingHomeViewController ()

@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) SSJBookKeepingHeader *bookKeepingHeader;
@property (nonatomic,strong) SSJBudgetModel *lastBudgetModel;
@property (nonatomic,strong) SSJHomeBudgetButton *budgetButton;
@property (nonatomic,strong) SSJHomeReminderView *remindView;
@property (nonatomic,strong) SSJBudgetModel *model;
@property (nonatomic,strong) UIView *clearView;
@property(nonatomic, strong) SSJBookKeepingButton *homeButton;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) SSJHomeTableView *tableView;
@property(nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;
@property(nonatomic) BOOL refreshSuccessOrNot;
@end

@implementation SSJBookKeepingHomeViewController
  
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"首页";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsMake(38, 0, 0, 0);
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveLoginOrRegistKey]) {
        NSDate *currentDate = [NSDate date];
        NSDate *lastPopTime = [[NSUserDefaults standardUserDefaults]objectForKey:SSJLastPopTimeKey];
        NSTimeInterval time=[currentDate timeIntervalSinceDate:lastPopTime];
        int days=((int)time)/(3600*24);
        if (days > 14) {
            SSJBookKeepingHomePopView *popView = [SSJBookKeepingHomePopView BookKeepingHomePopView];
            popView.frame = [UIScreen mainScreen].bounds;
            __weak typeof(self) weakSelf = self;
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
    [self getCurrentDate];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor colorWithRed:85.0 / 255.0 green:72.0 / 255.0 blue:0 alpha:0.1] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.budgetButton];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace  target:nil action:nil];
    rightSpace.width = -15;
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace  target:nil action:nil];
    leftSpace.width = -10;
//    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[leftBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[rightSpace, self.rightBarButton];
    
    //  数据库初始化完成后再查询数据
    if (self.isDatabaseInitFinished) {
        [self getDateFromDatebase];
        [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
            self.budgetButton.model = [result firstObject];
            for (int i = 0; i < result.count; i++) {
                if ([result objectAtIndex:i].remindMoney >= [result objectAtIndex:i].budgetMoney - [result objectAtIndex:i].payMoney && [result objectAtIndex:i].isRemind == 1 && [result objectAtIndex:i].isAlreadyReminded == 0) {
                    self.remindView.model = [result objectAtIndex:i];
                    [[UIApplication sharedApplication].keyWindow addSubview:self.remindView];
                    break;
                }
            }
        } failure:^(NSError * _Nullable error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bookKeepingHeader];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:self.statusLabel];
    self.tableView.frame = self.view.frame;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.selectIndex = nil;
    [self getCurrentDate];
}

-(void)viewDidLayoutSubviews{
    self.bookKeepingHeader.size = CGSizeMake(self.view.width, 170);
    self.bookKeepingHeader.top = 0;
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - 49);
    self.tableView.top = self.bookKeepingHeader.bottom;
    self.clearView.frame = self.view.frame;
    self.homeButton.size = CGSizeMake(96, 96);
    self.homeButton.top = self.bookKeepingHeader.bottom - 60;
    self.homeButton.centerX = self.view.width / 2;
    self.statusLabel.height = 21;
    self.statusLabel.top = self.homeButton.bottom;
    self.statusLabel.centerX = self.view.width / 2;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y < -38) {
        [self.homeButton startLoading];
        scrollView.contentInset = UIEdgeInsetsMake(59, 0, 0, 0);
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"数据同步中";
        [self.statusLabel sizeToFit];
        [self.view setNeedsLayout];
        __weak typeof(self) weakSelf = self;
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(SSJDataSynchronizeType type){
            if (type == SSJDataSynchronizeTypeData) {
                weakSelf.refreshSuccessOrNot = YES;
                [weakSelf.homeButton stopLoading];
            }
        }failure:^(SSJDataSynchronizeType type, NSError *error) {
            weakSelf.refreshSuccessOrNot = NO;
            [weakSelf.homeButton stopLoading];
        }];
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
    if (indexPath.row == self.items.count - 1) {
        bookKeepingCell.isLastRowOrNot = NO;
    }else{
        bookKeepingCell.isLastRowOrNot = YES;
    }
    bookKeepingCell.item = [self.items objectAtIndex:indexPath.row];
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
        SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
        recordMakingVc.item = cell.item;
        [weakSelf.navigationController pushViewController:recordMakingVc animated:YES];
    };
    bookKeepingCell.imageClickBlock = ^(SSJBillingChargeCellItem *item){
        SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
        imageBrowserVC.item = item;
        [weakSelf.navigationController pushViewController:imageBrowserVC animated:YES];
    };
    bookKeepingCell.deleteButtonClickBlock = ^{
        weakSelf.selectIndex = nil;
        [weakSelf getDateFromDatebase];
        [weakSelf.tableView reloadData];
        [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
            self.budgetButton.model = [result firstObject];
            for (int i = 0; i < result.count; i++) {
                if ([result objectAtIndex:i].remindMoney < [result objectAtIndex:i].payMoney && [result objectAtIndex:i].isRemind == 1 && [result objectAtIndex:i].isAlreadyReminded == 0) {
                    self.remindView.model = [result objectAtIndex:i];
                    [[UIApplication sharedApplication].keyWindow addSubview:self.remindView];
                    break;
                }
            }
        } failure:^(NSError * _Nullable error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    };
    return bookKeepingCell;
}

#pragma mark - Getter
-(SSJHomeTableView *)tableView{
    if (!_tableView) {
        _tableView = [[SSJHomeTableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        __weak typeof(self) weakSelf = self;
        _tableView.tableViewClickBlock = ^(){
            weakSelf.selectIndex = nil;
            [weakSelf.tableView reloadData];
        };
    }
    return _tableView;
}

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        SSJHomeBarButton *buttonView = [[SSJHomeBarButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
//        buttonView.layer.borderColor = [UIColor redColor].CGColor;
//        buttonView.layer.borderWidth = 1;
        buttonView.currentDay = _currentDay;
        [buttonView.btn addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    }
    return _rightBarButton;
}

-(SSJHomeReminderView *)remindView{
    if (!_remindView) {
        _remindView = [[SSJHomeReminderView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _remindView;
}

-(SSJBookKeepingHeader *)bookKeepingHeader{
    if (!_bookKeepingHeader) {
        _bookKeepingHeader = [SSJBookKeepingHeader BookKeepingHeader];
        _bookKeepingHeader.frame = CGRectMake(0, 0, self.view.width, 132);
    }
    return _bookKeepingHeader;
}

-(SSJHomeBudgetButton *)budgetButton{
    if (!_budgetButton) {
        _budgetButton = [[SSJHomeBudgetButton alloc]initWithFrame:CGRectMake(0, 0, 100, 46)];
        __weak typeof(self) weakSelf = self;
        _budgetButton.budgetButtonClickBlock = ^(SSJBudgetModel *model){
            if (model == nil) {
                SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc]init];
                [weakSelf.navigationController pushViewController:budgetEditVC animated:YES];
            }else{
                SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc]init];
                [weakSelf.navigationController pushViewController:budgetListVC animated:YES];
            }
        };
    }
    return _budgetButton;
}

-(SSJBookKeepingButton *)homeButton{
    if (!_homeButton) {
        _homeButton = [[SSJBookKeepingButton alloc]initWithFrame:CGRectMake(0, 0, 96, 96)];
        _homeButton.layer.cornerRadius = 48.f;
        __weak typeof(self) weakSelf = self;
        _homeButton.recordMakingClickBlock = ^(){
            SSJRecordMakingViewController *recordmaking = [[SSJRecordMakingViewController alloc]init];
            [weakSelf.navigationController pushViewController:recordmaking animated:YES];
        };
        _homeButton.animationStopBlock = ^(){
            weakSelf.statusLabel.hidden = NO;
            if (weakSelf.refreshSuccessOrNot) {
                weakSelf.statusLabel.text = @"数据同步成功";
                weakSelf.homeButton.refreshSuccessOrNot = YES;
                [weakSelf.statusLabel sizeToFit];
                [weakSelf.view setNeedsLayout];
            }else{
                weakSelf.statusLabel.text = @"数据同步失败";
                weakSelf.homeButton.refreshSuccessOrNot = NO;
                [weakSelf.statusLabel sizeToFit];
                [weakSelf.view setNeedsLayout];
            }
            [weakSelf.tableView setContentOffset:CGPointMake(0, -36) animated:YES];
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC);
            
            dispatch_after(time, dispatch_get_main_queue(), ^{
                weakSelf.statusLabel.text = @"";
                weakSelf.statusLabel.hidden = YES;
            });
        };
    }
    return _homeButton;
}

-(UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _statusLabel.font = [UIFont systemFontOfSize:14];
        _statusLabel.hidden = YES;
        _statusLabel.backgroundColor = [UIColor whiteColor];
        _statusLabel.text = @"";
    }
    return _statusLabel;
}

#pragma mark - Private
-(void)rightBarButtonClicked{
    SSJCalendarViewController *calendarVC = [[SSJCalendarViewController alloc]init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

-(void)budgetButtonClicked:(id)sender{
    if (self.budgetButton.model == nil) {
        SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc]init];
        [self.navigationController pushViewController:budgetEditVC animated:YES];
    }else{
        SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc]init];
        [self.navigationController pushViewController:budgetListVC animated:YES];
    }
}

-(void)getDateFromDatebase{
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    [SSJBookKeepingHomeHelper queryForIncomeAndExpentureSumWithMonth:_currentMonth Year:_currentYear Success:^(NSDictionary *result) {
        weakSelf.bookKeepingHeader.income = [NSString stringWithFormat:@"%.2f",[result[SSJIncomeSumlKey] doubleValue]];
        weakSelf.bookKeepingHeader.expenditure = [NSString stringWithFormat:@"%.2f",[result[SSJExpentureSumKey] doubleValue]];
    } failure:^(NSError *error) {
        
    }];
    [SSJBookKeepingHomeHelper queryForChargeListWithSuccess:^(NSArray<SSJBillingChargeCellItem *> *result) {
        weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
        if (result.count == 0) {
            [weakSelf.tableView ssj_showWatermarkWithImageName:@"home_none" animated:NO target:nil action:nil];
        }else{
            [weakSelf.tableView ssj_hideWatermark:YES];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView ssj_hideLoadingIndicator];
    }failure:^(NSError *error) {
        
    }];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    _currentYear= now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
    self.bookKeepingHeader.currentMonth = self.currentMonth;
}

-(void)reloadDataAfterSync{
    [self getDateFromDatebase];
    [self reloadBudgetData];
}

- (void)reloadDataAfterInitDatabase {
    [self getDateFromDatebase];
    [self reloadBudgetData];
}

- (void)reloadBudgetData {
    [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
        self.budgetButton.model = [result firstObject];
        for (int i = 0; i < result.count; i++) {
            if ([result objectAtIndex:i].remindMoney >= [result objectAtIndex:i].budgetMoney - [result objectAtIndex:i].payMoney && [result objectAtIndex:i].isRemind == 1 && [result objectAtIndex:i].isAlreadyReminded == 0) {
                self.remindView.model = [result objectAtIndex:i];
                [[UIApplication sharedApplication].keyWindow addSubview:self.remindView];
                break;
            }
        }
    } failure:^(NSError * _Nullable error) {
        NSLog(@"%@",error.localizedDescription);
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
