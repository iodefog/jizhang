
//
//  SSJCalenderDetailViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailViewController.h"
#import "SSJBillingChargeCell.h"
#import "SSJCalenderDetailCell.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalenderTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJChargeDetailMemoCell.h"
#import "SSJCalenderDetaiImagelFooterView.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJReportFormsViewController.h"
#import "FMDB.h"

@interface SSJCalenderDetailViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic, strong) NSString *cellImage;
@property (nonatomic,strong) NSString *cellTitle;
@property (nonatomic,strong) NSString *cellColor;
@property (nonatomic)BOOL incomeOrExpence;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property(nonatomic, strong) SSJCalenderDetaiImagelFooterView *imageFooter;
@end

@implementation SSJCalenderDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"流水详情";
        self.title = @"详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.cellColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.tableView registerClass:[SSJCalenderTableViewCell class] forCellReuseIdentifier:@"BillingChargeCell"];
    [self.tableView registerClass:[SSJCalenderDetailCell class] forCellReuseIdentifier:@"calenderDetailCellID"];
    [self.tableView registerClass:[SSJChargeDetailMemoCell class] forCellReuseIdentifier:@"calenderDetailMemoCellID"];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromDb];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.item.colorValue] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 55;
    }
    if (indexPath.row == 4) {
        return 85;
    }
    return 50;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.item.chargeImage != nil && ![self.item.chargeImage isEqualToString:@""]) {
        return 300;
    }
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.item.chargeImage != nil && ![self.item.chargeImage isEqualToString:@""]) {
        self.imageFooter.imageName = self.item.chargeImage;
        return self.imageFooter;
    }
    return self.footerView;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (![self.item.chargeMemo isEqualToString:@""] && self.item.chargeMemo != nil) {
        return 5;
    }
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SSJCalenderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillingChargeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellItem:self.item];
        return cell;
    }else if (indexPath.row == 1){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.selectionStyle = UITableViewCellSelectionStyleNone;

        detailcell.detailLabel.text = self.item.billDate;
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"时间";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else if(indexPath.row == 2){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.selectionStyle = UITableViewCellSelectionStyleNone;
        detailcell.detailLabel.text = [self getParentFundingNameWithParentfundingID:self.item.fundId];
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"资金类型";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else if(indexPath.row == 3){
        SSJCalenderDetailCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailCellID" forIndexPath:indexPath];
        detailcell.selectionStyle = UITableViewCellSelectionStyleNone;
        SSJBooksTypeItem *booksItem = [SSJBooksTypeStore queryCurrentBooksTypeForBooksId:self.item.booksId];
        detailcell.detailLabel.text = booksItem.booksName;
        [detailcell.detailLabel sizeToFit];
        detailcell.cellLabel.text = @"账本类型";
        [detailcell.cellLabel sizeToFit];
        return detailcell;
    }else{
        SSJChargeDetailMemoCell *detailcell = [tableView dequeueReusableCellWithIdentifier:@"calenderDetailMemoCellID" forIndexPath:indexPath];
        detailcell.selectionStyle = UITableViewCellSelectionStyleNone;
        detailcell.cellMemo = self.item.chargeMemo;
        detailcell.cellTitle = @"备注";
        return detailcell;
    }
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

#pragma mark - UIAlertViewDelegate


#pragma mark - Getter
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
        UIButton *editeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 22, 40)];
        [editeButton setTitle:@"修改此记录" forState:UIControlStateNormal];
        [editeButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        editeButton.layer.borderWidth = 1.f;
        editeButton.layer.cornerRadius = 2.f;
        editeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"eb4a64"].CGColor;
        editeButton.center = CGPointMake(_footerView.width / 2, _footerView.height / 2);
        [editeButton addTarget:self action:@selector(editeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:editeButton];
    }
    return _footerView;
}

-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked:)];
    }
    return _rightBarButton;
}

-(SSJCalenderDetaiImagelFooterView *)imageFooter{
    if (!_imageFooter) {
        _imageFooter = [[SSJCalenderDetaiImagelFooterView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 300)];
        __weak typeof(self) weakSelf = self;
        _imageFooter.ModifyButtonClickedBlock = ^(){
            [weakSelf editeButtonClicked];
        };
        _imageFooter.ImageClickedBlock = ^(){
            SSJImaageBrowseViewController *imageBrowseVc = [[SSJImaageBrowseViewController alloc]init];
            imageBrowseVc.type = SSJImageBrowseVcTypeBrowse;
            imageBrowseVc.item = weakSelf.item;
            [weakSelf.navigationController pushViewController:imageBrowseVc animated:YES];
        };
    }
    return _imageFooter;
}

#pragma mark - Private

/**
 *  修改流水
 */
-(void)editeButtonClicked{
    SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
    recordMakingVc.item = self.item;
    [self.navigationController pushViewController:recordMakingVc animated:YES];
}


/**
 *  每次进入页面之前获取一次最修改的数据
 */
-(void)getDataFromDb{
    __weak typeof(self) weakSelf = self;

    [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT A.* , B.* FROM BK_USER_CHARGE AS A , BK_BILL_TYPE AS B WHERE A.ICHARGEID = ? AND A.CUSERID = ?  AND A.IBILLID = B.ID",self.item.ID,SSJUSERID()];
        while ([rs next]) {
            weakSelf.item.money = [rs stringForColumn:@"IMONEY"];
            weakSelf.item.billId = [rs stringForColumn:@"IBILLID"];
            weakSelf.item.billDate = [rs stringForColumn:@"CBILLDATE"];
            weakSelf.item.fundId = [rs stringForColumn:@"IFUNSID"];
            weakSelf.item.typeName = [rs stringForColumn:@"CNAME"];
            weakSelf.item.imageName = [rs stringForColumn:@"CCOIN"];
            weakSelf.item.colorValue = [rs stringForColumn:@"CCOLOR"];
            weakSelf.item.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
        }
        SSJDispatch_main_async_safe(^(){
            [weakSelf.tableView reloadData];
        })
    }];
}

-(void)rightBarButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
    SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action){
        [weakSelf deleteCharge];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [SSJAlertViewAdapter showAlertViewWithTitle:@"提示" message:@"你确定要删除这条流水吗" action: cancelAction , sureAction, nil];
}

/**
 *  数据库中删除流水
 */
-(void)deleteCharge{
    __block NSString *booksid = SSJGetCurrentBooksType();
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db){
        NSString *userId = SSJUSERID();
        [db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),weakSelf.item.ID];
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",weakSelf.item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ? and cuserid = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,booksid,userId]) {
                return;
            }
        }else{
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE  CFUNDID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],weakSelf.item.fundId] || ![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ? and cuserid = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,booksid,userId]) {
                return;
            }
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
        if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[SSJReportFormsViewController class]]) {
            if (![db intForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cbooksid = ?",weakSelf.item.booksId,userId]) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
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
