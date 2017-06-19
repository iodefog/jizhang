//
//  SJJBookKeepingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeViewController.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalendarViewController.h"
#import "SSJLoginViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJBudgetListViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBooksTypeSelectViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJSearchingViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJThemBgImageClipViewController.h"
#import "SSJNavigationController.h"
#import "UIViewController+SSJMotionPassword.h"
#import "SSJLoginViewController+SSJCategory.h"
#import "SSJShareBooksMenberManagerViewController.h"

#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJBookKeepingHomeNoDataCell.h"
#import "SSJHomeBarCalenderButton.h"
#import "SSJBookKeepingHomePopView.h"
#import "SSJBookKeepingHeader.h"
#import "SSJHomeBudgetButton.h"
#import "SSJBookKeepingButton.h"
#import "SSJHomeReminderView.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJBookKeepingHomeNoDataHeader.h"
#import "SSJBookKeepingHomeBooksButton.h"
#import "SSJBookKeepingHomeDateView.h"
#import "SSJMultiFunctionButtonView.h"
#import "SSJBookKeepingHomeBar.h"
#import "SSJBookKeepingHomeEvaluatePopView.h"
#import "SSJLoginPopView.h"
#import "SSJBookKeepingHomePopView.h"
#import "SSJHomeBillStickyNoteView.h"
#import "SSJBookKeepingHomeHeaderView.h"
#import "SSJHomeThemeModifyView.h"
#import "SSJAlertViewAdapter.h"
#import "SSJAlertViewAction.h"
#import "SSJListMenu.h"
#import "SSJChargeImageBrowseView.h"

#import "SSJBudgetModel.h"
#import "SSJBooksTypeItem.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJBookKeepingHomeListItem.h"
#import "SSJBooksTypeStore.h"
#import "SSJShareBooksHelper.h"
#import "SSJBookKeepingHomeHelper.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJUserTableManager.h"
#import "SSJCustomThemeManager.h"
#import "SSJBooksTypeStore.h"


static NSString *const kHeaderId = @"SSJBookKeepingHomeHeaderView";

@interface SSJBookKeepingHomeViewController () <SSJMultiFunctionButtonDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

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
/**指引弹框*/
@property (nonatomic, strong) SSJListMenu *guidePopView;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) NSIndexPath *selectIndex;
@property(nonatomic, strong) NSString *currentIncome;
@property(nonatomic, strong) NSString *currentExpenditure;
@property(nonatomic, strong) UIImageView *backImage;
@property(nonatomic, strong) NSMutableArray *newlyAddChargeArr;
@property(nonatomic, strong) NSMutableArray *newlyAddSectionArr;
@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;

/**
 预算超支弹框是否弹过
 */
@property (nonatomic, assign) BOOL isBudgetOverrunsPopViewShow;

// 保存用户哪个账本的预算提醒过 @{userId:@[booksType, ...], ...}
@property (nonatomic, strong) NSMutableDictionary *budgetRemindInfo;
/**
 <#注释#>
 */
@property (nonatomic, strong) SSJBookKeepingHomePopView *keepingHomePopView;

@property (nonatomic, strong) SSJHomeBillStickyNoteView *billStickyNoteView;

@property(nonatomic, strong) SSJHomeThemeModifyView *themeModifyView;
@end

@implementation SSJBookKeepingHomeViewController{
    BOOL _isRefreshing;
    BOOL _dateViewHasDismiss;
    BOOL _hasChangeBooksType;
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"首页";
        self.hidesNavigationBarWhenPushed = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.homeBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bookKeepingHeader];
    [self.view addSubview:self.homeButton];
    [self.view addSubview:self.statusLabel];
    [self.tableView addSubview:self.noDataHeader];
