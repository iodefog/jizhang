

//
//  SSJSharebooksMemberDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSharebooksMemberDetailViewController.h"
#import "SSJReportFormsPeriodSelectionControl.h"
#import "SSJMagicExportCalendarViewController.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsChartCell.h"

#import "SSJUserTableManager.h"
#import "SSJDatePeriod.h"
#import "SSJShareBooksMemberStore.h"

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";

@interface SSJSharebooksMemberDetailViewController ()<SCYSlidePagingHeaderViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UIView *userInfoHeader;

@property(nonatomic, strong) UIImageView *iconImageView;

@property(nonatomic, strong) UILabel *nickNameLab;

@property(nonatomic, strong) SSJReportFormsPeriodSelectionControl *periodControl;

@property (nonatomic, strong) SCYSlidePagingHeaderView *payAndIncomeSegmentControl;

@property(nonatomic, strong) UITableView *tableView;

//  tableview数据源
@property (nonatomic, strong) NSMutableArray *datas;


@end

@implementation SSJSharebooksMemberDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SSJShareBooksMemberStore queryMemberItemWithMemberId:@"" booksId:@"" Success:^(SSJUserItem *memberItem) {
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    SSJReportFormsChartCell *chartCell = [tableView dequeueReusableCellWithIdentifier:@"" forIndexPath:indexPath];
    chartCell.cellItem = item;
//    chartCell.option = _selectedOption;
//    __weak typeof(self) wself = self;
//    chartCell.selectOptionHandle = ^(SSJReportFormsChartCell *cell) {
//        wself.selectedOption = cell.option;
//        [wself reloadDatasInPeriod:wself.periodControl.selectedPeriod];
//        
//        switch (wself.selectedOption) {
//            case SSJReportFormsMemberAndCategoryOptionCategory:
//                [SSJAnaliyticsManager event:@"form_category"];
//                break;
//                
//            case SSJReportFormsMemberAndCategoryOptionMember:
//                [SSJAnaliyticsManager event:@"form_member"];
//                break;
//        }
//    };
    
    return chartCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [SSJAnaliyticsManager event:@"forms_bar_chart"];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
//    
//    SSJReportFormsItem *tmpItem = (SSJReportFormsItem *)item;
//    SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
//    billingChargeVC.ID = tmpItem.ID;
//    billingChargeVC.color = [UIColor ssj_colorWithHex:tmpItem.colorValue];
//    billingChargeVC.period = _periodControl.currentPeriod;
//    billingChargeVC.isMemberCharge = tmpItem.isMember;
//    billingChargeVC.isPayment = _payAndIncomeSegmentControl.selectedIndex == 0;
//    if (tmpItem.isMember) {
//        billingChargeVC.title = tmpItem.name;
//    }
//    [self.navigationController pushViewController:billingChargeVC animated:YES];
//
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.payAndIncomeSegmentControl;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    return item.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.payAndIncomeSegmentControl.height;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = _periodControl.currentPeriod;
//    switch (self.navigationBar.option) {
//        case SSJReportFormsNavigationBarChart:
//            [self reloadDatasInPeriod:period];
//            break;
//            
//        case SSJReportFormsNavigationBarCurve:
//            [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:_currentBooksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
//                [self reorganiseCurveTableDataWithOriginalData:list];
//            } failure:^(NSError *error) {
//                [SSJAlertViewAdapter showError:error];
//                [self.view ssj_hideLoadingIndicator];
//            }];
//            break;
//    }
    
}

#pragma mark - LazyLoading
- (SSJReportFormsPeriodSelectionControl *)periodControl {
    if (!_periodControl) {
        __weak typeof(self) wself = self;
        _periodControl = [[SSJReportFormsPeriodSelectionControl alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 40)];
        _periodControl.periodChangeHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [SSJAnaliyticsManager event:@"form_date_picked"];
        };
        _periodControl.addCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself enterCalendarVC];
        };
        _periodControl.clearCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
//            [wself reloadDatasInPeriod:control.selectedPeriod];
        };
    }
    return _periodControl;
}

- (SCYSlidePagingHeaderView *)payAndIncomeSegmentControl {
    if (!_payAndIncomeSegmentControl) {
        _payAndIncomeSegmentControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _payAndIncomeSegmentControl.customDelegate = self;
        _payAndIncomeSegmentControl.buttonClickAnimated = YES;
        [_payAndIncomeSegmentControl setTabSize:CGSizeMake(_payAndIncomeSegmentControl.width * 0.5, 3)];
        _payAndIncomeSegmentControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome];
        [_payAndIncomeSegmentControl ssj_setBorderWidth:1];
        [_payAndIncomeSegmentControl ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _payAndIncomeSegmentControl;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.periodControl.bottom, self.view.width, self.view.height - self.periodControl.bottom - SSJ_TABBAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
//        [_tableView registerClass:[SSJReportFormsChartCell class] forCellReuseIdentifier:kChartViewCellID];
//        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
//        [_tableView registerClass:[SSJReportFormCurveListCell class] forCellReuseIdentifier:kSSJReportFormCurveListCellID];
//        [_tableView registerClass:[SSJReportFormsNoDataCell class] forCellReuseIdentifier:kNoDataRemindCellID];
    }
    return _tableView;
}


#pragma mark - Event
- (void)enterCalendarVC {
    __weak typeof(self) wself = self;
    [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
        SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
        calendarVC.title = @"自定义时间";
        calendarVC.booksId = booksId;
        calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
            wself.periodControl.customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        };
        [wself.navigationController pushViewController:calendarVC animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
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
