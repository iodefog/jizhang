//
//  SSJInstalmentDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJInstalmentDetailViewController.h"
#import "SSJInstalmentEditeViewController.h"

#import "SSJChargeCircleModifyCell.h"
#import "SSJInstalmentDateSelectCell.h"

#import "SSJRepaymentStore.h"

#import "SSJRepaymentModel.h"

static NSString *const kTitle1 = @"流水名称";
static NSString *const kTitle2 = @"分期还款";
static NSString *const kTitle3 = @"分期总期数";
static NSString *const kTitle4 = @"当前期数";
static NSString *const kTitle5 = @"分期入账时间";
static NSString *const kTitle6 = @"资金类型";

static NSString *const SSJInstalmentDetailCellIdentifier = @"SSJInstalmentDetailCellIdentifier";

static NSString *const SSJInstalmentDetailMutiLabCellIdentifier = @"SSJInstalmentDetailMutiLabCellIdentifier";


@interface SSJInstalmentDetailViewController ()

@property(nonatomic, strong) SSJRepaymentModel *repaymentModel;

@property(nonatomic, strong) UIView *editeFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@end

@implementation SSJInstalmentDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"账单分期";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[kTitle1,kTitle2,kTitle3,kTitle4,kTitle5,kTitle6];
    self.images = @[@"",@"card_instalment",@"card_instalmencount",@"card_currentinstalment",@"loan_expires",@"card_zhanghu"];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJInstalmentDetailCellIdentifier];
    [self.tableView registerClass:[SSJInstalmentDateSelectCell class] forCellReuseIdentifier:SSJInstalmentDetailMutiLabCellIdentifier];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.chargeItem) {
        self.repaymentModel = [SSJRepaymentStore queryRepaymentModelWithChargeItem:self.chargeItem];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    if([title isEqualToString:kTitle1]) {
        return 70;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.editeFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 80;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    NSString *image = [self.images ssj_safeObjectAtIndex:indexPath.row];
    if([title isEqualToString:kTitle2]) {
        SSJInstalmentDateSelectCell *dateSelectCell = [tableView dequeueReusableCellWithIdentifier:SSJInstalmentDetailMutiLabCellIdentifier];
        dateSelectCell.imageView.image = [[UIImage imageNamed:@"card_instalment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        dateSelectCell.textLabel.text = title;
        double poudageRate = [self.repaymentModel.poundageRate doubleValue] * 100;
        dateSelectCell.subtitleLabel.text = [NSString stringWithFormat:@"分期金额%@,手续费率%@%%",self.repaymentModel.repaymentMoney,[[NSString stringWithFormat:@"%f",poudageRate] ssj_moneyDecimalDisplayWithDigits:2]];
        dateSelectCell.subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [dateSelectCell setNeedsLayout];
        return dateSelectCell;
    }else{
        SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJInstalmentDetailCellIdentifier];
        if (![title isEqualToString:kTitle1]) {
            repaymentModifyCell.cellTitle = title;
            repaymentModifyCell.cellImageName = image;
        }
        repaymentModifyCell.cellInput.hidden = YES;
        repaymentModifyCell.accessoryType = UITableViewCellAccessoryNone;
        if ([title isEqualToString:kTitle1]) {
            if ([self.chargeItem.billId isEqualToString:@"11"]) {
                repaymentModifyCell.cellTitle = [NSString stringWithFormat:@"%ld月份账单本金",(long)self.repaymentModel.repaymentMonth.month];
                repaymentModifyCell.cellDetail = [[NSString stringWithFormat:@"%f",[self.repaymentModel.repaymentMoney doubleValue] / self.repaymentModel.instalmentCout] ssj_moneyDecimalDisplayWithDigits:2];
                repaymentModifyCell.cellImageName = @"ft_cash";
            } else {
                repaymentModifyCell.cellTitle = [NSString stringWithFormat:@"%ld月份账单手续费",(long)self.repaymentModel.repaymentMonth.month];
                repaymentModifyCell.cellDetail = [[NSString stringWithFormat:@"%f",[self.repaymentModel.repaymentMoney doubleValue] * [self.repaymentModel.poundageRate doubleValue]] ssj_moneyDecimalDisplayWithDigits:2];
                repaymentModifyCell.cellImageName = @"bt_shouxufei";
            }
        } else if ([title isEqualToString:kTitle3]) {
            repaymentModifyCell.cellDetail = [NSString stringWithFormat:@"%ld期",(long)self.repaymentModel.instalmentCout];
        } else if ([title isEqualToString:kTitle4]) {
            repaymentModifyCell.cellDetail = [NSString stringWithFormat:@"%ld期",(long)self.repaymentModel.currentInstalmentCout];
        } else if ([title isEqualToString:kTitle5]) {
            repaymentModifyCell.cellDetail = [NSString stringWithFormat:@"%@",self.chargeItem.billDate];
        } else if ([title isEqualToString:kTitle6]) {
            repaymentModifyCell.cellDetail = self.repaymentModel.cardName;
            repaymentModifyCell.cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        }
        return repaymentModifyCell;
    }
}

#pragma mark - Getter
- (UIView *)editeFooterView{
    if (_editeFooterView == nil) {
        _editeFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *editeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _editeFooterView.width - 20, 40)];
        [editeButton setTitle:@"编辑" forState:UIControlStateNormal];
        editeButton.layer.cornerRadius = 3.f;
        editeButton.layer.masksToBounds = YES;
        [editeButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [editeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        editeButton.center = CGPointMake(_editeFooterView.width / 2, _editeFooterView.height / 2);
        [_editeFooterView addSubview:editeButton];
    }
    return _editeFooterView;
}

#pragma mark - Event
- (void)editeButtonClicked:(id)sender{
    SSJInstalmentEditeViewController *instalmentVc = [[SSJInstalmentEditeViewController alloc]init];
    instalmentVc.repaymentModel = self.repaymentModel;
    [self.navigationController pushViewController:instalmentVc animated:YES];
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