//    [self.view addSubview:self.billStickyNoteView];//mzl新年账单
    self.tableView.frame = self.view.frame;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[SSJBookKeepingHomeHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterBooksTypeChange) name:SSJBooksTypeDidChangeNotification object:nil];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueLoading) name:SSJHomeContinueLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDidFail) name:SSJSyncDataFailureNotification object:nil];
    [self showGuildView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    __weak typeof(self) weakSelf = self;
    [self.mm_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
        __strong typeof(weakSelf) sself = weakSelf;
        if (drawerController.openSide == MMDrawerSideNone) {
            [weakSelf getDataFromDataBase];
        }
        if (!sself->_dateViewHasDismiss) {
            [weakSelf.floatingDateView dismiss];
            [weakSelf.mutiFunctionButton dismiss];
            sself->_dateViewHasDismiss = YES;
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if (_needEditeThemeModel) {
        [self.themeModifyView show];
        _needEditeThemeModel = NO;
    }
    [self getCurrentDate];
    
    
    //  数据库初始化完成后再查询数据
    if (self.isDatabaseInitFinished) {
        [self getDataFromDataBase];
        [self updateTabbar];
        [self updateBooksItem];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self ssj_remindUserToSetMotionPasswordIfNeeded];
    [self whichViewShouldPopToHomeView];//弹框
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.selectIndex = nil;
    [self getCurrentDate];
    [self.floatingDateView dismiss];
    [self.mutiFunctionButton dismiss];
    _dateViewHasDismiss = YES;
    
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.homeBar.leftTop = CGPointMake(0, 0);
    self.bookKeepingHeader.size = CGSizeMake(self.view.width, 136);
    self.bookKeepingHeader.top = self.homeBar.bottom;
    self.homeButton.size = CGSizeMake(106, 106);
    self.homeButton.top = self.bookKeepingHeader.bottom - 60;
    self.homeButton.centerX = self.view.width / 2;
//    self.billStickyNoteView.centerX = self.view.centerX;
//    self.billStickyNoteView.width = self.view.width;
//    self.billStickyNoteView.top = self.homeButton.bottom;
//    BOOL haveShowTheNoteView = YES;//是否显示过新年账单默认显示过了//[[[NSUserDefaults standardUserDefaults] objectForKey:SSJShowBillNoteKey] boolValue];
//    if (!haveShowTheNoteView) {
//        //没显示过
//        self.billStickyNoteView.height = 105;
//        self.billStickyNoteView.hidden = NO;
//    } else {
//        self.billStickyNoteView.height = 0;
//        self.billStickyNoteView.hidden = YES;
//    }
    
    float tabBarHeight = SSJ_CURRENT_THEME.tabBarBackgroundImage.length ? 0 : SSJ_TABBAR_HEIGHT;
    
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - tabBarHeight);
    
    self.tableView.contentInset = UIEdgeInsetsMake(46, 0, 0, 0);

    self.tableView.top = self.bookKeepingHeader.bottom;
    
    self.noDataHeader.top = -60;
    
    self.noDataHeader.size = CGSizeMake(self.view.width, self.tableView.height - 60);
    
    self.clearView.frame = self.view.frame;
    self.statusLabel.height = 21;
    self.statusLabel.top = self.homeButton.bottom;
    self.statusLabel.centerX = self.view.width / 2;
    self.themeModifyView.leftBottom = CGPointMake(0, self.view.height);
} 


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SSJBookKeepingHomeListItem *item = [self.items ssj_safeObjectAtIndex:section];
    SSJBookKeepingHomeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderId];
    headerView.item = item;
    return headerView;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBookKeepingHomeListItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    if (![item.date isEqualToString:@"-1"]) {
        SSJBookKeepingHomeTableViewCell * currentCell = (SSJBookKeepingHomeTableViewCell *)cell;
        SSJBillingChargeCellItem *item = currentCell.item;
        if ([self.newlyAddChargeArr containsObject:item]) {
            [currentCell performAddOrEditAnimation];
            [self.newlyAddChargeArr removeObject:item];
        }else{
            if (!self.hasLoad && self.items.count) {
                __weak typeof(self) weakSelf = self;
                SSJBookKeepingHomeListItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
                [currentCell animatedShowCellWithDistance:self.view.height + indexPath.row * 130 delay:0.2 * (item.totalCount + indexPath.row) completion:^{
                    weakSelf.hasLoad = YES;
                }];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    SSJBookKeepingHomeHeaderView * currentHeader = (SSJBookKeepingHomeHeaderView *)view;
    SSJBookKeepingHomeListItem *item = currentHeader.item;
    if ([self.newlyAddChargeArr containsObject:item]) {
        currentHeader.categoryImageButton.transform = CGAffineTransformMakeTranslation(0,  - currentHeader.height / 2);
        currentHeader.expenditureLabel.alpha = 0;
        currentHeader.incomeLabel.alpha = 0;
        if (item.balance < 0) {
            currentHeader.expenditureLabel.transform = CGAffineTransformMakeScale(0, 0);
        }else{
            currentHeader.incomeLabel.transform = CGAffineTransformMakeScale(0, 0);
        }
        [UIView animateWithDuration:0.7 animations:^{
            currentHeader.expenditureLabel.alpha = 1;
            currentHeader.incomeLabel.alpha = 1;
            currentHeader.categoryImageButton.transform = CGAffineTransformIdentity;
            currentHeader.expenditureLabel.transform = CGAffineTransformIdentity;
            currentHeader.incomeLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [currentHeader shake];
        }];

        [self.newlyAddChargeArr removeObject:item];
    }else{
        if (!self.hasLoad && self.items.count) {
            __weak typeof(self) weakSelf = self;
            SSJBookKeepingHomeListItem *item = [self.items ssj_safeObjectAtIndex:section];
            [currentHeader animatedShowCellWithDistance:self.view.height + item.totalCount * 130 delay:0.2 * item.totalCount completion:^{
                weakSelf.hasLoad = YES;
            }];
            
        }
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SSJBookKeepingHomeListItem *listItem = [self.items ssj_safeObjectAtIndex:section];
    return listItem.chargeItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBookKeepingHomeListItem *listItem = [self.items ssj_safeObjectAtIndex:indexPath.section];
    if (![listItem.date isEqualToString:@"-1"]) {
        static NSString *cellId = @"SSJBookKeepingCell";
        SSJBookKeepingHomeTableViewCell *bookKeepingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!bookKeepingCell) {
            bookKeepingCell = [[SSJBookKeepingHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1 && indexPath.section == self.items.count - 1) {
            bookKeepingCell.isLastRow = YES;
        }else{
            bookKeepingCell.isLastRow = NO;
        }
        SSJBookKeepingHomeListItem *listItem = [self.items objectAtIndex:indexPath.section];
        bookKeepingCell.item = [listItem.chargeItems ssj_safeObjectAtIndex:indexPath.row];
        __weak typeof(self) weakSelf = self;
        bookKeepingCell.imageClickBlock = ^(SSJBillingChargeCellItem *item){
            NSURL *imgUrl = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(item.chargeImage)]) {
                imgUrl = [NSURL fileURLWithPath:SSJImagePath(item.chargeImage)];
            } else {
                imgUrl = [NSURL URLWithString:SSJGetChargeImageUrl(item.chargeImage)];
            }
            [UIImage ssj_loadUrl:imgUrl compeltion:^(NSError *error, UIImage *image) {
                if (image) {
                    [SSJChargeImageBrowseView showWithImage:image];
                }
            }];
        };
        bookKeepingCell.enterChargeDetailBlock = ^(SSJBookKeepingHomeTableViewCell *cell) {
            SSJCalenderDetailViewController *detailVc = [[SSJCalenderDetailViewController alloc] init];
            [SSJAnaliyticsManager event:@"home_liushui_detail"];
            detailVc.item = cell.item;
            [weakSelf.navigationController pushViewController:detailVc animated:YES];
        };
        return bookKeepingCell;
    } else {
        static NSString *cellId = @"SSJBookKeepingNoDataCell";
        SSJBookKeepingHomeNoDataCell *noDataCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!noDataCell) {
            noDataCell = [[SSJBookKeepingHomeNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        return noDataCell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.homeButton stopLoading];
    if (scrollView.contentOffset.y < - scrollView.contentInset.top - 34) {
        _isRefreshing = NO;
        
        [SSJAnaliyticsManager event:@"pull_add_record"];

        __weak typeof(self) weakSelf = self;
        SSJRecordMakingViewController *recordmakingVC = [[SSJRecordMakingViewController alloc]init];
        recordmakingVC.addNewChargeBlock = ^(NSArray *chargeIdArr ,BOOL hasChangeBooksType){
            weakSelf.newlyAddChargeArr = [NSMutableArray arrayWithArray:chargeIdArr];
            _hasChangeBooksType = hasChangeBooksType;
        };
        SSJNavigationController *recordNav = [[SSJNavigationController alloc] initWithRootViewController:recordmakingVC];
        [self presentViewController:recordNav animated:YES completion:NULL];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= - scrollView.contentInset.top) {
        [self updateTabbar];
    }
    if (scrollView.contentOffset.y < - scrollView.contentInset.top) {
        if (!_dateViewHasDismiss) {
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
        self.tableView.lineHeight = - scrollView.contentOffset.y - scrollView.contentInset.top;
        if (!scrollView.decelerating && !_isRefreshing) {
            [self.homeButton startAnimating];
            
            _isRefreshing = YES;
        }

    }else {
        if (scrollView.contentOffset.y > MAX(- 20, - scrollView.contentInset.top)  && self.items.count != 0)  {
            [self.floatingDateView showOnView:self.view];
            [self.mutiFunctionButton showOnView:self.view];
        }
        CGPoint currentPostion = [self.view convertPoint:CGPointMake(self.view.width / 2, self.view.height / 2) toView:self.tableView];
        NSInteger currentSection = [self.tableView indexPathForRowAtPoint:currentPostion].section;
        if (currentSection <= self.items.count && self.items.count) {
            SSJBookKeepingHomeListItem *listItem = [self.items ssj_safeObjectAtIndex:currentSection];
            self.floatingDateView.currentDate = listItem.date;
            _isRefreshing = NO;
            if (self.items.count == 0 || [self.homeBar.budgetButton.model isKindOfClass:[SSJShareBookItem class]]) {
                return;
            }else{
                CGPoint currentPostion = CGPointMake(self.view.frame.size.width / 2, scrollView.contentOffset.y + 46);
                NSInteger currentSection = [self.tableView indexPathForRowAtPoint:currentPostion].section;
                SSJBookKeepingHomeListItem *listItem = [self.items objectAtIndex:currentSection];
                NSInteger currentMonth = [[listItem.date substringWithRange:NSMakeRange(5, 2)] integerValue];
                NSInteger currentYear = [[listItem.date substringWithRange:NSMakeRange(0, 4)] integerValue];
                if ((currentMonth != self.currentMonth || currentYear != self.currentYear) && ![self.homeBar.budgetButton.model isKindOfClass:[SSJShareBookItem class]]) {
                    self.currentYear = currentYear;
                    self.currentMonth = currentMonth;
                    [self reloadCurrentMonthData];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y <= - scrollView.contentInset.top) {
        if (!_dateViewHasDismiss) {
            [self updateTabbar];
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.items.count == 0  || [self.homeBar.budgetButton.model isKindOfClass:[SSJShareBookItem class]]) {
        return;
    }else{
        [self reloadCurrentMonthData];
    }
}

#pragma mark - SSJMultiFunctionButtonDelegate
- (void)multiFunctionButtonView:(SSJMultiFunctionButtonView *)buttonView willSelectButtonAtIndex:(NSUInteger)index{
    if (index == 1) {
        [SSJAnaliyticsManager event:@"main_to_top"];
        [self.tableView setContentOffset:CGPointMake(0, -46) animated:YES];
        [self.floatingDateView dismiss];
        [self.mutiFunctionButton dismiss];
    }else if (index == 2){
        [SSJAnaliyticsManager event:@"main_search"];
        SSJSearchingViewController *searchVC = [[SSJSearchingViewController alloc]init];
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) return;
    //图片编辑
    SSJThemBgImageClipViewController *imageClipVC = [[SSJThemBgImageClipViewController alloc] init];
    imageClipVC.normalImage = image;
    imageClipVC.clipImageBlock = ^(UIImage *newImage) {
        [SSJCustomThemeManager changeThemeWithLocalImage:newImage type:0];
        [self.themeModifyView show];
    };
    [self presentViewController:imageClipVC animated:YES completion:NULL];
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
        _tableView = [[SSJHomeTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
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
        _bookKeepingHeader.buttonWidth = self.homeButton.width;
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
            recordmakingVC.addNewChargeBlock = ^(NSArray *chargeIdArr ,BOOL hasChangeBooksType){
                weakSelf.newlyAddChargeArr = [NSMutableArray arrayWithArray:chargeIdArr];
                _hasChangeBooksType = hasChangeBooksType;
            };
            SSJNavigationController *recordNav = [[SSJNavigationController alloc]initWithRootViewController:recordmakingVC];
            [weakSelf presentViewController:recordNav animated:YES completion:NULL];
        };
    }
    return _homeButton;
}

-(SSJBookKeepingHomeNoDataHeader *)noDataHeader{
    if (!_noDataHeader) {
        _noDataHeader = [[SSJBookKeepingHomeNoDataHeader alloc]init];
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
        _homeBar.budgetButton.budgetButtonClickBlock = ^(id model){
            if (model == nil) {
                SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc]init];
                SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc] init];
                NSMutableArray *viewControllers = [weakSelf.navigationController.viewControllers mutableCopy];
                [viewControllers addObject:budgetListVC];
                [viewControllers addObject:budgetEditVC];
                [weakSelf.navigationController setViewControllers:viewControllers animated:YES];
            } else if ([model isKindOfClass:[SSJBudgetModel class]]) {
                SSJBudgetListViewController *budgetListVC = [[SSJBudgetListViewController alloc]init];
                [weakSelf.navigationController pushViewController:budgetListVC animated:YES];
            } else if ([model isKindOfClass:[SSJShareBookItem class]]) {
                SSJShareBooksMenberManagerViewController *memberVc = [[SSJShareBooksMenberManagerViewController alloc] init];
                [SSJAnaliyticsManager event:@"sb_home_member_count"];
                memberVc.item = model;
                [weakSelf.navigationController pushViewController:memberVc animated:YES];
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
        _evaluatePopView = [[SSJBookKeepingHomeEvaluatePopView alloc] initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, SSJSCREENHEIGHT)];
    }
    return _evaluatePopView;
}

- (SSJBookKeepingHomePopView *)keepingHomePopView
{
    if (!_keepingHomePopView) {
        _keepingHomePopView = [SSJBookKeepingHomePopView BookKeepingHomePopView];
    }
    return _keepingHomePopView;
}

- (SSJListMenu *)guidePopView {
    if (!_guidePopView) {
        _guidePopView = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 154, 50)];
        _guidePopView.maxDisplayRowCount = 1;
        _guidePopView.gapBetweenImageAndTitle = 0;
        _guidePopView.titleFont = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _guidePopView.backgroundColor = [UIColor clearColor];
        _guidePopView.fillColor = [UIColor ssj_colorWithHex:@"666666"];
        [_guidePopView addTarget:self action:@selector(guidePopViewClicked) forControlEvents:UIControlEventValueChanged];
    }
    return _guidePopView;
}

//- (SSJHomeBillStickyNoteView *)billStickyNoteView
//{
//    __weak typeof(self) weakSelf = self;
//    if (!_billStickyNoteView) {
//        _billStickyNoteView = [[SSJHomeBillStickyNoteView alloc] init];
//        _billStickyNoteView.closeBillNoteBlock = ^{
//            [weakSelf.view layoutIfNeeded];
//            [weakSelf.tableView setContentOffset:CGPointMake(0, -46)];
//        };
//        
////        _billStickyNoteView.openBillNoteBlock = ^{
////            //如果没有登录
////            if (!SSJIsUserLogined()) {
////                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"请登录后再查看2016账单吧！" action:[SSJAlertViewAction actionWithTitle:@"关闭" handler:^(SSJAlertViewAction *action) {
////                }],[SSJAlertViewAction actionWithTitle:@"立即登录" handler:^(SSJAlertViewAction *action) {
////                    SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
////                    [weakSelf.navigationController pushViewController:loginVC animated:YES];
////                }],nil];
////            }else{
////                //跳转2016账单
////                SSJBillNoteWebViewController *billVC = [[SSJBillNoteWebViewController alloc] init];
////                billVC.backButtonClickBlock = ^(){
////                    [weakSelf.tableView setContentOffset:CGPointMake(0, -46)];
////                };
////                billVC.hidesBottomBarWhenPushed = YES;
//////                [weakSelf.navigationController pushViewController:billVC animated:YES];
////                [weakSelf presentViewController:billVC animated:YES completion:nil];
////                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SSJShowBillNoteKey];
////                [[NSUserDefaults standardUserDefaults] synchronize];
//////                [weakSelf.billStickyNoteView removeFromSuperview];
////                [weakSelf.view layoutIfNeeded];
////            }
////        };
//    }
//    return _billStickyNoteView;
//}

- (SSJHomeThemeModifyView *)themeModifyView {
    __weak __typeof(self)weakSelf = self;
    if (!_themeModifyView) {
        _themeModifyView = [[SSJHomeThemeModifyView alloc] init];
        _themeModifyView.themeSelectBlock = ^(NSString *selectTheme, BOOL selectType){

        };
        _themeModifyView.themeSelectCustomImageBlock = ^(){
            //访问相册
            [weakSelf localPhoto];
            [SSJAnaliyticsManager event:@"more_define_bg_upload_image"];
        };
    }
    return _themeModifyView;
}

//选择相册
-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
//    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}


#pragma mark - Event
- (void)rightBarButtonClicked {
    SSJCalendarViewController *calendarVC = [[SSJCalendarViewController alloc] init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (void)leftBarButtonClicked:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        if (!_dateViewHasDismiss) {
            [self.floatingDateView dismiss];
            [self.mutiFunctionButton dismiss];
            _dateViewHasDismiss = YES;
        }
    }];
}

- (void)continueLoading {
    self.homeBar.isAnimating = YES;
    [UIView animateWithDuration:0.6 animations:^{
        self.homeBar.height = 110;
        self.bookKeepingHeader.top = self.homeBar.bottom;
        if (!SSJ_CURRENT_THEME.tabBarBackgroundImage.length) {
            self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - SSJ_TABBAR_HEIGHT);
        }else{
            self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom);
        } 
    } completion:^(BOOL finished) {
        
    }];
}

- (void)syncDidFail {
    [self stopLoading];
}

- (void)guidePopViewClicked {
    //[self.guidePopView dismiss];
}

#pragma mark - Private

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.bookKeepingHeader updateAfterThemeChange];
    [self.tableView updateAfterThemeChange];
    [self.homeButton updateAfterThemeChange];
    [self.homeBar updateAfterThemeChange];
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

