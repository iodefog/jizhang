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

#import "FMDB.h"

@interface SSJModifyFundingViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic,strong) TPKeyboardAvoidingTableView *tableView;
@end

@implementation SSJModifyFundingViewController{
    NSArray *_cellTitleArray;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
    UITextField *_nameTextField;
    NSString *_selectParent;
    NSString *_selectColor;
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
    self.title = self.item.fundingName;
    _cellTitleArray = @[@"账户名称",@"账户余额",@"备注",@"账户类型",@"编辑账户卡片"];
    _selectColor = self.item.fundingColor;
    _selectParent = self.item.fundingParent;
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
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
    if (indexPath.section != 4 && indexPath.section != 3) {
        [((SSJModifyFundingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).cellDetail resignFirstResponder];
    }else if (indexPath.section == 4) {
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
        __weak typeof(self) weakSelf = self;
        fundingTypeVC.typeSelectedBlock = ^(NSString *selectParent){
            _selectParent = selectParent;
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
        }
            break;
        case 1:{
            _amountTextField = NewFundingCell.cellDetail;
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [NSString stringWithFormat:@"%.2f",self.item.fundingAmount];
            NewFundingCell.cellDetail.keyboardType = UIKeyboardTypeDecimalPad;
        }
            break;
        case 2:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingMemo;
            _memoTextField = NewFundingCell.cellDetail;
        }
            break;
        case 3:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [self getParentFundingNameWithParentfundingID:_selectParent];
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
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - Private
-(void)saveButtonClicked:(id)sender{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    if([db intForQuery:@"SELECT COUNT(1) FROM BK_FUND_INFO WHERE CACCTNAME = ? AND CFUNDID <> ?",_nameTextField.text,self.item.fundingID] > 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已有同名称账户，请换个名称吧。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    if ([_amountTextField.text doubleValue] < self.item.fundingAmount) {
        [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSNumber numberWithDouble:self.item.fundingAmount - [_amountTextField.text doubleValue]],[NSNumber numberWithInt:2],self.item.fundingID,[NSNumber numberWithDouble:self.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate alloc]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLong:SSJSyncVersion()],[NSNumber numberWithInt:0],currentDateStr];
    }else if ([_amountTextField.text doubleValue] > self.item.fundingAmount) {
        [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSNumber numberWithDouble:[_amountTextField.text doubleValue] - self.item.fundingAmount] ,@"1",self.item.fundingID,[NSNumber numberWithDouble:self.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],[[NSDate alloc]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLong:SSJSyncVersion()],[NSNumber numberWithInt:0],currentDateStr];
    }
    [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = ? WHERE CFUNDID = ? AND CUSERID = ? ",[NSNumber numberWithDouble:[_amountTextField.text doubleValue]] , self.item.fundingID,SSJUSERID()];
    [db executeUpdate:@"UPDATE BK_FUND_INFO SET CACCTNAME = ? , CPARENT = ? , CCOLOR = ? , CICOIN = (SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID = ?) , IVERSION = ? , CWRITEDATE = ? , OPERATORTYPE = ? WHERE CFUNDID = ? AND CUSERID = ? ",_nameTextField.text,_selectParent,_selectColor, _selectParent , [NSNumber numberWithLong:SSJSyncVersion()], [[NSDate alloc]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , [NSNumber numberWithInt:1] ,self.item.fundingID,SSJUSERID()];
    [self.navigationController popViewControllerAnimated:YES];
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
