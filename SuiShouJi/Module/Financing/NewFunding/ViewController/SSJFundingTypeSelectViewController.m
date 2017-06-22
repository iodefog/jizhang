
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

#import "SSJFundingTypeTableViewCell.h"
#import "SCYSlidePagingHeaderView.h"

#import "SSJFundingItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJFinancingStore.h"



@interface SSJFundingTypeSelectViewController () <SCYSlidePagingHeaderViewDelegate>

@property(nonatomic, strong) SCYSlidePagingHeaderView *slideView;

@property(nonatomic, strong) NSArray *items;

@end

@implementation SSJFundingTypeSelectViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择账户类型";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.slideView];
    [self reloadFundList];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.slideView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM);
    self.tableView.height = self.view.height - self.slideView.bottom;
    self.tableView.top = self.slideView.bottom;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFundingItem *item = [self.items objectAtIndex:indexPath.row];
    if ([item.fundingID isEqualToString:@"10"]) {
        SSJAddOrEditLoanViewController *addLoanController = [[SSJAddOrEditLoanViewController alloc] init];
        addLoanController.type = SSJLoanTypeLend;
        addLoanController.enterFromFundTypeList = YES;
        [self.navigationController pushViewController:addLoanController animated:YES];
        
        [SSJAnaliyticsManager event:@"add_loan"];
        
    }else if ([item.fundingID isEqualToString:@"11"]){
        
        SSJAddOrEditLoanViewController *addLoanController = [[SSJAddOrEditLoanViewController alloc] init];
        addLoanController.type = SSJLoanTypeBorrow;
        addLoanController.enterFromFundTypeList = YES;
        [self.navigationController pushViewController:addLoanController animated:YES];
        
        [SSJAnaliyticsManager event:@"add_owed"];
        
    }else if ([item.fundingID isEqualToString:@"3"]){
        SSJNewCreditCardViewController *newCreditCardVc = [[SSJNewCreditCardViewController alloc]init];
        newCreditCardVc.cardType = SSJCrediteCardTypeCrediteCard;
        __weak typeof(self) weakSelf = self;
        newCreditCardVc.addNewCardBlock = ^(SSJBaseCellItem *newItem){
            if (weakSelf.addNewFundingBlock) {
                weakSelf.addNewFundingBlock(newItem);
            }
        };
        [self.navigationController pushViewController:newCreditCardVc animated:YES];
    } else if ([item.fundingID isEqualToString:@"16"]){
        SSJNewCreditCardViewController *newCreditCardVc = [[SSJNewCreditCardViewController alloc]init];
        newCreditCardVc.cardType = SSJCrediteCardTypeAlipay;
        __weak typeof(self) weakSelf = self;
        newCreditCardVc.addNewCardBlock = ^(SSJBaseCellItem *newItem){
            if (weakSelf.addNewFundingBlock) {
                weakSelf.addNewFundingBlock(newItem);
            }
        };
        [self.navigationController pushViewController:newCreditCardVc animated:YES];
    } else {
        UINavigationController *lastVc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        if ([lastVc isKindOfClass:[SSJNewFundingViewController class]]) {
            if (![item.fundingID isEqualToString:@"3"] && ![item.fundingID isEqualToString:@"9"] && ![item.fundingID isEqualToString:@"10"] && ![item.fundingID isEqualToString:@"11"]) {
                [self.navigationController popViewControllerAnimated:YES];
                if (self.fundingParentSelectBlock) {
                    self.fundingParentSelectBlock(item);
                }
            }
        } else {
            SSJNewFundingViewController *normalFundingVc = [[SSJNewFundingViewController alloc] init];
            __weak typeof(self) weakSelf = self;
            normalFundingVc.addNewFundBlock = ^(SSJFinancingHomeitem *newItem){
                if (weakSelf.addNewFundingBlock) {
                    weakSelf.addNewFundingBlock(newItem);
                }
            };
            normalFundingVc.selectParent = item.fundingID;
            [self.navigationController pushViewController:normalFundingVc animated:YES];
        }
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJFundingTypeCell";
    SSJFundingTypeTableViewCell *FundingTypeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!FundingTypeCell) {
        FundingTypeCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    FundingTypeCell.item = [self.items objectAtIndex:indexPath.row];
    FundingTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return FundingTypeCell;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadFundList];
}

#pragma mark - Getter
- (SCYSlidePagingHeaderView *)slideView {
    if (!_slideView) {
        _slideView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, 40)];
        _slideView.customDelegate = self;
        _slideView.buttonClickAnimated = NO;
        _slideView.titles = @[@"资产账户", @"负债账户"];
        [_slideView setTabSize:CGSizeMake(self.view.width * 0.5, 3)];
        [_slideView ssj_setBorderWidth:1];
        _slideView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _slideView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _slideView;
}


#pragma mark - Private
- (void)reloadFundList {
    [self.view ssj_showLoadingIndicator];
    @weakify(self);
    [SSJFinancingStore queryFundingParentListWithFundingType:self.slideView.selectedIndex Success:^(NSArray<SSJFundingItem *> *items) {
        @strongify(self);
        [self.view ssj_hideLoadingIndicator];
        self.items = [NSArray arrayWithArray:items];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];

    }];
}

-(void)reloadSelectedStatusexceptIndexPath:(NSIndexPath*)selectedIndexpath{
    for (int i = 0; i < [self.tableView numberOfSections]; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([indexPath compare:selectedIndexpath] == NSOrderedSame) {
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = YES;
        }else{
            ((SSJFundingTypeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).selectedOrNot = NO;
        }
    }
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    _slideView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _slideView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
