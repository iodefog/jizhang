

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
#import "SSJReminderItem.h"
#import "SSJLocalNotificationStore.h"
#import "SSJColorSelectViewController.h"
#import "SSJReminderEditeViewController.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJDataSynchronizer.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJListMenu.h"

#define NUM @"+-.0123456789"

static NSString *const kTitle1 = @"账户名称";
static NSString *const kTitle2 = @"账户类型";
static NSString *const kTitle3 = @"信用额度";
static NSString *const kTitle4 = @"余额/欠款";
static NSString *const kTitle5 = @"备注说明";
static NSString *const kTitle6 = @"以账单日结算";
static NSString *const kTitle7 = @"账单日";
static NSString *const kTitle8 = @"还款日";
static NSString *const kTitle9 = @"还款日提醒";
static NSString *const kTitle10 = @"编辑卡片颜色";

static NSString * SSJCreditCardEditeCellIdentifier = @"SSJCreditCardEditeCellIdentifier";

@interface SSJNewCreditCardViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) SSJCreditCardItem *item;

// 提醒开关
@property (nonatomic, strong) UISwitch *remindStateButton;

// 是否已账单日结算开关
@property (nonatomic, strong) UISwitch *billDateSettleMentButton;

@property (nonatomic, strong) SSJBillingDaySelectView *billingDateSelectView;

@property (nonatomic, strong) SSJBillingDaySelectView *repaymentDateSelectView;

@property (nonatomic, strong) SSJReminderItem *remindItem;

@property (nonatomic, strong) UIView *saveFooterView;

@property (nonatomic, strong) UIView *colorSelectView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

@property (nonatomic, strong) SSJListMenu *debtOrbalanceChoice;

// 0是欠款,1是余额
@property (nonatomic) BOOL debtOrbalance;

@end

