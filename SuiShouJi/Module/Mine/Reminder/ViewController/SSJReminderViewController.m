
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

static NSString * SSJReminderListCellIdentifier = @"SSJReminderListCellIdentifier";

@interface SSJReminderViewController ()
@property(nonatomic, strong) NSArray *items;
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
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SSJLocalNotificationStore queryForreminderListWithSuccess:^(NSArray<SSJReminderItem *> *result) {
        weakSelf.items = [NSArray arrayWithArray:result];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReminderItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    SSJReminderListCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJReminderListCellIdentifier forIndexPath:indexPath];
    [cell setCellItem:item];
    return cell;
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
    [self.navigationController pushViewController:remindEditeVc animated:YES];
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
