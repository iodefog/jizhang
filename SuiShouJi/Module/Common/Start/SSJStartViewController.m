//
//  SSJStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartViewController.h"
#import "SSJServerLaunchView.h"
#import "SSJBookkeepingTreeView.h"
#import "SSJGuideView.h"
#import "SSJUserSignLaunchView.h"

#import "SSJStartChecker.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJStartLunchItem.h"

#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJUserSignNetworkService.h"

#import "SSJBookkeepingTreeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJUserTableManager.h"

// 请求启动接口超时时间
static const NSTimeInterval kLoadStartAPITimeout = 1;

// 请求签到接口超时时间
static const NSTimeInterval kLoadCheckInAPITimeout = 60;

// 加载服务器下发启动页超时时间
static const NSTimeInterval kLoadStartImgTimeout = 1;

// 加载记账树图片超时时间
static const NSTimeInterval kLoadTreeImgTimeout = 60;

// 启动页、记账树图片、引导页之间过渡时间
static const NSTimeInterval kTransitionDuration = 0.3;


@interface SSJStartViewController ()

@property (nonatomic, strong) SSJServerLaunchView *launchView;

//@property (nonatomic, strong) SSJBookkeepingTreeView *treeView;

@property (nonatomic, strong) SSJGuideView *guideView;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

/**启动页*/
@property (nonatomic, strong) SSJUserSignNetworkService *startLunchService;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

/**启动模型*/
@property (nonatomic, strong) SSJStartLunchItem *startLunchItem;

/**签名的启动页*/
@property (nonatomic, strong) SSJUserSignLaunchView *userSignLaunchView;


@end

@implementation SSJStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.launchView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestStartAPI];
    [self.startLunchService requestUserSign];
    
    // 如果没有本地签到表（升级新版本，数据库还没升级完成的情况下），不能请求签到接口
    // 如果没有userid，就不调用签到接口，签到接口需要userid（第一次启动初始化数据库未完成前，userid为空）
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db tableExists:@"bk_user_tree"] && SSJUSERID().length) {
            [self requestCheckIn];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Lazy
- (SSJUserSignNetworkService *)startLunchService {
    if (!_startLunchService) {
        _startLunchService = [[SSJUserSignNetworkService alloc] initWithDelegate:self];
        _startLunchService.timeoutInterval = 1;
    }
    return _startLunchService;
}

- (SSJUserSignLaunchView *)userSignLaunchView {
    if (!_userSignLaunchView) {
        _userSignLaunchView = [[SSJUserSignLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];

        @weakify(self);
        _userSignLaunchView.skipBtnBlock = ^(UIButton *btn) {

        };
    }
    return _userSignLaunchView;
}

- (SSJServerLaunchView *)launchView {
    if (!_launchView) {
        _launchView = [[SSJServerLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _launchView;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    
}


#pragma mark - Private
// 请求启动接口，检测是否有更新、苹果是否正在审核、
//加载下发启动页新版本删除
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithTimeoutInterval:kLoadStartAPITimeout success:^(BOOL isInReview, SSJAppUpdateType type) {
        //        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
        //        if (!startImgUrl) {
        //            [wself showGuideViewIfNeeded];
        //            return;
        //        }
        //
        //        [wself.launchView downloadImgWithUrl:startImgUrl timeout:kLoadStartImgTimeout completion:^{
        //            [wself showGuideViewIfNeededWithFirstView:self.launchView];
        //        }];
        
    } failure:^(NSString *message) {
        //        [wself showGuideViewIfNeeded];
    }];
}

// 请求签到接口
- (void)requestCheckIn {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = NO;
        _checkInService.timeoutInterval = kLoadCheckInAPITimeout;
    }
    [_checkInService checkIn];
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"请求签到接口"];
#endif
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
