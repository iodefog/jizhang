//
//  SSJNewMineHomeViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewMineHomeViewController.h"
#import "SSJPersonalDetailViewController.h"
#import "SSJBookkeepingTreeViewController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJReminderViewController.h"
#import "SSJCircleChargeSettingViewController.h"
#import "SSJThemeHomeViewController.h"
#import "SSJHelpAndAdviceViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJSettingViewController.h"
#import "SSJAnnouncementsListViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJEncourageViewController.h"
#import "SSJNavigationController.h"
#import "SSJQiuChengWebViewController.h"
#import "UIViewController+SSJMotionPassword.h"
#import "SSJWishStartViewController.h"
#import "SSJMakeWishViewController.h"
#import "SSJWishManageViewController.h"
#import "SSJAnnouncementWebViewController.h"

#import "SSJMineHomeTableViewHeader.h"
#import "SSJNewMineHomeTabelviewCell.h"
#import "SSJMoreHomeAnnouncementButton.h"
#import "SSJMineHomeBannerHeader.h"
#import "SSJScrollalbleAnnounceView.h"

#import "SSJStartChecker.h"
#import "SSJMineHomeTableViewItem.h"
#import "SSJUserTableManager.h"
#import "SSJBannerNetworkService.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJWishHelper.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJAnnoucementService.h"
#import "SSJMineHomeHeadLineService.h"

static NSString *const kTitle0 = @"心愿存钱";
static NSString *const kTitle1 = @"记账提醒";
static NSString *const kTitle2 = @"主题皮肤";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"帮助与反馈";
static NSString *const kTitle5 = @"爱的鼓励";

static NSString * SSJNewMineHomeTabelviewCelldentifier = @"SSJNewMineHomeTabelviewCelldentifier";

static NSString * SSJNewMineHomeBannerHeaderdentifier = @"SSJNewMineHomeBannerHeaderdentifier";


@interface SSJNewMineHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *titles;

@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;

@property (nonatomic, strong) NSMutableArray *images;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) SSJMoreHomeAnnouncementButton *rightButton;

@property(nonatomic, strong) SSJBannerNetworkService *bannerService;

@property(nonatomic, strong) SSJAnnoucementService *annoucementService;

@property(nonatomic, strong) NSArray *bannerItems;

@property(nonatomic, strong) NSArray *listItems;

@property(nonatomic, strong) NSArray *announcements;

@property (nonatomic, strong) SSJScrollalbleAnnounceView *announceView;

@property (nonatomic, strong) SSJMineHomeHeadLineService *headLineService;

@end

