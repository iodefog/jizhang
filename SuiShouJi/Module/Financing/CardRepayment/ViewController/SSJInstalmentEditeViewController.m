//
//  SSJRepaymentDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJInstalmentEditeViewController.h"
#import "SSJFundingDetailsViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJMonthSelectView.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJInstalmentDateSelectCell.h"
#import "SSJHomeDatePickerView.h"
#import "SSJTextFieldToolbarManager.h"

#import "SSJRepaymentStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJCreditCardStore.h"
#import "SSJDataSynchronizer.h"

static NSString *const SSJInstalmentCellIdentifier = @"SSJInstalmentCellIdentifier";

static NSString *const SSJPoundageCellIdentifier = @"SSJPoundageCellIdentifier";

static NSString *const SSJInstalmentDateSelectCellIdentifier = @"SSJInstalmentDateSelectCellIdentifier";

static NSString *const kTitle1 = @"还款方式";
static NSString *const kTitle2 = @"账单分期月份";
static NSString *const kTitle3 = @"期数";
static NSString *const kTitle4 = @"申请分期金额";
static NSString *const kTitle5 = @"手续费率";
static NSString *const kTitle6 = @"分期申请日";

@interface SSJInstalmentEditeViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) SSJHomeDatePickerView *repaymentTimeView;

@property(nonatomic, strong) SSJMonthSelectView *repaymentMonthSelectView;

@property(nonatomic, strong) UITextField *instalmentCountView;

@end

@implementation SSJInstalmentEditeViewController{
    UILabel *_instalDateLab;
    UILabel *_poundageLab;
    UILabel *_fenQiLab;
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
    self.titles = @[@[kTitle1,kTitle2,kTitle3],@[kTitle4,kTitle5,kTitle6]];
    if (self.repaymentModel.repaymentId.length) {
        self.originalRepaymentModel = [self.repaymentModel copy];
    }
//    loan_expires
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJInstalmentCellIdentifier];
    [self.tableView registerClass:[SSJAddOrEditLoanMultiLabelCell class] forCellReuseIdentifier:SSJPoundageCellIdentifier];
    [self.tableView registerClass:[SSJInstalmentDateSelectCell class] forCellReuseIdentifier:SSJInstalmentDateSelectCellIdentifier];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.chargeItem && !self.repaymentModel.repaymentId) {
        self.repaymentModel.applyDate = [NSDate date];
        self.repaymentModel.instalmentCout = 3;
        NSDate *repaymentDate = [NSDate date];
        if (repaymentDate.day < self.repaymentModel.cardBillingDay) {
            repaymentDate = [repaymentDate dateBySubtractingMonths:1];
        }else {
            repaymentDate = repaymentDate;
        }
        self.repaymentModel.repaymentMonth = repaymentDate;
        self.title = @"新建账单分期";
    } else {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
        self.title = @"编辑账单分期";
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 65;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return self.saveFooterView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section  {
    if (section == 1) {
        return 80 ;
    }
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle6]) {
        self.repaymentTimeView.date = self.repaymentModel.applyDate;
        [self.repaymentTimeView show];
    }else if ([title isEqualToString:kTitle2]) {
        self.repaymentMonthSelectView.currentDate = self.repaymentModel.repaymentMonth;
        [self.repaymentMonthSelectView show];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle5]) {
        SSJAddOrEditLoanMultiLabelCell *poundageModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJPoundageCellIdentifier];
        poundageModifyCell.imageView.image = [[UIImage imageNamed:@"loan_yield"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        poundageModifyCell.textLabel.text = title;
        poundageModifyCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        poundageModifyCell.textField.tag = 102;
        if (self.repaymentModel.poundageRate) {
            poundageModifyCell.textField.text = [NSString stringWithFormat:@"%.2f", [self.repaymentModel.poundageRate doubleValue] * 100];
        }
        _poundageLab = poundageModifyCell.subtitleLabel;
        poundageModifyCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        poundageModifyCell.textField.delegate = self;
        [poundageModifyCell.textField ssj_installToolbar];
        [poundageModifyCell setNeedsLayout];
        [self updatePoundageLab];
        return poundageModifyCell;
    }else if([title isEqualToString:kTitle6]) {
        SSJInstalmentDateSelectCell *dateSelectCell = [tableView dequeueReusableCellWithIdentifier:SSJInstalmentDateSelectCellIdentifier];
        dateSelectCell.imageView.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        dateSelectCell.textLabel.text = title;
        dateSelectCell.detailLabel.text = [self.repaymentModel.applyDate formattedDateWithFormat:@"yyyy-MM-dd"];
        [dateSelectCell setNeedsLayout];
        _instalDateLab = dateSelectCell.subtitleLabel;
        dateSelectCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self updatePoundageLab];
        return dateSelectCell;
    }else if ([title isEqualToString:kTitle4]){
        SSJAddOrEditLoanMultiLabelCell *fenQiCell = [tableView dequeueReusableCellWithIdentifier:SSJPoundageCellIdentifier];
        fenQiCell.imageView.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fenQiCell.textLabel.text = title;
        _fenQiLab = fenQiCell.subtitleLabel;
        fenQiCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        fenQiCell.textField.tag = 101;
        fenQiCell.textField.delegate = self;
        [fenQiCell.textField ssj_installToolbar];
        if ([self.repaymentModel.repaymentMoney doubleValue] > 0) {
            fenQiCell.textField.text = [NSString stringWithFormat:@"%.2f",[self.repaymentModel.repaymentMoney doubleValue]];
        }
        fenQiCell.haspercentLab = NO;
        [fenQiCell setNeedsLayout];
        fenQiCell.textField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        [self updateFenqiLab];
        return fenQiCell;
    }else{
        SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJInstalmentCellIdentifier];
        repaymentModifyCell.cellTitle = title;
        repaymentModifyCell.cellImageName = image;
        if ([title isEqualToString:kTitle2]) {
            repaymentModifyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            repaymentModifyCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if ([title isEqualToString:kTitle1]) {
            repaymentModifyCell.cellDetail = @"分期还款";
            repaymentModifyCell.cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        }else if ([title isEqualToString:kTitle2]) {
            repaymentModifyCell.cellDetail = [self.repaymentModel.repaymentMonth formattedDateWithFormat:@"yyyy年MM月"];
        }else if ([title isEqualToString:kTitle3]) {
            repaymentModifyCell.accessoryView = self.instalmentCountView;
        }
        return repaymentModifyCell;
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 101){
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
    }
    
    if (textField.tag == 102){
        NSString *poudageStr = [[NSString stringWithFormat:@"%f",[textField.text doubleValue] / 100] ssj_moneyDecimalDisplayWithDigits:2];
        self.repaymentModel.poundageRate = [NSDecimalNumber decimalNumberWithString:poudageStr];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == 101) {
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    }
    
    if (textField.tag == 102) {
        self.repaymentModel.poundageRate = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    }
    
    [self updatePoundageLab];
    
    return YES;
}

