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
#import "SSJProductAdviceViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJSettingViewController.h"
#import "SSJAnnouncementsListViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJEncourageViewController.h"

#import "SSJMineHomeTableViewHeader.h"
#import "SSJNewMineHomeTabelviewCell.h"
#import "SSJMoreHomeAnnouncementButton.h"
#import "SSJMineHomeBannerHeader.h"

#import "SSJStartChecker.h"
#import "SSJMineHomeTableViewItem.h"
#import "SSJUserTableManager.h"
#import "SSJBannerNetworkService.h"

static NSString *const kTitle1 = @"记账提醒";
static NSString *const kTitle2 = @"主题皮肤";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"帮助与反馈";
static NSString *const kTitle5 = @"爱的鼓励";

static NSString * SSJNewMineHomeTabelviewCelldentifier = @"SSJNewMineHomeTabelviewCelldentifier";

static NSString * SSJNewMineHomeBannerHeaderdentifier = @"SSJNewMineHomeBannerHeaderdentifier";


@interface SSJNewMineHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *titles;

@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;

@property (nonatomic, strong) NSMutableArray *images;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) SSJMoreHomeAnnouncementButton *rightButton;

@property(nonatomic, strong) SSJBannerNetworkService *bannerService;

@property(nonatomic, strong) NSArray *bannerItems;

@property(nonatomic, strong) NSArray *listItems;

@property(nonatomic, strong) NSArray *announcements;

@end

@implementation SSJNewMineHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的";
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.images = [@[@[@"more_tixing"], @[@"more_pifu", @"more_zhouqi"],@[@"more_fankui", @"more_haoping"]] mutableCopy];
    self.titles = [@[@[kTitle1] , @[kTitle2 , kTitle3], @[kTitle4,kTitle5]] mutableCopy];
    self.items = [self defualtItems];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"more_setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonClicked:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    // Do any additional setup after loading the view.
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

    [self.bannerService requestBannersList];
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
    
    if ([item.title isEqualToString:kTitle1]) {
        SSJReminderViewController *BookkeepingReminderVC = [[SSJReminderViewController alloc]init];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    
    //主题
    if ([item.title isEqualToString:kTitle2]) {
        SSJThemeHomeViewController *themeVC = [[SSJThemeHomeViewController alloc]init];
        [self.navigationController pushViewController:themeVC animated:YES];
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
    }
    
    //建议与咨询
    if ([item.title isEqualToString:kTitle4]) {
        SSJProductAdviceViewController *adviceVC = [[SSJProductAdviceViewController alloc] init];
        [self.navigationController pushViewController:adviceVC animated:YES];
    }
    
    if ([item.title isEqualToString:kTitle5]) {
        SSJEncourageViewController *encourageVc = [[SSJEncourageViewController alloc] init];
        [self.navigationController pushViewController:encourageVc animated:YES];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.bannerItems.count && section == 0) {
        SSJMineHomeBannerHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SSJNewMineHomeBannerHeaderdentifier];
        @weakify(self);
        headerView.bannerView.tapAction = ^(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex) {
            @strongify(self);
            SSJBannerItem *item = [self.bannerItems ssj_safeObjectAtIndex:tapIndex];
            SSJAdWebViewController *webVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:item.bannerUrl]];
            [self.navigationController pushViewController:webVc animated:YES];
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
    [self sortPinnedBannerWithItems:self.bannerService.item.listAdItems];
    self.listItems = self.bannerService.item.listAdItems;
    self.bannerItems = self.bannerService.item.bannerItems;
    [self.tableView reloadData];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - SSJ_TABBAR_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.dataSource=self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.tableHeaderView = self.header;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView registerClass:[SSJNewMineHomeTabelviewCell class] forCellReuseIdentifier:SSJNewMineHomeTabelviewCelldentifier];
        [_tableView registerClass:[SSJMineHomeBannerHeader class] forHeaderFooterViewReuseIdentifier:SSJNewMineHomeBannerHeaderdentifier];
        [_tableView ssj_clearExtendSeparator];
        
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

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
                [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，登录后才能同步数据哦" action:[SSJAlertViewAction actionWithTitle:@"暂不同步" handler:NULL], [SSJAlertViewAction actionWithTitle:@"去登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                    [self login];
                }], nil];
            }
            return shouldSync;
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
    SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
        loginVc.finishHandle = ^(UIViewController *controller) {
        UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
        UINavigationController *navi = [tabVC.viewControllers firstObject];
        UIViewController *homeController = [navi.viewControllers firstObject];
        
        controller.backController = homeController;
        [controller ssj_backOffAction];
    };
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (void)leftButtonClicked:(id)sender {
    SSJSettingViewController *settingVC = [[SSJSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.rightButton updateAfterThemeChange];
    [self.header updateAfterThemeChange];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
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
        cellItem.image = item.imageUrl;
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