- (void)getDataFromDataBase{
    __weak typeof(self) weakSelf = self;
    if (self.allowRefresh) {
        [self.tableView ssj_showLoadingIndicator];
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
            weakSelf.items = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJOrginalChargeArrKey]];
            weakSelf.newlyAddChargeArr = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJNewAddChargeArrKey]];
            weakSelf.newlyAddSectionArr = [[NSMutableArray alloc]initWithArray:[result objectForKey:SSJNewAddChargeSectionArrKey]];
            
            if (weakSelf.items.count) {
                self.noDataHeader.hidden = YES;
                self.tableView.hasData = YES;
                if (weakSelf.newlyAddChargeArr.count && !_hasChangeBooksType) {
                    
                    NSInteger maxSection = [weakSelf.tableView numberOfSections];
                    NSInteger rowCount = [weakSelf.tableView numberOfRowsInSection:maxSection];
                    NSIndexPath *currentMaxIndex = [NSIndexPath indexPathForRow:rowCount - 1 inSection:maxSection];
                                        
                    
                    BOOL needToReload = NO;
                    
                    for (SSJBillingChargeCellItem *item in weakSelf.newlyAddChargeArr) {
                        
                        if (item.operatorType == 0) {
                            [weakSelf.tableView beginUpdates];
                            if ([weakSelf.newlyAddSectionArr containsObject:@(item.chargeIndex.section)]) {
                                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:item.chargeIndex.section] withRowAnimation:UITableViewRowAnimationTop];
                            } else {
                                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:item.chargeIndex.section] withRowAnimation:UITableViewRowAnimationNone];
                            }

                            [self.tableView insertRowsAtIndexPaths:@[item.chargeIndex] withRowAnimation:UITableViewRowAnimationTop];
                            needToReload = [currentMaxIndex compare:item.chargeIndex] == NSOrderedAscending;
                            [weakSelf.tableView endUpdates];
                            
                            [weakSelf.tableView scrollToRowAtIndexPath:item.chargeIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];

                        } else {
                            [self.tableView reloadData];
                            [weakSelf.tableView scrollToRowAtIndexPath:item.chargeIndex atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        }
                    }
                    
                    if (needToReload) {
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[currentMaxIndex] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                    //                    [weakSelf.tableView endUpdates];
                    
                    
                    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                    
                    [self.newlyAddChargeArr removeAllObjects];
                } else {
                    [weakSelf.tableView reloadData];
                }
            } else {
                self.tableView.hasData = NO;
                self.noDataHeader.hidden = NO;
                [self.tableView reloadData];
            }
            
            [weakSelf.tableView ssj_hideLoadingIndicator];
        } failure:^(NSError *error) {
            [self.tableView ssj_hideLoadingIndicator];
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
            [self getDataFromDataBase];
        });
    } else {
        [self getDataFromDataBase];
    }
    [self stopLoading];
    [self updateTabbar];
    [self updateBooksItem];
    
    
}

