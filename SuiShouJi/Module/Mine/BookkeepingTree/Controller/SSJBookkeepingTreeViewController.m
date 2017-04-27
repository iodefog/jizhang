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
#import "SSJBookkeepingTreeHelpViewController.h"
#import "UIView+SSJViewAnimatioin.h"
#import "SSJBookkeepingTreeView.h"
#import "SSJBookkeepingTreeHelper.h"
#import "CDPointActivityIndicator.h"
#import <CoreMotion/CoreMotion.h>
#import "SSJNetworkReachabilityManager.h"

@interface SSJBookkeepingTreeViewController ()

// 签到模型
@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

// 签到请求
@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

// 树图
@property (nonatomic, strong) SSJBookkeepingTreeView *treeView;

// 已经浇过水提示
@property (nonatomic, strong) UIImageView *alertView;

// 签到状态提示
@property (nonatomic, strong) UIImageView *checkInStateView;

@property (nonatomic, strong) UILabel *checkInStateLab;

@property (nonatomic) BOOL isViewSetuped;

@property (nonatomic, strong) CMMotionManager *motionManager;

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
    
    if ([self requestIfNeeded]) {
        return;
    }
    
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateNavigationBar];
    [self beginMotionUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [CDPointActivityIndicator stopAnimating];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        [_checkInService cancel];
    }
    
    [_motionManager stopDeviceMotionUpdates];
}

//#pragma mark - UIResponder
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event {
//    [super motionBegan:motion withEvent:event];
//    
//    [SSJAnaliyticsManager event:@"account_tree_shake"];
//    // 如果正在请求签到接口，直接返回
//    if (_checkInService.isLoading) {
//        return;
//    }
//    
//    // 今天已经浇过水
//    if (_checkInModel.hasShaked) {
//        [self showAlreadyWaterAlert];
//        return;
//    }
//    
//    // 没浇过水
//    _checkInModel.hasShaked = YES;
//    if ([self saveCheckInModel]) {
//        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_checkInModel.treeGifUrl finish:^(NSData *data, BOOL success) {
//            if (success) {
//                [SSJAnaliyticsManager event:@"account_tree_sign"];
//                [_treeView startRainWithGifData:data completion:^{
//                    _checkInStateLab.text = @"Yeah,浇水成功啦！";
//                    [self showWaterSuccessAlert];
//                }];
//            } else {
//                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
//            }
//        }];
//    }
//}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidStart:(SSJBaseNetworkService *)service {
    [super serverDidStart:service];
    [CDPointActivityIndicator startAnimating];
}

- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    
    if ([_checkInService.returnCode isEqualToString:@"1"]) {
        // 签到成功，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        _checkInModel.hasShaked = NO;
        [self setupView];
        [self saveCheckInModel];
    } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
        // 已经签过到，保存签到结果
        _checkInModel = _checkInService.checkInModel;
        _checkInModel.hasShaked = YES;
        [self setupView];
        [self saveCheckInModel];
    } else {
        // 签到失败
        [CDAutoHideMessageHUD showMessage:(service.desc.length > 0 ? service.desc : SSJ_ERROR_MESSAGE)];
    }
}

- (void)serverDidCancel:(SSJBaseNetworkService *)service {
    [super serverDidCancel:service];
    [CDPointActivityIndicator stopAnimating];
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    [super server:service didFailLoadWithError:error];
    [CDPointActivityIndicator stopAnimating];
}

#pragma mark - Event
- (void)checkHelpAction {
    SSJBookkeepingTreeHelpViewController *helpVC = [[SSJBookkeepingTreeHelpViewController alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}

- (void)beginMotionUpdate {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    if(!_motionManager.deviceMotionActive && _motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                                                CGFloat devicevalue = 1.3;
                                                CMAcceleration acceleration = deviceMotion.userAcceleration;
                                                
                                                CMAcceleration a ;
                                                a.x = ABS(acceleration.x);
                                                a.y = ABS(acceleration.y);
                                                a.z = ABS(acceleration.z);
                                                
                                                static BOOL shouldStartMotion = YES;
                                                if ((a.x>devicevalue &&a.x<10)||a.y>devicevalue||a.z>devicevalue){
                                                    if (shouldStartMotion){
                                                        shouldStartMotion = NO;
                                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                            shouldStartMotion = YES;
                                                        });
                                                        [self startMotion];
                                                    }
                                                }
                                            }];
    }
}

- (void)startMotion {
    [SSJAnaliyticsManager event:@"account_tree_shake"];
    // 如果正在请求签到接口，直接返回
    if (_checkInService.isLoading) {
        return;
    }
    
    // 今天已经浇过水
    if (_checkInModel.hasShaked) {
        [self showAlreadyWaterAlert];
        return;
    }
    
    // 没浇过水
    _checkInModel.hasShaked = YES;
    if ([self saveCheckInModel]) {
        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_checkInModel.treeGifUrl finish:^(NSData *data, BOOL success) {
            if (success) {
                [SSJAnaliyticsManager event:@"account_tree_sign"];
                [_treeView startRainWithGifData:data completion:^{
                    _checkInStateLab.text = @"Yeah,浇水成功啦！";
                    [self showWaterSuccessAlert];
                }];
            } else {
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }
        }];
    }
}

