
//
//  SSJFundingTypeSelectViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewCreditCardViewController.h"
#import "SSJAddOrEditLoanViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJAddOrEditFixedFinanceProductViewController.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJFundingParentSelectHeader.h"
#import "SSJBaseTableViewCell.h"

#import "SSJFundingItem.h"
#import "SSJFinancingStore.h"

static NSString *const kSSJFinancingColorSelectHeaderID = @"kSSJFinancingColorSelectHeaderID";
static NSString *kCellID = @"cellID";

@interface SSJFundingTypeSelectViewController () <SCYSlidePagingHeaderViewDelegate>

@property(nonatomic , strong) SCYSlidePagingHeaderView *slideView;

@property(nonatomic , strong) NSArray *items;

@end

@implementation SSJFundingTypeSelectViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择账户类型";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.slideView];
    [self.tableView registerClass:[SSJFundingParentSelectHeader class] forHeaderFooterViewReuseIdentifier:kSSJFinancingColorSelectHeaderID];
    [self reloadFundList];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.slideView.leftTop = CGPointMake(0 , SSJ_NAVIBAR_BOTTOM);
    self.tableView.height = self.view.height - self.slideView.bottom;
    self.tableView.top = self.slideView.bottom;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 75;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJFundingParentmodel *model = [self.items ssj_safeObjectAtIndex:section];
    SSJFundingParentSelectHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSSJFinancingColorSelectHeaderID];
    @weakify(self);
    headerView.didSelectFundParentHeader = ^(SSJFundingParentmodel *model) {
        @strongify(self);
        if (model.subFunds.count) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];

        } else {
            [self popToVcWithModel:model];
        }
    };
    headerView.model = model;
    return headerView;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFundingParentmodel *model = [self.items ssj_safeObjectAtIndex:indexPath.section];

    SSJFundingParentmodel *cellItem = [model.subFunds ssj_safeObjectAtIndex:indexPath.row];
    [self popToVcWithModel:cellItem];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SSJFundingParentmodel *model = [self.items ssj_safeObjectAtIndex:section];
    if (model.expended == NO) {
        return 0;
    }
    return model.subFunds.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SSJFundingParentmodel *model = [self.items ssj_safeObjectAtIndex:indexPath.section];

    SSJFundingParentmodel *cellItem = [model.subFunds ssj_safeObjectAtIndex:indexPath.row];

    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];

    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellID];
        cell.backgroundColor = [UIColor clearColor];
    }

    cell.imageView.image = [UIImage imageNamed:cellItem.icon];


    cell.textLabel.text = cellItem.name;

    cell.textLabel.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];

    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];

    return cell;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate

- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadFundList];
}

#pragma mark - Getter

- (SCYSlidePagingHeaderView *)slideView {
    if (!_slideView) {
        _slideView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(self.view.width , 0 , self.view.width , 40)];
        _slideView.customDelegate = self;
        _slideView.buttonClickAnimated = NO;
        _slideView.titles = @[@"资产账户" , @"负债账户"];
        [_slideView setTabSize:CGSizeMake(self.view.width * 0.5 , 3)];
        [_slideView ssj_setBorderWidth:1];
        _slideView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _slideView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _slideView;
}


#pragma mark - Private

- (void)reloadFundList {
    if (!self.slideView.selectedIndex) {
        self.items = [SSJFundingTypeManager sharedManager].sassetsFunds;
    } else {
        self.items = [SSJFundingTypeManager sharedManager].liabilitiesFunds;
    }
    [self.tableView reloadData];
}

- (void)popToVcWithModel:(SSJFundingParentmodel *)model {

    if ([model.ID isEqualToString:@"10"]) {
        SSJAddOrEditLoanViewController *addLoanController = [[SSJAddOrEditLoanViewController alloc] init];
        addLoanController.type = SSJLoanTypeLend;
        addLoanController.enterFromFundTypeList = YES;
        [self.navigationController pushViewController:addLoanController animated:YES];

        [SSJAnaliyticsManager event:@"add_loan"];

    } else if ([model.ID isEqualToString:@"11"]) {
        SSJAddOrEditLoanViewController *addLoanController = [[SSJAddOrEditLoanViewController alloc] init];
        addLoanController.type = SSJLoanTypeBorrow;
        addLoanController.enterFromFundTypeList = YES;
        [self.navigationController pushViewController:addLoanController animated:YES];
        [SSJAnaliyticsManager event:@"add_owed"];

    } else if ([model.ID isEqualToString:@"3"]) {
        SSJNewCreditCardViewController *newCreditCardVc = [[SSJNewCreditCardViewController alloc] init];
        newCreditCardVc.cardType = SSJCrediteCardTypeCrediteCard;
        newCreditCardVc.selectParent = model.ID;
        __weak typeof(self) weakSelf = self;
        newCreditCardVc.addNewCardBlock = ^(SSJFinancingHomeitem *newItem) {
            if (weakSelf.addNewFundingBlock) {
                weakSelf.addNewFundingBlock(newItem);
            }
        };
        [self.navigationController pushViewController:newCreditCardVc animated:YES];
    } else if ([model.ID isEqualToString:@"16"]) {
        SSJNewCreditCardViewController *newCreditCardVc = [[SSJNewCreditCardViewController alloc] init];
        newCreditCardVc.selectParent = model.ID;
        newCreditCardVc.cardType = SSJCrediteCardTypeAlipay;
        __weak typeof(self) weakSelf = self;
        newCreditCardVc.addNewCardBlock = ^(SSJFinancingHomeitem *newItem) {
            if (weakSelf.addNewFundingBlock) {
                weakSelf.addNewFundingBlock(newItem);
            }
        };
        [self.navigationController pushViewController:newCreditCardVc animated:YES];
    } else if ([model.ID isEqualToString:@"17"]) {
        SSJAddOrEditFixedFinanceProductViewController *addOrEditVC = [[SSJAddOrEditFixedFinanceProductViewController alloc] init];
        //        listVC.item = item;
        [self.navigationController pushViewController:addOrEditVC animated:YES];
    } else {
        UINavigationController *lastVc = [self.navigationController.viewControllers objectAtIndex:
                                                                                            self.navigationController.viewControllers.count
                                                                                            - 2];
        if ([lastVc isKindOfClass:[SSJNewFundingViewController class]]) {
            if (![model.ID isEqualToString:@"3"] && ![model.ID isEqualToString:@"9"]
                && ![model.ID isEqualToString:@"10"] && ![model.ID isEqualToString:@"11"]) {
                [self.navigationController popViewControllerAnimated:YES];
                //                if (self.fundingParentSelectBlock) {
                //                    self.fundingParentSelectBlock(item);
                //                }
            }
        } else {
            SSJNewFundingViewController *normalFundingVc = [[SSJNewFundingViewController alloc] init];
            __weak typeof(self) weakSelf = self;
            normalFundingVc.addNewFundBlock = ^(SSJFinancingHomeitem *newItem) {
                if (weakSelf.addNewFundingBlock) {
                    weakSelf.addNewFundingBlock(newItem);
                }
            };
            normalFundingVc.selectParent = model.ID;
            [self.navigationController pushViewController:normalFundingVc animated:YES];
        }
    }

}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    _slideView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _slideView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