@implementation SSJNewMineHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
        }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.announceView];
    [self.view addSubview:self.tableView];
    self.images = [@[@[@"more_wish"],@[@"more_tixing"], @[@"more_pifu", @"more_zhouqi"],@[@"more_fankui", @"more_haoping"]] mutableCopy];
    self.titles = [@[@[kTitle0],@[kTitle1] , @[kTitle2 , kTitle3], @[kTitle4,kTitle5]] mutableCopy];
    self.items = [self defualtItems];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"more_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClicked:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.tableView.tableHeaderView = self.header;
    [self.tableView registerClass:[SSJNewMineHomeTabelviewCell class] forCellReuseIdentifier:SSJNewMineHomeTabelviewCelldentifier];
    [self.tableView registerClass:[SSJMineHomeBannerHeader class] forHeaderFooterViewReuseIdentifier:SSJNewMineHomeBannerHeaderdentifier];
    // Do any additional setup after loading the view.
    
    [self.headLineService requestHeadLines];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self ssj_remindUserToSetMotionPasswordIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @weakify(self);
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        @strongify(self);
        self.header.item = userItem;
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull checkInModel) {
        self.header.checkInLevel = [SSJBookkeepingTreeHelper treeLevelForDays:checkInModel.checkInTimes];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];

    [self.bannerService requestBannersList];
    
    [self.annoucementService requestAnnoucementsWithPage:1];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.height = self.view.height - SSJ_NAVIBAR_BOTTOM - SSJ_TABBAR_HEIGHT - self.announceView.height;
    self.tableView.top = self.announceView.bottom;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.bannerItems.count && section == 0) {
        return 110;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJMineHomeTableViewItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    
    if (item.toUrl.length) {
        SSJAdWebViewController *adWeb = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:item.toUrl]];
        [self.navigationController pushViewController:adWeb animated:YES];
        return;
    }
    
    //心愿存钱
    if ([item.title isEqualToString:kTitle0]) {
        if ([SSJWishHelper queryHasWishsWithError:nil]) {
            SSJWishManageViewController *wishManageVC = [[SSJWishManageViewController alloc] init];
            wishManageVC.showAnimation = NO;
            [self.navigationController pushViewController:wishManageVC animated:YES];
            return;
        }
        SSJWishStartViewController *wishStartVC = [[SSJWishStartViewController alloc] init];
        [self.navigationController pushViewController:wishStartVC animated:YES];
        return;
    }
    
    //记账提醒
    if ([item.title isEqualToString:kTitle1]) {
        SSJReminderViewController *BookkeepingReminderVC = [[SSJReminderViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    //主题
    if ([item.title isEqualToString:kTitle2]) {
        SSJThemeHomeViewController *themeVC = [[SSJThemeHomeViewController alloc]init];
        [self.navigationController pushViewController:themeVC animated:YES];
        return;
    }
    
    //  周期记账
    if ([item.title isEqualToString:kTitle3]) {
        if (SSJGetBooksCategory() == SSJBooksCategoryPersional) {
            SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
            return;
        } else if (SSJGetBooksCategory() == SSJBooksCategoryPublic) {
            [CDAutoHideMessageHUD showMessage:@"共享账本不能周期记账哦~"];
        }
        return;
    }
    
    //建议与咨询
    if ([item.title isEqualToString:kTitle4]) {
        SSJHelpAndAdviceViewController *adviceVC = [[SSJHelpAndAdviceViewController alloc] init];
        [self.navigationController pushViewController:adviceVC animated:YES];
        return;
    }
    
    //爱的鼓励
    if ([item.title isEqualToString:kTitle5]) {
        SSJEncourageViewController *encourageVc = [[SSJEncourageViewController alloc] init];
        [self.navigationController pushViewController:encourageVc animated:YES];
        //存储
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJLoveKey] == NO) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJLoveKey];//已经显示过
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        return;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.bannerItems.count && section == 0) {
        SSJMineHomeBannerHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SSJNewMineHomeBannerHeaderdentifier];
        @weakify(self);
        headerView.bannerView.tapAction = ^(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex) {
            @strongify(self);
            SSJBannerItem *item = [self.bannerItems ssj_safeObjectAtIndex:tapIndex];
            if (item.needLogin && !SSJIsUserLogined()) {
                SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
                SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVc];
                [self presentViewController:naviVC animated:YES completion:NULL];
            } else {
                if ([item.bannerId isEqualToString:@"10000"]) {
                    SSJQiuChengWebViewController *qiuchengWebVc = [[SSJQiuChengWebViewController alloc] init];
                    qiuchengWebVc.title = @"生财有道";
                    [self.navigationController pushViewController:qiuchengWebVc animated:YES];
                } else {
                    if (item.bannerType == 0) {
                        SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:item.bannerTarget]];
                         webVc.showPageTitleInNavigationBar = YES;
                        [self.navigationController pushViewController:webVc animated:YES];
                    }
                }

            }
        };
        headerView.items = self.bannerItems;
        return headerView;
    }
    UIView *clearView = [[UIView alloc] init];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJMineHomeTableViewItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    
    SSJNewMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:SSJNewMineHomeTabelviewCelldentifier];
    
    mineHomeCell.item = item;

    return mineHomeCell;

}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service == self.bannerService) {
        [self sortPinnedBannerWithItems:self.bannerService.item.listAdItems];
        self.listItems = self.bannerService.item.listAdItems;
        self.bannerItems = self.bannerService.item.bannerItems;
        [self.tableView reloadData];
    } else if (service == self.annoucementService){
        self.rightButton.hasNewAnnoucements = self.annoucementService.hasNewAnnouceMent;
    } else if (service == self.headLineService) {
        SSJHeadLineItem *headLine = [self.headLineService.headLines firstObject];
        if (headLine.headId != [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastReadHeadLineIdKey] || ![[NSUserDefaults standardUserDefaults] objectForKey:SSJLastReadHeadLineIdKey]) {
            self.announceView.item = headLine;
            self.announceView.height = 0;
            @weakify(self);
            [UIView animateWithDuration:0.7 animations:^{
                @strongify(self);
                SSJDispatch_main_async_safe(^{
                    self.announceView.height = 34;
                    self.announceView.hidden = NO;
                    self.tableView.top = self.announceView.bottom;
                    self.tableView.height = self.view.height - SSJ_NAVIBAR_BOTTOM - SSJ_TABBAR_HEIGHT - self.announceView.height;
                });
            }];
        }
    }
}

#pragma mark - Getter
-(SSJMineHomeTableViewHeader *)header {
    if (!_header) {
        @weakify(self);
        _header = [[SSJMineHomeTableViewHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 170)];
        _header.HeaderClickedBlock = ^(){
            @strongify(self);
            [self loginButtonClicked];
        };
        _header.checkInButtonClickBlock = ^(){
            @strongify(self);
            SSJBookkeepingTreeViewController *treeVC = [[SSJBookkeepingTreeViewController alloc] init];
            [self.navigationController pushViewController:treeVC animated:YES];
        };
        _header.shouldSyncBlock = ^BOOL() {
            @strongify(self);
            BOOL shouldSync = SSJIsUserLogined();
            
            if (!shouldSync) {
                [SSJAnaliyticsManager event:@"sync_tologin"];
                [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，登录后才能同步数据哦" action:[SSJAlertViewAction actionWithTitle:@"暂不同步" handler:NULL], [SSJAlertViewAction actionWithTitle:@"去登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                    [self login];
                }], nil];
                
                return NO;
            }
            return YES;
        };
    }
    return _header;
}

