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
#import <LocalAuthentication/LocalAuthentication.h>

static NSString *const kCellId = @"kCellId";

@interface SSJMotionPasswordSettingViewController ()

@property (nonatomic, strong) UISwitch *motionSwitch;

@property (nonatomic, strong) UISwitch *trackSwitch;

@property (nonatomic, strong) UISwitch *fingerSwitch;

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SSJMotionPasswordSettingViewController

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableViewStyle{
    self = [super init];
    if (self) {
        self.title = @"手势密码";
        [self initTitles];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userItem = [SSJUserTableManager queryProperty:@[@"motionPWDState", @"motionTrackState", @"fingerPrintState"] forUserId:SSJUSERID()];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 8)];
    headerView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    self.tableView.tableHeaderView = headerView;
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
}

- (void)initTitles {
    LAContext *context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码", @"指纹解锁"];
    } else {
        _titles = @[@"手势密码", @"显示手势轨迹", @"修改手势密码"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    cell.textLabel.text = [_titles ssj_safeObjectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.accessoryView = self.motionSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.row == 1) {
        cell.accessoryView = self.trackSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
    [SSJUserTableManager saveUserItem:_userItem];
}

- (void)trackSwitchAction {
    _userItem.motionTrackState = [NSString stringWithFormat:@"%d", _trackSwitch.on];
    [SSJUserTableManager saveUserItem:_userItem];
}

- (void)fingerSwitchAction {
    _userItem.fingerPrintState = [NSString stringWithFormat:@"%d", _fingerSwitch.on];
    [SSJUserTableManager saveUserItem:_userItem];
}

#pragma mark - Getter
- (UISwitch *)motionSwitch {
    if (!_motionSwitch) {
        _motionSwitch = [[UISwitch alloc] init];
        _motionSwitch.on = [_userItem.motionPWDState boolValue];
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
