//
//  SSJStartView.m
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartView.h"
#import "SSJGuideView.h"
#import "SSJStartView.h"
#import "SSJStartChecker.h"
#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserTableManager.h"
#import "SSJBookkeepingTreeHelper.h"

static const NSTimeInterval kTransitionDuration = 0.3;

@interface SSJStartView () <SSJBaseNetworkServiceDelegate>

@property (nonatomic) BOOL isFirstLaunchForCurrentVersion;

@property (nonatomic) BOOL isServerStartViewShowed;

@property (nonatomic) BOOL hasCheckInTable;

@property (nonatomic, strong) NSURL *serverImageUrl;

@property (nonatomic, strong) UIImageView *defaultView;

@property (nonatomic, strong) UIImageView *startView;

@property (nonatomic, strong) SSJGuideView *guideView;

// 虚线边框
@property (nonatomic, strong) UIImageView *dashLineView;

@property (nonatomic, strong) UILabel *checkInDescLab;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

@property (nonatomic, copy) void (^completion)();

@end

@implementation SSJStartView

+ (void)showWithCompletion:(void(^)())completion {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    SSJStartView *startView = [[SSJStartView alloc] initWithFrame:window.bounds];
    startView.completion = completion;
    [window addSubview:startView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isFirstLaunchForCurrentVersion = SSJIsFirstLaunchForCurrentVersion();
        _isServerStartViewShowed = _isFirstLaunchForCurrentVersion;
        
        _defaultView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"default"]];
        _defaultView.frame = self.bounds;
        [self addSubview:_defaultView];
        
        [self requestStartAPI];
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
            _hasCheckInTable = [db tableExists:@"bk_user_tree"];
        }];
        if (_hasCheckInTable) {
            [self requestCheckIn];
        } else {
            // 如果当前版本第一次启动并且没有本地签到表（升级新版本，数据库还没升级完成的情况下），就直接显示引导页
            [self showGuideViewIfNeeded];
        }
        
        if (SSJIsUserLogined()) {
            SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"nickName"] forUserId:SSJUSERID()];
            _nickName = userItem.nickName;
        }
    }
    return self;
}

- (void)layoutSubviews {
    _defaultView.frame = self.bounds;
    _startView.frame = self.bounds;
    _guideView.frame = self.bounds;
}

- (void)dismiss {
    if (self.superview) {
        [UIView animateWithDuration:0.5f animations:^(void){
            self.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            self.alpha = 0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
            if (_completion) {
                _completion();
            }
        }];
    }
}

// 请求签到接口
- (void)requestCheckIn {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = NO;
    }
    [_checkInService checkIn];
}

// 请求启动接口，检测是否有更新、苹果是否正在审核、加载下发启动页
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
        // 有下发启动页，就显示；没有就显示记账树
        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
        if (startImgUrl.length) {
            _serverImageUrl = [NSURL URLWithString:startImgUrl];
        }
        
        [wself showStartViewIfNeeded];
        [wself showTreeViewIfNeeded];
    } failure:^(NSString *message) {
        [wself showTreeViewIfNeeded];
    }];
}

// 显示服务端下发的启动页
- (void)showStartViewIfNeeded {
    if (!_serverImageUrl || _isFirstLaunchForCurrentVersion) {
        return;
    }
    
    __weak typeof(self) wself = self;
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    manager.imageDownloader.downloadTimeout = 2;
    [manager downloadImageWithURL:_serverImageUrl options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image || error) {
            wself.isServerStartViewShowed = YES;
            [wself showTreeViewIfNeeded];
            return;
        }
        SSJDispatchMainSync(^{
            if (!wself.startView) {
                wself.startView = [[UIImageView alloc] initWithFrame:wself.bounds];
            }
            [wself addSubview:wself.startView];
            [UIView transitionWithView:wself.startView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                wself.startView.image = image;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    wself.isServerStartViewShowed = YES;
                    [wself showTreeViewIfNeeded];
                });
            }];
        });
    }];
}

// 显示记账树启动页
- (void)showTreeViewIfNeeded {
    if (!_checkInService.isLoaded) {
        return;
    }
    
    if (_isFirstLaunchForCurrentVersion) {
        [self showTreeView];
        return;
    }
    
    if (_isServerStartViewShowed) {
        [self showTreeView];
        return;
    }
}

- (void)showTreeView {
    [self updateCheckInDesc];
    
    [UIView transitionWithView:_defaultView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _defaultView.image = [UIImage imageNamed:[self treeName]];
        [self addSubview:self.dashLineView];
        [self addSubview:self.checkInDescLab];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showGuideViewIfNeeded];
        });
    }];
}

- (UIImageView *)dashLineView {
    if (!_dashLineView) {
        _dashLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dash_border"]];
        _dashLineView.center = CGPointMake(self.width * 0.5, self.height * 0.78);
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

// 当前版本第一次启动显示引导页
- (void)showGuideViewIfNeeded {
    if (_isFirstLaunchForCurrentVersion) {
        if (!_guideView) {
            _guideView = [[SSJGuideView alloc] initWithFrame:self.bounds];
        }
        __weak typeof(self) wself = self;
        _guideView.beginHandle = ^(SSJGuideView *guide) {
            [wself dismiss];
        };
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self addSubview:_guideView];
        } completion:NULL];
    } else {
        [self dismiss];
    }
}

// 返回记账树图片名称
- (NSString *)treeName {
    NSInteger checkTimes = _checkInModel.checkInTimes;
    if (checkTimes >= 0 && checkTimes <= 7) {
        return @"tree_level_1";
    } else if (checkTimes >= 8 && checkTimes <= 30) {
        return @"tree_level_2";
    } else if (checkTimes >= 31 && checkTimes <= 50) {
        return @"tree_level_3";
    } else if (checkTimes >= 51 && checkTimes <= 100) {
        return @"tree_level_4";
    } else if (checkTimes >= 101 && checkTimes <= 180) {
        return @"tree_level_5";
    } else if (checkTimes >= 181 && checkTimes <= 300) {
        return @"tree_level_6";
    } else if (checkTimes >= 301 && checkTimes <= 450) {
        return @"tree_level_7";
    } else if (checkTimes >= 451 && checkTimes <= 599) {
        return @"tree_level_8";
    } else if (checkTimes >= 600) {
        return @"tree_level_9";
    } else {
        return @"";
    }
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

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service == _checkInService) {
        // 1：签到成功 2：已经签过到 else：签到失败
        if ([_checkInService.returnCode isEqualToString:@"1"]) {
            
            _checkInModel = _checkInService.checkInModel;
            [SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil];
            
        } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
            
            // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
            _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
            if (![_checkInModel.lastCheckInDate isEqualToString:_checkInService.checkInModel.lastCheckInDate]) {
                _checkInModel = _checkInService.checkInModel;
                [SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil];
            }
            
        } else {
            // 根据本地保存的签到记录，显示记账树等级
            _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
        }
        
        [self showTreeViewIfNeeded];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    if (service == _checkInService) {
        _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
        [self showTreeViewIfNeeded];
    }
}

@end
