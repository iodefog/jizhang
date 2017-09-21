
//
//  SSJReminderViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderViewController.h"
#import "SSJLocalNotificationStore.h"
#import "SSJReminderListCell.h"
#import "SSJReminderEditeViewController.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJGeTuiManager.h"
#import "SSJDataSynchronizer.h"

static NSString * SSJReminderListCellIdentifier = @"SSJReminderListCellIdentifier";

@interface SSJReminderViewController ()

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;
@end

@implementation SSJReminderViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"提醒";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJReminderListCell class] forCellReuseIdentifier:SSJReminderListCellIdentifier];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"founds_jia"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [SSJLocalNotificationStore queryForreminderListForUserId:SSJUSERID() WithSuccess:^(NSArray<SSJReminderItem *> *result) {
        if (!result.count) {
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        }else{
            [self.view ssj_hideWatermark:YES];
        }
        weakSelf.items = [NSArray arrayWithArray:result];
        [self.view ssj_hideLoadingIndicator];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJReminderItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    return item.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1f;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJReminderItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    SSJReminderEditeViewController *reminderEditeVc = [[SSJReminderEditeViewController alloc]init];
    reminderEditeVc.needToSave = YES;
    @weakify(self);
    reminderEditeVc.addNewReminderAction = ^(SSJReminderItem *item) {
        @strongify(self);
        [self remindLocationWithItem:item withSwitch:nil];
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:item Success:^(SSJReminderItem *Ritem){
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showError:error];
        }];
    };
    reminderEditeVc.item = item;
    [self.navigationController pushViewController:reminderEditeVc animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReminderItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    SSJReminderListCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJReminderListCellIdentifier forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.switchAction = ^(SSJReminderListCell *cell,UISwitch *switchA) {
        SSJReminderItem *item = cell.cellItem;
        if (item.remindState == NO) {
            [weakSelf remindLocationWithItem:cell.cellItem withSwitch:switchA];
        } else {
            item.remindState = NO;
        }
        
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:(SSJReminderItem *)cell.cellItem Success:^(SSJReminderItem *item){
            if (!item.remindState) {
                [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:item];
            }
        }failure:^(NSError *error) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    };
    [cell setCellItem:item];
    return cell;
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
    
    remindEditeVc.needToSave = YES;
    
    __weak typeof(self) weakSelf = self;
    remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item) {

        [weakSelf remindLocationWithItem:item withSwitch:nil];
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:item Success:^(SSJReminderItem *Ritem){
            [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            
        }];
        
    };
    remindEditeVc.needToSave = YES;
    [self.navigationController pushViewController:remindEditeVc animated:YES];
}

- (void)remindLocationWithItem:(SSJReminderItem *)item withSwitch:(UISwitch *)switchA {
    //如果已经弹出过授权弹框开启通知
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJNoticeAlertKey]) {//弹出过授权弹框
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (UIUserNotificationTypeNone == setting.types) {
                item.remindState = NO;
                if (switchA) {
                    switchA.on = NO;
                }
                //推送关闭(去设置)
                [SSJAlertViewAdapter showAlertViewWithTitle:@"哎呀，未开启推送通知" message:@"这样会错过您设定的提醒，墙裂建议您打开吆" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL],[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        
                        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                    }
                    
                }],nil];
            }else{
                //推送打开
                item.remindState = YES;
                if (switchA) {
                    switchA.on = YES;
                }
            }
        }
        
    } else { //没有弹出过授权弹框
        //弹出授权弹框
        item.remindState = NO;
        if (switchA) {
            switchA.on = NO;
        }
        [[SSJGeTuiManager shareManager] registerRemoteNotificationWithDelegate:[UIApplication sharedApplication]];//远程通知
    }
}

#pragma mark - Getter
- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"暂未设置提醒哦~";
    }
    return _noDataRemindView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
