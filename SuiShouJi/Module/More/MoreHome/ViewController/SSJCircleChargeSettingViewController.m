
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

#import "FMDB.h"


@interface SSJCircleChargeSettingViewController ()
@property (nonatomic,strong) NSArray *items;
@end

@implementation SSJCircleChargeSettingViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
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

#pragma mark - Private
-(void)getDateFromDatebase{
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        FMResultSet * result = [db executeQuery:@"select a.* from BK_CHARGE_PERIOD_CONFIG as a,  where CUSERID = ? AND OPERATORTYPE != 2",SSJUSERID()];
        while ([result next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [result stringForColumn:@"CCOIN"];
            item.typeName = [result stringForColumn:@"CNAME"];
            item.money = [result stringForColumn:@"IMONEY"];
            item.colorValue = [result stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [result boolForColumn:@"ITYPE"];
            item.ID = [result stringForColumn:@"ICHARGEID"];
            item.fundId = [result stringForColumn:@"IFUNSID"];
            item.billDate = [result stringForColumn:@"CBILLDATE"];
            item.editeDate = [result stringForColumn:@"CWRITEDATE"];
            item.billId = [result stringForColumn:@"IBILLID"];
            item.chargeImage = [result stringForColumn:@"CIMGURL"];
            item.chargeThumbImage = [result stringForColumn:@"THUMBURL"];
            item.chargeMemo = [result stringForColumn:@"CMEMO"];
            item.configId = [result stringForColumn:@"ICONFIGID"];
            item.chargeCircleType = [result intForColumn:@"CHARGECIRCLE"];
            [tempArray addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
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