- (void)reloadDataAfterInitDatabase {
    [self getDataFromDataBase];
    [self updateTabbar];
    [self updateBooksItem];
}

- (void)reloadAfterBooksTypeChange{
    _hasChangeBooksType = YES;
    [self getDataFromDataBase];
    [self updateTabbar];
    [self updateBooksItem];
}

- (void)updateTabbar {
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJBooksTypeStore queryCurrentBooksItemWithSuccess:^(id booksItem) {
            [subscriber sendNext:booksItem];
            [subscriber sendCompleted];
        } failure:^(NSError *error){
            [subscriber sendError:error];
        }];
        return nil;
    }] flattenMap:^RACStream *(id booksItem) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

            if ([booksItem isKindOfClass:[SSJBooksTypeItem class]]) {
                [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
                    [subscriber sendNext:result];
                    [subscriber sendCompleted];
                } failure:^(NSError * _Nonnull error) {
                    [subscriber sendError:error];
                }];
            } else if ([booksItem isKindOfClass:[SSJShareBookItem class]]){
                [subscriber sendNext:booksItem];
                [subscriber sendCompleted];
            }
            return nil;
        }];
    }] subscribeNext:^(id result) {
        if ([result isKindOfClass:[NSArray class]]) {
            [self updateBudgetWithModels:result];
        } else {
            self.homeBar.budgetButton.model = result;
        }

    } error:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];

    
}

