//
//  SSJCreditCardRepaymentViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardRepaymentViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJMonthSelectView.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJReminderDateSelectView.h"
#import "SSJHomeDatePickerView.h"

#import "SSJFinancingHomeHelper.h"
#import "SSJRepaymentStore.h"
#import "SSJCreditCardStore.h"

#import "SSJFundingItem.h"
#import "SSJCreditCardItem.h"
#import "SSJDataSynchronizer.h"

static NSString *const SSJRepaymentEditeCellIdentifier = @"SSJRepaymentEditeCellIdentifier";

static NSString *const kTitle1 = @"待还款账户";
static NSString *const kTitle2 = @"还款金额";
static NSString *const kTitle3 = @"备注";
static NSString *const kTitle4 = @"付款账户";
static NSString *const kTitle5 = @"还款日期";
static NSString *const kTitle6 = @"还款账单月份";


@interface SSJCreditCardRepaymentViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) SSJFundingTypeSelectView *fundSelectView;

@property(nonatomic, strong) SSJHomeDatePickerView *repaymentTimeView;

@property(nonatomic, strong) SSJMonthSelectView *repaymentMonthSelectView;

@end

@implementation SSJCreditCardRepaymentViewController{
    UILabel *_fenQiLab;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"还款";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2,kTitle3],@[kTitle4,kTitle6,kTitle5]];
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"loan_calendar",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJRepaymentEditeCellIdentifier];
    if (self.repaymentModel.repaymentId.length || self.chargeItem) {
        self.repaymentModel = [SSJRepaymentStore queryRepaymentModelWithChargeItem:self.chargeItem];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }else {
        self.repaymentModel.applyDate = [NSDate date];
        self.repaymentModel.repaymentSourceFoundId = [SSJFinancingHomeHelper queryfirstFundItem].fundingID;
        self.repaymentModel.repaymentSourceFoundName = [SSJFinancingHomeHelper queryfirstFundItem].fundingName;
        self.repaymentModel.repaymentSourceFoundImage = [SSJFinancingHomeHelper queryfirstFundItem].fundingIcon;
        NSDate *repaymentDate = [NSDate date];
        if (repaymentDate.day < self.repaymentModel.cardBillingDay) {
            repaymentDate = [repaymentDate dateBySubtractingMonths:1];
        }else {
            repaymentDate = repaymentDate;
        }
        self.repaymentModel.repaymentMonth = repaymentDate;
    }
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
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
    if ([title isEqualToString:kTitle4]) {
        self.fundSelectView.selectFundID = self.repaymentModel.repaymentSourceFoundId;
        self.fundSelectView.exceptionIDs = @[self.repaymentModel.cardId];
        [self.fundSelectView show];
    }else if ([title isEqualToString:kTitle5]) {
        self.repaymentTimeView.date = self.repaymentModel.applyDate;
        [self.repaymentTimeView show];
    }else if ([title isEqualToString:kTitle6]) {
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
    if (indexPath.section == 0 && indexPath.row == 1) {
        static NSString *cellId = @"tempCellID";
        SSJAddOrEditLoanMultiLabelCell *fenQiCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!fenQiCell) {
            fenQiCell = [[SSJAddOrEditLoanMultiLabelCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        fenQiCell.imageView.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fenQiCell.textLabel.text = title;
//        _fenQiLab = fenQiCell.subtitleLabel;
        fenQiCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        fenQiCell.textField.delegate = self;
        fenQiCell.textField.tag = 100;
        if ([self.repaymentModel.repaymentMoney doubleValue] > 0) {
            fenQiCell.textField.text = [NSString stringWithFormat:@"%.2f",[self.repaymentModel.repaymentMoney doubleValue]];
        }
        fenQiCell.haspercentLab = NO;
        [fenQiCell setNeedsLayout];
        fenQiCell.textField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        if ([self.repaymentModel.repaymentMoney doubleValue] > 0) {
            fenQiCell.textField.text = [[NSString stringWithFormat:@"%@",self.repaymentModel.repaymentMoney] ssj_moneyDecimalDisplayWithDigits:2];
        }
        _fenQiLab = fenQiCell.subtitleLabel;
        [self updateFenqiLab];
        [fenQiCell.subtitleLabel sizeToFit];

        return fenQiCell;
    }
    
    SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJRepaymentEditeCellIdentifier];
    repaymentModifyCell.cellInput.delegate = self;

    repaymentModifyCell.cellTitle = title;
    repaymentModifyCell.cellImageName = image;
    if ([title isEqualToString:kTitle2] || [title isEqualToString:kTitle3]) {
        repaymentModifyCell.cellInput.hidden = NO;
    }else {
        repaymentModifyCell.cellInput.hidden = YES;
    }
    if (indexPath.section == 1) {
        repaymentModifyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        repaymentModifyCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([title isEqualToString:kTitle1]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.cardName;
    }else if ([title isEqualToString:kTitle3]) {
        repaymentModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        repaymentModifyCell.cellInput.tag = 101;
        repaymentModifyCell.cellInput.text = self.repaymentModel.memo;
    }else if ([title isEqualToString:kTitle4]) {
        repaymentModifyCell.cellDetail = self.repaymentModel.repaymentSourceFoundName;
        repaymentModifyCell.cellTypeImageName = self.repaymentModel.repaymentSourceFoundImage;
    }else if ([title isEqualToString:kTitle5]) {
        repaymentModifyCell.cellDetail = [self.repaymentModel.applyDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }else if ([title isEqualToString:kTitle6]) {
        repaymentModifyCell.cellDetail = [self.repaymentModel.repaymentMonth formattedDateWithFormat:@"yyyy年MM月"];
    }
    return repaymentModifyCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField.tag == 100) {
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:text];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }else if (textField.tag == 101){
        self.repaymentModel.memo = text;
    }

    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField.tag == 100) {
        [self setupTextFiledNum:textField num:2];
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:textField.text];
    }else if (textField.tag == 101){
        self.repaymentModel.memo = textField.text;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == 100) {
        self.repaymentModel.repaymentMoney = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    }
    
    return YES;
}

