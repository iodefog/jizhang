
//
//  SSJChargeCicleModifyViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString *const kTitle1 = @"账本";
static NSString *const kTitle2 = @"收支类型";
static NSString *const kTitle3 = @"类别";
static NSString *const kTitle4 = @"金额";
static NSString *const kTitle5 = @"备注";
static NSString *const kTitle6 = @"照片";
static NSString *const kTitle7 = @"循环周期";
static NSString *const kTitle8 = @"资金账户";
static NSString *const kTitle9 = @"起始日期";
static NSString *const kTitle10 = @"不支持设置历史日期的周期账";

static NSString * SSJChargeCircleEditeCellIdentifier = @"chargeCircleEditeCell";


#import "SSJChargeCicleModifyViewController.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJCircleChargeStore.h"
#import "SSJCategoryListHelper.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJBillTypeSelectViewController.h"
#import "SSJChargeCircleTimeSelectView.h"
#import "SSJCircleChargeTypeSelectView.h"
#import "SSJRecordMakingCategoryItem.h"

@interface SSJChargeCicleModifyViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property(nonatomic, strong) UIView *saveFooterView;
@property(nonatomic, strong) SSJFundingTypeSelectView *fundSelectView;
@property(nonatomic, strong) SSJChargeCircleSelectView *circleSelectView;
@property(nonatomic, strong) SSJChargeCircleTimeSelectView *chargeCircleTimeView;
@property(nonatomic, strong) SSJCircleChargeTypeSelectView *chargeTypeSelectView;
@end