@implementation SSJNewCreditCardViewController{
    UITextField *_limitInput;
    UITextField *_balaceInput;
    UITextField *_nameInput;
    UITextField *_memoInput;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.cardType == SSJCrediteCardTypeAlipay) {
        self.titles = @[@[kTitle1,kTitle3,kTitle4],@[kTitle7,kTitle8],@[kTitle9],@[kTitle10,kTitle5]];
        self.images = @[@[@"loan_person",@"loan_yield",@"loan_money"],@[@"loan_zhangdanri",@"loan_huankuanri"],@[@"loan_clock"  ],@[@"card_yanse",@"loan_memo"]];
        
    } else {
        self.titles = @[@[kTitle1,kTitle3,kTitle4],@[kTitle7,kTitle8],@[kTitle9,kTitle6],@[kTitle10,kTitle5]];
        self.images = @[@[@"loan_person",@"loan_yield",@"loan_money"],@[@"loan_zhangdanri",@"loan_huankuanri"],@[@"loan_clock",@"loan_expires"],@[@"card_yanse",@"loan_memo"]];
    }

    if (!self.cardId.length) {
        self.title = @"添加资金账户";
        self.item = [[SSJCreditCardItem alloc]init];
        self.item.settleAtRepaymentDay = YES;
        self.item.cardBillingDay = 1;
        self.item.cardRepaymentDay = 10;
        self.item.cardType = self.cardType;
        self.item.startColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].startColor;
        self.item.endColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].endColor;
    }else{
        self.title = @"编辑资金账户";
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
        self.navigationItem.rightBarButtonItem = rightItem;
        self.item = [SSJCreditCardStore queryCreditCardDetailWithCardId:self.cardId];
        if (self.item.cardBillingDay == 0) {
            self.item.cardBillingDay = 1;
        }
        if (self.item.cardRepaymentDay == 0) {
            self.item.cardRepaymentDay = 10;
        }
        self.cardType = self.item.cardType;
    }
    if (self.item.remindId.length) {
        self.remindItem = [SSJLocalNotificationStore queryReminderItemForID:self.item.remindId];
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    
    //账单日
    if ([title isEqualToString:kTitle7] && self.cardType != SSJCrediteCardTypeAlipay) {
        if (self.item.hasMadeInstalment) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",不能更改账单日,否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alert addAction:comfirmAction];
            [self.navigationController presentViewController:alert animated:YES completion:NULL];
        } else {
            [SSJAnaliyticsManager event:@"credit_bill_date"];
            self.billingDateSelectView.currentDate = self.item.cardBillingDay;
            [self.billingDateSelectView show];
        }
    }
    
    //还款日
    if ([title isEqualToString:kTitle8]) {
        if (self.item.hasMadeInstalment) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",不能更改还款日,否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alert addAction:comfirmAction];
            [self.navigationController presentViewController:alert animated:YES completion:NULL];
        } else {
            [SSJAnaliyticsManager event:@"credit_payment_date"];
            self.repaymentDateSelectView.currentDate = self.item.cardRepaymentDay;
            [self.repaymentDateSelectView show];
        }
    }
    
    if ([title isEqualToString:kTitle10]) {
        SSJColorSelectViewController *colorSelectVc = [[SSJColorSelectViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        colorSelectVc.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor){
            weakSelf.item.startColor = selectColor.startColor;
            weakSelf.item.endColor = selectColor.endColor;
            [weakSelf.tableView reloadData];
        };
        colorSelectVc.fundingAmount = self.item.cardBalance;
        colorSelectVc.fundingName = self.item.cardName;
        SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
        item.startColor = self.item.startColor;
        item.endColor = self.item.endColor;
        colorSelectVc.fundingColor = item;
        [self.navigationController pushViewController:colorSelectVc animated:YES];
    }
    
    if ([title isEqualToString:kTitle9]) {
        if (self.item.remindId.length) {
            SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
            remindEditeVc.needToSave = NO;
            remindEditeVc.item = self.remindItem;
            __weak typeof(self) weakSelf = self;
            remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item){
                weakSelf.remindItem = item;
                weakSelf.item.remindState = 1;
                weakSelf.item.remindId = item.remindId;
                [weakSelf.tableView reloadData];
            };
            remindEditeVc.deleteReminderAction = ^(){
                weakSelf.remindItem = nil;
                [weakSelf.tableView reloadData];
            };
            [self.navigationController pushViewController:remindEditeVc animated:YES];
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
    newReminderCell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    // 信用卡名称
    newReminderCell.cellImageName = image;
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入账户名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.item.cardName;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        _nameInput = newReminderCell.textInput;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账户类型
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        if (self.cardType == SSJCrediteCardTypeAlipay) {
            newReminderCell.cellDetail = @"蚂蚁花呗";
            newReminderCell.cellDetailImageName = @"ft_huabei";
        } else {
            newReminderCell.cellDetail = @"信用卡";
            newReminderCell.cellDetailImageName = @"ft_creditcard";
        }
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡额度
    if ([title isEqualToString:kTitle3]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        if (self.cardType == SSJCrediteCardTypeAlipay) {
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入蚂蚁花呗额度" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        } else {
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入信用卡额度" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        }
        newReminderCell.textInput.keyboardType = UIKeyboardTypeDecimalPad;
        if (self.item.cardLimit != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardLimit];
        }
        newReminderCell.textInput.tag = 101;
        newReminderCell.textInput.delegate = self;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        _limitInput = newReminderCell.textInput;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡余额
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardBalanceCell;
        newReminderCell.cellTitle = title;
        if (self.cardType == SSJCrediteCardTypeAlipay) {
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"当前蚂蚁花呗余额/欠款" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        } else {
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"当前信用卡余额/欠款" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        }
        if (self.item.cardBalance != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.item.cardBalance];
        }
        _balaceInput = newReminderCell.textInput;
        newReminderCell.textInput.tag = 102;
        newReminderCell.textInput.delegate = self;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡备注
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoInput = newReminderCell.textInput;
        newReminderCell.textInput.text = self.item.cardMemo;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 103;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 是否已账单日结算
    if ([title isEqualToString:kTitle6]) {
        newReminderCell.type = SSJCreditCardCellTypeSubTitle;
        newReminderCell.cellTitle = title;
        newReminderCell.cellSubTitle = @"开启后资金账户详情列表以账单日结算";
        self.billDateSettleMentButton.on = self.item.settleAtRepaymentDay;
        newReminderCell.accessoryView = self.billDateSettleMentButton;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账单日
    if ([title isEqualToString:kTitle7]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",(long)self.item.cardBillingDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",(long)self.item.cardBillingDay]]];
        [attributeddetail addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, detail.length)];
        newReminderCell.cellAtrributedDetail = attributeddetail;
        if (self.cardType == SSJCrediteCardTypeAlipay) {
            newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        } else {
            newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
    }
    
    // 还款日
    if ([title isEqualToString:kTitle8]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",(long)self.item.cardRepaymentDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",(long)self.item.cardRepaymentDay]]];
        [attributeddetail addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, detail.length)];
        newReminderCell.cellAtrributedDetail = attributeddetail;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 还款日提醒
    if ([title isEqualToString:kTitle9]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellDetail = [self.remindItem.remindDate formattedDateWithFormat:@"yyyy-MM-dd"];
        newReminderCell.cellTitle = title;
        self.remindStateButton.on = self.remindItem.remindState;
        newReminderCell.accessoryView = self.remindStateButton;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 编辑卡片颜色
    if ([title isEqualToString:kTitle10]) {
        newReminderCell.type = SSJCreditCardCellColorSelect;
        newReminderCell.cellTitle = title;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
        item.startColor = self.item.startColor;
        item.endColor = self.item.endColor;
        newReminderCell.colorItem = item;
    }
    return newReminderCell;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    self.item.settleAtRepaymentDay = self.billDateSettleMentButton.isOn;
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    self.item.cardName = _nameInput.text;
    self.item.cardMemo = _memoInput.text;
    self.item.cardType = self.cardType;
    if (![numberPre evaluateWithObject:_balaceInput.text] && [_balaceInput.text doubleValue] != 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    } else if (!self.item.cardName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入信用卡名称"];
        return;
    } else if (self.item.cardName.length > 13) {
        [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
        return;
    } else if (self.item.cardLimit == 0) {
        [CDAutoHideMessageHUD showMessage:@"信用卡额度不能为0"];
        return;
    } else if (self.item.cardMemo.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"信用卡备注不能超过15个字"];
        return;
    }
    
    if (!self.remindItem.remindId.length) {
        self.item.remindId = self.remindItem.remindId;
    }
    if (!self.item.remindId.length) {
        if (self.item.cardName) {
            self.remindItem.remindName = [NSString stringWithFormat:@"%@还款日",self.item.cardName];
        }
        if (self.item.cardMemo) {
            self.remindItem.remindMemo = self.item.cardMemo;
        }
    }
    
    @weakify(self);
    
    [SSJCreditCardStore saveCreditCardWithCardItem:self.item remindItem:self.remindItem Success:^(NSInteger operatortype){
        @strongify(self);
        if (!operatortype) {
            UIViewController *viewControllerNeedToPop = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
            [self.navigationController popToViewController:viewControllerNeedToPop animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.addNewCardBlock) {
            self.addNewCardBlock(self.item);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)rightButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除该资金账户吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.authCodeAlertView show];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {

        if (textField.tag == 100) {
            self.item.cardName = textField.text;
        }
        if (textField.tag == 101){
            textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:9];
            self.item.cardLimit = [textField.text doubleValue];
        }
        if (textField.tag == 102){
            if ([textField.text rangeOfString:@"+"].location != NSNotFound) {
                NSString *nunberStr = [textField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
                nunberStr = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
                nunberStr = [nunberStr ssj_reserveDecimalDigits:2 intDigits:9];
                textField.text = [NSString stringWithFormat:@"+%@", nunberStr];
            } else if ([textField.text rangeOfString:@"-"].location != NSNotFound) {
                NSString *nunberStr = [textField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
                nunberStr = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
                nunberStr = [nunberStr ssj_reserveDecimalDigits:2 intDigits:9];
                textField.text = [NSString stringWithFormat:@"-%@", nunberStr];
            } else {
                textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:9];
            }
            self.item.cardBalance = [textField.text doubleValue];
        }
        if (textField.tag == 103){
            self.item.cardMemo = textField.text;
        }
    }
}

- (void)remindSwitchChange:(id)sender{
    if (self.remindItem) {
        self.remindItem.remindState = self.remindStateButton.isOn;
    }else{
        if (self.remindStateButton.isOn) {
            [SSJAnaliyticsManager event:@"credit_remind"];
            SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
            remindEditeVc.needToSave = NO;
            SSJReminderItem *item = [[SSJReminderItem alloc]init];
            item.remindCycle = 4;
            item.remindType = SSJReminderTypeCreditCard;
            if (self.item.cardName) {
                item.remindName = [NSString stringWithFormat:@"%@还款日提醒",self.item.cardName];
            }
            if (self.item.cardMemo) {
                item.remindMemo = self.item.cardMemo;
            }
            if ([NSDate date].day > self.item.cardRepaymentDay) {
                item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month + 1 day:self.item.cardRepaymentDay hour:12 minute:0 second:0];
            }else{
                item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:self.item.cardRepaymentDay hour:12 minute:0 second:0];
            }
            item.remindState = 1;
            remindEditeVc.item = item;
            __weak typeof(self) weakSelf = self;
            remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item){
                weakSelf.remindItem = item;
                weakSelf.item.remindState = 1;
                weakSelf.item.remindId = item.remindId;
                [weakSelf.tableView reloadData];
            };
            remindEditeVc.deleteReminderAction = ^(){
                weakSelf.remindItem = nil;
                [weakSelf.tableView reloadData];
            };
            [self.navigationController pushViewController:remindEditeVc animated:YES];
        }
    }
}

