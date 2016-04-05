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
#import "SSJLocalNotificationHelper.h"
#import "SSJDatabaseQueue.h"

@interface SSJBookkeepingReminderViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) SSJChargeReminderTimeView *chargeReminderTime;
@property (nonatomic,strong) SSJBookKeepingRiminderCircleView *chargeReminderCircle;
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) SSJChargeReminderItem *item;
@property (nonatomic,strong) NSString *selectTime;
@property (nonatomic,strong) NSString *selectCircle;
@property (nonatomic,strong) NSString *selectNumCircle;
@end

@implementation SSJBookkeepingReminderViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"记账提醒";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
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
        __weak typeof(self) weakSelf = self;
        _chargeReminderCircle.circleSelectBlock = ^(NSString *dateNumString , NSString *dateString){
            weakSelf.selectNumCircle  = dateNumString;
            weakSelf.selectCircle = dateString;
            [weakSelf.tableView reloadData];
        };
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
        comfirmButton.layer.cornerRadius = 4.0f;
        [comfirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:comfirmButton];
    }
    return _footerView;
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
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
    switchButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
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
    self.item.isOnOrNot = ((UISwitch *)sender).isOn;
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
        weakSelf.selectNumCircle = weakSelf.item.circleString;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *tempArr = [weakSelf.item.circleString componentsSeparatedByString:@","];
            if (tempArr.count == 7) {
                weakSelf.selectCircle = @"每天";
            }else if (tempArr.count == 5 && ![tempArr containsObject:@"1"] &&  ![tempArr containsObject:@"7" ]){
                weakSelf.selectCircle = @"每个工作日";
            }else if (tempArr.count == 2 && [tempArr containsObject:@"1"] &&  [tempArr containsObject:@"7" ]){
                weakSelf.selectCircle = @"每个周末";
            }else{
                NSMutableArray *array = [[NSMutableArray alloc]init];
                for (int i = 0; i < tempArr.count; i ++) {
                    NSInteger date = [[tempArr objectAtIndex:i] intValue];
                    switch (date) {
                        case 1:
                            [array addObject:@"周日"];
                            break;
                        case 2:
                            [array addObject:@"周一"];
                            break;
                        case 3:
                            [array addObject:@"周二"];
                            break;
                        case 4:
                            [array addObject:@"周三"];
                            break;
                        case 5:
                            [array addObject:@"周四"];
                            break;
                        case 6:
                            [array addObject:@"周五"];
                            break;
                        case 7:
                            [array addObject:@"周六"];
                            break;
                        default:
                            break;
                    }
                }
                weakSelf.selectCircle = [array componentsJoinedByString:@","];
            }
            weakSelf.selectTime = weakSelf.item.timeString;
            [weakSelf.tableView reloadData];
            weakSelf.chargeReminderCircle.selectWeekStr = weakSelf.selectNumCircle;
        });
    }];
}

-(void)saveButtonClicked:(id)sender{
    [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
    if (self.item.isOnOrNot) {
        NSArray *tempArr = [self.selectNumCircle componentsSeparatedByString:@","];
        NSString *baseDateStr = [NSString stringWithFormat:@"%@ %@:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"],self.selectTime];
        NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
        if (tempArr.count == 7) {
            if ([baseDate isEarlierThan:[NSDate date]]) {
                baseDate = [baseDate dateByAddingDays:1];
            }
            [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
        }else if (tempArr.count == 1){
            if ([baseDate isEarlierThan:[NSDate date]]) {
                baseDate = [baseDate dateByAddingDays:7];
            }
            [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSWeekCalendarUnit notificationKey:SSJChargeReminderNotification];
        }else{
            for (int i = 0; i < tempArr.count; i ++) {
                NSDate *firedate = [NSDate date];
                if ([(NSString *)[tempArr ssj_safeObjectAtIndex:i] intValue] > [NSDate date].weekday){
                    firedate = [baseDate dateByAddingDays:[(NSString *)[tempArr ssj_safeObjectAtIndex:i] intValue] - [NSDate date].weekday];
                    [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:firedate repeatIterval:NSWeekCalendarUnit notificationKey:SSJChargeReminderNotification];
                }else if ([(NSString *)[tempArr ssj_safeObjectAtIndex:i] intValue] < [NSDate date].weekday){
                    firedate = [baseDate dateByAddingDays:[(NSString *)[tempArr ssj_safeObjectAtIndex:i] intValue] - [NSDate date].weekday + 7];
                    [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:firedate repeatIterval:NSWeekCalendarUnit notificationKey:SSJChargeReminderNotification];
                }else{
                    if ([baseDate isEarlierThan:[NSDate date]]) {
                        baseDate = [baseDate dateByAddingDays:7];
                        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSWeekCalendarUnit notificationKey:SSJChargeReminderNotification];
                    }else{
                        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSWeekCalendarUnit notificationKey:SSJChargeReminderNotification];
                    }
                }
            }
        }
    }
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update BK_CHARGE_REMINDER set ISONORNOT = ? ,TIME = ?, CIRCLE = ?",[NSNumber numberWithBool:weakSelf.item.isOnOrNot],weakSelf.selectTime,weakSelf.selectNumCircle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
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
