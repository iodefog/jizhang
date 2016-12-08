//
//  SSJRepaymentDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJInstalmentEditeViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJReminderDateSelectView.h"
#import "SSJMonthSelectView.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"

#import "SSJRepaymentStore.h"
#import "SSJFinancingHomeHelper.h"

static NSString *const SSJInstalmentCellIdentifier = @"SSJInstalmentCellIdentifier";

static NSString *const SSJPoundageCellIdentifier = @"SSJPoundageCellIdentifier";

static NSString *const kTitle1 = @"还款方式";
static NSString *const kTitle2 = @"账单分期月份";
static NSString *const kTitle3 = @"期数";
static NSString *const kTitle4 = @"申请分期金额";
static NSString *const kTitle5 = @"手续费";
static NSString *const kTitle6 = @"分期申请日";

@interface SSJInstalmentEditeViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) SSJReminderDateSelectView *repaymentTimeView;

@property(nonatomic, strong) SSJMonthSelectView *repaymentMonthSelectView;

@property(nonatomic, strong) UITextField *instalmentCountView;

@end

@implementation SSJInstalmentEditeViewController

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
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJInstalmentCellIdentifier];
    [self.tableView registerClass:[SSJAddOrEditLoanMultiLabelCell class] forCellReuseIdentifier:SSJPoundageCellIdentifier];

    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.chargeItem && !self.repaymentModel.repaymentId) {
        self.repaymentModel.applyDate = [NSDate date];
        self.repaymentModel.instalmentCout = 1;
        NSDate *repaymentDate = [NSDate date];
        if (repaymentDate.day < self.repaymentModel.cardBillingDay) {
            repaymentDate = [repaymentDate dateBySubtractingMonths:2];
        }else {
            repaymentDate = [repaymentDate dateBySubtractingMonths:1];
        }
        self.repaymentModel.repaymentMonth = repaymentDate;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle5] || [title isEqualToString:kTitle6]) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 80 ;
    }
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle6]) {
        self.repaymentTimeView.currentDate = self.repaymentModel.applyDate;
        [self.repaymentTimeView show];
    }else if ([title isEqualToString:kTitle2]) {
        self.repaymentMonthSelectView.currentDate = self.repaymentModel.repaymentMonth;
        [self.repaymentMonthSelectView show];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
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
        poundageModifyCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        poundageModifyCell.textField.delegate = self;
        [poundageModifyCell setNeedsLayout];
        
        return poundageModifyCell;
    }else{
        SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJInstalmentCellIdentifier];
        repaymentModifyCell.cellTitle = title;
        repaymentModifyCell.cellImageName = image;
        if ([title isEqualToString:kTitle4]) {
            repaymentModifyCell.cellInput.hidden = NO;
        }else {
            repaymentModifyCell.cellInput.hidden = YES;
        }
        if (([title isEqualToString:kTitle2] || [title isEqualToString:kTitle6])) {
            repaymentModifyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            repaymentModifyCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if ([title isEqualToString:kTitle1]) {
            repaymentModifyCell.cellDetail = @"分期还款";
        }else if ([title isEqualToString:kTitle2]) {
            repaymentModifyCell.cellDetail = [self.repaymentModel.repaymentMonth formattedDateWithFormat:@"yyyy年MM月"];
        }else if ([title isEqualToString:kTitle3]) {
            repaymentModifyCell.accessoryView = self.instalmentCountView;
        }else if ([title isEqualToString:kTitle4]) {
            if (self.repaymentModel.repaymentMoney != 0) {
                repaymentModifyCell.cellInput.text = [NSString stringWithFormat:@"%@",self.repaymentModel.repaymentMoney];
            }
            repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            repaymentModifyCell.cellInput.tag = 101;
            repaymentModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        }else if ([title isEqualToString:kTitle6]) {
            repaymentModifyCell.cellDetail = [self.repaymentModel.applyDate formattedDateWithFormat:@"yyyy-MM-dd"];
        }
        return repaymentModifyCell;
        
    }
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        
    }else if (textField.tag == 101){
        self.repaymentModel.memo = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
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
                textField.text = [NSString stringWithFormat:@"%ld",self.repaymentModel.instalmentCout];
            }else{
                self.repaymentModel.instalmentCout = 0;
                textField.text = @"";
            }
        }else if (textField.tag == 101) {
            textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:0];
            self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
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
    }
}

- (void)plusButtonClicked:(id)sender{
    self.repaymentModel.instalmentCout = self.repaymentModel.instalmentCout + 1;
    if (self.repaymentModel.instalmentCout > 36) {
        self.repaymentModel.instalmentCout = 36;
        [CDAutoHideMessageHUD showMessage:@"分期期数最大为36期哦"];
    }
    self.instalmentCountView.text = [NSString stringWithFormat:@"%ld",self.repaymentModel.instalmentCout];
}

- (void)minusButtonClicked:(id)sender{
    self.repaymentModel.instalmentCout = self.repaymentModel.instalmentCout - 1;
    if (self.repaymentModel.instalmentCout < 1) {
        self.repaymentModel.instalmentCout = 1;
        [CDAutoHideMessageHUD showMessage:@"分期期数最小为1期哦"];
        }
    self.instalmentCountView.text = [NSString stringWithFormat:@"%ld",self.repaymentModel.instalmentCout];
}

- (void)saveButtonClicked:(id)sender{
    if (self.repaymentModel.repaymentMoney == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入还款金额"];
        return;
    }
    if ([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay] isLaterThan:self.repaymentModel.applyDate]) {
        [CDAutoHideMessageHUD showMessage:@"本期账单还没有出不能分期哦"];
        return;
    }
    if (!self.repaymentModel.instalmentCout) {
        [CDAutoHideMessageHUD showMessage:@"请选择分期期数"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [SSJRepaymentStore saveRepaymentWithRepaymentModel:self.repaymentModel Success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
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
        _instalmentCountView.backgroundColor = [UIColor redColor];
        _instalmentCountView.textAlignment = NSTextAlignmentCenter;
        _instalmentCountView.text = [NSString stringWithFormat:@"%ld",self.repaymentModel.instalmentCout];
        _instalmentCountView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        UIButton *plusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        UIButton *minusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [minusButton addTarget:self action:@selector(minusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [minusButton setTitle:@"-" forState:UIControlStateNormal];
        _instalmentCountView.rightViewMode = UITextFieldViewModeAlways;
        _instalmentCountView.leftViewMode = UITextFieldViewModeAlways;
        _instalmentCountView.rightView = plusButton;
        _instalmentCountView.leftView = minusButton;
        _instalmentCountView.tag = 100;
        _instalmentCountView.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _instalmentCountView;
}

#pragma mark - private



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
