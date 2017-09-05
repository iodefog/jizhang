

//
//  SSJNewCreditCardViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewCreditCardViewController.h"
#import "SSJFundingMergeViewController.h"
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
#import "SSJTextFieldToolbarManager.h"
#import "SSJListMenu.h"
#import "SSJFinancingStore.h"

#define NUM @"+-.0123456789"

static NSString *const kTitle1 = @"账户名称";
static NSString *const kTitle2 = @"账户类型";
static NSString *const kTitle3 = @"信用额度";
static NSString *const kTitle4 = @"余额/欠款";
static NSString *const kTitle5 = @"备注";
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

// 提醒开关
@property (nonatomic, strong) UISwitch *remindStateButton;

// 是否已账单日结算开关
@property (nonatomic, strong) UISwitch *billDateSettleMentButton;

@property (nonatomic, strong) SSJBillingDaySelectView *billingDateSelectView;

@property (nonatomic, strong) SSJBillingDaySelectView *repaymentDateSelectView;

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
    

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.financingItem) {
        if (self.cardType == SSJCrediteCardTypeCrediteCard) {
            self.title = @"添加信用卡账户";
        } else {
            self.title = @"添加蚂蚁花呗账户";
        }
        self.financingItem = [[SSJFinancingHomeitem alloc] init];
        self.financingItem.cardItem = [[SSJCreditCardItem alloc] init];
        self.financingItem.cardItem.settleAtRepaymentDay = YES;
        self.financingItem.cardItem.cardBillingDay = 1;
        self.financingItem.cardItem.cardRepaymentDay = 10;
        self.financingItem.cardItem.cardType = self.cardType;
        self.financingItem.startColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].startColor;
        self.financingItem.endColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].endColor;
    }else{
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
        self.navigationItem.rightBarButtonItem = rightItem;
        if (!self.financingItem.cardItem) {
            self.financingItem.cardItem = [[SSJCreditCardItem alloc] init];
        }
        if (self.financingItem.fundingAmount > 0) {
            self.debtOrbalance = YES;
        } else {
            self.debtOrbalance = NO;
        }
        if (self.financingItem.cardItem.cardBillingDay == 0) {
            self.financingItem.cardItem.cardBillingDay = 1;
        }
        if (self.financingItem.cardItem.cardRepaymentDay == 0) {
            self.financingItem.cardItem.cardRepaymentDay = 10;
        }
    }
    if (self.cardType == SSJCrediteCardTypeCrediteCard) {
        self.title = @"编辑信用卡账户";
    } else {
        self.title = @"编辑蚂蚁花呗账户";
    }
    
    if (self.cardType == SSJCrediteCardTypeAlipay) {
        self.titles = @[@[kTitle1,kTitle3,kTitle4],@[kTitle7,kTitle8],@[kTitle9],@[kTitle10,kTitle5]];
        self.images = @[@[@"loan_person",@"loan_yield",@"loan_money"],@[@"loan_zhangdanri",@"loan_huankuanri"],@[@"loan_clock"  ],@[@"card_yanse",@"loan_memo"]];
        
    } else {
        self.titles = @[@[kTitle1,kTitle3,kTitle4],@[kTitle7,kTitle8],@[kTitle9,kTitle6],@[kTitle10,kTitle5]];
        self.images = @[@[@"loan_person",@"loan_yield",@"loan_money"],@[@"loan_zhangdanri",@"loan_huankuanri"],@[@"loan_clock",@"loan_expires"],@[@"card_yanse",@"loan_memo"]];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

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
        if (self.financingItem.cardItem.hasMadeInstalment) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",不能更改账单日,否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alert addAction:comfirmAction];
            [self.navigationController presentViewController:alert animated:YES completion:NULL];
        } else {
            [SSJAnaliyticsManager event:@"credit_bill_date"];
            self.billingDateSelectView.currentDate = self.financingItem.cardItem.cardBillingDay;
            [self.billingDateSelectView show];
        }
    }
    
    //还款日
    if ([title isEqualToString:kTitle8]) {
        if (self.financingItem.cardItem.hasMadeInstalment) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",不能更改还款日,否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alert addAction:comfirmAction];
            [self.navigationController presentViewController:alert animated:YES completion:NULL];
        } else {
            [SSJAnaliyticsManager event:@"credit_payment_date"];
            self.repaymentDateSelectView.currentDate = self.financingItem.cardItem.cardRepaymentDay;
            [self.repaymentDateSelectView show];
        }
    }
    
    if ([title isEqualToString:kTitle10]) {
        SSJColorSelectViewController *colorSelectVc = [[SSJColorSelectViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        colorSelectVc.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor){
            weakSelf.financingItem.startColor = selectColor.startColor;
            weakSelf.financingItem.endColor = selectColor.endColor;
            [weakSelf.tableView reloadData];
        };
        colorSelectVc.fundingItem = self.financingItem;
        [self.navigationController pushViewController:colorSelectVc animated:YES];
    }
    
    if ([title isEqualToString:kTitle9]) {
        if (self.financingItem.cardItem.remindItem) {
            SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
            remindEditeVc.needToSave = NO;
            remindEditeVc.item = self.financingItem.cardItem.remindItem;
            __weak typeof(self) weakSelf = self;
            remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item){
                weakSelf.financingItem.cardItem.remindItem = item;
                [weakSelf.tableView reloadData];
            };
            remindEditeVc.deleteReminderAction = ^(){
                weakSelf.financingItem.cardItem.remindItem = nil;
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
        newReminderCell.textInput.text = self.financingItem.fundingName;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.textInput.returnKeyType = UIReturnKeyDone;
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
            newReminderCell.cellDetailImageName = @"ft_mayihuabei";
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
        if (self.financingItem.cardItem.cardLimit != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.financingItem.cardItem.cardLimit];
        }
        newReminderCell.textInput.tag = 101;
        newReminderCell.textInput.delegate = self;
        [newReminderCell.textInput ssj_installToolbar];
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        _limitInput = newReminderCell.textInput;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡余额
    if ([title isEqualToString:kTitle4]) {
        newReminderCell.type = SSJCreditCardBalanceCell;
        if (!self.debtOrbalance) {
            newReminderCell.cellTitle = @"当前欠款";
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入欠款" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        } else {
            newReminderCell.cellTitle = @"当前余额";
            newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入余额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        }
        
        if (self.financingItem.cardItem.fundingAmount != 0) {
            newReminderCell.textInput.text = [NSString stringWithFormat:@"%.2f",self.financingItem.cardItem.fundingAmount];
        }
        _balaceInput = newReminderCell.textInput;
        newReminderCell.textInput.tag = 102;
        newReminderCell.textInput.delegate = self;
        @weakify(self);
        newReminderCell.showBalanceTypeSelectViewBlock = ^(CGPoint arrowPoint, BOOL isExpand, SSJCreditCardEditeCell *cell) {
            @strongify(self);
            self.debtOrbalanceChoice.selectedIndex = self.debtOrbalance;
            [self.debtOrbalanceChoice showInView:self.view atPoint:[cell convertPoint:CGPointMake(arrowPoint.x, arrowPoint.y + 10) toView:self.view] superViewInsets:UIEdgeInsetsMake(0, 15, 0, 0) finishHandle:NULL dismissHandle:^(SSJListMenu *listMenu) {
                self.debtOrbalance = listMenu.selectedIndex;
                double currentMoney = fabs([cell.textInput.text doubleValue]);
                if (!self.debtOrbalance) {
                    cell.cellTitle = @"当前欠款";
                    cell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入欠款" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
                    if (cell.textInput.text.length) {
                        cell.textInput.text = [[NSString stringWithFormat:@"%f",-currentMoney] ssj_moneyDecimalDisplayWithDigits:2];
                        self.financingItem.cardItem.fundingAmount = -currentMoney;
                    }
                } else {
                    cell.cellTitle = @"当前余额";
                    cell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入余额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
                    if (cell.textInput.text.length) {
                        cell.textInput.text = [[NSString stringWithFormat:@"%f",currentMoney] ssj_moneyDecimalDisplayWithDigits:2];
                        self.financingItem.cardItem.fundingAmount = currentMoney;
                    }

                }
            }];

        };
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 信用卡备注
    if ([title isEqualToString:kTitle5]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoInput = newReminderCell.textInput;
        newReminderCell.textInput.text = self.financingItem.cardItem.fundingMemo;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 103;
        newReminderCell.textInput.returnKeyType = UIReturnKeyDone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 是否已账单日结算
    if ([title isEqualToString:kTitle6]) {
        newReminderCell.type = SSJCreditCardCellTypeSubTitle;
        newReminderCell.cellTitle = title;
        newReminderCell.cellSubTitle = @"开启后资金账户详情列表以账单日结算";
        self.billDateSettleMentButton.on = self.financingItem.cardItem.settleAtRepaymentDay;
        newReminderCell.accessoryView = self.billDateSettleMentButton;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 账单日
    if ([title isEqualToString:kTitle7]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellTitle = title;
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",(long)self.financingItem.cardItem.cardBillingDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",(long)self.financingItem.cardItem.cardBillingDay]]];
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
        NSString *detail = [NSString stringWithFormat:@"每月%ld日",(long)self.financingItem.cardItem.cardRepaymentDay];
        NSMutableAttributedString *attributeddetail = [[NSMutableAttributedString alloc]initWithString:detail];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, detail.length)];
        [attributeddetail addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[detail rangeOfString:[NSString stringWithFormat:@"%ld",(long)self.financingItem.cardItem.cardRepaymentDay]]];
        [attributeddetail addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, detail.length)];
        newReminderCell.cellAtrributedDetail = attributeddetail;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 还款日提醒
    if ([title isEqualToString:kTitle9]) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellDetail = [self.financingItem.cardItem.remindItem.remindDate formattedDateWithFormat:@"yyyy-MM-dd"];
        newReminderCell.cellTitle = title;
        self.remindStateButton.on = self.financingItem.cardItem.remindItem.remindState;
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
        item.startColor = self.financingItem.startColor;
        item.endColor = self.financingItem.endColor;
        newReminderCell.colorItem = item;
    }
    return newReminderCell;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
    [self.view endEditing:YES];
    self.financingItem.cardItem.settleAtRepaymentDay = self.billDateSettleMentButton.isOn;
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    self.financingItem.cardItem.fundingName = _nameInput.text;
    self.financingItem.cardItem.fundingMemo = _memoInput.text;
    self.financingItem.cardItem.cardType = self.cardType;
    if (![numberPre evaluateWithObject:_balaceInput.text] && [_balaceInput.text doubleValue] != 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    } else if (!self.financingItem.cardItem.fundingName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入信用卡名称"];
        return;
    } else if (self.financingItem.cardItem.fundingName.length > 13) {
        [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
        return;
    } else if (self.financingItem.cardItem.cardLimit == 0) {
        [CDAutoHideMessageHUD showMessage:@"信用卡额度不能为0"];
        return;
    } else if (self.financingItem.cardItem.fundingMemo.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"信用卡备注不能超过15个字"];
        return;
    }
    
    @weakify(self);
    
    [SSJFinancingStore saveFundingItem:self.financingItem Success:^(SSJFinancingHomeitem *item) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        if (self.addNewCardBlock) {
            self.addNewCardBlock(self.financingItem);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)rightButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    @weakify(self);
    
    [SSJFinancingStore fundHasDataOrNotWithFundid:self.financingItem.fundingID Success:^(BOOL hasData) {
        @strongify(self);
        if (hasData) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该资金账户，其对应的记账数据将一并删除" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"一并删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                @strongify(self);
                [self.authCodeAlertView show];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"迁移数据" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                @strongify(self);
                SSJFundingMergeViewController *mergeVc = [[SSJFundingMergeViewController alloc] init];
                mergeVc.transferOutFundItem = self.financingItem;
                mergeVc.transferOutType = SSJFundsTransferTypeCreditCard;
                mergeVc.transferInSelectable = YES;
                mergeVc.transferOutSelectable = NO;
                mergeVc.needToDelete = YES;
                [self.navigationController pushViewController:mergeVc animated:YES];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
            [self presentViewController:alert animated:YES completion:NULL];
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该资金账户，其对应的记账数据将一并删除？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                @strongify(self);
                [self.authCodeAlertView show];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    } failure:^(NSError *error) {
        
    }];


    
    
}

