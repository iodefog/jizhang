//
//  SSJMotionPasswordSettingViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/5/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordSettingViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJUserTableManager.h"
#import "SSJBaseTableViewCell.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SSJMotionPasswordSettingViewController ()

@property (nonatomic, strong) UISwitch *motionSwitch;

@property (nonatomic, strong) UISwitch *trackSwitch;

@property (nonatomic, strong) UISwitch *fingerSwitch;

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic) BOOL canTouchIdUsed;

@end

@implementation SSJMotionPasswordSettingViewController

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableViewStyle{
    self = [super init];
    if (self) {
        self.title = @"手势密码";
        LAContext *context = [[LAContext alloc] init];
        _canTouchIdUsed = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 8)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    self.tableView.rowHeight = 60;
    self.tableView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    [SSJUserTableManager queryProperty:@[@"userId", @"motionPWDState", @"motionPWD", @"motionTrackState", @"fingerPrintState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
        _userItem = userModel;
        [self updateTitles];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        [self.view ssj_hideLoadingIndicator];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
        [self.view ssj_hideLoadingIndicator];
    }];
}

- (void)updateTitles {
    if ([_userItem.motionPWDState boolValue] && _userItem.motionPWD.length) {
        if (_canTouchIdUsed) {
            _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码", @"指纹解锁"];
        } else {
            _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码"];
        }
    } else {
        _titles = @[@"手势密码"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    cell.textLabel.text = [_titles ssj_safeObjectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.accessoryView = self.motionSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.row == 1) {
        cell.accessoryView = self.trackSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.row == 2) {
        cell.accessoryView = nil;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    } else if (indexPath.row == 3) {
        cell.accessoryView = self.fingerSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
        motionPasswordVC.type = SSJMotionPasswordViewControllerTypeSetting;
        [self.navigationController pushViewController:motionPasswordVC animated:YES];
    }
}

#pragma mark - Event
- (void)motionSwitchAction {
    _userItem.motionPWDState = [NSString stringWithFormat:@"%d", _motionSwitch.on];
    [SSJUserTableManager saveUserItem:_userItem success:^{
        if (_motionSwitch.on) {
            [self.tableView beginUpdates];
            if (_canTouchIdUsed) {
                _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码", @"指纹解锁"];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                         [NSIndexPath indexPathForRow:2 inSection:0],
                                                         [NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码"];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                         [NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.tableView endUpdates];
            
            if (!_userItem.motionPWD.length) {
                SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
                motionPasswordVC.type = SSJMotionPasswordViewControllerTypeSetting;
                [self.navigationController pushViewController:motionPasswordVC animated:YES];
            }
        } else {
            _titles = @[@"手势密码"];
            [self.tableView beginUpdates];
            if (_canTouchIdUsed) {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                         [NSIndexPath indexPathForRow:2 inSection:0],
                                                         [NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                         [NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.tableView endUpdates];
            
            SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
            motionPasswordVC.type = SSJMotionPasswordViewControllerTypeTurnoff;
            [self.navigationController pushViewController:motionPasswordVC animated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)trackSwitchAction {
    _userItem.motionTrackState = [NSString stringWithFormat:@"%d", _trackSwitch.on];
    [SSJUserTableManager saveUserItem:_userItem success:NULL failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)fingerSwitchAction {
    _userItem.fingerPrintState = [NSString stringWithFormat:@"%d", _fingerSwitch.on];
    [SSJUserTableManager saveUserItem:_userItem success:NULL failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - Getter
- (UISwitch *)motionSwitch {
    if (!_motionSwitch) {
        _motionSwitch = [[UISwitch alloc] init];
        _motionSwitch.on = [_userItem.motionPWDState boolValue] && _userItem.motionPWD.length;
        [_motionSwitch addTarget:self action:@selector(motionSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _motionSwitch;
}

- (UISwitch *)trackSwitch {
    if (!_trackSwitch) {
        _trackSwitch = [[UISwitch alloc] init];
        _trackSwitch.on = [_userItem.motionTrackState boolValue];
        [_trackSwitch addTarget:self action:@selector(trackSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _trackSwitch;
}

- (UISwitch *)fingerSwitch {
    if (!_fingerSwitch) {
        _fingerSwitch = [[UISwitch alloc] init];
        _fingerSwitch.on = [_userItem.fingerPrintState boolValue];
        [_fingerSwitch addTarget:self action:@selector(fingerSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _fingerSwitch;
}

@end
