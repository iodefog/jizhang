
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
    [SSJLocalNotificationStore queryForreminderListWithSuccess:^(NSArray<SSJReminderItem *> *result) {
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
    if (item.remindMemo.length) {
        return 70;
    }
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJReminderItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    SSJReminderEditeViewController *reminderEditeVc = [[SSJReminderEditeViewController alloc]init];
    reminderEditeVc.needToSave = YES;
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
    cell.switchAction = ^(SSJReminderListCell *cell) {
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:(SSJReminderItem *)cell.cellItem Success:NULL failure:^(NSError *error) {
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
    [self.navigationController pushViewController:remindEditeVc animated:YES];
}

#pragma mark - Getter
- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"报表空空如也";
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
