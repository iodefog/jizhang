//
//  SSJInterestDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/9/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJInterestDetailViewController.h"
#import "SSJLoanHelper.h"
#import "SSJBaseTableViewCell.h"
#import "SSJFinancingHomeHelper.h"

static NSString *const kTitle1 = @"利息";
static NSString *const kTitle2 = @"支出资金账户";
static NSString *const kTitle3 = @"收入资金账户";
static NSString *const kTitle4 = @"欠谁钱款";
static NSString *const kTitle5 = @"收谁钱款";
static NSString *const kTitle6 = @"结清日";

@interface SSJInterestDetailViewController ()

@property(nonatomic, strong) SSJLoanModel *model;

@property(nonatomic, strong) NSArray *titles;

@end

@implementation SSJInterestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDetailOfInterestForLoanId:self.loanId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    cell.textLabel.text = title;
    if ([title isEqualToString:kTitle1]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@￥%.2f",self.model.type ? @"-" : @"+",[SSJLoanHelper closeOutInterestWithLoanModel:self.model]];
    }
    if ([title isEqualToString:kTitle2] || [title isEqualToString:kTitle3]) {
        cell.detailTextLabel.text = [SSJFinancingHomeHelper queryFundItemWithFundingId:self.model.endTargetFundID].fundingName;
    }
    if ([title isEqualToString:kTitle4] || [title isEqualToString:kTitle5]) {
        cell.detailTextLabel.text = self.model.lender;
    }
    if ([title isEqualToString:kTitle6]) {
        cell.detailTextLabel.text = [self.model.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

#pragma mark - Private
- (void)getDetailOfInterestForLoanId:(NSString *)loanId{
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryForLoanModelWithLoanID:loanId success:^(SSJLoanModel * _Nonnull model) {
        weakSelf.model = model;
        if (!model.type) {
            self.titles = @[@[kTitle1],@[kTitle3],@[kTitle5],@[kTitle6]];
        }else{
            self.titles = @[@[kTitle1],@[kTitle2],@[kTitle4],@[kTitle6]];
        }
        [self.view ssj_hideLoadingIndicator];
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
    }];
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