#pragma mark - Private
- (void)setupView {
    [CDPointActivityIndicator startAnimating];
    [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:_checkInModel.treeImgUrl finish:^(UIImage *image, BOOL success) {
        if (!success) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            [CDPointActivityIndicator stopAnimating];
            return;
        }
        
        if (_checkInModel.hasShaked) {
            [CDPointActivityIndicator stopAnimating];
            
            if (!_treeView) {
                _treeView = [[SSJBookkeepingTreeView alloc] initWithFrame:self.view.bounds];
                [_treeView setMuteButtonShowed:YES];
                [self.view addSubview:_treeView];
            }
            [_treeView setTreeImg:image];
            [_treeView setCheckTimes:_checkInModel.checkInTimes];
            
            if (!self.checkInStateView.superview) {
                [self.view addSubview:self.checkInStateView];
            }
            if (!self.checkInStateLab.superview) {
                [self.view addSubview:self.checkInStateLab];
            }
            _checkInStateLab.text = _checkInModel.hasShaked ? @"主人，您今天已经浇过水啦！" : @"签到摇一摇，来浇浇水吧～";
            _isViewSetuped = YES;
            [self updateNavigationBar];
            return;
        }
        
        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_checkInModel.treeGifUrl finish:^(NSData *data, BOOL success) {
            [CDPointActivityIndicator stopAnimating];
            if (success) {
                if (!_treeView) {
                    _treeView = [[SSJBookkeepingTreeView alloc] initWithFrame:self.view.bounds];
                    [self.view addSubview:_treeView];
                }
                [_treeView setTreeImg:image];
                [_treeView setCheckTimes:_checkInModel.checkInTimes];
                
                if (!self.checkInStateView.superview) {
                    [self.view addSubview:self.checkInStateView];
                }
                if (!self.checkInStateLab.superview) {
                    [self.view addSubview:self.checkInStateLab];
                }
                _checkInStateLab.text = _checkInModel.hasShaked ? @"主人，您今天已经浇过水啦！" : @"签到摇一摇，来浇浇水吧～";
                _isViewSetuped = YES;
                [self updateNavigationBar];
            } else {
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }
        }];
    }];
}

- (BOOL)requestIfNeeded {
    // 如果_checkInModel为nil，说明本地没有用户的签到记录，直接请求接口
    if (!_checkInModel) {
        if ([SSJNetworkReachabilityManager isReachable]) {
            [self.checkInService checkIn];
        } else {
            [self showNoNetworkAlert];
        }
        return YES;
    }
    
    // 判断本地是否保存了今天的签到记录，如果没有保存，就请求接口
    NSDate *lastCheckInDate = [NSDate dateWithString:_checkInModel.lastCheckInDate formatString:@"yyyy-MM-dd"];
    if (![[NSDate date] isSameDay:lastCheckInDate]) {
        if ([SSJNetworkReachabilityManager isReachable]) {
            [self.checkInService checkIn];
        } else {
            [self showNoNetworkAlert];
        }
        return YES;
    }
    
    return NO;
}

// 存储签到记录
- (BOOL)saveCheckInModel {
    if ([SSJBookkeepingTreeStore saveCheckInModel:_checkInModel error:nil]) {
        return YES;
    } else {
        // 保存失败
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        return NO;
    }
}

- (UIImageView *)alertView {
    if (!_alertView) {
        _alertView = [[UIImageView alloc] init];
    }
    return _alertView;
}

// 显示浇水成功弹窗提示
- (void)showWaterSuccessAlert {
    self.alertView.image = [UIImage imageNamed:@"water_success_alert"];
    [self.alertView sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self.alertView ssj_popupInView:window completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertView ssj_dismiss:NULL];
        });
    }];
}

// 显示已经浇过水弹窗提示
- (void)showAlreadyWaterAlert {
    self.alertView.image = [UIImage imageNamed:@"already_water_alert"];
    [self.alertView sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self.alertView ssj_popupInView:window completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertView ssj_dismiss:NULL];
        });
    }];
}

// 显示没有网络连接提示
- (void)showNoNetworkAlert {
    self.alertView.image = [UIImage imageNamed:@"no_network_alert"];
    [self.alertView sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self.alertView ssj_popupInView:window completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertView ssj_dismiss:NULL];
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

- (void)updateNavigationBar {
    if (_isViewSetuped) {
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
    } else {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    }
}

#pragma mark - Getter
- (SSJBookkeepingTreeCheckInService *)checkInService {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = NO;
        _checkInService.showMessageIfErrorOccured = NO;
    }
    return _checkInService;
}

- (UIImageView *)checkInStateView {
    if (!_checkInStateView) {
        UIImage *img = [[UIImage imageNamed:@"check_state_bg"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        _checkInStateView = [[UIImageView alloc] initWithImage:img];
        _checkInStateView.frame = CGRectMake(0, self.navigationController.navigationBar.bottom, self.view.width, 40);
    }
    return _checkInStateView;
}

- (UILabel *)checkInStateLab {
    if (!_checkInStateLab) {
        _checkInStateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bottom, self.view.width, 40)];
        _checkInStateLab.backgroundColor = [UIColor clearColor];
        _checkInStateLab.font = [UIFont systemFontOfSize:16];
        _checkInStateLab.textColor = [UIColor ssj_colorWithHex:@"468f1b"];
        _checkInStateLab.textAlignment = NSTextAlignmentCenter;
    }
    return _checkInStateLab;
}

@end