- (void)updateBudgetWithModels:(NSArray *)models {
    [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
        self.homeBar.budgetButton.model = [models firstObject];
        for (int i = 0; i < models.count; i++) {
            SSJBudgetModel *model = [models objectAtIndex:i];
            NSArray *remindedBookTypes = _budgetRemindInfo[SSJUSERID()];
            
            if (model.isRemind
                && !model.isAlreadyReminded
                && ![remindedBookTypes containsObject:booksId]
                && (model.remindMoney >= model.budgetMoney - model.payMoney)
                && (![[UIApplication sharedApplication].keyWindow.subviews containsObject:self.evaluatePopView])
                && (![[UIApplication sharedApplication].keyWindow.subviews containsObject:self.keepingHomePopView])) {
                self.remindView.model = model;
                [self.remindView show];
                self.isBudgetOverrunsPopViewShow = YES;
                NSMutableArray *tmpRemindBookTypes = [remindedBookTypes mutableCopy];
                if (!tmpRemindBookTypes) {
                    tmpRemindBookTypes = [NSMutableArray array];
                }
                [tmpRemindBookTypes addObject:booksId];
                [_budgetRemindInfo setObject:tmpRemindBookTypes forKey:SSJUSERID()];
                
                break;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];

}

-(void)reloadWithAnimation{
    self.allowRefresh = YES;
    self.hasLoad = NO;
    [self getDataFromDataBase];
}

- (void)stopLoading {
    self.homeBar.isAnimating = NO;
    [UIView animateWithDuration:0.6 animations:^{
        self.homeBar.height = 64;
        self.bookKeepingHeader.top = self.homeBar.bottom;
        if (!SSJ_CURRENT_THEME.tabBarBackgroundImage.length) {
            self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom - SSJ_TABBAR_HEIGHT);
        }else{
            self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.bookKeepingHeader.bottom);
        }
    } completion:NULL];
}

