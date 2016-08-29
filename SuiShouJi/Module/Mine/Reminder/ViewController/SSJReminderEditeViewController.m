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
#import "SSJLocalNotificationStore.h"
#import "SSJChargeReminderTimeView.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJReminderDateSelectView.h"

static NSString *const kTitle1 = @"请输入提醒名称";
static NSString *const kTitle2 = @"备注（选填）";
static NSString *const kTitle3 = @"提醒周期";
static NSString *const kTitle4 = @"提醒闹钟";
static NSString *const kTitle5 = @"下次提醒时间";

static NSString * SSJCreditCardEditeCellIdentifier = @"SSJCreditCardEditeCellIdentifier";

@interface SSJReminderEditeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSDate *nextRemindDate;

@property(nonatomic, strong) SSJChargeReminderTimeView *reminderTimeView;

@property(nonatomic, strong) SSJChargeCircleSelectView *circleSelectView;

@property(nonatomic, strong) SSJReminderDateSelectView *dateSelectView;

@property(nonatomic, strong) UIView *saveFooterView;

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
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonCliked:)];
        self.navigationItem.rightBarButtonItem = rightItem;
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
    if (section == [self.tableView numberOfSections] - 1) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return 80 ;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle4]) {
        self.reminderTimeView.currentDate = self.item.remindDate;
        [self.reminderTimeView show];
    }
    if ([title isEqualToString:kTitle5]) {
        self.dateSelectView.currentDate = self.item.remindDate;
        [self.dateSelectView show];
    }
    if ([title isEqualToString:kTitle3]) {
        if (self.item.remindType == SSJReminderTypeCreditCard || self.item.remindType == SSJReminderTypeBorrowing ) {

        }else{
            self.circleSelectView.selectCircleType = self.item.remindCycle;
            [self.circleSelectView show];
        }

    }
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
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.remindMemo;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 101;
    }
    
    // 提醒周期
    if ([title isEqualToString:kTitle3]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        switch (self.item.remindCycle) {
            case 0:{
                newReminderCell.cellDetail = @"每天";
            }
                break;
                
            case 1:{
                newReminderCell.cellDetail = @"每个工作日";
            }
                break;
                
            case 2:{
                newReminderCell.cellDetail = @"每周末";
            }
                break;
                
            case 3:{
                newReminderCell.cellDetail = @"每周";
            }
                break;
                
            case 4:{
                newReminderCell.cellDetail = @"每月";
            }
                break;
                
            case 5:{
                newReminderCell.cellDetail = @"每月最后一天";
            }
                break;
                
            case 6:{
                newReminderCell.cellDetail = @"每年";
            }
                break;
                
            case 7:{
                newReminderCell.cellDetail = @"仅一次";
            }
                break;
                
            default:
                break;
        }
        if (self.item.remindType == SSJReminderTypeCreditCard || self.item.remindType == SSJReminderTypeBorrowing ) {
            newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        }else{
            newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    // 提醒闹钟
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = [self.item.remindDate formattedDateWithFormat:@"HH:mm"];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 下次提醒时间
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = [self.nextRemindDate formattedDateWithStyle:NSDateFormatterFullStyle];
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
        self.item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:20 minute:0 second:0];
        self.item.remindCycle = 0;
        self.item.remindType = SSJReminderTypeNormal;
    }
    // 算出下一次提示时间
    NSDate *today = [NSDate date];
    NSDate *endOfToday = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:24 minute:0 second:0];
    NSDate *baseStartDate;
    if ([self.item.remindDate isLaterThan:endOfToday]) {
        baseStartDate = self.item.remindDate;
    }else{
        baseStartDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
    }
    NSDate *baseDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
    switch (self.item.remindCycle) {
        case 0:{
            // 如果是每天
            if ([baseStartDate isEarlierThan:[NSDate date]]) {
                // 如果已经早于现在,则加一天
                self.nextRemindDate = [baseStartDate dateByAddingDays:1];
            }else{
                self.nextRemindDate = baseStartDate;
            }
        }
            break;
            
        case 2:{
            //若是每周末
            if ([baseStartDate isWeekend]) {
                if (baseStartDate.weekday == 1) {
                    // 如果是礼拜天
                    if ([baseStartDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加六天
                        self.nextRemindDate = [baseStartDate dateByAddingDays:6];
                    }else{
                        self.nextRemindDate = baseStartDate;
                    }
                }else{
                    // 如果是礼拜六
                    if ([baseStartDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加一天
                        self.nextRemindDate = [baseStartDate dateByAddingDays:1];
                    }else{
                        self.nextRemindDate = baseStartDate;
                    }
                }
            }else{
                // 如果不是周末
                self.nextRemindDate = [[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:7];
            }
        }
            break;
            
        case 1:{
            // 如果是每个工作日
            if (![baseStartDate isWeekend]) {
                // 如果是工作日
                if ([baseStartDate isEarlierThan:today]) {
                    // 如果时间早于现在
                    if (baseStartDate.weekday == 6) {
                        // 如果是礼拜五则要加到下个礼拜一
                        self.nextRemindDate = [baseStartDate dateByAddingDays:3];
                    }else{
                        self.nextRemindDate = [baseStartDate dateByAddingDays:1];
                    }
                }else{
                    self.nextRemindDate = baseStartDate;
                }
            }else{
                // 如果是周末
                if (baseStartDate.weekday == 1) {
                    self.nextRemindDate = [baseStartDate dateByAddingDays:1];
                }else{
                    self.nextRemindDate = [baseStartDate dateByAddingDays:2];
                }
            }
        }
            break;
            
        case 3:{
            // 如果是每周
            if (self.item.remindDate.weekday == baseStartDate.weekday) {
                // 如果每周是今天记账
                if ([baseStartDate isEarlierThan:today]) {
                    // 如果是早于现在则要到下周提醒
                    self.nextRemindDate = [baseStartDate dateByAddingDays:7];
                }else{
                    self.nextRemindDate = baseStartDate;
                }
            }else{
                if (self.item.remindDate.weekday < baseStartDate.weekday) {
                    // 如果提醒的星期几比今天早,则下个礼拜提醒
                    self.nextRemindDate = [[[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:self.item.remindDate.weekday] dateByAddingWeeks:1];
                }else{
                    self.nextRemindDate = [[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:self.item.remindDate.weekday];
                }
            }
        }
            break;
            
        case 4:{
            // 如果是每月
            if (self.item.remindDate.day > 28 && self.item.remindDate.day < baseStartDate.daysInMonth) {
                // 如果提醒时间大于28号,并且日期大于本月的最大日期
                if (self.item.remindAtTheEndOfMonth) {
                    self.nextRemindDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:baseStartDate.daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
                }else{
                    self.nextRemindDate = [baseStartDate dateByAddingMonths:1];
                }
            }else{
                if (self.item.remindDate.day > baseStartDate.day) {
                    // 如果提醒还没到时间
                    self.nextRemindDate = baseStartDate;
                }else if (self.item.remindDate.day < baseStartDate.day){
                    self.nextRemindDate = [baseStartDate dateByAddingMonths:1];
                }else{
                    if ([baseStartDate isEarlierThan:baseDate]) {
                        //如果提醒过了
                        self.nextRemindDate = [baseStartDate dateByAddingMonths:1];
                    }else{
                        self.nextRemindDate = baseStartDate;
                    }
                }
            }
        }
            break;
            
        case 5:{
            // 如果是每月最后一天
            if (baseStartDate.day != baseStartDate.daysInMonth) {
                self.nextRemindDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:baseStartDate.daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second];
            }else{
                //如果今天是每月最后一天
                if ([baseStartDate isEarlierThan:today]) {
                    //如果已经提醒过了就下个月提醒
                    self.nextRemindDate = [[NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:[baseStartDate dateByAddingMonths:1].daysInMonth hour:self.item.remindDate.hour minute:self.item.remindDate.minute second:self.item.remindDate.second] dateByAddingMonths:1];
                }else{
                    //如果没有就今天提醒
                    self.nextRemindDate = baseStartDate;
                }
            }
        }
            break;
            
        case 6:{
            // 如果是每年
            if ([baseStartDate isEarlierThan:today]) {
                self.nextRemindDate = [baseStartDate dateByAddingYears:1];
            }else{
                self.nextRemindDate = baseStartDate;
            }
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

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.remindName = textField.text;
    }else if (textField.tag == 101){
        self.item.remindMemo = textField.text;
    }
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    SSJCreditCardEditeCell *nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    SSJCreditCardEditeCell *memoCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.item.remindName = nameCell.textInput.text;
    self.item.remindMemo = memoCell.textInput.text;
    if ([self.item.remindDate isEarlierThan:self.item.minimumDate] && self.item.remindType == SSJReminderTypeBorrowing) {
        [CDAutoHideMessageHUD showMessage:@"提醒日期不能晚于借贷的借款日期"];
        return;
    }
    if (!self.item.remindName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入提醒名称"];
        return;
    }
    if (!self.item.remindId.length) {
        self.item.remindId = SSJUUID();
    }
    if (self.item.remindType == SSJReminderTypeNormal || self.item.remindType == SSJReminderTypeCharge) {
        __weak typeof(self) weakSelf = self;
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:self.item Success:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            
        }];
    }else{
        if (self.addNewReminderAction) {
            self.addNewReminderAction(self.item);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightButtonCliked:(id)sender{
    
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

-(SSJChargeCircleSelectView *)circleSelectView{
    if (!_circleSelectView) {
        _circleSelectView = [[SSJChargeCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _circleSelectView.title = @"提醒周期";
        __weak typeof(self) weakSelf = self;
        _circleSelectView.chargeCircleSelectBlock = ^(NSInteger chargeCircleType){
            weakSelf.item.remindCycle = chargeCircleType;
            [weakSelf initdata];
        };
    }
    return _circleSelectView;
}

-(SSJChargeReminderTimeView *)reminderTimeView{
    if (!_reminderTimeView) {
        _reminderTimeView = [[SSJChargeReminderTimeView alloc]initWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        _reminderTimeView.timerSetBlock = ^(NSString *time , NSDate *date){
            weakSelf.item.remindDate = [NSDate dateWithYear:weakSelf.item.remindDate.year month:weakSelf.item.remindDate.month day:weakSelf.item.remindDate.day hour:date.hour minute:date.minute second:date.second];
            [weakSelf initdata];
        };
    }
    return _reminderTimeView;
}

-(SSJReminderDateSelectView *)dateSelectView{
    if (!_dateSelectView) {
        _dateSelectView = [[SSJReminderDateSelectView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 500)];
        __weak typeof(self) weakSelf = self;
        _dateSelectView.dateSetBlock = ^(NSDate *date){
            weakSelf.item.remindDate = [NSDate dateWithYear:date.year month:date.month day:date.day hour:weakSelf.item.remindDate.hour minute:weakSelf.item.remindDate.minute second:weakSelf.item.remindDate.second];
            [weakSelf initdata];
        };
    }
    return _dateSelectView;
}

-(UIView *)saveFooterView{
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        saveButton.layer.cornerRadius = 3.f;
        saveButton.layer.masksToBounds = YES;
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
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
