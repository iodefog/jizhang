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
#import "SSJUserTableManager.h"

@interface SSJBookkeepingTreeViewController ()

// 签到模型
@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

// 签到请求
@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

// 树图
@property (nonatomic, strong) UIImageView *treeView;

// 浇水成功提示
@property (nonatomic, strong) UIImageView *waterSuccessAlertView;

// 已经浇过水提示
@property (nonatomic, strong) UIImageView *alreadyWaterAlertView;

// 虚线边框
@property (nonatomic, strong) UIImageView *dashLineView;

// 签到状态提示
@property (nonatomic, strong) UIImageView *checkInStateView;

// 签到描述
@property (nonatomic, strong) UILabel *checkInDescLab;

@property (nonatomic, copy) NSString *nickName;

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
    
    if (SSJIsUserLogined()) {
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"nickName"] forUserId:SSJUSERID()];
        _nickName = userItem.nickName;
    }
    
    [self.view addSubview:self.treeView];
    [self.view addSubview:self.checkInStateView];
    [self.view addSubview:self.dashLineView];
    [self.view addSubview:self.checkInDescLab];
    
    [self updateTree];
    [self updateCheckInStateView];
    [self updateCheckInDesc];
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.treeView.frame = self.view.bounds;
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
        [self updateTree];
        [self updateCheckInDesc];
        self.checkInStateView.image = [UIImage imageNamed:@"tip_water_success"];
        [self showWaterSuccessAlert];
        [self showWateringAnimation];
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
            [self updateTree];
            [self updateCheckInDesc];
            self.checkInStateView.image = [UIImage imageNamed:@"tip_water_success"];
            [self showWaterSuccessAlert];
            [self showWateringAnimation];
        }
    } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
        // 已经签过到，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        [self saveCheckInModel];
        [self showAlreadyWaterAlert];
        [self updateTree];
        [self updateCheckInDesc];
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

// 显示浇水动画
- (void)showWateringAnimation {
    NSString *gifName = [NSString stringWithFormat:@"%@.gif", [SSJBookkeepingTreeHelper treeImageNameForDays:[self shakedCheckInTimes]]];
    NSString *gifpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gifName];
    NSData *gifData = [NSData dataWithContentsOfFile:gifpath];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
    
    FLAnimatedImageView *rainingView = [[FLAnimatedImageView alloc] initWithFrame:self.view.bounds];
    rainingView.animatedImage = image;
    [self.view insertSubview:rainingView aboveSubview:self.treeView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [rainingView removeFromSuperview];
    });
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

// 更新记账树等级
- (void)updateTree {
    NSString *treeImageName = [SSJBookkeepingTreeHelper treeImageNameForDays:[self shakedCheckInTimes]];
    UIImage *treeImage = [UIImage ssj_compatibleImageNamed:treeImageName];
    self.treeView.image = treeImage;
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

// 更新签到信息描述
- (void)updateCheckInDesc {
    NSMutableString *desc = [@"Hi" mutableCopy];
    if (_nickName.length) {
        [desc appendFormat:@",%@~", _nickName];
    }
    [desc appendFormat:@"\n%@", [SSJBookkeepingTreeHelper descriptionForDays:[self shakedCheckInTimes]]];
    self.checkInDescLab.text = desc;
    [self.checkInDescLab sizeToFit];
    self.checkInDescLab.center = self.dashLineView.center;
}

#pragma mark - Getter
- (SSJBookkeepingTreeCheckInService *)checkInService {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = YES;
    }
    return _checkInService;
}

- (UIImageView *)treeView {
    if (!_treeView) {
        _treeView = [[UIImageView alloc] init];
    }
    return _treeView;
}

- (UIImageView *)checkInStateView {
    if (!_checkInStateView) {
        _checkInStateView = [[UIImageView alloc] init];
    }
    return _checkInStateView;
}

- (UIImageView *)dashLineView {
    if (!_dashLineView) {
        _dashLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dash_border"]];
        _dashLineView.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.78);
    }
    return _dashLineView;
}

- (UILabel *)checkInDescLab {
    if (!_checkInDescLab) {
        _checkInDescLab = [[UILabel alloc] init];
        _checkInDescLab.font = [UIFont systemFontOfSize:14];
        _checkInDescLab.textColor = [UIColor blackColor];
        _checkInDescLab.textAlignment = NSTextAlignmentCenter;
        _checkInDescLab.numberOfLines = 0;
    }
    return _checkInDescLab;
}

@end
