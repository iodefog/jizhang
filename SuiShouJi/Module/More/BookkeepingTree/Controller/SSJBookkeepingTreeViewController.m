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

@interface SSJBookkeepingTreeViewController ()

// 签到模型
@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

// 签到请求
@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

// 下雨gif图
@property (nonatomic, strong) FLAnimatedImageView *imageView;

// 浇水成功提示
@property (nonatomic, strong) UIImageView *waterSuccessAlertView;

// 已经浇过水提示
@property (nonatomic, strong) UIImageView *alreadyWaterAlertView;

@end

@implementation SSJBookkeepingTreeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"记账树";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error = nil;
    _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:&error];
    if (error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    } else {
        [self.view addSubview:self.imageView];
    }
    
    UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStylePlain target:self action:@selector(checkHelpAction)];
    self.navigationItem.rightBarButtonItem = helpItem;
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
    self.imageView.frame = self.view.bounds;
}

#pragma mark - UIResponder
- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event {
    [super motionBegan:motion withEvent:event];
    [self shakeToCheckIn];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    
    if (service != _checkInService) {
        return;
    }
    
    if ([_checkInService.returnCode isEqualToString:@"1"]) {
        // 签到成功，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        if ([self saveCheckInModel]) {
            [self showWateringAnimation];
        }
        
    } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
        // 已经签过到，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        [self saveCheckInModel];
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
- (void)shakeToCheckIn {
    
    // 如果正在请求签到接口，直接返回
    if (_checkInService.isLoading) {
        return;
    }
    
    // 判断本地是否保存了今天的签到记录，如果保存了，就根据hasShaked是否浇过水
    NSDate *lastCheckInDate = [NSDate dateWithString:_checkInModel.lastCheckInDate formatString:@"yyyy-MM-dd"];
    if ([[NSDate date] isSameDay:lastCheckInDate]) {
        // 已经浇过水
        if (_checkInModel.hasShaked) {
            [self showRemindView];
            return;
        }
        
        // 没浇过水
        if ([self saveCheckInModel]) {
            [self showWateringAnimation];
        }
        return;
    }
    
    // 本地没有保存今天的签到记录，先请求签到接口
    [self.checkInService checkIn];
}

- (BOOL)saveCheckInModel {
    _checkInModel.hasShaked = YES;
    if ([SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil]) {
        return YES;
    } else {
        // 保存失败
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        return NO;
    }
}

// 显示浇水动画
- (void)showWateringAnimation {
    NSString *gifName = [NSString stringWithFormat:@"%@.gif", [SSJBookkeepingTreeHelper treeImageNameForDays:_checkInModel.checkInTimes]];
    NSString *gifpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gifName];
    NSData *gifData = [NSData dataWithContentsOfFile:gifpath];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
    self.imageView.animatedImage = image;
}

// 显示已经浇过水提示
- (void)showRemindView {
    if (!_waterSuccessAlertView) {
        _waterSuccessAlertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"water_success_alert"]];
    }
//    if (!self.superview) {
//        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//        [keyWindow addSubview:self.backgroundView];
//        [keyWindow addSubview:self];
//        self.center = CGPointMake(keyWindow.width * 0.5, keyWindow.height * 0.5);
//        self.transform = CGAffineTransformMakeScale(0, 0);
//        
//        [UIView animateKeyframesWithDuration:0.36 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
//                self.transform = CGAffineTransformMakeScale(0.7, 0.7);
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
//                self.transform = CGAffineTransformMakeScale(0.9, 0.9);
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
//                self.transform = CGAffineTransformMakeScale(1.2, 1.2);
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
//                self.transform = CGAffineTransformMakeScale(1, 1);
//            }];
//        } completion:NULL];
//    }
}

#pragma mark - Getter
- (SSJBookkeepingTreeCheckInService *)checkInService {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = YES;
    }
    return _checkInService;
}

- (FLAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[FLAnimatedImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:[SSJBookkeepingTreeHelper treeImageNameForDays:_checkInModel.checkInTimes]]];
    }
    return _imageView;
}

@end
