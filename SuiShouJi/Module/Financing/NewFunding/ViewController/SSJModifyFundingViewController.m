//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJModifyFundingViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJColorSelectViewController.h"
#import "SSJModifyFundingTableViewCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJCustomKeyboard.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJFinancingStore.h"

#import "FMDB.h"

#define NUM @"+-.0123456789"

@interface SSJModifyFundingViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@end

@implementation SSJModifyFundingViewController{
    NSArray *_cellTitleArray;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
    UITextField *_nameTextField;
    NSString *_selectParent;
    SSJFinancingGradientColorItem *_selectColor;
    NSString *_selectIcoin;
    double _amountValue;
}

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {\
        self.title = @"编辑资金账户";
//        self.hideKeyboradWhenTouch = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellTitleArray = @[@"账户名称",@"账户余额",@"备注",@"账户类型",@"选择颜色"];
    SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
    item.startColor = self.item.startColor;
    item.endColor = self.item.endColor;

    _selectColor = item;
    _selectParent = self.item.fundingParent;
    _selectIcoin = self.item.fundingIcon;
    _amountValue = self.item.fundingAmount;
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _amountValue = [_amountTextField.text doubleValue];
    self.item.fundingMemo = _memoTextField.text;
    self.item.fundingName = _nameTextField.text;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 4) {
        return 80;
    }
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 4) {
        SSJColorSelectViewController *colorSelectVC = [[SSJColorSelectViewController alloc]init];
        colorSelectVC.fundingColor = _selectColor;
        colorSelectVC.fundingAmount = _amountValue;
        colorSelectVC.fundingName = self.item.fundingName;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor){
            _selectColor = selectColor;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    }else if (indexPath.section == 3) {

    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 4) {
        return self.footerView;
    }
    return nil;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJModifyFundingCell";
    SSJModifyFundingTableViewCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJModifyFundingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NewFundingCell.cellTitle = _cellTitleArray[indexPath.section];
    switch (indexPath.section) {
        case 0:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingName;
            _nameTextField = NewFundingCell.cellDetail;
            _nameTextField.delegate = self;
        }
            break;
        case 1:{
            _amountTextField = NewFundingCell.cellDetail;
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [NSString stringWithFormat:@"%.2f",_amountValue];
            _amountTextField.delegate = self;

        }
            break;
        case 2:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingMemo;
            _memoTextField = NewFundingCell.cellDetail;
            _memoTextField.delegate = self;
        }
            break;
        case 3:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.typeTitle.text = [self getParentFundingNameWithParentfundingID:_selectParent];
            [NewFundingCell.typeTitle sizeToFit];
            NewFundingCell.typeImage.image = [UIImage imageNamed:_selectIcoin];
            NewFundingCell.cellDetail.enabled = NO;
            NewFundingCell.customAccessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case 4:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
//            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
            NewFundingCell.item = _selectColor;
            NewFundingCell.cellDetail.hidden = YES;
            NewFundingCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        default:
            break;
    }
    return NewFundingCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    /*NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (textField == _nameTextField || textField == _memoTextField) {
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

-(TPKeyboardAvoidingTableView *)tableView{
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

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
//        _rightBarButton.tintColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _rightBarButton;
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

-(void)saveButtonClicked:(id)sender{
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
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

    __weak typeof(self) weakSelf = self;
    __block NSString *currentDateStr = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db,BOOL *rollback){
        if ([db intForQuery:@"SELECT OPERATORTYPE FROM BK_FUND_INFO WHERE CFUNDID = ? AND CUSERID = ?",weakSelf.item.fundingID,SSJUSERID()] == 2) {
            return ;
        }
        if([db intForQuery:@"SELECT COUNT(1) FROM BK_FUND_INFO WHERE CACCTNAME = ? AND CFUNDID <> ? AND CUSERID = ? AND OPERATORTYPE <> 2",_nameTextField.text,weakSelf.item.fundingID,SSJUSERID()] > 0){
            dispatch_async(dispatch_get_main_queue(), ^(){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已有同名称账户，请换个名称吧。" delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            });
        }
        if ([_amountTextField.text doubleValue] < self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",weakSelf.item.fundingAmount - [_amountTextField.text doubleValue]],[NSNumber numberWithInt:2],weakSelf.item.fundingID,[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
            
        }else if ([_amountTextField.text doubleValue] > self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",[_amountTextField.text doubleValue] - weakSelf.item.fundingAmount],@"1",weakSelf.item.fundingID,[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
        }
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CACCTNAME = ? , CPARENT = ? , CCOLOR = ?, CSTARTCOLOR = ?, CENDCOLOR = ?, CICOIN = (SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID = ?) , CMEMO = ? , IVERSION = ? , CWRITEDATE = ? , OPERATORTYPE = ? WHERE CFUNDID = ? AND CUSERID = ? ", _nameTextField.text, _selectParent, _selectColor.startColor, _selectColor.startColor, _selectColor.endColor, _selectParent, _memoTextField.text , @(SSJSyncVersion()), [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , [NSNumber numberWithInt:1] ,weakSelf.item.fundingID,SSJUSERID()];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
}

-(NSString*)getParentFundingNameWithParentfundingID:(NSString*)fundingID{
    NSString *fundingName;
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        SSJPRINT(@"Could not open db");
        return nil;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT CACCTNAME FROM BK_FUND_INFO WHERE CFUNDID = ?",fundingID];
    while ([rs next]) {
        fundingName = [rs stringForColumn:@"CACCTNAME"];
    }
    [db close];
    return fundingName;
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

-(void)rightBarButtonClicked:(id)sender{
    @weakify(self);
    [SSJFinancingStore fundHasDataOrNotWithFundid:self.item.fundingID Success:^(BOOL hasData) {
        @strongify(self);
        if (hasData) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除该资金账户吗?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
            UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if (self.item.chargeCount) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该资金后，是否将展示在首页和报表的流水及相关借贷数据一并删除" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *reserve = [UIAlertAction actionWithTitle:@"仅删除资金" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self deleteFundingItem:self.item type:0];
                    }];
                    UIAlertAction *destructive = [UIAlertAction actionWithTitle:@"一并删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [self deleteFundingItem:self.item type:1];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alert addAction:reserve];
                    [alert addAction:destructive];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:NULL];
                }else{
                    [self deleteFundingItem:self.item type:0];
                }
            }];
            [alert addAction:cancel];
            [alert addAction:comfirm];
            [self presentViewController:alert animated:YES completion:NULL];

        } else {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    __weak typeof(self) weakSelf = self;
    if (buttonIndex == 1 && alertView.tag == 101) {
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db){
            [db executeUpdate:@"UPDATE BK_FUND_INFO SET OPERATORTYPE = 2 , IVERSION = ? , CWRITEDATE = ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithLongLong:SSJSyncVersion()],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.fundingID,SSJUSERID()];
            SSJDispatch_main_async_safe(^(){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
    }else if (buttonIndex == 1 && alertView.tag == 100){
        [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:@"UPDATE BK_FUND_INFO SET OPERATORTYPE = 2 , IVERSION = ? , CWRITEDATE = ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithLongLong:SSJSyncVersion()],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.fundingID,SSJUSERID()]) {
                [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set ISTATE = 0 where IFUNSID = ?",weakSelf.item.fundingID];
            }
            SSJDispatch_main_async_safe(^(){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
    }
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
