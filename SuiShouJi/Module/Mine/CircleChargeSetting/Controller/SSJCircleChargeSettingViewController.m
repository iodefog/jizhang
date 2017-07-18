
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
#import "SSJChargeCicleModifyViewController.h"
#import "SSJNoneCircleChargeView.h"
#import "SSJDataSynchronizer.h"
#import "SSJCircleChargeStore.h"
#import "SSJChargeCicleModifyViewController.h"
#import "SSJChargeCircleNoneView.h"

@interface SSJCircleChargeSettingViewController ()
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) SSJChargeCircleNoneView *nodataView;
@end

@implementation SSJCircleChargeSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"周期记账";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self getDataFromDataBase];
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJCircleChargeCell";
    SSJCircleChargeCell *circleChargeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!circleChargeCell) {
        circleChargeCell = [[SSJCircleChargeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        circleChargeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    circleChargeCell.item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    __weak typeof(self) weakSelf = self;
    circleChargeCell.openSpecialCircle = ^(SSJBillingChargeCellItem *item){
        SSJChargeCicleModifyViewController *circleModifyVc = [[SSJChargeCicleModifyViewController alloc]init];
        circleModifyVc.item = item;
        [weakSelf.navigationController pushViewController:circleModifyVc animated:YES];
    };
    return circleChargeCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBillingChargeCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.section];
    SSJChargeCicleModifyViewController *circleModifyVc = [[SSJChargeCicleModifyViewController alloc]init];
    circleModifyVc.item = item;
    [self.navigationController pushViewController:circleModifyVc animated:YES];
}

#pragma mark - Getter
-(SSJChargeCircleNoneView *)nodataView{
    if (!_nodataView) {
        _nodataView = [[SSJChargeCircleNoneView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        __weak typeof(self) weakSelf = self;
        _nodataView.makeChargeCircleBlock = ^(){
            [weakSelf addButtonClicked];
        };
    }
    return _nodataView;
}

#pragma mark - Private
-(void)addButtonClicked{
    SSJChargeCicleModifyViewController *circleChargeModifyVC = [[SSJChargeCicleModifyViewController alloc]init];
    [self.navigationController pushViewController:circleChargeModifyVC animated:YES];
}

-(void)getDataFromDataBase{
    [self.tableView ssj_showLoadingIndicator];
    __weak typeof(self) weakSelf = self;
    [SSJCircleChargeStore queryForChargeListWithSuccess:^(NSArray<SSJBillingChargeCellItem *> *result) {
        if (result.count == 0) {
            [self.tableView ssj_showWatermarkWithCustomView:self.nodataView animated:NO target:self action:NULL];
            self.navigationItem.rightBarButtonItem = nil;
        }else{
            [self.tableView ssj_hideWatermark:YES];
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"tianjia"] style:UIBarButtonItemStylePlain target:self action:@selector(addButtonClicked)];
            self.navigationItem.rightBarButtonItem = rightItem;
        }
        weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
        [weakSelf.tableView ssj_hideLoadingIndicator];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [weakSelf.tableView ssj_hideLoadingIndicator];
    }];
}

-(void)reloadDataAfterSync{
    [self getDataFromDataBase];
}

@end
