//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewFundingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJModifyFundingTableViewCell.h"
#import "SSJColorSelectViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJDataSynchronizer.h"
#import "SSJFinancingStore.h"
#import "SSJFinancingHomeHelper.h"

#import "FMDB.h"

#define NUM @"+-.0123456789"


@interface SSJNewFundingViewController ()

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableview;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@end

@implementation SSJNewFundingViewController{
    UITextField *_nameTextField;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[@"账户名称",@"账户余额",@"备注"],@[@"账户类型",@"选择颜色"]];
    self.images = @[@[@"fund_name",@"fund_balance",@"fund_memo"],@[@"fund_type",@"fund_color"]];
    if (!self.item) {
        self.title = @"添加资金账户";
        self.item = [[SSJFinancingHomeitem alloc] init];
    } else {
        self.title = @"编辑资金账户";
    }
    
    if (!self.item.startColor.length || !self.item.endColor.length) {
        self.item.startColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].startColor;
        self.item.endColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].endColor;
    }
    
    if (self.selectParent.length) {
        self.item.fundingParentName = [SSJFinancingHomeHelper fundParentNameForFundingParent:self.selectParent];
        self.item.fundingIcon = [SSJFinancingHomeHelper fundIconForFundingParent:self.selectParent];
        self.item.fundingParent = self.selectParent;
    }
    
    [self.view addSubview:self.tableview];
    self.navigationItem.rightBarButtonItem = self.rightButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:@"选择颜色"]) {
        SSJColorSelectViewController *colorSelectVC = [[SSJColorSelectViewController alloc]init];
        colorSelectVC.fundingColor = _selectColor;
        colorSelectVC.fundingAmount = [_amountTextField.text doubleValue];
        colorSelectVC.fundingName = _nameTextField.text;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor){
            weakSelf.item.startColor = selectColor.startColor;
            weakSelf.item.endColor = selectColor.endColor;
            [weakSelf.tableview reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    }
//        else if (indexPath.section == 3) {
//        SSJFundingTypeSelectViewController *fundingTypeVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
//        __weak typeof(self) weakSelf = self;
//            fundingTypeVC.typeSelectedBlock = ^(NSString *selectParent , NSString *selectIcon){
//            _selectParent = selectParent;
//            _selectIcoin = selectIcon;
//            [weakSelf.tableview reloadData];
//        };
//        [self.navigationController pushViewController:fundingTypeVC animated:YES];
//    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJModifyFundingTableViewCell";
    SSJModifyFundingTableViewCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJModifyFundingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NewFundingCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    NewFundingCell.cellImage = [self.images ssj_objectAtIndexPath:indexPath];

    if ([title isEqualToString:@"账户名称"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        NewFundingCell.cellDetail.text = self.item.fundingName;
        _nameTextField = NewFundingCell.cellDetail;
        _nameTextField.delegate = self;

    } else if ([title isEqualToString:@"账户余额"]) {
        _amountTextField = NewFundingCell.cellDetail;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户余额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        NewFundingCell.cellDetail.text = [[NSString stringWithFormat:@"%f",self.item.fundingAmount] ssj_moneyDecimalDisplayWithDigits:2];
        NewFundingCell.cellDetail.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _amountTextField.delegate = self;
    } else if ([title isEqualToString:@"备注"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewFundingCell.cellDetail.text = self.item.fundingMemo;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoTextField = NewFundingCell.cellDetail;
        _memoTextField.delegate = self;
    } else if ([title isEqualToString:@"账户类型"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewFundingCell.typeImage.image = [UIImage imageNamed:self.item.fundingIcon];
        NewFundingCell.typeTitle.text = self.item.fundingParentName;
        [NewFundingCell.typeTitle sizeToFit];
        NewFundingCell.cellDetail.enabled = NO;
        NewFundingCell.cellDetail.hidden = YES;
    } else if ([title isEqualToString:@"选择颜色"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = self.item.startColor;
        colorItem.endColor = self.item.endColor;
        //            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
        NewFundingCell.item = colorItem;
        //            NewFundingCell.cellText.text = @"选择颜色";
        NewFundingCell.cellDetail.enabled = NO;
        NewFundingCell.cellDetail.hidden = YES;
        NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return NewFundingCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSInteger existedLength = textField.text.length;
//    NSInteger selectedLength = range.length;
//    NSInteger replaceLength = string.length;
    /*if (textField == _nameTextField || textField == _memoTextField) {
        if (string.length == 0) return YES;
        if (existedLength - selectedLength + replaceLength > 13) {
            if (textField == _nameTextField) {
                [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
            }else{
                [CDAutoHideMessageHUD showMessage:@"备注不能超过13个字"];
            }
            return NO;
        }
    }else */if (textField == _amountTextField){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![string isEqualToString:filtered]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Getter
-(TPKeyboardAvoidingTableView *)tableview{
    if (!_tableview) {
        _tableview = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.backgroundColor = [UIColor clearColor];
        _tableview.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableview.tableFooterView = [[UIView alloc] init];
        [_tableview setSeparatorInset:UIEdgeInsetsZero];
    }
    return _tableview;
}

-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked)];
    }
    return _rightButton;
}

#pragma mark - Private
-(void)rightButtonClicked{
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    }
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
    }
    if ([_nameTextField.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入资金账户名称"];
        return;
    }
    if (_nameTextField.text.length > 13) {
        [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
        return;
    }
    if (_memoTextField.text.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"备注不能超过15个字"];
        return;
    }
    
    self.item.fundingName = _nameTextField.text;
    self.item.fundingAmount = [_amountTextField.text doubleValue];
    self.item.fundingMemo = _memoTextField.text;
    
    __weak typeof(self) weakSelf = self;
    [SSJFinancingStore saveFundingItem:self.item Success:^(SSJFinancingHomeitem *item) {
        if (weakSelf.addNewFundBlock) {
            weakSelf.addNewFundBlock(item);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        if (item.fundOperatortype == 0) {
            UIViewController *viewControllerNeedToPop = [self.navigationController.viewControllers ssj_safeObjectAtIndex:self.navigationController.viewControllers.count - 3];
            [self.navigationController popToViewController:viewControllerNeedToPop animated:YES];
        } else {
            [weakSelf.navigationController popViewControllerAnimated:YES];

        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

- (void)transferTextDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if (textField == _amountTextField) {
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
    }
}

@end