- (void)billDateSettleMentButtonClicked{
    if (!self.billDateSettleMentButton.isOn && self.item.hasMadeInstalment) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",需\"以账单日结算\",否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
        [alert addAction:comfirmAction];
        __weak typeof(self) weakSelf = self;
        [self.navigationController presentViewController:alert animated:YES completion:^{
            [weakSelf.billDateSettleMentButton setOn:YES animated:YES];
        }];
    }
}

- (void)debtOrbalanceChoiceChange {
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    /*NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == 100 || textField.tag == 103) {
        if (string.length == 0) return YES;
        if (existedLength - selectedLength + replaceLength > 13) {
            if (textField.tag == 100) {
                [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
            }else{
                [CDAutoHideMessageHUD showMessage:@"备注不能超过13个字"];
            }
            return NO;
        }
    }else*/ if (textField.tag == 102){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![string isEqualToString:filtered]) {
            return NO;
        }
    }
    /*if (textField.tag == 100) {
        self.item.cardName = newStr;
    }else if (textField.tag == 101){
        self.item.cardLimit = [newStr doubleValue];
    }else if (textField.tag == 102){
        self.item.cardBalance = [newStr doubleValue];
    }else if (textField.tag == 103){
        self.item.cardMemo = newStr;
    }*/
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.cardName = textField.text;
    }else if (textField.tag == 101){
        self.item.cardLimit = [textField.text doubleValue];
    }else if (textField.tag == 102){
        self.item.cardBalance = [textField.text doubleValue];
    }else if (textField.tag == 103){
        self.item.cardMemo = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
        if (self.cardType == SSJCrediteCardTypeAlipay) {
            _repaymentDateSelectView = [[SSJBillingDaySelectView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 500) Type:SSJDateSelectViewTypeAlipay];
        } else {
            _repaymentDateSelectView = [[SSJBillingDaySelectView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 500) Type:SSJDateSelectViewTypeShortMonth];
        }
        __weak typeof(self) weakSelf = self;
        _repaymentDateSelectView.dateSetBlock = ^(NSInteger selectedDay){
            if (selectedDay != weakSelf.remindItem.remindDate.day && weakSelf.item.remindId.length) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"还款日已改，是否需要更改提醒时间"  action:[SSJAlertViewAction actionWithTitle:@"暂不更改" handler:NULL],[SSJAlertViewAction actionWithTitle:@"立即更改" handler:^(SSJAlertViewAction *action) {
                    weakSelf.remindItem.remindDate = [NSDate dateWithYear:weakSelf.remindItem.remindDate.year month:weakSelf.remindItem.remindDate.month day:selectedDay hour:weakSelf.remindItem.remindDate.hour minute:weakSelf.remindItem.remindDate.minute second:weakSelf.remindItem.remindDate.second];
                    [weakSelf.tableView reloadData];
                }],nil];
            }
            weakSelf.item.cardRepaymentDay = selectedDay;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentDateSelectView;
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

