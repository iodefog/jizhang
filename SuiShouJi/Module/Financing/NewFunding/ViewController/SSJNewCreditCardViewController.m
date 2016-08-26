

//
//  SSJNewCreditCardViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewCreditCardViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJCreditCardEditeCell.h"
#import "SSJCreditCardItem.h"
#import "SSJCreditCardStore.h"
#import "SSJBillingDaySelectView.h"
#import "SSJDatabaseQueue.h"
#import "SSJReminderItem.h"

static NSString *const kTitle1 = @"输入账户名称";
static NSString *const kTitle2 = @"账户类型";
static NSString *const kTitle3 = @"输入信用额度";
static NSString *const kTitle4 = @"当前信用卡余额/欠款";
static NSString *const kTitle5 = @"备注说明(选填)";
static NSString *const kTitle6 = @"以账单日结算";
static NSString *const kTitle7 = @"账单日";
static NSString *const kTitle8 = @"还款日";
static NSString *const kTitle9 = @"还款日提醒";
static NSString *const kTitle10 = @"编辑卡片颜色";

static NSString * SSJCreditCardEditeCellIdentifier = @"SSJCreditCardEditeCellIdentifier";

@interface SSJNewCreditCardViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSArray *titles;

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) SSJCreditCardItem *item;

// 提醒开关
@property(nonatomic, strong) UISwitch *remindStateButton;

// 是否已账单日结算开关
@property(nonatomic, strong) UISwitch *billDateSettleMentButton;

@property(nonatomic, strong) SSJBillingDaySelectView *billingDateSelectView;

@property(nonatomic, strong) SSJBillingDaySelectView *repaymentDateSelectView;

@property(nonatomic, strong) SSJReminderItem *remindItem;

@end

@implementation SSJNewCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5],@[kTitle6,kTitle7,kTitle8],@[kTitle9,kTitle10]];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.cardId.length) {
        self.item = [[SSJCreditCardItem alloc]init];
        self.item.settleAtRepaymentDay = YES;
        self.item.cardBillingDay = 1;
        self.item.cardRepaymentDay = 10;
        self.item.cardColor = @"";
    }else{
        self.item = [SSJCreditCardStore queryCreditCardDetailWithCardId:self.cardId];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];

    if ([title isEqualToString:kTitle6]) {
        return 75;
    }
    return 55;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle7]) {
        self.billingDateSelectView.currentDate = self.item.cardBillingDay;
        [self.billingDateSelectView show];
    }
    
    if ([title isEqualToString:kTitle8]) {
        self.repaymentDateSelectView.currentDate = self.item.cardRepaymentDay;
        [self.repaymentDateSelectView show];
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
    
    // 信用卡名称
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.cardName;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账户类型
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = @"信用卡";
        newReminderCell.cellDetailImageName = @"ft_creditcard";
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡额度
    if ([title isEqualToString:kTitle3]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.keyboardType = UIKeyboardTypeDecimalPad;
        if (self.item.cardLimit != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardLimit];
        }
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡余额
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        if (self.item.cardBalance != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardBalance];
        }
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡备注
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.cardMemo;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 是否已账单日结算
    if ([title isEqualToString:kTitle6]) {
        newReminderCell.type = SSJCreditCardCellTypeSubTitle;
        newReminderCell.cellTitle = title;
        newReminderCell.cellSubTitle = @"账户详情类别以账单日结算,流水在记账与报表仍以月末结算";
        self.billDateSettleMentButton.on = self.item.settleAtRepaymentDay;
        newReminderCell.accessoryView = self.billDateSettleMentButton;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账单日
    if ([title isEqualToString:kTitle7]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",self.item.cardBillingDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",self.item.cardBillingDay]]];
        [attributeddetail addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, detail.length)];
        newReminderCell.cellAtrributedDetail = attributeddetail;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 还款日
    if ([title isEqualToString:kTitle8]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",self.item.cardRepaymentDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",self.item.cardRepaymentDay]]];
        [attributeddetail addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, detail.length)];
        newReminderCell.cellAtrributedDetail = attributeddetail;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 还款日提醒
    if ([title isEqualToString:kTitle9]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        self.remindStateButton.on = self.item.remindState;
        newReminderCell.accessoryView = self.remindStateButton;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 编辑卡片颜色
    if ([title isEqualToString:kTitle10]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return newReminderCell;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    self.item.settleAtRepaymentDay = self.billDateSettleMentButton.isOn;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
    }];
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

-(SSJBillingDaySelectView *)billingDateSelectView{
    if (!_billingDateSelectView) {
        _billingDateSelectView = [[SSJBillingDaySelectView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 500) Type:SSJDateSelectViewTypeShortMonth];
        __weak typeof(self) weakSelf = self;
        _billingDateSelectView.dateSetBlock = ^(NSInteger selectedDay){
            weakSelf.item.cardBillingDay = selectedDay;
            [weakSelf.tableView reloadData];
        };
    }
    return _billingDateSelectView;
}

-(SSJBillingDaySelectView *)repaymentDateSelectView{
    if (!_repaymentDateSelectView) {
        _repaymentDateSelectView = [[SSJBillingDaySelectView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 500) Type:SSJDateSelectViewTypeFullMonth];
        __weak typeof(self) weakSelf = self;
        _repaymentDateSelectView.dateSetBlock = ^(NSInteger selectedDay){
            weakSelf.item.cardRepaymentDay = selectedDay;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentDateSelectView;
}

- (UISwitch *)remindStateButton{
    if (!_remindStateButton) {
        _remindStateButton = [[UISwitch alloc]init];
        _remindStateButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
    }
    return _remindStateButton;
}

- (UISwitch *)billDateSettleMentButton{
    if (!_billDateSettleMentButton) {
        _billDateSettleMentButton = [[UISwitch alloc]init];
        _billDateSettleMentButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
    }
    return _billDateSettleMentButton;
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
