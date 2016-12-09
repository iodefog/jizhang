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
#import "SSJReminderCircleSelectView.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJDataSynchronizer.h"

static NSString *const kTitle1 = @"提醒名称";
static NSString *const kTitle2 = @"备注";
static NSString *const kTitle3 = @"提醒周期";
static NSString *const kTitle4 = @"提醒闹钟";
static NSString *const kTitle5 = @"下次提醒";

static NSString * SSJCreditCardEditeCellIdentifier = @"SSJCreditCardEditeCellIdentifier";

@interface SSJReminderEditeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSDate *nextRemindDate;

@property(nonatomic, strong) SSJChargeReminderTimeView *reminderTimeView;

@property(nonatomic, strong) SSJReminderCircleSelectView *circleSelectView;

@property(nonatomic, strong) SSJReminderDateSelectView *dateSelectView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *images;

@end

@implementation SSJReminderEditeViewController{
    UITextField *_nameInput;
    UITextField *_memoInput;
}


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
    self.images = @[@[@"loan_remind",@"loan_memo"],@[@"card_zhouqi",@"loan_clock",@"loan_calendar"]];
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
//        if (self.item.remindType == SSJReminderTypeCreditCard || self.item.remindType == SSJReminderTypeBorrowing ) {
//
//        }else{
            self.circleSelectView.selectCircleType = self.item.remindCycle;
            [self.circleSelectView show];
//        }

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
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    newReminderCell.cellImageName = image;
    
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入提醒名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.remindName;
        _nameInput = newReminderCell.textInput;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注（选填）" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoInput = newReminderCell.textInput;
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
//        if (self.item.remindType == SSJReminderTypeCreditCard || self.item.remindType == SSJReminderTypeBorrowing ) {
//            newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
//        }else{
            newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
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
    self.nextRemindDate = [SSJLocalNotificationHelper calculateNexRemindDateWithStartDate:self.item.remindDate remindCycle:self.item.remindCycle remindAtEndOfMonth:self.item.remindAtTheEndOfMonth];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 100) {
        self.item.remindName = textField.text;
    }else if (textField.tag == 101){
        self.item.remindMemo = textField.text;
    }
    return YES;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    self.item.remindName = _nameInput.text;
    self.item.remindMemo = _memoInput.text;
    self.item.remindState = YES;
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
    if (self.needToSave == YES) {
        __weak typeof(self) weakSelf = self;
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:self.item Success:^(SSJReminderItem *item){
//            [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
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
    if ([SSJLocalNotificationStore deleteReminderWithItem:self.item error:NULL]) {
        [CDAutoHideMessageHUD showMessage:@"删除成功"];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [CDAutoHideMessageHUD showMessage:@"删除失败"];

    };
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

-(SSJReminderCircleSelectView *)circleSelectView{
    if (!_circleSelectView) {
        _circleSelectView = [[SSJReminderCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
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
        _dateSelectView.minmumDate = [NSDate date];
        __weak typeof(self) weakSelf = self;
        _dateSelectView.dateSetBlock = ^(NSDate *date){
            if (date.day > 28) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"每月不一定都有30号哦，是否将无30号的月份提醒设置跳过？或自动将无30号的月份的提醒设置在每月最后一天？" action:[SSJAlertViewAction actionWithTitle:@"部分月份设在最后一天" handler:^(SSJAlertViewAction * _Nonnull action) {
                    weakSelf.item.remindAtTheEndOfMonth = 1;
                }],[SSJAlertViewAction actionWithTitle:@"自动跳过" handler:^(SSJAlertViewAction * _Nonnull action) {
                    weakSelf.item.remindAtTheEndOfMonth = 0;
                }],nil];
            }
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