- (void)remindSwitchChange:(id)sender{
    if (self.financingItem.cardItem.remindItem.remindId.length) {
        self.financingItem.cardItem.remindItem.remindState = self.remindStateButton.isOn;
    }else{
        if (self.remindStateButton.isOn) {
            [SSJAnaliyticsManager event:@"credit_remind"];
            SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
            remindEditeVc.needToSave = NO;
            SSJReminderItem *item = [[SSJReminderItem alloc]init];
            item.remindCycle = 4;
            item.remindType = SSJReminderTypeCreditCard;
            if (self.financingItem.fundingName) {
                item.remindName = [NSString stringWithFormat:@"%@还款日提醒",self.financingItem.fundingName];
            }
            if (self.financingItem.fundingMemo) {
                item.remindMemo = self.financingItem.fundingMemo;
            }
            if ([NSDate date].day > self.financingItem.cardItem.cardRepaymentDay) {
                item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month + 1 day:self.financingItem.cardItem.cardRepaymentDay hour:12 minute:0 second:0];
            }else{
                item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:self.financingItem.cardItem.cardRepaymentDay hour:12 minute:0 second:0];
            }
            item.remindState = 1;
            remindEditeVc.item = item;
            __weak typeof(self) weakSelf = self;
            remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item){
                weakSelf.financingItem.cardItem.remindItem = item;
                [weakSelf.tableView reloadData];
            };
            remindEditeVc.deleteReminderAction = ^(){
                self.financingItem.cardItem.remindItem = nil;
                [weakSelf.tableView reloadData];
            };
            
            [self.navigationController pushViewController:remindEditeVc animated:YES];
        }
    }
}

