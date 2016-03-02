
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

#import "FMDB.h"


@interface SSJCircleChargeSettingViewController ()
@property (nonatomic,strong) NSArray *items;
@end

@implementation SSJCircleChargeSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDateFromDatebase];
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
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


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.items.count;
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
