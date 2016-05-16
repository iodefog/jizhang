//
//  SSJMotionPasswordSettingViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/5/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordSettingViewController.h"
#import "SSJMotionPasswordViewController.h"

static NSString *const kCellId = @"kCellId";

@interface SSJMotionPasswordSettingViewController ()

@property (nonatomic, strong) UISwitch *motionSwitch;

@property (nonatomic, strong) UISwitch *trackSwitch;

@property (nonatomic, strong) UISwitch *fingerSwitch;

@end

@implementation SSJMotionPasswordSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"手势密码";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = 8;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
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
    if (indexPath.row == 2) {
        SSJMotionPasswordViewController *motionPasswordVC = [[SSJMotionPasswordViewController alloc] init];
        motionPasswordVC.type = SSJMotionPasswordViewControllerTypeSetting;
        [self.navigationController pushViewController:motionPasswordVC animated:YES];
    }
}

#pragma mark - Event
- (void)motionSwitchAction {
    
}

- (void)trackSwitchAction {
    
}

- (void)fingerSwitchAction {
    
}

#pragma mark - Getter
- (UISwitch *)motionSwitch {
    if (!_motionSwitch) {
        _motionSwitch = [[UISwitch alloc] init];
        [_motionSwitch addTarget:self action:@selector(motionSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _motionSwitch;
}

- (UISwitch *)trackSwitch {
    if (!_trackSwitch) {
        _trackSwitch = [[UISwitch alloc] init];
        [_trackSwitch addTarget:self action:@selector(trackSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _trackSwitch;
}

- (UISwitch *)fingerSwitch {
    if (!_fingerSwitch) {
        _fingerSwitch = [[UISwitch alloc] init];
        [_fingerSwitch addTarget:self action:@selector(fingerSwitchAction) forControlEvents:UIControlEventValueChanged];
    }
    return _fingerSwitch;
}

@end
