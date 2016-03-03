//
//  SSJBookkeepingReminderViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString *const kTitle1 = @"提醒开关";
static NSString *const kTitle2 = @"提醒时间";
static NSString *const kTitle3 = @"定期提醒";

#import "SSJBookkeepingReminderViewController.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJChargeReminderTimeView.h"

@interface SSJBookkeepingReminderViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) SSJChargeReminderTimeView *chargeReminder;
@property (nonatomic,strong) NSString *selectTime;
@end

@implementation SSJBookkeepingReminderViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3]];
}

#pragma mark - Getter
-(SSJChargeReminderTimeView *)chargeReminder{
    if (!_chargeReminder) {
        _chargeReminder = [[SSJChargeReminderTimeView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        _chargeReminder.timerSetBlock = ^(NSString *time , NSDate *date){
            weakSelf.selectTime = time;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeReminder;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UISwitch *switchButton = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    switchButton.onTintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    [switchButton addTarget:self action:@selector(switchButtonChange:) forControlEvents:UIControlEventValueChanged];
    if (indexPath.section == 0) {
        mineHomeCell.accessoryView = switchButton;
    }else if (indexPath.section == 2){
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        mineHomeCell.cellDetail = _selectTime;
    }
    mineHomeCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    
    return mineHomeCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.chargeReminder];
    }
}

#pragma mark - Private
-(void)switchButtonChange:(id)sender{
    
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