- (void)whichViewShouldPopToHomeView
{
    
    //当前版本是否显示过弹框()
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:SSJEvaluateSelecatedKey] intValue];
    if(type == SSJEvaluateSelecatedTypeNotShowAgain && SSJLaunchTimesForCurrentVersion() <= 1){//更新新版本继续弹出,当前版本是第一次启动并且上一个版本选择了高冷无视更新为还未选择
        self.evaluatePopView.evaluateSelecatedType = SSJEvaluateSelecatedTypeUnKnow;
    }
    
    //1.定期登录提示
    if ([self.keepingHomePopView popLoginViewWithNav:self.navigationController backController:self] == YES) return;
    
    //2预算超支
    //3.退出登录后
    if ([SSJLoginPopView popIfNeededWithNav:self.navigationController backController:self] == YES) return;
    //4.评分
    if (self.isBudgetOverrunsPopViewShow == NO) {
        if ([self.evaluatePopView showEvaluatePopView] == YES) return;
    }
}


/**
 显示引导页（第一次启动app并且没有登录的时候）
 */
- (void)showGuildView {
//    if (SSJLaunchTimesForCurrentVersion() <= 1 && !SSJIsUserLogined()) {
//    SSJListMenuItem *listItem = [[SSJListMenuItem alloc] init];
//    listItem.title = @"点击这里即可记一笔账";
//    listItem.backgroundColor = [UIColor clearColor];
//    listItem.normalTitleColor = [UIColor whiteColor];
//        self.guidePopView.items = [NSMutableArray arrayWithObject:listItem];
//    __weak __typeof(self)weakSelf = self;
//        [self.guidePopView showInView:self.view atPoint:CGPointMake(SSJSCREENWITH * 0.5, self.homeButton.bottom) dismissHandle:^(SSJListMenu *listMenu) {
//            weakSelf.guidePopView = nil;
//            listItem.title = @"你的账本全在这里";
//            weakSelf.guidePopView.items = [NSMutableArray arrayWithObject:listItem];
//            [weakSelf.guidePopView showInView:self.view atPoint:CGPointMake(20, 64) dismissHandle:^(SSJListMenu *listMenu) {
//                
//            }];
//        }];
//    }
}

- (void)updateBooksItem {
    [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
        [SSJBooksTypeStore queryCurrentBooksItemWithSuccess:^(id result) {
            self.homeBar.leftButton.item = result;
        } failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

@end