- (UISwitch *)remindStateButton{
    if (!_remindStateButton) {
        _remindStateButton = [[UISwitch alloc]init];
        _remindStateButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
        [_remindStateButton addTarget:self action:@selector(remindSwitchChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _remindStateButton;
}

- (UISwitch *)billDateSettleMentButton{
    if (!_billDateSettleMentButton) {
        _billDateSettleMentButton = [[UISwitch alloc]init];
        _billDateSettleMentButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
        [_billDateSettleMentButton addTarget:self action:@selector(billDateSettleMentButtonClicked) forControlEvents:UIControlEventValueChanged];
    }
    return _billDateSettleMentButton;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)authCodeAlertView {
    if (!_authCodeAlertView) {
        __weak typeof(self) wself = self;
        _authCodeAlertView = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        _authCodeAlertView.finishVerification = ^{
            [wself deleteFundingItem:wself.item type:1];
        };
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        style.alignment = NSTextAlignmentCenter;
        _authCodeAlertView.message = [[NSAttributedString alloc] initWithString:@"删除后将难以恢复\n仍然删除，请输入下列验证码" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _authCodeAlertView;
}

- (SSJListMenu *)debtOrbalanceChoice {
    if (!_debtOrbalanceChoice) {
        _debtOrbalanceChoice = [[SSJListMenu alloc] init];
        _debtOrbalanceChoice = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 154, 50)];
        _debtOrbalanceChoice.maxDisplayRowCount = 1;
        _debtOrbalanceChoice.gapBetweenImageAndTitle = 0;
        _debtOrbalanceChoice.backgroundColor = [UIColor clearColor];
        _debtOrbalanceChoice.items = [self debtOrbalanceChoiceItems];
        [_debtOrbalanceChoice addTarget:self action:@selector(debtOrbalanceChoiceChange) forControlEvents:UIControlEventValueChanged];

    }
    return _debtOrbalanceChoice;
}

#pragma mark - Private
- (void)deleteFundingItem:(SSJBaseCellItem *)item type:(BOOL)type{
    __weak typeof(self) weakSelf = self;
    [SSJFinancingHomeHelper deleteFundingWithFundingItem:item deleteType:type Success:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        SSJPRINT(@"%@",[error localizedDescription]);
    }];
}

/**
 *   限制输入框小数点(输入框只改变时候调用valueChange)
 *
 *  @param TF  输入框
 *  @param num 小数点后限制位数
 */
-(void)setupTextFiledNum:(UITextField *)TF num:(int)num
{
    NSString *str = [TF.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    NSArray *arr = [TF.text componentsSeparatedByString:@"."];
    if ([str isEqualToString:@"0."] || [str isEqualToString:@"."]) {
        TF.text = @"0.";
    }else if (str.length == 2) {
        if ([str floatValue] == 0) {
            TF.text = @"0";
        }else if(arr.count < 2){
            TF.text = [NSString stringWithFormat:@"%d",[str intValue]];
        }
    }
    
    if (arr.count > 2) {
        TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > num) {
            TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:num]];
        }
    }
}