#pragma mark - Event


- (void)saveButtonClicked:(id)sender{
    if (self.repaymentModel.repaymentMoney == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入还款金额"];
        return;
    }
    if ([[NSDate dateWithYear:self.repaymentModel.repaymentMonth.year month:self.repaymentModel.repaymentMonth.month day:self.repaymentModel.cardBillingDay] isLaterThan:self.repaymentModel.applyDate]) {
        [CDAutoHideMessageHUD showMessage:@"本期账单还没有出不能还款哦"];
        return;
    }
    
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [SSJRepaymentStore saveRepaymentWithRepaymentModel:self.repaymentModel Success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)deleteButtonClicked{
    [SSJRepaymentStore deleteRepaymentWithRepaymentModel:self.repaymentModel Success:^{
        [self.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
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

-(SSJFundingTypeSelectView *)fundSelectView{
    if (!_fundSelectView) {
        _fundSelectView = [[SSJFundingTypeSelectView alloc]init];
        _fundSelectView.needCreditOrNot = NO;
        __weak typeof(self) weakSelf = self;
        _fundSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *item){
            if (item.fundingID.length) {
                weakSelf.repaymentModel.repaymentSourceFoundId = item.fundingID;
                weakSelf.repaymentModel.repaymentSourceFoundName = item.fundingName;
                weakSelf.repaymentModel.repaymentSourceFoundImage = item.fundingIcon;
                [weakSelf.tableView reloadData];
                [weakSelf.fundSelectView dismiss];
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                        SSJFinancingHomeitem *fundItem = (SSJFinancingHomeitem *)item;
                        weakSelf.repaymentModel.repaymentSourceFoundId = fundItem.fundingID;
                        weakSelf.repaymentModel.repaymentSourceFoundName = fundItem.fundingName;
                        weakSelf.repaymentModel.repaymentSourceFoundImage = fundItem.fundingIcon;
                        [weakSelf.tableView reloadData];
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.repaymentModel.repaymentSourceFoundId = cardItem.cardId;
                        weakSelf.repaymentModel.repaymentSourceFoundName = cardItem.cardName;
                        weakSelf.repaymentModel.repaymentSourceFoundImage = @"ft_creditcard";
                        [weakSelf.tableView reloadData];
                    }
                    
                };
                [weakSelf.fundSelectView dismiss];
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
        };
    }
    return _fundSelectView;
}

- (SSJHomeDatePickerView *)repaymentTimeView{
    if (!_repaymentTimeView) {
        _repaymentTimeView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 360)];
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

#pragma mark - Private
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

- (void)updateFenqiLab{
    [SSJCreditCardStore queryTheTotalExpenceForCardId:self.repaymentModel.cardId cardBillingDay:self.repaymentModel.cardBillingDay month:self.repaymentModel.repaymentMonth Success:^(double sumMoney) {
        if (sumMoney > 0) {
            sumMoney = 0;
        }
        NSString *totalArrearStr = [[NSString stringWithFormat:@"%f",fabs(sumMoney)] ssj_moneyDecimalDisplayWithDigits:2];
        NSString *oldStr = [NSString stringWithFormat:@"该账单周期内总欠款为%@元",totalArrearStr];
        _fenQiLab.attributedText = [oldStr attributeStrWithTargetStr:totalArrearStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];;
        [_fenQiLab sizeToFit];
    } failure:^(NSError *error) {
        
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
