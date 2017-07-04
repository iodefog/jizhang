//
//  SSJClearDataViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJClearDataViewController.h"
#import "SSJClearDataCell.h"
#import "SSJSyncSettingWarningFooterView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJDataClearHelper.h"
#import "SSJDataSynchronizer.h"

static NSString *const kSSJClearDataCellId = @"SSJClearDataCell";

@interface SSJClearDataViewController ()

@property (nonatomic, strong) NSArray<SSJClearDataCellItem *> *cellItems;

@property (nonatomic, strong) SSJSyncSettingWarningFooterView *footer;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *alert;

@end

@implementation SSJClearDataViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"清理缓存";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self organiseCellItems];
    [self caculateDataSize];
    self.tableView.tableFooterView = self.footer;
    [self.tableView registerClass:[SSJClearDataCell class] forCellReuseIdentifier:kSSJClearDataCellId];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.footer updateAppearanceAccordingToTheme];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJClearDataCellId forIndexPath:indexPath];
    cell.cellItem = [self.cellItems ssj_objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 10;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        [SSJDataClearHelper clearLocalDataCacheWithSuccess:^{
            [self caculateDataSize];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.alert show];
    }
}

#pragma mark - Private
- (void)organiseCellItems {
    self.cellItems = @[@[[SSJClearDataCellItem itemWithLeftTitle:@"数据清理"
                                                      rightTitle:nil]],
                       @[[SSJClearDataCellItem itemWithLeftTitle:@"数据格式化"
                                                      rightTitle:nil]]];
}

/**
 计算数据大小
 */
- (void)caculateDataSize {
    [SSJDataClearHelper caculateCacheDataSizeWithSuccess:^(int64_t size) {
        float number = size;
        NSString *unit = @"B";
        
        float result = number / 1024.0;
        if (result >= 1) {
            number = result;
            unit = @"KB";
        }
        
        result = number / 1024.0;
        if (result >= 1) {
            number = result;
            unit = @"MB";
        }
        
        SSJClearDataCellItem *item = [self.cellItems ssj_objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        item.rightTitle = [NSString stringWithFormat:@"%.1f%@", number, unit];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - Lazyloading
- (SSJSyncSettingWarningFooterView *)footer {
    if (!_footer) {
        _footer = [[SSJSyncSettingWarningFooterView alloc] init];
        _footer.warningText = @"数据格式化，本机数据、云端数据将全部清空。";
    }
    return _footer;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)alert {
    if (!_alert) {
        _alert = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        _alert.message = [[NSAttributedString alloc] initWithString:@"选择数据格式化之后，云端和本地的数据将被彻底清除且不可恢复，确定要执行此操作？" attributes:nil];
        _alert.sureButtonTitle = @"格式化";
        _alert.finishVerification = ^{
            [SSJDataClearHelper clearAllDataWithSuccess:^{
                [CDAutoHideMessageHUD showMessage:@"数据初始化成功"];
                if (SSJIsUserLogined()) {
                    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
                }
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:@"数据初始化失败"];
            }];
        };
    }
    return _alert;
}

@end
