//
//  SSJBalenceChangeDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBalenceChangeDetailViewController.h"

#import "SSJFundingDetailCell.h"

#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"

#import "SSJDatabaseQueue.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";
static NSString *const kFundingListFirstLineCellID = @"kFundingListFirstLineCellID";

@interface SSJBalenceChangeDetailViewController ()

@end

@implementation SSJBalenceChangeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chargeItem.chargeImage = @"";
    self.chargeItem.chargeMemo = @"";
    [self.tableView registerClass:[SSJFundingDetailCell class] forCellReuseIdentifier:kFundingDetailCellID];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"详情";
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        SSJFundingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingDetailCellID];
        cell.item = self.chargeItem;
        cell.moneyLab.text = [[NSString stringWithFormat:@"%f",fabs([self.chargeItem.money doubleValue])] ssj_moneyDecimalDisplayWithDigits:2];
        return cell;
    }
    if (indexPath.section == 1) {
        SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingListFirstLineCellID];
        if (!cell) {
            cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kFundingListFirstLineCellID];
            cell.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
            cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
            cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"时间";
            cell.detailTextLabel.text = self.chargeItem.billDate;
        } else {
            cell.textLabel.text = @"资金类型";
            if ([self.fundItem isKindOfClass:[SSJCreditCardItem class]]) {
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *)self.fundItem;
                cell.detailTextLabel.text = cardItem.cardName;
            }else{
                SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)self.fundItem;
                cell.detailTextLabel.text = financingItem.fundingName;
            }
        }
        return cell;

    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    return 55;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma Event
- (void)deleteButtonClicked{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [db executeUpdate:@"update bk_user_charge set operatortype = 2, iversion = ?,cwritedate = ? where ichargeid = ? and cuserid = ?",@(SSJSyncVersion()),writeDate,weakSelf.chargeItem.ID,userId];
        SSJDispatchMainAsync(^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
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
