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
#import "FLAnimatedImage.h"

@interface SSJBookkeepingTreeViewController ()

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

@property (nonatomic, strong) FLAnimatedImageView *imageView;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
    
    
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

#pragma mark - Private
- (void)shakeToCheckIn {
    
#warning test
    [self showWateringAnimation];
    
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
    NSString *gifName = [NSString stringWithFormat:@"%@.gif", [self treeName]];
    NSString *gifpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:gifName];
    NSData *gifData = [NSData dataWithContentsOfFile:gifpath];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
    self.imageView.animatedImage = image;
}

// 显示已经浇过水提示
- (void)showRemindView {
    
}

- (NSString *)treeName {
    if (_checkInModel.checkInTimes >= 0 && _checkInModel.checkInTimes <= 7) {
        return @"tree_level_1";
    } else if (_checkInModel.checkInTimes >= 8 && _checkInModel.checkInTimes <= 30) {
        return @"tree_level_2";
    } else if (_checkInModel.checkInTimes >= 31 && _checkInModel.checkInTimes <= 50) {
        return @"tree_level_3";
    } else if (_checkInModel.checkInTimes >= 51 && _checkInModel.checkInTimes <= 100) {
        return @"tree_level_4";
    } else if (_checkInModel.checkInTimes >= 101 && _checkInModel.checkInTimes <= 180) {
        return @"tree_level_5";
    } else if (_checkInModel.checkInTimes >= 181 && _checkInModel.checkInTimes <= 300) {
        return @"tree_level_6";
    } else if (_checkInModel.checkInTimes >= 301 && _checkInModel.checkInTimes <= 450) {
        return @"tree_level_7";
    } else if (_checkInModel.checkInTimes >= 451 && _checkInModel.checkInTimes <= 599) {
        return @"tree_level_8";
    } else if (_checkInModel.checkInTimes >= 600) {
        return @"tree_level_9";
    } else {
        return @"";
    }
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
        _imageView = [[FLAnimatedImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:[self treeName]]];
    }
    return _imageView;
}

@end
