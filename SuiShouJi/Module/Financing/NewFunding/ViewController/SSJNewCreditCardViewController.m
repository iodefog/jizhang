

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

@end

@implementation SSJNewCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5],@[kTitle6,kTitle7,kTitle8],@[kTitle9,kTitle10]];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
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
    
    // 信用卡名称
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.cardName;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账户类型
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.detailLabel.text = @"信用卡";
        [newReminderCell.detailLabel sizeToFit];
        newReminderCell.cellDetailImageName = @"ft_creditcard";
    }
    
    // 信用卡额度
    if ([title isEqualToString:kTitle3]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.keyboardType = UIKeyboardTypeDecimalPad;
        newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardLimit];
    }
    
    // 信用卡余额
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardBalance];
    }
    
    // 信用卡备注
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.cardMemo;
    }
    
    // 是否已账单日结算
    if ([title isEqualToString:kTitle6]) {
        newReminderCell.type = SSJCreditCardCellTypeSubTitle;
        newReminderCell.cellTitle = title;
    }
    return newReminderCell;
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
