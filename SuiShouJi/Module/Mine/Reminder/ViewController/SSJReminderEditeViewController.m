//
//  SSJReminderEditeViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderEditeViewController.h"
#import "SSJCreditCardEditeCell.h"
#import "TPKeyboardAvoidingTableView.h"

static NSString *const kTitle1 = @"请输入提醒名称";
static NSString *const kTitle2 = @"备注（选填）";
static NSString *const kTitle3 = @"提醒周期";
static NSString *const kTitle4 = @"提醒闹钟";
static NSString *const kTitle5 = @"下次提醒时间";

static NSString * SSJCreditCardEditeCellIdentifier = @"SSJCreditCardEditeCellIdentifier";

@interface SSJReminderEditeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSDate *nextRemindDate;
@end

@implementation SSJReminderEditeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initdata];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJCreditCardEditeCell class] forCellReuseIdentifier:SSJCreditCardEditeCellIdentifier];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5]];
    if (self.item.remindId.length) {
        self.title = @"提醒详情";
    }else{
        self.title = @"添加提醒";
    }
    // Do any additional setup after loading the view.
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
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
    SSJCreditCardEditeCell *newReminderCell = [tableView dequeueReusableCellWithIdentifier:SSJCreditCardEditeCellIdentifier];
    if (!newReminderCell) {
        newReminderCell = [[SSJCreditCardEditeCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:SSJCreditCardEditeCellIdentifier];
    }
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.remindName;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.remindMemo;
    }
    
    // 提醒周期
    if ([title isEqualToString:kTitle3]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        switch (self.item.remindCycle) {
            case 0:{
                newReminderCell.detailLabel.text = @"每天";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 1:{
                newReminderCell.detailLabel.text = @"每个工作日";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 2:{
                newReminderCell.detailLabel.text = @"每周末";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 3:{
                newReminderCell.detailLabel.text = @"每周";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 4:{
                newReminderCell.detailLabel.text = @"每月";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 5:{
                newReminderCell.detailLabel.text = @"每月最后一天";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 6:{
                newReminderCell.detailLabel.text = @"每年";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            case 7:{
                newReminderCell.detailLabel.text = @"仅一次";
                [newReminderCell.detailLabel sizeToFit];
            }
                break;
                
            default:
                break;
        }
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 提醒闹钟
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.detailLabel.text = [self.item.remindDate formattedDateWithFormat:@"HH:mm"];
        [newReminderCell.detailLabel sizeToFit];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 下次提醒时间
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.detailLabel.text = [self.nextRemindDate formattedDateWithStyle:NSDateFormatterFullStyle];
        [newReminderCell.detailLabel sizeToFit];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return newReminderCell;
}

#pragma mark - Private
- (void)initdata{
    // 如果是新建一套默认的数据
    if (self.item == nil) {
        self.item = [[SSJReminderItem alloc]init];
        self.item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:8 minute:0 second:0];
        self.item.remindCycle = 0;
    }
    // 算出下一次提示时间
    NSDate *today = [NSDate date];
    NSDate *baseDate = [NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
    switch (self.item.remindCycle) {
        case 0:{
            // 如果是每天
            if ([baseDate isEarlierThan:[NSDate date]]) {
                // 如果已经早于现在,则加一天
                self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:1];
            }else{
                self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
            }
        }
            break;
            
        case 1:{
            //若是每周末
            if ([[NSDate date] isWeekend]) {
                if ([NSDate date].weekday == 1) {
                    // 如果是礼拜天
                    if ([baseDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加六天
                        self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:6];
                    }else{
                        self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                    }
                }else{
                    // 如果是礼拜六
                    if ([baseDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加一天
                        self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:1];
                    }else{
                        self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                    }
                }
            }else{
                // 如果不是周末
                self.nextRemindDate = [[[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateBySubtractingDays:today.weekday] dateByAddingDays:7];
            }
        }
            break;
            
        case 2:{
            // 如果是每个工作日
            if (![today isWeekend]) {
                // 如果是工作日
                if ([baseDate isEarlierThan:today]) {
                    // 如果时间早于现在
                    if (today.weekday == 6) {
                        // 如果是礼拜五则要加到下个礼拜一
                        self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:3];
                    }else{
                        self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:1];
                    }
                }else{
                    self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                }
            }else{
                // 如果是周末
                if (today.weekday == 1) {
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:1];
                }else{
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:2];
                }
            }
        }
            break;
            
        case 3:{
            // 如果是每个工作日
            if (self.item.remindDate.weekday == today.weekday) {
                // 如果每周是今天记账
                if ([baseDate isEarlierThan:today]) {
                    // 如果是早于现在则要到下周提醒
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingDays:7];
                }else{
                    self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                }
            }else{
                if (self.item.remindDate.weekday < today.weekday) {
                    // 如果提醒的星期几比今天早,则下个礼拜提醒
                    self.nextRemindDate = [[[[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateBySubtractingDays:today.weekday] dateByAddingDays:self.item.remindDate.weekday] dateByAddingWeeks:1];
                }else{
                    self.nextRemindDate = [[[NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateBySubtractingDays:today.weekday] dateByAddingDays:self.item.remindDate.weekday];
                }
            }
        }
            break;
            
        case 4:{
            // 如果是每月
            if (self.item.remindDate.day > 28 && self.item.remindDate.day < today.daysInMonth) {
                // 如果提醒时间大于28号,并且日期大于本月的最大日期
                if (self.item.remindAtTheEndOfMonth) {
                    self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                }else{
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                }
            }else{
                if (self.item.remindDate.day > today.day) {
                    // 如果提醒还没到时间
                    self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                }else if (self.item.remindDate.day < today.day){
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                }else{
                    if ([baseDate isEarlierThan:today]) {
                        //如果提醒过了
                        self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                    }else{
                        self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:self.item.remindDate.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                    }
                }
            }
        }
            break;
            
        case 5:{
            // 如果是每月最后一天
            if (today.day != today.daysInMonth) {
                self.nextRemindDate = [NSDate dateWithYear:today.year month:today.month day:today.daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
            }else{
                if ([baseDate isEarlierThan:today]) {
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:[today dateByAddingMonths:1].daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                }else{
                    self.nextRemindDate = [[NSDate dateWithYear:today.year month:today.month day:[today dateByAddingMonths:1].daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                }
            }
        }
            break;
            
        case 6:{
            // 如果是每年
        }
            break;
            
        case 7:{
            //仅一次
            self.nextRemindDate = self.item.remindDate;
        }
            break;
            
        default:
            self.nextRemindDate = self.item.remindDate;
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return _tableView;
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