- (SSJBannerNetworkService *)bannerService {
    if (!_bannerService) {
        _bannerService = [[SSJBannerNetworkService alloc] initWithDelegate:self];
    }
    return _bannerService;
}

- (SSJMoreHomeAnnouncementButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[SSJMoreHomeAnnouncementButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        @weakify(self);
        _rightButton.buttonClickBlock = ^(){
            [SSJAnaliyticsManager event:@"youyu_message"];
            @strongify(self);
            SSJAnnouncementsListViewController *annoucementListVc = [[SSJAnnouncementsListViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
            annoucementListVc.items = [self.announcements mutableCopy];
//            annoucementListVc.totalPage = self.annoucementService.totalPage;
            
//            SSJTestViewController *annoucementListVc = [[SSJTestViewController alloc] init];
//
            [self.navigationController pushViewController:annoucementListVc animated:YES];
        };
    }
    return _rightButton;
}

- (SSJAnnoucementService *)annoucementService {
    if (!_annoucementService) {
        _annoucementService = [[SSJAnnoucementService alloc] initWithDelegate:self];
    }
    return _annoucementService;
}

- (SSJScrollalbleAnnounceView *)announceView {
    if (!_announceView) {
        _announceView = [[SSJScrollalbleAnnounceView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 0)];
        _announceView.hidden = YES;
        MJWeakSelf;
        _announceView.headLineClickedBlock = ^(SSJHeadLineItem *item) {
            //进入webview
            SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:item.target]];
            webVc.showPageTitleInNavigationBar = YES;
            [weakSelf.navigationController pushViewController:webVc animated:YES];
        };
        
        _announceView.headLineCloseBtnClickedBlock = ^(SSJHeadLineItem *item) {
            //停止计时器
            [weakSelf.announceView removeDisplayLink];
            //位置更改
            [UIView animateWithDuration:0.7 animations:^{
                SSJDispatch_main_async_safe(^{
                    weakSelf.announceView.height = 0;
                    weakSelf.announceView.hidden = YES;
                    weakSelf.tableView.top = weakSelf.announceView.bottom;
                    weakSelf.tableView.height = weakSelf.view.height - SSJ_NAVIBAR_BOTTOM - SSJ_TABBAR_HEIGHT - weakSelf.announceView.height;
                });
            } completion:^(BOOL finished) {
                [weakSelf.announceView removeFromSuperview];
            }];

        };
    }
    return _announceView;
}

- (SSJMineHomeHeadLineService *)headLineService {
    if (!_headLineService) {
        _headLineService = [[SSJMineHomeHeadLineService alloc] initWithDelegate:self];
    }
    return _headLineService;
}

#pragma mark - Event
- (void)loginButtonClicked {
    if (!SSJIsUserLogined()) {
        [self login];
    } else {
        SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc] init];
        [self.navigationController pushViewController:personalDetailVc animated:YES];
    }
}

- (void)login {
    __weak typeof(self) wself = self;
    SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
    loginVc.finishHandle = ^(UIViewController *controller) {
        wself.tabBarController.selectedIndex = 0;
    };
    SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVc];
    [self presentViewController:naviVC animated:YES completion:NULL];
}

- (void)leftButtonClicked:(id)sender {
    SSJSettingViewController *settingVC = [[SSJSettingViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.rightButton updateAfterThemeChange];
    [self.header updateAfterThemeChange];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)reloadDataAfterSync {
    @weakify(self);
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        @strongify(self);
        self.header.item = userItem;
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull checkInModel) {
        self.header.checkInLevel = [SSJBookkeepingTreeHelper treeLevelForDays:checkInModel.checkInTimes];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - Private
- (NSMutableArray *)defualtItems {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (NSArray *titles in self.titles) {
        NSInteger section = [self.titles indexOfObject:titles];
        NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *title in titles) {
            NSInteger row = [titles indexOfObject:title];
            SSJMineHomeTableViewItem *item = [[SSJMineHomeTableViewItem alloc] init];
            item.title = title;
            item.image = [self.images ssj_objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            [sectionArr addObject:item];
        }

        [tempArr addObject:sectionArr];
    }
    return tempArr;
}

- (void)sortPinnedBannerWithItems:(NSArray *)items {
    if (!items.count) {
        return;
    }

    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    for (SSJListAdItem *item in items) {
        SSJMineHomeTableViewItem *cellItem = [[SSJMineHomeTableViewItem alloc] init];
        cellItem.title = item.adTitle;
        cellItem.image = item.smallImage;
        cellItem.toUrl = item.url;
        [tempArr addObject:cellItem];
    }
    
    if (self.listItems.count) {
        [self.items replaceObjectAtIndex:0 withObject:tempArr];
    } else {
        [self.items insertObject:tempArr atIndex:0];
    }
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