- (NSArray *)debtOrbalanceChoiceItems {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    style.lineSpacing = 7;
    
    NSMutableAttributedString *firstTitle = [[NSMutableAttributedString alloc] initWithString:@"当前欠款\n输入数字为负数，代表当前信用卡有欠款"];
    
    [firstTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, firstTitle.length)];

    [firstTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, 3)];
    
    [firstTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, 3)];
    
    [firstTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(4, firstTitle.length)];
    
    [firstTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(4, firstTitle.length)];


    SSJListMenuItem *firstItem = [SSJListMenuItem itemWithImageName:nil title:nil normalTitleColor:nil selectedTitleColor:nil normalImageColor:nil selectedImageColor:nil backgroundColor:nil attributedText:firstTitle];

    [tempArr addObject:firstItem];
    
    NSMutableAttributedString *secondTitle = [[NSMutableAttributedString alloc] initWithString:@"当前余额\n输入数字为负数，代表当前信用卡有余额"];
    
    [secondTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, secondTitle.length)];

    [secondTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, 3)];
    
    [secondTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, 3)];

    [secondTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(4, firstTitle.length)];
    
    [secondTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(4, firstTitle.length)];

    
    SSJListMenuItem *secondItem = [SSJListMenuItem itemWithImageName:nil title:nil normalTitleColor:nil selectedTitleColor:nil normalImageColor:nil selectedImageColor:nil backgroundColor:nil attributedText:secondTitle];
    
    [tempArr addObject:secondItem];
 
    return tempArr;
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