#pragma mark - Event
- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        if (textField.tag == 100) {
            if (textField.text.length > 0) {
                if ([textField.text integerValue] > 36) {
                    [CDAutoHideMessageHUD showMessage:@"分期期数最大为36期哦"];
                    self.repaymentModel.instalmentCout = 36;
                }else if ([textField.text integerValue] < 1) {
                    [CDAutoHideMessageHUD showMessage:@"分期期数最小为1期哦"];
                    self.repaymentModel.instalmentCout = 1;
                }else{
                    self.repaymentModel.instalmentCout = [textField.text integerValue];
                }
                textField.text = [NSString stringWithFormat:@"%ld",(long)self.repaymentModel.instalmentCout];
            }else{
                self.repaymentModel.instalmentCout = 0;
                textField.text = @"";
            }
        }else if (textField.tag == 101) {
            textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:9];
            if (textField.text.length) {
                self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
            } else {
                self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:@"0.00"];
            }
        }else if (textField.tag == 102) {
            textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:0];
            if ([textField.text doubleValue] > 100) {
                textField.text = @"100.00";
                [CDAutoHideMessageHUD showMessage:@"手续费不能超过100%哦"];
            }
            double rate = [textField.text doubleValue] / 100;
            NSString *rateStr = [NSString stringWithFormat:@"%f",rate];
            self.repaymentModel.poundageRate = [NSDecimalNumber decimalNumberWithString:rateStr];
        }
        [self updatePoundageLab];
    }
}

- (void)plusButtonClicked:(id)sender{
    self.repaymentModel.instalmentCout = self.repaymentModel.instalmentCout + 1;
    if (self.repaymentModel.instalmentCout > 36) {
        self.repaymentModel.instalmentCout = 36;
        [CDAutoHideMessageHUD showMessage:@"分期期数最大为36期哦"];
    }
    [self updatePoundageLab];
    self.instalmentCountView.text = [NSString stringWithFormat:@"%ld",(long)self.repaymentModel.instalmentCout];
}

- (void)minusButtonClicked:(id)sender{
    self.repaymentModel.instalmentCout = self.repaymentModel.instalmentCout - 1;
    if (self.repaymentModel.instalmentCout < 1) {
        self.repaymentModel.instalmentCout = 1;
        [CDAutoHideMessageHUD showMessage:@"分期期数最小为1期哦"];
    }
    [self updatePoundageLab];
    self.instalmentCountView.text = [NSString stringWithFormat:@"%ld",(long)self.repaymentModel.instalmentCout];
}

