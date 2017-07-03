//
//  SSJSyncSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingViewController.h"
#import "SSJSyncSettingTableViewCell.h"

@interface SSJSyncSettingViewController ()
@end

@implementation SSJSyncSettingViewController{
    NSIndexPath *_selectedIndex;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"同步设置";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSelectedIndex];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveSetting];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;

}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *titleArray = @[@"仅在Wi-FI下自动同步",@"有网络连接时自动同步"];
    static NSString *cellId = @"SSJMineHomeCell";
    SSJSyncSettingTableViewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJSyncSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    mineHomeCell.cellTitle = [titleArray ssj_safeObjectAtIndex:indexPath.row];
    mineHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return mineHomeCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJSyncSettingTableViewCell *mineHomeCell = (SSJSyncSettingTableViewCell *)cell;
    if ([indexPath compare:_selectedIndex] == NSOrderedSame) {
        mineHomeCell.selected = YES;
    }else{
        mineHomeCell.selected = NO;
    }
}

- (void)saveSetting {
    if ([_selectedIndex compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJSaveSyncSetting(SSJSyncSettingTypeWIFI);
    } else if ([_selectedIndex compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJSaveSyncSetting(SSJSyncSettingTypeWWAN);
    }
}

- (void)loadSelectedIndex {
    SSJSyncSettingType setting = SSJSyncSetting();
    switch (setting) {
        case SSJSyncSettingTypeWIFI:
            _selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            break;
            
        case SSJSyncSettingTypeWWAN:
            _selectedIndex = [NSIndexPath indexPathForRow:1 inSection:0];
            break;
    }
}

@end