@implementation SSJChargeCicleModifyViewController{
    UIImage *_selectedImage;
    UITextField *_moneyInput;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加周期记账";
        self.hidesBottomBarWhenPushed = YES;
        self.hideKeyboradWhenTouch = YES;
    }
    return self;
} 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5,kTitle6],@[kTitle7,kTitle8,kTitle9,kTitle10]];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange)name:UITextFieldTextDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.item == nil) {
        __weak typeof(self) weakSelf = self;
        [SSJCircleChargeStore queryDefualtItemWithIncomeOrExpence:1 Success:^(SSJBillingChargeCellItem *item) {
            weakSelf.item = item;
            [weakSelf.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle10]) {
        return 30;
    }else{
        return 55;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80 ;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle8]) {
        [self.fundSelectView show];
    }
    if ([title isEqualToString:kTitle7]) {
        [self.circleSelectView show];
    }
    if ([title isEqualToString:kTitle3]) {
        SSJBillTypeSelectViewController *billTypeSelectVC = [[SSJBillTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        __weak typeof(self) weakSelf = self;
        billTypeSelectVC.incomeOrExpenture = !self.item.incomeOrExpence;
        billTypeSelectVC.selectedId = self.item.billId;
        billTypeSelectVC.typeSelectBlock = ^(NSString *typeId , NSString *typeName){
            weakSelf.item.typeName = typeName;
            weakSelf.item.billId = typeId;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:billTypeSelectVC animated:YES];
    }
    if ([title isEqualToString:kTitle9]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [dateFormatter dateFromString:self.item.billDate];
        self.chargeCircleTimeView.currentDate = date;
        [self.chargeCircleTimeView show];
    }
    if ([title isEqualToString:kTitle2]) {
        [self.chargeTypeSelectView show];
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *circleModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJChargeCircleEditeCellIdentifier];
    if (!circleModifyCell) {
        circleModifyCell = [[SSJChargeCircleModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    }
    if ([title isEqualToString:kTitle4]) {
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.placeholder = @"￥0.00";
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeNumberPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = 100;
        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle5]) {
        circleModifyCell.cellInput.placeholder = @"选填";
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.tag = 101;
    }else{
        circleModifyCell.cellInput.hidden = YES;
    }
    if ([title isEqualToString:kTitle10]) {
        circleModifyCell.cellSubTitle = title;
        circleModifyCell.cellSubTitleLabel.hidden = NO;
    }else{
        circleModifyCell.cellTitle = title;
        circleModifyCell.cellSubTitleLabel.hidden = YES;
    }
    if ([title isEqualToString:kTitle1]) {
        circleModifyCell.cellDetail = self.item.booksName;
    }else if ([title isEqualToString:kTitle2]) {
        circleModifyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!self.item.incomeOrExpence) {
            circleModifyCell.cellDetail = @"支出";
        }else{
            circleModifyCell.cellDetail = @"收入";
        }
    }else if ([title isEqualToString:kTitle3]) {
        circleModifyCell.cellDetail = self.item.typeName;
    }else if ([title isEqualToString:kTitle4]) {
        circleModifyCell.cellDetail = self.item.money;
    }else if ([title isEqualToString:kTitle5]) {
        circleModifyCell.cellDetail = self.item.chargeMemo;
    }else if ([title isEqualToString:kTitle7]) {
        switch (self.item.chargeCircleType) {
            case 0:
                circleModifyCell.cellDetail = @"每天";
                break;
            case 1:
                circleModifyCell.cellDetail = @"每个工作日";
                break;
            case 2:
                circleModifyCell.cellDetail = @"每个周末";
                break;
            case 3:
                circleModifyCell.cellDetail = @"每周";
                break;
            case 4:
                circleModifyCell.cellDetail = @"每月";
                break;
            case 5:
                circleModifyCell.cellDetail = @"每月最后一天";
                break;
            case 6:
                circleModifyCell.cellDetail = @"每年";
                break;
            default:
                break;
        }
    }else if ([title isEqualToString:kTitle8]) {
        circleModifyCell.cellDetail = self.item.fundName;
    }else if ([title isEqualToString:kTitle9]) {
        circleModifyCell.cellDetail = self.item.billDate;
    }
    return circleModifyCell;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.money = textField.text;
    }else if (textField.tag == 101){
        self.item.chargeMemo = textField.text;
    }
}

#pragma mark - Getter
-(TPKeyboardAvoidingTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

-(UIView *)saveFooterView{
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *quitLogButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        [quitLogButton setTitle:@"保存" forState:UIControlStateNormal];
        quitLogButton.layer.cornerRadius = 3.f;
        quitLogButton.layer.masksToBounds = YES;
        [quitLogButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        [quitLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitLogButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        quitLogButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:quitLogButton];
    }
    return _saveFooterView;
}

-(SSJFundingTypeSelectView *)fundSelectView{
    if (!_fundSelectView) {
        _fundSelectView = [[SSJFundingTypeSelectView alloc]init];
        __weak typeof(self) weakSelf = self;
        _fundSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *item){
            weakSelf.item.fundId = item.fundingID;
            weakSelf.item.fundName = item.fundingName;
            [weakSelf.tableView reloadData];
            [weakSelf.fundSelectView dismiss];
        };
    }
    return _fundSelectView;
}

-(SSJChargeCircleSelectView *)circleSelectView{
    if (!_circleSelectView) {
        _circleSelectView = [[SSJChargeCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        _circleSelectView.chargeCircleSelectBlock = ^(NSInteger chargeCircleType){
            weakSelf.item.chargeCircleType = chargeCircleType;
            [weakSelf.tableView reloadData];
        };
    }
    return _circleSelectView;
}

-(SSJChargeCircleTimeSelectView *)chargeCircleTimeView{
    if (!_chargeCircleTimeView) {
        _chargeCircleTimeView = [[SSJChargeCircleTimeSelectView alloc]initWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        _chargeCircleTimeView.timerSetBlock = ^(NSString *dateStr){
            weakSelf.item.billDate = dateStr;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeCircleTimeView;
}

-(SSJCircleChargeTypeSelectView *)chargeTypeSelectView{
    if (!_chargeTypeSelectView) {
        _chargeTypeSelectView = [[SSJCircleChargeTypeSelectView alloc]init];
        __weak typeof(self) weakSelf = self;
        
        _chargeTypeSelectView.chargeTypeSelectBlock = ^(NSInteger selectType){
            weakSelf.item.incomeOrExpence = selectType;
            SSJRecordMakingCategoryItem *categoryItem = [SSJCategoryListHelper queryfirstCategoryItemWithIncomeOrExpence:!weakSelf.item.incomeOrExpence];
            weakSelf.item.typeName = categoryItem.categoryTitle;
            weakSelf.item.billId = categoryItem.categoryID;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeTypeSelectView;
}

#pragma mark - Private
-(void)transferTextDidChange{
    [self setupTextFiledNum:_moneyInput num:2];
}

-(void)saveButtonClicked:(id)sender{
    
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