- (void)saveButtonClicked:(id)sender{
    if (self.repaymentModel.repaymentMoney == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入还款金额"];
        return;
    }
    if (!self.repaymentModel.instalmentCout) {
        [CDAutoHideMessageHUD showMessage:@"请选择分期期数"];
        return;
    }
    if ([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay] isLaterThan:[NSDate date]]) {
        [CDAutoHideMessageHUD showMessage:@"本期账单还没有出不能分期哦"];
        return;
    }
    if (self.repaymentModel.cardBillingDay < self.repaymentModel.cardRepaymentDay) {
        if (!([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay]isEarlierThanOrEqualTo:self.repaymentModel.applyDate] && [[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardRepaymentDay] isLaterThanOrEqualTo:self.repaymentModel.applyDate])) {
            [CDAutoHideMessageHUD showMessage:@"分期日期只能在账单日和还款日之间申请哦"];
            return;
        }
    } else {
        if (!([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay] isEarlierThanOrEqualTo:self.repaymentModel.applyDate] && [[[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardRepaymentDay] dateByAddingMonths:1] isLaterThanOrEqualTo:self.repaymentModel.applyDate])) {
            [CDAutoHideMessageHUD showMessage:@"分期日期只能在账单日和还款日之间申请哦"];
            return;
        }
    }
    if ([self checkTheInstalCountWithMonth:self.repaymentModel.repaymentMonth] > 0 && !self.repaymentModel.repaymentId.length) {
        [CDAutoHideMessageHUD showMessage:@"每个账单周期只能申请一次分期哦"];
        return;
    }
    if (![SSJRepaymentStore checkTheMoneyIsValidForTheRepaymentWithRepaymentModel:self.repaymentModel]) {
        [CDAutoHideMessageHUD showMessage:@"分期金额不能大于当期账单金额哦"];
        return;
    }
    if ((self.repaymentModel.instalmentCout != self.originalRepaymentModel.instalmentCout
         || self.repaymentModel.repaymentMoney != self.originalRepaymentModel.repaymentMoney
         || self.repaymentModel.poundageRate != self.originalRepaymentModel.poundageRate)
        && self.repaymentModel.repaymentId.length) {
        
        [self.view endEditing:YES];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SSJRepaymentStore saveRepaymentWithRepaymentModel:self.repaymentModel Success:^{
                for (UIViewController *viewcontroller in self.navigationController.viewControllers) {
                    if ([viewcontroller isKindOfClass:[SSJFundingDetailsViewController class]]) {
                        [weakSelf.navigationController popToViewController:viewcontroller animated:YES];
                    }
                }
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }];
        NSString *massage = [NSString stringWithFormat:@"若修改分期还款，则先前生成的%ld期相关流水将被删除并根据新的设置重新生成哦，你确定要执行吗？",(long)self.originalRepaymentModel.instalmentCout];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:massage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        return;
    } else {
        __weak typeof(self) weakSelf = self;
        [SSJRepaymentStore saveRepaymentWithRepaymentModel:self.repaymentModel Success:^{
            for (UIViewController *viewcontroller in self.navigationController.viewControllers) {
                if ([viewcontroller isKindOfClass:[SSJFundingDetailsViewController class]]) {
                    [weakSelf.navigationController popToViewController:viewcontroller animated:YES];
                }
            }
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
        return;
    }
}

- (void)deleteButtonClicked{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定要删除此分期设置吗?删除后先前生前的分期本金和手续费流水将被一并删除哦?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SSJRepaymentStore deleteRepaymentWithRepaymentModel:self.repaymentModel Success:^{
            for (UIViewController *viewcontroller in self.navigationController.viewControllers) {
                if ([viewcontroller isKindOfClass:[SSJFundingDetailsViewController class]]) {
                    [weakSelf.navigationController popToViewController:viewcontroller animated:YES];
                }
            }
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }];
    [alert addAction:cancel];
    [alert addAction:comfirm];
    [self.navigationController presentViewController:alert animated:YES completion:NULL];    
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

- (UIView *)saveFooterView{
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

- (UITextField *)instalmentCountView{
    if (!_instalmentCountView) {
        _instalmentCountView = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 110, 25)];
        _instalmentCountView.textAlignment = NSTextAlignmentCenter;
        _instalmentCountView.text = [NSString stringWithFormat:@"%ld",(long)self.repaymentModel.instalmentCout];
        _instalmentCountView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        UIButton *plusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [plusButton setImage:[UIImage ssj_themeImageWithName:@"card_repaymentplus"] forState:UIControlStateNormal];
        UIButton *minusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [minusButton addTarget:self action:@selector(minusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [minusButton setImage:[UIImage ssj_themeImageWithName:@"card_repaymentminus"] forState:UIControlStateNormal];
        _instalmentCountView.rightViewMode = UITextFieldViewModeAlways;
        _instalmentCountView.leftViewMode = UITextFieldViewModeAlways;
        _instalmentCountView.rightView = plusButton;
        _instalmentCountView.leftView = minusButton;
        _instalmentCountView.tag = 100;
        _instalmentCountView.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _instalmentCountView;
}

- (SSJHomeDatePickerView *)repaymentTimeView{
    if (!_repaymentTimeView) {
        _repaymentTimeView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 350)];
        _repaymentTimeView.datePickerMode = SSJDatePickerModeDate;
        __weak typeof(self) weakSelf = self;
        _repaymentTimeView.confirmBlock = ^(SSJHomeDatePickerView *view){
            weakSelf.repaymentModel.applyDate = view.date;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentTimeView;
}

- (SSJMonthSelectView *)repaymentMonthSelectView{
    if (!_repaymentMonthSelectView) {
        _repaymentMonthSelectView = [[SSJMonthSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        __weak typeof(self) weakSelf = self;
        _repaymentMonthSelectView.timerSetBlock = ^(NSDate *date){
            weakSelf.repaymentModel.repaymentMonth = date;
            [weakSelf updateFenqiLab];
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentMonthSelectView;
}

#pragma mark - private
- (void)updatePoundageLab{

    double principalMoney;
    if (self.repaymentModel.instalmentCout) {
        principalMoney = [self.repaymentModel.repaymentMoney doubleValue] / self.repaymentModel.instalmentCout;
    } else {
        principalMoney = 0;
    }
    NSString *pripalStr = [[NSString stringWithFormat:@"%f",principalMoney] ssj_moneyDecimalDisplayWithDigits:2];
    double poundageMoney;
    if (self.repaymentModel.instalmentCout) {
        poundageMoney = [self.repaymentModel.repaymentMoney doubleValue] * [self.repaymentModel.poundageRate doubleValue];
    } else {
        poundageMoney = 0;
    }
    NSString *poundageStr = [[NSString stringWithFormat:@"%f",poundageMoney] ssj_moneyDecimalDisplayWithDigits:2];
    double sumMoney = principalMoney + poundageMoney;
    NSString *sumMoneyStr = [[NSString stringWithFormat:@"%f",sumMoney] ssj_moneyDecimalDisplayWithDigits:2];
    NSString *firstStr = [NSString stringWithFormat:@"每期应还本金%@,手续费%@",pripalStr,poundageStr];
    NSMutableAttributedString *firstAtrributeStr = [[NSMutableAttributedString alloc]initWithString:firstStr];
    [firstAtrributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:NSMakeRange(6, pripalStr.length)];
    [firstAtrributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:NSMakeRange(firstStr.length - poundageStr.length, poundageStr.length)];
    _poundageLab.attributedText = firstAtrributeStr;
    [_poundageLab sizeToFit];
    NSString *secondStr = [NSString stringWithFormat:@"每月%ld号信用卡将自动生成%@元的分期流水",(long)self.repaymentModel.applyDate.day,sumMoneyStr];
    NSMutableAttributedString *secondAtrributeStr = [[NSMutableAttributedString alloc]initWithString:secondStr];
    [secondAtrributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[secondStr rangeOfString:sumMoneyStr]];
    _instalDateLab.attributedText = secondAtrributeStr;
    [_instalDateLab sizeToFit];
}

- (void)updateFenqiLab{
    [SSJCreditCardStore queryTheTotalExpenceForCardId:self.repaymentModel.cardId cardBillingDay:self.repaymentModel.cardBillingDay month:self.repaymentModel.repaymentMonth Success:^(double sumMoney) {
        if (sumMoney > 0) {
            sumMoney = 0;
        }
        NSString *totalArrearStr = [[NSString stringWithFormat:@"%f",fabs(sumMoney)] ssj_moneyDecimalDisplayWithDigits:2];
        NSString *oldStr = [NSString stringWithFormat:@"该账单周期内总欠款为%@元",totalArrearStr];
        _fenQiLab.attributedText = [oldStr attributeStrWithTargetStr:totalArrearStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
        [_fenQiLab sizeToFit];
    } failure:^(NSError *error) {
        
    }];

}

- (NSInteger)checkTheInstalCountWithMonth:(NSDate *)month{
    __block NSInteger instalmentCount;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        instalmentCount = [db intForQuery:@"select count(1) from bk_credit_repayment where cuserid = ? and operatortype <> 2 and iinstalmentcount > 0 and crepaymentmonth = ?",userId,[month formattedDateWithFormat:@"yyyy-MM"]];
    }];
    return instalmentCount;
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
