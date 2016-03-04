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
#import "SSJBookKeepingRiminderCircleView.h"
#import "SSJChargeReminderItem.h"
#import "SSJDatabaseQueue.h"

@interface SSJBookkeepingReminderViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) SSJChargeReminderTimeView *chargeReminderTime;
@property (nonatomic,strong) SSJBookKeepingRiminderCircleView *chargeReminderCircle;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) SSJChargeReminderItem *item;
@property (nonatomic,strong) NSString *selectTime;
@property (nonatomic,strong) NSString *selectCircle;
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromDB];
}

#pragma mark - Getter
-(SSJChargeReminderTimeView *)chargeReminderTime{
    if (!_chargeReminderTime) {
        _chargeReminderTime = [[SSJChargeReminderTimeView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        _chargeReminderTime.timerSetBlock = ^(NSString *time , NSDate *date){
            weakSelf.selectTime = time;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeReminderTime;
}

-(SSJBookKeepingRiminderCircleView *)chargeReminderCircle{
    if (!_chargeReminderCircle) {
        _chargeReminderCircle = [[SSJBookKeepingRiminderCircleView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _chargeReminderCircle;
}

-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]init];
        _footerView.size = CGSizeMake(self.view.width, 80);
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.size = CGSizeMake(self.view.width - 40, 40);
        comfirmButton.center = CGPointMake(_footerView.width / 2, _footerView.height / 2);
        comfirmButton.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        [comfirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:comfirmButton];
    }
    return _footerView;
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80;
    }
    return 0.1f;
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
    switchButton.on = self.item.isOnOrNot;
    switchButton.onTintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    [switchButton addTarget:self action:@selector(switchButtonChange:) forControlEvents:UIControlEventValueChanged];
    if (indexPath.section == 0) {
        mineHomeCell.accessoryView = switchButton;
    }else if (indexPath.section == 2){
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        mineHomeCell.cellDetail = self.selectCircle;
    }else{
        mineHomeCell.cellDetail = self.selectTime;
    }
    mineHomeCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    
    return mineHomeCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.chargeReminderTime];
    }else if (indexPath.section == 2){
        [[UIApplication sharedApplication].keyWindow addSubview:self.chargeReminderCircle];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return self.footerView;
    }
    return nil;
}

#pragma mark - Private
-(void)switchButtonChange:(id)sender{
    
}

-(void)getDataFromDB{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
       FMResultSet *result = [db executeQuery:@"select * from BK_CHARGE_REMINDER"];
        while ([result next]) {
            weakSelf.item = [[SSJChargeReminderItem alloc]init];
            weakSelf.item.isOnOrNot = [result boolForColumn:@"ISONORNOT"];
            weakSelf.item.timeString = [result stringForColumn:@"TIME"];
            weakSelf.item.circleString = [result stringForColumn:@"CIRCLE"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.selectCircle = weakSelf.item.circleString;
            weakSelf.selectTime = weakSelf.item.timeString;
            [weakSelf.tableView reloadData];
        });
    }];
}

-(void)saveButtonClicked:(id)sender{
    
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
