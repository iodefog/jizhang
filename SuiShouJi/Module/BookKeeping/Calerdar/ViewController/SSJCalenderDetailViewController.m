
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
#import "SSJCanlenderChargeDetailCell.h"
#import "SSJChargeDetailMemberCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJChargeDetailMemoCell.h"
#import "SSJCalenderDetaiImagelFooterView.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJReportFormsViewController.h"
#import "FMDB.h"
#import "SSJChargeMemBerItem.h"
#import "SSJCalenderDetailHeader.h"


@interface SSJCalenderDetailViewController ()
@property (nonatomic,strong) UIView *footerView;
@property (nonatomic, strong) NSString *cellImage;
@property (nonatomic,strong) NSString *cellTitle;
@property (nonatomic,strong) NSString *cellColor;
@property (nonatomic)BOOL incomeOrExpence;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property(nonatomic, strong) SSJCalenderDetaiImagelFooterView *imageFooter;
@property(nonatomic, strong) NSMutableArray *items;
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
    self.tableView.top = SSJ_NAVIBAR_BOTTOM;
    [self.view becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:self.cellColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.tableView registerClass:[SSJCalenderTableViewCell class] forCellReuseIdentifier:@"CalenderTableViewCell"];
    [self.tableView registerClass:[SSJChargeDetailMemberCell class] forCellReuseIdentifier:@"ChargeDetailMemberCell"];
    [self.tableView registerClass:[SSJCanlenderChargeDetailCell class] forCellReuseIdentifier:@"CanlenderChargeDetailCell"];

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
    SSJBaseItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJBillingChargeCellItem class]] && indexPath.section == 1) {
        if (self.item.chargeMemo.length) {
            return 142;
        }else{
            return 120;
        }
    }
    return 55;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        SSJCalenderDetailHeader *header = [[SSJCalenderDetailHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        header.item = self.item;
        return header;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 44;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.item.chargeImage != nil && ![self.item.chargeImage isEqualToString:@""]) {
            return 300;
        }
        return 100;
    }
    return 0.1f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.item.chargeImage != nil && ![self.item.chargeImage isEqualToString:@""]) {
            self.imageFooter.imageName = self.item.chargeImage;
            return self.imageFooter;
        }
        return self.footerView;
    }
    return nil;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.items[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        SSJCalenderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellItem:item];
        return cell;
    }else if (indexPath.section == 1){
        if ([item isKindOfClass:[SSJChargeMemberItem class]]) {
            SSJChargeDetailMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargeDetailMemberCell" forIndexPath:indexPath];
            float money = [self.item.money floatValue];
            cell.memberMoney = [NSString stringWithFormat:@"%.2f",money / (self.item.membersItem.count - 1)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.memberItem = (SSJChargeMemberItem *)item;
            return cell;
        }else{
            SSJCanlenderChargeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CanlenderChargeDetailCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.item = (SSJBillingChargeCellItem *)item;
            return cell;
        }
    }
    return nil;
}

#pragma mark - Getter
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
        UIButton *editeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 22, 40)];
        [editeButton setTitle:@"修改此记录" forState:UIControlStateNormal];
        [editeButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        editeButton.layer.borderWidth = 1.f;
        editeButton.layer.cornerRadius = 2.f;
        editeButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor].CGColor;
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
        FMResultSet *chargeResult = [db executeQuery:@"SELECT A.* , B.* , c.* FROM BK_USER_CHARGE AS A , BK_BILL_TYPE AS B , bk_fund_info as c WHERE A.ICHARGEID = ? AND A.CUSERID = ?  AND A.IBILLID = B.ID and a.ifunsid = c.cfundid",self.item.ID,SSJUSERID()];
        while ([chargeResult next]) {
            weakSelf.item.money = [chargeResult stringForColumn:@"IMONEY"];
            weakSelf.item.billId = [chargeResult stringForColumn:@"IBILLID"];
            weakSelf.item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            weakSelf.item.fundId = [chargeResult stringForColumn:@"IFUNSID"];
            weakSelf.item.typeName = [chargeResult stringForColumn:@"CNAME"];
            weakSelf.item.imageName = [chargeResult stringForColumn:@"CCOIN"];
            weakSelf.item.colorValue = [chargeResult stringForColumn:@"CCOLOR"];
            weakSelf.item.incomeOrExpence = [chargeResult boolForColumn:@"ITYPE"];
            weakSelf.item.fundName = [chargeResult stringForColumn:@"cacctname"];
            weakSelf.item.booksId = [chargeResult stringForColumn:@"cbooksid"];
            weakSelf.item.booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ?",weakSelf.item.booksId];
        }
        [chargeResult close];
        FMResultSet *memberResult = [db executeQuery:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.ichargeid = ? and a.cmemberid = b.cmemberid and b.cuserid = ?",weakSelf.item.ID,SSJUSERID()];
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        while ([memberResult next]) {
            SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
            memberItem.memberId = [memberResult stringForColumn:@"cmemberId"];
            memberItem.memberName = [memberResult stringForColumn:@"cname"];
            memberItem.memberColor = [memberResult stringForColumn:@"ccolor"];
            [tempArr addObject:memberItem];
        }
        if (!tempArr.count) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
            item.memberName = @"我";
            item.memberColor = @"#fc7a60";
            [tempArr addObject:item];
        }
        weakSelf.item.membersItem = tempArr;
        weakSelf.items = [NSMutableArray arrayWithCapacity:0];
        [weakSelf.items addObject:@[weakSelf.item]];
        [tempArr addObject:weakSelf.item];
        [weakSelf.items addObject:tempArr];
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
    }];
    [SSJAlertViewAdapter showAlertViewWithTitle:@"提示" message:@"你确定要删除这条流水吗" action: cancelAction , sureAction, nil];
}

/**
 *  数据库中删除流水
 */
-(void)deleteCharge{
    __block NSString *booksid = SSJGetCurrentBooksType();
    __weak typeof(self) weakSelf = self;
    __block int chargeCount = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db){
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
        chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cbooksid = ? and cbilldate like ? and operatortype <> 2",weakSelf.item.booksId,userId,[NSString stringWithFormat:@"%@__",[weakSelf.item.billDate substringWithRange:NSMakeRange(0, 8)]]];
    }];
    if ([[self.navigationController.viewControllers firstObject] isKindOfClass:[SSJReportFormsViewController class]]) {
        if (chargeCount == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
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
