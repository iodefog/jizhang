//
//  SSJSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSettingViewController.h"
#import "SSJSyncSettingViewController.h"
#import "SSJMagicExportViewController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJClearDataViewController.h"
#import "SSJBindMobileNoViewController.h"
#import "SSJMobileNoBindingDetailViewController.h"
#import "SSJSettingPasswordViewController.h"
#import "SSJNavigationController.h"

#import "SSJMineHomeTabelviewCell.h"

#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJLocalNotificationHelper.h"
#import <LocalAuthentication/LocalAuthentication.h>

static const CGFloat kLogoutButtonHeight = 44;

static NSString *const kBindMobileNoTitle = @"手机绑定";
static NSString *const kMobileNoTitle = @"手机号";
static NSString *const kModifyPwdTitle = @"修改密码";
static NSString *const kFingerPrintPwdTitle = @"指纹密码";
static NSString *const kMotionPwdTitle = @"手势密码";
static NSString *const kMagicExportTitle = @"数据导出";
static NSString *const kDataSyncTitle = @"数据同步";
static NSString *const kClearDataTitle = @"清理数据";


@interface SSJSettingViewController ()

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *titles;

@property (nonatomic, strong) UISwitch *fingerPrintPwdCtrl;

@property (nonatomic, strong) UISwitch *motionPwdCtrl;

@property (nonatomic, strong) UIButton *logoutBtn;

@property (nonatomic, strong) LAContext *context;

@end

@implementation SSJSettingViewController

#pragma mark - Lifecycle
- (void)dealloc {
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"设置";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (SSJIsUserLogined()) {
        [self.view addSubview:self.logoutBtn];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kLogoutButtonHeight, 0);
    }
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reorganiseDatas];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.logoutBtn.frame = CGRectMake(0, self.view.height - kLogoutButtonHeight, self.view.width, kLogoutButtonHeight);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
    // 只有清除数据不需要用户登录，其他操作均要求登录
    if (![title isEqualToString:kClearDataTitle]
        && !SSJIsUserLogined()) {
        [self login];
        return;
    }
    
    if ([title isEqualToString:kBindMobileNoTitle]) {// 手机绑定
        SSJBindMobileNoViewController *bindVC = [[SSJBindMobileNoViewController alloc] init];
        [self.navigationController pushViewController:bindVC animated:YES];
    } else if ([title isEqualToString:kMobileNoTitle]) {// 手机号
        SSJMobileNoBindingDetailViewController *mobileNoDetailVC = [[SSJMobileNoBindingDetailViewController alloc] init];
        [self.navigationController pushViewController:mobileNoDetailVC animated:YES];
    } else if ([title isEqualToString:kModifyPwdTitle]) {// 修改密码
        SSJSettingPasswordViewController *modifyPwdVC = [[SSJSettingPasswordViewController alloc] init];
        modifyPwdVC.mobileNo = self.userItem.mobileNo;
        modifyPwdVC.type = SSJSettingPasswordTypeResettingPassword;
        [self.navigationController pushViewController:modifyPwdVC animated:YES];
    } else if ([title isEqualToString:kMagicExportTitle]) {// 数据导出
        SSJMagicExportViewController *magicExportVC = [[SSJMagicExportViewController alloc] init];
        [self.navigationController pushViewController:magicExportVC animated:YES];
    } else if ([title isEqualToString:kDataSyncTitle]) {// 数据同步
        SSJSyncSettingViewController *syncSettingVC = [[SSJSyncSettingViewController alloc] init];
        [self.navigationController pushViewController:syncSettingVC animated:YES];
    } else if ([title isEqualToString:kClearDataTitle]) {// 清除数据
        SSJClearDataViewController *clearDataVC = [[SSJClearDataViewController alloc] init];
        [self.navigationController pushViewController:clearDataVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    mineHomeCell.cellTitle = title;
    
    if ([title isEqualToString:kBindMobileNoTitle]) {
        mineHomeCell.cellDetail = @"去绑定";
    } else if ([title isEqualToString:kMobileNoTitle]) {
        if (self.userItem.mobileNo.length >= 7) {
            mineHomeCell.cellDetail = [self.userItem.mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        } else {
            mineHomeCell.cellDetail = self.userItem.mobileNo;
        }
    } else {
        mineHomeCell.cellDetail = nil;
    }
    
    if ([title isEqualToString:kFingerPrintPwdTitle]) {
        mineHomeCell.accessoryView = self.fingerPrintPwdCtrl;
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryNone;
        mineHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([title isEqualToString:kMotionPwdTitle]) {
        mineHomeCell.accessoryView = self.motionPwdCtrl;
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryNone;
        mineHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        mineHomeCell.accessoryView = nil;
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        mineHomeCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    }
    
    return mineHomeCell;
}

#pragma mark - Private
- (void)reorganiseDatas {
    @weakify(self);
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (SSJIsUserLogined()) {
            [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                self.userItem = userItem;
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        } else {
            [subscriber sendCompleted];
        }
        return nil;
    }] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        @strongify(self);
        
        BOOL hasBindMobileNo = SSJIsUserLogined() && self.userItem.mobileNo.length > 0;
        NSArray *section1 = hasBindMobileNo ? @[kMobileNoTitle, kModifyPwdTitle] : @[kBindMobileNoTitle];
        
        BOOL supportTouchID = NO;
        NSError *error = nil;
        NSArray *section2 = @[kFingerPrintPwdTitle, kMotionPwdTitle];
        if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            section2 = @[kFingerPrintPwdTitle, kMotionPwdTitle];
            supportTouchID = YES;
        } else {
            switch (error.code) {
                case LAErrorTouchIDNotEnrolled: // 没有录入指纹
                    section2 = @[kFingerPrintPwdTitle, kMotionPwdTitle];
                    break;
                    
                case LAErrorTouchIDNotAvailable: // 设备不支持指纹
                    section2 = @[kMotionPwdTitle];
                    break;
                    
                default:
                    break;
            }
        }
        
        NSArray *section3 = @[kMagicExportTitle, kDataSyncTitle, kClearDataTitle];
        self.titles = @[section1, section2, section3];
        [self.tableView reloadData];
        
        if (SSJIsUserLogined()) {
            self.fingerPrintPwdCtrl.on = [self.userItem.fingerPrintState boolValue] && supportTouchID;
            self.motionPwdCtrl.on = [self.userItem.motionPWDState boolValue] && self.userItem.motionPWD.length;
        } else {
            self.fingerPrintPwdCtrl.on = NO;
            self.motionPwdCtrl.on = NO;
        }
    }];
}

