//
//  SSJSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSettingViewController.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJUserTableManager.h"
#import "SSJSyncSettingViewController.h"
#import "SSJMagicExportViewController.h"
#import "SSJLoginViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJClearDataViewController.h"
#import "SSJBindMobileNoViewController.h"

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

@end

@implementation SSJSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"设置";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reorganiseDatas];
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
        
    } else if ([title isEqualToString:kModifyPwdTitle]) {// 修改密码
        
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
        mineHomeCell.cellDetail = self.userItem.mobileNo;
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
    [[self loadUserItemIfNeeded] subscribeNext:^(NSNumber *bindValue) {
        NSArray *section1 = [bindValue boolValue] ? @[kMobileNoTitle, kModifyPwdTitle] : @[kBindMobileNoTitle];
        NSArray *section2 = @[kFingerPrintPwdTitle, kMotionPwdTitle];
        NSArray *section3 = @[kMagicExportTitle, kDataSyncTitle, kClearDataTitle];
        self.titles = @[section1, section2, section3];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (RACSignal *)loadUserItemIfNeeded {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (SSJIsUserLogined()) {
            [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                self.userItem = userItem;
                self.fingerPrintPwdCtrl.on = [self.userItem.fingerPrintState boolValue];
                self.motionPwdCtrl.on = [self.userItem.motionPWDState boolValue] && self.userItem.motionPWD.length;
                [subscriber sendNext:@(userItem.mobileNo.length > 0)];
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        } else {
            [subscriber sendNext:@(NO)];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (void)login {
    SSJLoginViewController *loginVc = [[SSJLoginViewController alloc] init];
    loginVc.backController = self;
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (void)settingMotionPwd {
    SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
    motionPasswordVC.type = SSJMotionPasswordViewControllerTypeSetting;
    [self.navigationController pushViewController:motionPasswordVC animated:YES];
}

#pragma mark - Getter
- (UISwitch *)fingerPrintPwdCtrl {
    if (!_fingerPrintPwdCtrl) {
        _fingerPrintPwdCtrl = [[UISwitch alloc] init];
        [[_fingerPrintPwdCtrl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *ctrl) {
            if (SSJIsUserLogined()) {
                self.userItem.fingerPrintState = [NSString stringWithFormat:@"%d", ctrl.on];
                [SSJUserTableManager saveUserItem:self.userItem success:NULL failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
            } else {
                [self login];
            }
        }];
    }
    return _fingerPrintPwdCtrl;
}

- (UISwitch *)motionPwdCtrl {
    if (!_motionPwdCtrl) {
        _motionPwdCtrl = [[UISwitch alloc] init];
        [[_motionPwdCtrl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *ctrl) {
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

@end
