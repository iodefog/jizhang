
//
//  SSJCircleChargeSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeSettingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJCircleChargeCell.h"
#import "SSJRecordMakingViewController.h"

#import "FMDB.h"


@interface SSJCircleChargeSettingViewController ()
@property (nonatomic,strong) NSMutableArray *items;
@end

@implementation SSJCircleChargeSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"周期记账";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editeButtonClicked:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    [self getDateFromDatebase];
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}



#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.items.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBillingChargeCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    [self.items removeObjectAtIndex:indexPath.section];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    [self deleteConfigWithConfigId:item.configId];  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJCircleChargeCell";
    SSJCircleChargeCell *circleChargeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!circleChargeCell) {
        circleChargeCell = [[SSJCircleChargeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        circleChargeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    circleChargeCell.item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    return circleChargeCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBillingChargeCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    SSJRecordMakingViewController *RecordMakingVC = [[SSJRecordMakingViewController alloc]init];
    RecordMakingVC.item = item;
    [self.navigationController pushViewController:RecordMakingVC animated:YES];
}

#pragma mark - Private
-(void)getDateFromDatebase{
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        FMResultSet * result = [db executeQuery:@"select a.* , b.CCOIN , b.CNAME , b.CCOLOR , b.ITYPE as INCOMEOREXPENSE , b.ID from BK_CHARGE_PERIOD_CONFIG as a, BK_BILL_TYPE as b where CUSERID = ? and OPERATORTYPE != 2 and a.IBILLID = b.ID",SSJUSERID()];
        while ([result next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [result stringForColumn:@"CCOIN"];
            item.typeName = [result stringForColumn:@"CNAME"];
            item.money = [result stringForColumn:@"IMONEY"];
            item.colorValue = [result stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [result boolForColumn:@"INCOMEOREXPENSE"];
            item.fundId = [result stringForColumn:@"IFUNSID"];
            item.billDate = [result stringForColumn:@"CBILLDATE"];
            item.editeDate = [result stringForColumn:@"CWRITEDATE"];
            item.billId = [result stringForColumn:@"IBILLID"];
            item.chargeImage = [result stringForColumn:@"CIMGURL"];
            item.chargeMemo = [result stringForColumn:@"CMEMO"];
            item.configId = [result stringForColumn:@"ICONFIGID"];
            item.chargeCircleType = [result intForColumn:@"ITYPE"];
            item.isOnOrNot = [result intForColumn:@"ISTATE"];
            [tempArray addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            weakSelf.items = [[NSMutableArray alloc]initWithArray:tempArray];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView ssj_hideLoadingIndicator];
        });
    }];
    
}

-(void)editeButtonClicked:(id)sender{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
    }else{
        self.navigationItem.rightBarButtonItem.title = @"编辑";
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

-(void)deleteConfigWithConfigId:(NSString *)configId{
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set OPERATORTYPE = 2 , CWRITEDATE = ? where ICONFIGID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],configId];
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
