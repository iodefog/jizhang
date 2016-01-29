//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJModifyFundingViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJColorSelectViewControllerViewController.h"
#import "SSJModifyFundingTableViewCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJDatabaseQueue.h"

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
    NSString *_selectColor;
    NSString *_selectIcoin;

}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        self.hideKeyboradWhenTouch = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"close"] target:self selector:@selector(closeButtonClicked:)];
    self.title = self.item.fundingName;
    _cellTitleArray = @[@"账户名称",@"账户余额",@"备注",@"账户类型",@"选择颜色"];
    _selectColor = self.item.fundingColor;
    _selectParent = self.item.fundingParent;
    _selectIcoin = self.item.fundingIcon;
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.item.fundingAmount = [_amountTextField.text doubleValue];
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
        SSJColorSelectViewControllerViewController *colorSelectVC = [[SSJColorSelectViewControllerViewController alloc]init];
        colorSelectVC.fundingColor = _selectColor;
        colorSelectVC.fundingAmount = self.item.fundingAmount;
        colorSelectVC.fundingName = self.item.fundingName;
        __weak typeof(self) weakSelf = self;
        colorSelectVC.colorSelectedBlock = ^(NSString *selectColor){
            _selectColor = selectColor;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:colorSelectVC animated:YES];
    }else if (indexPath.section == 3) {
        SSJFundingTypeSelectViewController *fundingTypeVC = [[SSJFundingTypeSelectViewController alloc]init];
        fundingTypeVC.selectFundID = _selectParent;
        __weak typeof(self) weakSelf = self;
        fundingTypeVC.typeSelectedBlock = ^(NSString *selectParent,NSString *selectIcon){
            _selectParent = selectParent;
            _selectIcoin = selectIcon;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:fundingTypeVC animated:YES];
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
    NewFundingCell.cellTitle.text = _cellTitleArray[indexPath.section];
    [NewFundingCell.cellTitle sizeToFit];
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
            NewFundingCell.cellDetail.text = [NSString stringWithFormat:@"%.2f",self.item.fundingAmount];
            NewFundingCell.cellDetail.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
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
            NewFundingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 4:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:_selectColor];
            NewFundingCell.cellDetail.hidden = YES;
            NewFundingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        default:
            break;
    }
    return NewFundingCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _nameTextField || textField == _memoTextField) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 13) {
            if (textField == _nameTextField) {
                [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
            }else{
                [CDAutoHideMessageHUD showMessage:@"账户名称不能超过13个字"];
            }
            return NO;
        }
    }else if (textField == _amountTextField){
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
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
        comfirmButton.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        [comfirmButton setTitle:@"保存" forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:comfirmButton];
    }
    return _footerView;
}

-(TPKeyboardAvoidingTableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];

        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked:)];
        _rightBarButton.tintColor = [UIColor ssj_colorWithHex:@"cccccc"];
    }
    return _rightBarButton;
}

#pragma mark - Private
-(void)saveButtonClicked:(id)sender{
    NSString* number=@"^(\\-)?\\d+(\\.\\d{1,2})?$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    if (![numberPre evaluateWithObject:_amountTextField.text]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确金额"];
        return;
    }
//    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
//    if (![db open]) {
//        NSLog(@"Could not open db");
//        return;
//    }
    __weak typeof(self) weakSelf = self;
    __block NSString *currentDateStr = [[NSDate date]ssj_dateStringWithFormat:@"yyyy-MM-dd"];
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db,BOOL *rollback){
        if([db intForQuery:@"SELECT COUNT(1) FROM BK_FUND_INFO WHERE CACCTNAME = ? AND CFUNDID <> ? AND CUSERID = ?",_nameTextField.text,weakSelf.item.fundingID,SSJUSERID()] > 0){
            dispatch_async(dispatch_get_main_queue(), ^(){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已有同名称账户，请换个名称吧。" delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            });
        }
        if ([_amountTextField.text doubleValue] < self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",self.item.fundingAmount - [_amountTextField.text doubleValue]],[NSNumber numberWithInt:2],weakSelf.item.fundingID,[NSNumber numberWithDouble:self.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
            
        }else if ([_amountTextField.text doubleValue] > self.item.fundingAmount) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSString stringWithFormat:@"%.2f",[_amountTextField.text doubleValue] - self.item.fundingAmount],@"1",weakSelf.item.fundingID,[NSNumber numberWithDouble:weakSelf.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],currentDateStr]) {
                *rollback = YES;
            }
        }
        [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = ? WHERE CFUNDID = ? AND CUSERID = ? ",[NSNumber numberWithDouble:[_amountTextField.text doubleValue]] , weakSelf.item.fundingID,SSJUSERID()];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CACCTNAME = ? , CPARENT = ? , CCOLOR = ? , CICOIN = (SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID = ?) , CMEMO = ? , IVERSION = ? , CWRITEDATE = ? , OPERATORTYPE = ? WHERE CFUNDID = ? AND CUSERID = ? ",_nameTextField.text,_selectParent,_selectColor, _selectParent , _memoTextField.text , @(SSJSyncVersion()), [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , [NSNumber numberWithInt:1] ,weakSelf.item.fundingID,SSJUSERID()];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

-(NSString*)getParentFundingNameWithParentfundingID:(NSString*)fundingID{
    NSString *fundingName;
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你确定要删除该资金账户吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        __weak typeof(self) weakSelf = self;
        [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
            [db executeUpdate:@"UPDATE BK_FUND_INFO SET OPERATORTYPE = 2 , IVERSION = ? , CWRITEDATE = ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithLongLong:SSJSyncVersion()],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.fundingID,SSJUSERID()];
            SSJDispatch_main_async_safe(^(){
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }];
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