- (void)billDateSettleMentButtonClicked{
    if (!self.billDateSettleMentButton.isOn && self.financingItem.cardItem.hasMadeInstalment) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您使用了\"分期还款功能\",需\"以账单日结算\",否则每月账单会错乱哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
        [alert addAction:comfirmAction];
        __weak typeof(self) weakSelf = self;
        [self.navigationController presentViewController:alert animated:YES completion:^{
            [weakSelf.billDateSettleMentButton setOn:YES animated:YES];
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 102){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if (![string isEqualToString:filtered]) {
            return NO;
        }
        
        if (!self.debtOrbalance) {
            NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
            text = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            text = [text ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"-%@", text];
            return NO;
        }
    }
    
    if (textField.tag == 101){
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        self.financingItem.cardItem.cardLimit = [text doubleValue];
        return NO;
    }
    if (textField.tag == 102){
        if ([textField.text rangeOfString:@"+"].location != NSNotFound) {
            NSString *nunberStr = [text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            nunberStr = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            nunberStr = [nunberStr ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"+%@", nunberStr];
        } else if ([textField.text rangeOfString:@"-"].location != NSNotFound) {
            NSString *nunberStr = [textField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
            nunberStr = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
            nunberStr = [nunberStr ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"-%@", nunberStr];
        } else {
            textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        }
        self.financingItem.cardItem.fundingAmount = [textField.text doubleValue];
        return NO;
    }


    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.financingItem.cardItem.fundingName = textField.text;
    }else if (textField.tag == 101){
        self.financingItem.cardItem.cardLimit = [textField.text doubleValue];
    }else if (textField.tag == 102){
        self.financingItem.fundingAmount = [textField.text doubleValue];
    }else if (textField.tag == 103){
        self.financingItem.cardItem.fundingMemo = textField.text;
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
            weakSelf.financingItem.cardItem.cardBillingDay = selectedDay;
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
            if (selectedDay != weakSelf.financingItem.cardItem.remindItem.remindDate.day && weakSelf.financingItem.cardItem.remindItem.remindId.length) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"还款日已改，是否需要更改提醒时间"  action:[SSJAlertViewAction actionWithTitle:@"暂不更改" handler:NULL],[SSJAlertViewAction actionWithTitle:@"立即更改" handler:^(SSJAlertViewAction *action) {
                    weakSelf.financingItem.cardItem.remindItem.remindDate = [NSDate dateWithYear:weakSelf.financingItem.cardItem.remindItem.remindDate.year month:weakSelf.financingItem.cardItem.remindItem.remindDate.month day:selectedDay hour:weakSelf.financingItem.cardItem.remindItem.remindDate.hour minute:weakSelf.financingItem.cardItem.remindItem.remindDate.minute second:weakSelf.financingItem.cardItem.remindItem.remindDate.second];
                    [weakSelf.tableView reloadData];
                }],nil];
            }
            weakSelf.financingItem.cardItem.cardRepaymentDay = selectedDay;
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
            [wself deleteFundingItem:wself.financingItem type:1];
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
        _debtOrbalanceChoice = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
        _debtOrbalanceChoice.maxDisplayRowCount = 2;
        _debtOrbalanceChoice.gapBetweenImageAndTitle = 0;
        _debtOrbalanceChoice.numberOfLines = 0;
        _debtOrbalanceChoice.rowHeight = 70.f;
        _debtOrbalanceChoice.titleFont = nil;
        _debtOrbalanceChoice.contentAlignment = UIControlContentHorizontalAlignmentLeft;
        _debtOrbalanceChoice.backgroundColor = [UIColor clearColor];
        _debtOrbalanceChoice.items = [self debtOrbalanceChoiceItems];
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

- (NSArray *)debtOrbalanceChoiceItems {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    style.lineSpacing = 7;
    
    NSMutableAttributedString *firstTitle = [[NSMutableAttributedString alloc] initWithString:@"当前欠款\n输入数字为负数，代表当前信用卡有欠款"];
    
    [firstTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, firstTitle.length)];

    [firstTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, 3)];
    
    [firstTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, 3)];
    
    [firstTitle addAttribute:NSForegroundColorAttributeName value:SSJ_SECONDARY_COLOR range:NSMakeRange(4, firstTitle.length - 4)];
    
    [firstTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(4, firstTitle.length - 4)];


    SSJListMenuItem *firstItem = [SSJListMenuItem itemWithImageName:nil title:nil normalTitleColor:[UIColor redColor] selectedTitleColor:nil normalImageColor:nil selectedImageColor:nil backgroundColor:nil attributedText:firstTitle];

    [tempArr addObject:firstItem];
    
    NSMutableAttributedString *secondTitle = [[NSMutableAttributedString alloc] initWithString:@"当前余额\n输入数字为正数，代表当前信用卡有余额"];
    
    [secondTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, secondTitle.length)];

    [secondTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, 3)];
    
    [secondTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(0, 3)];

    [secondTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(4, secondTitle.length - 4)];
    
    [secondTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(4, secondTitle.length - 4)];

    
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