- (void)login {
    SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
    SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVc];
    [self presentViewController:naviVC animated:YES completion:NULL];
}

- (void)logout {
    __weak typeof(self) weakSelf = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"退出登录后,后续记账请登录同个帐号哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
        // 退出登陆后强制同步一次
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            NSData *currentUserData = [NSKeyedArchiver archivedDataWithRootObject:userItem];
            [[NSUserDefaults standardUserDefaults] setObject:currentUserData forKey:SSJLastLoggedUserItemKey];
        } failure:NULL];
        
        NSString *userID = SSJUSERID();
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type) {
            // 同步后会注册提醒通知，所以同步成功后要取消注册的通知
            [SSJLocalNotificationHelper cancelLocalNotificationWithUserId:userID];
        } failure:NULL];
        
        SSJClearLoginInfo();
        //清除当前账本类型
        clearCurrentBooksCategory();
        [SSJUserTableManager reloadUserIdWithSuccess:^{
            [weakSelf.tableView reloadData];
            [SSJAnaliyticsManager loginOut];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithUserId:SSJUSERID() success:NULL failure:NULL];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }], nil];
}

- (void)settingMotionPwd {
    SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
    motionPasswordVC.type = SSJMotionPasswordViewControllerTypeSetting;
    [self.navigationController pushViewController:motionPasswordVC animated:YES];
}

- (void)updateAppearance {
    [self.logoutBtn ssj_setBorderColor:SSJ_BORDER_COLOR];
    [self.logoutBtn setTitleColor:SSJ_MAIN_COLOR forState:UIControlStateNormal];
    self.logoutBtn.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

#pragma mark - Getter
- (UISwitch *)fingerPrintPwdCtrl {
    if (!_fingerPrintPwdCtrl) {
        _fingerPrintPwdCtrl = [[UISwitch alloc] init];
        @weakify(self);
        [[_fingerPrintPwdCtrl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *ctrl) {
            @strongify(self);
            if (!SSJIsUserLogined()) {
                [self login];
            } else if (ctrl.on) {
                [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按住Home键验证指纹解锁" reply:^(BOOL success, NSError * _Nullable error) {
                    self.context = nil;
                    SSJDispatchMainSync(^{
                        if (success) {
                            self.userItem.fingerPrintState = @"1";
                            [SSJUserTableManager saveUserItem:self.userItem success:NULL failure:^(NSError * _Nonnull error) {
                                [SSJAlertViewAdapter showError:error];
                            }];
                        } else {
                            if (error.code == LAErrorTouchIDNotEnrolled) {
                                [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"您尚未设置Touch ID，请在系统设置中添加指纹" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL], nil];
                            }
                            ctrl.on = NO;
                        }
                    });
                }];
            } else {
                self.userItem.fingerPrintState = @"0";
                [SSJUserTableManager saveUserItem:self.userItem success:NULL failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
            }
        }];
    }
    return _fingerPrintPwdCtrl;
}

- (UISwitch *)motionPwdCtrl {
    if (!_motionPwdCtrl) {
        _motionPwdCtrl = [[UISwitch alloc] init];
        @weakify(self);
        [[_motionPwdCtrl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *ctrl) {
            @strongify(self);
            if (!SSJIsUserLogined()) {
                [self login];
            } else if (ctrl.on) {
                [self settingMotionPwd];
            } else {
                self.userItem.motionPWDState = [NSString stringWithFormat:@"%d", NO];
                self.userItem.motionPWD = @"";
                [SSJUserTableManager saveUserItem:self.userItem success:NULL failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
            }
        }];
    }
    return _motionPwdCtrl;
}

- (UIButton *)logoutBtn {
    if (!_logoutBtn) {
        _logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _logoutBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_logoutBtn setTitle:@"退出账号" forState:UIControlStateNormal];
        [_logoutBtn ssj_setBorderStyle:SSJBorderStyleTop];
        [_logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutBtn;
}

- (LAContext *)context {
    if (!_context) {
        _context = [[LAContext alloc] init];
        _context.localizedFallbackTitle = @"";
    }
    return _context;
}

@end
