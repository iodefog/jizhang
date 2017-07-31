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
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJFundingMergeViewController.h"

#import "FMDB.h"

#define NUM @"+-.0123456789"


@interface SSJNewFundingViewController ()

@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableview;

@property (nonatomic,strong) UIBarButtonItem *rightButton;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@property(nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    self.titles = @[@[@"账户名称",@"账户余额",@"选择颜色"],@[@"备注"]];
    self.images = @[@[@"fund_name",@"fund_balance",@"fund_color"],@[@"fund_memo"]];
    if (!self.item) {
        NSString *parentName = [SSJFinancingHomeHelper fundParentNameForFundingParent:self.selectParent];
        self.title = [NSString stringWithFormat:@"新建%@账户",parentName];
        self.item = [[SSJFinancingHomeitem alloc] init];
        self.item.fundingParent = self.selectParent;
        self.item.fundingIcon = [SSJFinancingHomeHelper fundIconForFundingParent:self.selectParent];

    } else {
        self.title = [NSString stringWithFormat:@"编辑%@账户",self.item.fundingParentName];
        self.navigationItem.rightBarButtonItem = self.rightButton;
    }
    
    if (!self.item.startColor.length || !self.item.endColor.length) {
        self.item.startColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].startColor;
        self.item.endColor = [[SSJFinancingGradientColorItem defualtColors] firstObject].endColor;
    }
    
    [self.view addSubview:self.tableview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 80;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return self.footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:@"选择颜色"]) {
        SSJColorSelectViewController *colorSelectVC = [[SSJColorSelectViewController alloc]init];
        
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = self.item.startColor;
        colorItem.endColor = self.item.endColor;
        
        colorSelectVC.fundingColor = colorItem;
        colorSelectVC.fundingAmount = [_amountTextField.text doubleValue];
        colorSelectVC.fundingName = _nameTextField.text;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor){
            weakSelf.item.startColor = selectColor.startColor;
            weakSelf.item.endColor = selectColor.endColor;
            [weakSelf.tableview reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    } else if ([title isEqualToString:@"账户类型"]) {
        SSJFundingTypeSelectViewController *fundingTypeVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        __weak typeof(self) weakSelf = self;
        fundingTypeVC.fundingParentSelectBlock = ^(SSJFundingItem *selectItem){
            weakSelf.item.fundingParent = selectItem.fundingID;
            weakSelf.item.fundingParentName = selectItem.fundingName;
            weakSelf.item.fundingIcon = selectItem.fundingIcon;
            [weakSelf.tableview reloadData];
        };
        [self.navigationController pushViewController:fundingTypeVC animated:YES];
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
    static NSString *cellId = @"SSJModifyFundingTableViewCell";
    SSJModifyFundingTableViewCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJModifyFundingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        NewFundingCell.cellDetail.returnKeyType = UIReturnKeyDone;
    }
    NewFundingCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    NewFundingCell.cellImage = [self.images ssj_objectAtIndexPath:indexPath];

    if ([title isEqualToString:@"账户名称"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        NewFundingCell.cellDetail.text = self.item.fundingName;
        NewFundingCell.cellDetail.tag = 100;
        _nameTextField = NewFundingCell.cellDetail;
        _nameTextField.delegate = self;

    } else if ([title isEqualToString:@"账户余额"]) {
        _amountTextField = NewFundingCell.cellDetail;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账户余额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        NewFundingCell.cellDetail.text = self.item.fundingAmount != 0 ? [[NSString stringWithFormat:@"%f",self.item.fundingAmount]ssj_moneyDecimalDisplayWithDigits:2] :@"";
        NewFundingCell.cellDetail.tag = 101;
        NewFundingCell.cellDetail.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _amountTextField.delegate = self;
    } else if ([title isEqualToString:@"备注"]) {
        NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NewFundingCell.cellDetail.text = self.item.fundingMemo;
        NewFundingCell.cellDetail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        NewFundingCell.cellDetail.tag = 102;
        _memoTextField = NewFundingCell.cellDetail;
        _memoTextField.delegate = self;
    } else if ([title isEqualToString:@"账户类型"]) {
        NewFundingCell.typeImage.image = [UIImage imageNamed:self.item.fundingIcon];
        NewFundingCell.typeTitle.text = self.item.fundingParentName;
        [NewFundingCell.typeTitle sizeToFit];
        NewFundingCell.cellDetail.enabled = NO;
        NewFundingCell.cellDetail.hidden = YES;
        NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isKindOfClass:[UITextField class]]) {
        if (textField.tag == 100) {
            self.item.fundingName = textField.text;
        }
        if (textField.tag == 101){
            NSString *fundingBalance = [[NSString stringWithFormat:@"%f",[textField.text doubleValue]] ssj_moneyDecimalDisplayWithDigits:2];
            self.item.fundingAmount = [fundingBalance doubleValue];
        }
        if (textField.tag == 102){
            self.item.fundingMemo = textField.text;
        }
    }
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender {
    @weakify(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该资金账户，其对应的记账数据将一并删除？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"一并删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self.authCodeAlertView show];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"迁移数据" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        SSJFundingMergeViewController *mergeVc = [[SSJFundingMergeViewController alloc] init];
        [self.navigationController pushViewController:mergeVc animated:YES];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

-(void)saveButtonClicked:(id)sender {
    self.item.fundingName = _nameTextField.text;
    self.item.fundingAmount = [_amountTextField.text doubleValue];
    self.item.fundingMemo = _memoTextField.text;
    
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    }
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        SSJPRINT(@"Could not open db");
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
    if ([SSJFinancingStore checkWhetherSameFundingNameExsitsWith:_item]) {
        [CDAutoHideMessageHUD showMessage:@"已经有相同名称的资金帐户"];
        return;
        
    }
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


- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        
        if (textField.tag == 100) {
            self.item.fundingName = textField.text;
        }
        if (textField.tag == 101){
            NSString *fundingBalance = [[NSString stringWithFormat:@"%f",[textField.text doubleValue]] ssj_moneyDecimalDisplayWithDigits:2];
            self.item.fundingAmount = [fundingBalance doubleValue];
        }
        if (textField.tag == 102){
            self.item.fundingMemo = textField.text;
        }
    }
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
        _rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    }
    return _rightButton;
}

-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]init];
        _footerView.size = CGSizeMake(self.view.width, 80);
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.size = CGSizeMake(self.view.width - 40, 40);
        comfirmButton.center = CGPointMake(_footerView.width / 2, _footerView.height / 2);
        comfirmButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        comfirmButton.layer.cornerRadius = 4.0f;
        [comfirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:comfirmButton];
    }
    return _footerView;
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
