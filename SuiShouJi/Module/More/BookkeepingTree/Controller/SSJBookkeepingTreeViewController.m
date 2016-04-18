//
//  SSJBookkeepingTreeViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeViewController.h"
#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBookkeepingTreeHelper.h"
#import "FLAnimatedImage.h"
#import "SSJBookkeepingTreeHelpViewController.h"
#import "UIView+SSJViewAnimatioin.h"

#import "SSJBookkeepingTreeView.h"

@interface SSJBookkeepingTreeViewController ()

// 签到模型
@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

// 签到请求
@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

// 树图
@property (nonatomic, strong) SSJBookkeepingTreeView *treeView;

// 浇水成功提示
@property (nonatomic, strong) UIImageView *waterSuccessAlertView;

// 已经浇过水提示
@property (nonatomic, strong) UIImageView *alreadyWaterAlertView;

// 签到状态提示
@property (nonatomic, strong) UIImageView *checkInStateView;

@end

@implementation SSJBookkeepingTreeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"记账树";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help"] style:UIBarButtonItemStylePlain target:self action:@selector(checkHelpAction)];
    self.navigationItem.rightBarButtonItem = helpItem;
    
    NSError *error = nil;
    _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:&error];
    if (error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        return;
    }
    
    _treeView = [[SSJBookkeepingTreeView alloc] initWithFrame:self.view.bounds];
    _treeView.checkInModel = _checkInModel;
    [self.view addSubview:_treeView];
    
    _checkInStateView = [[UIImageView alloc] init];
    [self.view addSubview:_checkInStateView];
    
    [self updateCheckInStateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_checkInService cancel];
}

#pragma mark - UIResponder
- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event {
    [super motionBegan:motion withEvent:event];
    
    // 如果正在请求签到接口，直接返回
    if (_checkInService.isLoading) {
        return;
    }
    
    // 如果_checkInModel为nil，说明本地没有用户的签到记录，直接请求接口
    if (!_checkInModel) {
        [self.checkInService checkIn];
        return;
    }
    
    // 判断本地是否保存了今天的签到记录，如果没有保存，就请求接口
    NSDate *lastCheckInDate = [NSDate dateWithString:_checkInModel.lastCheckInDate formatString:@"yyyy-MM-dd"];
    if (![[NSDate date] isSameDay:lastCheckInDate]) {
        [self.checkInService checkIn];
        return;
    }
    
    // 今天已经浇过水
    if (_checkInModel.hasShaked) {
        [self showAlreadyWaterAlert];
        return;
    }
    
    // 没浇过水
    if ([self saveCheckInModel]) {
        self.checkInStateView.image = [UIImage imageNamed:@"tip_water_success"];
        [self showWaterSuccessAlert];
        [_treeView startRainning];
    }
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service != _checkInService) {
        return;
    }
    
    if ([_checkInService.returnCode isEqualToString:@"1"]) {
        // 签到成功，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        if ([self saveCheckInModel]) {
            self.checkInStateView.image = [UIImage imageNamed:@"tip_water_success"];
            [self showWaterSuccessAlert];
            [_treeView startRainning];
        }
    } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
        // 已经签过到，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        [self saveCheckInModel];
        [self showAlreadyWaterAlert];
        self.checkInStateView.image = [UIImage imageNamed:@"tip_already_water"];
    } else {
        // 签到失败
        [CDAutoHideMessageHUD showMessage:(service.desc.length > 0 ? service.desc : SSJ_ERROR_MESSAGE)];
    }
}

#pragma mark - Event
- (void)checkHelpAction {
    SSJBookkeepingTreeHelpViewController *helpVC = [[SSJBookkeepingTreeHelpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}

#pragma mark - Private
// 存储签到记录
- (BOOL)saveCheckInModel {
    _checkInModel.hasShaked = YES;
    if ([SSJBookkeepingTreeStore saveCheckInModel:_checkInModel error:nil]) {
        return YES;
    } else {
        // 保存失败
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        return NO;
    }
}

// 显示浇水成功弹窗提示
- (void)showWaterSuccessAlert {
    if (!_waterSuccessAlertView) {
        _waterSuccessAlertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"water_success_alert"]];
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [_waterSuccessAlertView popupInView:window completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_waterSuccessAlertView dismiss:NULL];
        });
    }];
}

// 显示已经浇过水弹窗提示
- (void)showAlreadyWaterAlert {
    if (!_alreadyWaterAlertView) {
        _alreadyWaterAlertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"already_water_alert"]];
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [_alreadyWaterAlertView popupInView:window completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_alreadyWaterAlertView dismiss:NULL];
        });
    }];
}

// 摇一摇签到的次数
- (NSInteger)shakedCheckInTimes {
    if (!_checkInModel) {
        return 0;
    }
    
    NSDate *lastCheckInDate = [NSDate dateWithString:_checkInModel.lastCheckInDate formatString:@"yyyy-MM-dd"];
    if ([[NSDate date] isSameDay:lastCheckInDate] && _checkInModel.hasShaked) {
        return _checkInModel.checkInTimes;
    }
    
    return MIN(_checkInModel.checkInTimes - 1, 0);
}

// 更新签到状态描述
- (void)updateCheckInStateView {
    if (!_checkInModel) {
        return;
    }
    
    NSDate *lastCheckInDate = [NSDate dateWithString:_checkInModel.lastCheckInDate formatString:@"yyyy-MM-dd"];
    if ([[NSDate date] isSameDay:lastCheckInDate] && _checkInModel.hasShaked) {
        // 已经浇过水
        self.checkInStateView.image = [UIImage imageNamed:@"tip_already_water"];
    } else {
        // 没浇过水
        self.checkInStateView.image = [UIImage imageNamed:@"tip_water"];
    }
    [self.checkInStateView sizeToFit];
    self.checkInStateView.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.2);
}

#pragma mark - Getter
- (SSJBookkeepingTreeCheckInService *)checkInService {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = YES;
    }
    return _checkInService;
}


@end
