//
//  SSJEveryInverestDetailViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/9/6.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEveryInverestDetailViewController.h"

#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJFixedFinanceProductItem.h"
#import "SSJLoanFundAccountSelectionViewItem.h"

#import "TPKeyboardAvoidingTableView.h"

#import "SSJFixedFinanceProductStore.h"
#import "SSJDataSynchronizer.h"

static  NSString *kTitle1 = @"收益详情";
static  NSString *kTitle2 = @"时间";
static  NSString *kTitle3 = @"投资名称";
@interface SSJEveryInverestDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *titleArray;

/**<#注释#>*/
@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation SSJEveryInverestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    [self.view addSubview:self.tableView];
    if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeInterest) {//利息流水
        self.title = @"收益详情";
        NSString *title1;
//        SSJMethodOfInterest interesttype;
        if (self.productItem.interesttype == SSJMethodOfInterestOncePaid) {
            title1 = @"到期收益";
        } else {
            title1 = @"每日收益";
        }
        [self.titleArray addObjectsFromArray:@[title1,kTitle2,kTitle3]];
        [self.dataArray addObject:[NSString stringWithFormat:@"%.2f",self.chargeItem.money]];
        [self.dataArray addObject:[self.chargeItem.billDate formattedDateWithFormat:@"yyyy-MM-dd"]];
        [self.dataArray addObject:self.productItem.productName];
        self.imageArray = [NSMutableArray arrayWithArray:@[@"fixed_finance_lixi",@"fixed_finance_qixi",@"loan_person"]];
        
    } else if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeCreate) {
        self.title = @"投资本金";
        [self.titleArray addObjectsFromArray:@[@"投资本金",@"转出账户",@"时间",@"投资名称"]];
        
        [self.dataArray addObject:[NSString stringWithFormat:@"%.2f",self.chargeItem.money]];
        SSJLoanFundAccountSelectionViewItem *funditem = [SSJFixedFinanceProductStore queryfundNameWithFundid:self.productItem.targetfundid];
        [self.dataArray addObject:funditem.title];
        [self.dataArray addObject:[self.chargeItem.billDate ssj_dateStringWithFormat:@"yyyy-MM-dd"]];
        [self.dataArray addObject:self.productItem.productName];
        
        self.imageArray = [NSMutableArray arrayWithArray:@[@"loan_money",@"fixed_finance_out",@"fixed_finance_qixi",@"loan_person",@"loan_memo"]];
        if (self.productItem.memo.length) {
            [self.titleArray addObject:@"备注"];
            [self.dataArray addObject:self.productItem.memo];
        }
    } else if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceIncrease || self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceDecrease) {
        self.title = @"平账利息";
        [self.titleArray addObjectsFromArray:@[@"利息平账金额",@"时间",@"投资名称"]];
        if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceIncrease) {
            [self.dataArray addObject:[NSString stringWithFormat:@"+%.2f",self.chargeItem.money]];
        } else if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceDecrease) {
            [self.dataArray addObject:[NSString stringWithFormat:@"-%.2f",self.chargeItem.money]];
        }
        self.imageArray = [NSMutableArray arrayWithArray:@[@"loan_money",@"fixed_finance_qixi",@"loan_person"]];
        [self.dataArray addObject:[self.chargeItem.billDate ssj_dateStringWithFormat:@"yyyy-MM-dd"]];
        [self.dataArray addObject:self.productItem.productName];
    } else if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeCloseOut) {
        self.title = @"结算金额";
        [self.titleArray addObjectsFromArray:@[@"结算金额",@"结算账户",@"时间",@"投资名称"]];
        self.imageArray = [NSMutableArray arrayWithArray:@[@"loan_money",@"fixed_finance_out",@"fixed_finance_qixi",@"loan_person"]];
        [self.dataArray addObject:[NSString stringWithFormat:@"%.2f",self.chargeItem.money]];
        SSJLoanFundAccountSelectionViewItem *funditem = [SSJFixedFinanceProductStore queryfundNameWithFundid:self.productItem.targetfundid];
        [self.dataArray addObject:funditem.ID];
        [self.dataArray addObject:[self.chargeItem.billDate ssj_dateStringWithFormat:@"yyyy-MM-dd"]];
        [self.dataArray addObject:self.productItem.productName];
    }
//    else if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeBalanceInterestIncrease || self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeBalanceInterestDecrease) {
//        if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeBalanceInterestIncrease) {//利息转入
//            self.title = @"固定理财利息转入";
//        } else {//利息支出
//            self.title = @"固定理财利息转出";
//        }
//        [self.titleArray addObjectsFromArray:@[]];
//    }
    [self updateAppearance];
}

- (void)setUpNav {
    if (self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeCreate || self.chargeItem.chargeType == SSJFixedFinCompoundChargeTypeInterest) {
        
    } else {
        if (self.productItem.isend != 1) {
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
            self.navigationItem.rightBarButtonItem = rightItem;
        }
    }
}

- (void)deleteButtonClicked {
    MJWeakSelf;
    [SSJFixedFinanceProductStore deleteFixedFinanceProductChargeWithModel:self.chargeItem productModel:self.productItem success:^{
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJEveryInverestDetailViewCellId";
    NSString *title = [self.titleArray ssj_safeObjectAtIndex:indexPath.row];
    NSString *imageName = [self.imageArray ssj_safeObjectAtIndex:indexPath.row];
    NSString *value = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.textLabel.textColor = SSJ_MAIN_COLOR;
        cell.detailTextLabel.textColor = SSJ_SECONDARY_COLOR;
        cell.textLabel.font = cell.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        cell.imageView.tintColor = SSJ_SECONDARY_COLOR;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        cell.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
//        cell.indicatorView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = value;
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.userInteractionEnabled = NO;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return _tableView;
}

- (void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}


@end
