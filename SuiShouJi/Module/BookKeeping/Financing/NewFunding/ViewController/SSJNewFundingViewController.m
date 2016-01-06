//
//  SSJNewFundingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJNewFundingViewController.h"
#import "SSJNewFundingTableViewCell.h"
#import "FMDB.h"

@interface SSJNewFundingViewController ()
@property (nonatomic,strong) UIView *footerView;
@end

@implementation SSJNewFundingViewController{
    NSArray *_cellTitleArray;
    UITextField *_amountTextField;
    UITextField *_memoTextField;
    UITextField *_nameTextField;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.item.fundingName;
    _cellTitleArray = @[@"账户名称",@"账户余额",@"备注",@"账户类型",@"编辑账户卡片"];
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
        [((SSJNewFundingTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]).cellDetail resignFirstResponder];
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
    static NSString *cellId = @"SSJNewFundingCell";
    SSJNewFundingTableViewCell *NewFundingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!NewFundingCell) {
        NewFundingCell = [[SSJNewFundingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NewFundingCell.cellTitle.text = _cellTitleArray[indexPath.section];
    [NewFundingCell.cellTitle sizeToFit];
    switch (indexPath.section) {
        case 0:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingName;
        }
            break;
        case 1:{
            _amountTextField = NewFundingCell.cellDetail;
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [NSString stringWithFormat:@"%.2f",self.item.fundingAmount];
            
            NewFundingCell.cellDetail.keyboardType = UIKeyboardTypeDecimalPad;
            NewFundingCell.cellDetail.delegate = self;
        }
            break;
        case 2:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = self.item.fundingMemo;
        }
            break;
        case 3:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.cellDetail.text = [self getParentFundingNameWithParentfundingID:self.item.fundingParent];
            NewFundingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NewFundingCell.cellDetail.userInteractionEnabled = NO;
        }
            break;
        case 4:{
            NewFundingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            NewFundingCell.colorView.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
            NewFundingCell.cellDetail.userInteractionEnabled = NO;
            NewFundingCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        default:
            break;
    }
    return NewFundingCell;
}

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
    if ([_amountTextField.text doubleValue] < self.item.fundingAmount) {
        [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , CADDDATE , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSNumber numberWithDouble:self.item.fundingAmount - [_amountTextField.text doubleValue]],[NSNumber numberWithInt:1],self.item.fundingID,@"",[NSNumber numberWithDouble:self.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],@"",@"0",[NSNumber numberWithInt:0],currentDateStr];
    }else if ([_amountTextField.text doubleValue] > self.item.fundingAmount) {
        [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , CADDDATE , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),[NSNumber numberWithDouble:[_amountTextField.text doubleValue] - self.item.fundingAmount] ,[NSNumber numberWithInt:2],self.item.fundingID,@"",[NSNumber numberWithDouble:self.item.fundingAmount],[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],@"",@"0",[NSNumber numberWithInt:0],currentDateStr];
    }
    [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = ?  WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[_amountTextField.text doubleValue]],self.item.fundingID,SSJUSERID()];
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
