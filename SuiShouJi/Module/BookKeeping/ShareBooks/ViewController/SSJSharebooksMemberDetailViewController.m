

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
#import "SSJBillingChargeViewController.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsIncomeAndPayCell.h"

#import "SSJUserTableManager.h"
#import "SSJDatePeriod.h"
#import "SSJShareBooksMemberStore.h"
#import "SSJReportFormsItem.h"
#import "SSJCreateOrDeleteBooksService.h"
#import "SSJBooksTypeStore.h"

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

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
@property (nonatomic, strong) NSMutableArray *cellItems;

@property(nonatomic, strong) SSJCreateOrDeleteBooksService *deleteService;

@end

@implementation SSJSharebooksMemberDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"账本成员";
        self.cellItems = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.userInfoHeader];
    [self.userInfoHeader addSubview:self.iconImageView];
    [self.userInfoHeader addSubview:self.nickNameLab];
    [self.view addSubview:self.periodControl];
    [self.view addSubview:self.tableView];
    if ([self.memberId isEqualToString:SSJUSERID()]) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.iconImageView.layer.cornerRadius = self.iconImageView.height / 2;
}

- (void)updateViewConstraints {
    
    [self.userInfoHeader mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(140);
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
    }];
    
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(65, 65));
        make.centerX.mas_equalTo(self.userInfoHeader.mas_centerX);
        make.top.mas_equalTo(18);
    }];
    
    [self.nickNameLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.userInfoHeader.mas_centerX);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(14);
    }];
    
    [self.periodControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(35);
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.userInfoHeader.mas_bottom).offset(10);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view).offset(self.periodControl.bottom);
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.periodControl.mas_bottom);
    }];
    
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SSJShareBooksMemberStore queryMemberItemWithMemberId:self.memberId booksId:self.booksId Success:^(SSJUserItem *memberItem) {
        [self updateUserInfoWithUserItem:memberItem];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
    [self reloadAllDatas];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.cellItems ssj_safeObjectAtIndex:indexPath.row];

    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    incomeAndPayCell.cellItem = item;
    return incomeAndPayCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.cellItems ssj_safeObjectAtIndex:indexPath.row];
    SSJReportFormsItem *tmpItem = (SSJReportFormsItem *)item;
    SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
    if (tmpItem.isMember) {
        billingChargeVC.memberId = tmpItem.ID;
    } else {
        billingChargeVC.billId = tmpItem.ID;
    }
    billingChargeVC.period = _periodControl.currentPeriod;
    billingChargeVC.isPayment = _payAndIncomeSegmentControl.selectedIndex == 0;
    [self.navigationController pushViewController:billingChargeVC animated:YES];
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
    return 55;
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
    [self reloadDatasInPeriod:period];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        @weakify(self);
        [SSJBooksTypeStore deleteShareBooksWithShareCharge:self.deleteService.shareChargeArray shareMember:self.deleteService.shareMemberArray bookId:self.booksId sucess:^(BOOL bookstypeHasChange){
            @strongify(self);
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:NULL];
    }
}

#pragma mark - LazyLoading
- (SSJReportFormsPeriodSelectionControl *)periodControl {
    if (!_periodControl) {
        __weak typeof(self) wself = self;
        _periodControl = [[SSJReportFormsPeriodSelectionControl alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 40)];
        _periodControl.periodChangeHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadDatasInPeriod:control.selectedPeriod];
        };
        _periodControl.addCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself enterCalendarVC];
        };
        _periodControl.clearCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadDatasInPeriod:control.selectedPeriod];
        };
    }
    return _periodControl;
}

- (SCYSlidePagingHeaderView *)payAndIncomeSegmentControl {
    if (!_payAndIncomeSegmentControl) {
        _payAndIncomeSegmentControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _payAndIncomeSegmentControl.customDelegate = self;
        _payAndIncomeSegmentControl.buttonClickAnimated = YES;
        _payAndIncomeSegmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
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
        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
//        [_tableView registerClass:[SSJReportFormCurveListCell class] forCellReuseIdentifier:kSSJReportFormCurveListCellID];
//        [_tableView registerClass:[SSJReportFormsNoDataCell class] forCellReuseIdentifier:kNoDataRemindCellID];
    }
    return _tableView;
}

- (UIView *)userInfoHeader {
    if (!_userInfoHeader) {
        _userInfoHeader = [[UIView alloc] init];
        _userInfoHeader.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _userInfoHeader;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)nickNameLab {
    if (!_nickNameLab) {
        _nickNameLab = [[UILabel alloc] init];
        _nickNameLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _nickNameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nickNameLab;
}

- (SSJCreateOrDeleteBooksService *)deleteService {
    if (!_deleteService) {
        _deleteService = [[SSJCreateOrDeleteBooksService alloc] initWithDelegate:self];
    }
    return _deleteService;
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

- (void)deleteButtonClicked:(id)sender {
    [self.deleteService deleteShareBookWithBookId:self.booksId memberId:self.memberId memberState:SSJShareBooksMemberStateKickedOut];
}

#pragma mark - Private
- (void)updateUserInfoWithUserItem:(SSJUserItem *)item {
    if ([item.userId isEqualToString:SSJUSERID()]) {
        self.nickNameLab.text = @"我";
    } else {
        self.nickNameLab.text = item.nickName;
    }
    if (![item.icon hasPrefix:@"http"]) {
        item.icon = SSJImageURLWithAPI(item.icon);
    }
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
}

- (SSJBillType)currentType {
    if (self.payAndIncomeSegmentControl.selectedIndex == 0) {
        return SSJBillTypePay;
    } else if (self.payAndIncomeSegmentControl.selectedIndex == 1) {
        return SSJBillTypeIncome;
    } else {
        return SSJBillTypeUnknown;
    }
}

- (void)updateSubveiwsHidden {
    if (self.periodControl.periods.count) {
        self.periodControl.hidden = NO;
        self.tableView.hidden = NO;
    } else {
        self.periodControl.hidden = YES;
        self.tableView.hidden = YES;
    }
}

//  重新加载数据
- (void)reloadAllDatas {
    [self.view ssj_showLoadingIndicator];
    [SSJShareBooksMemberStore queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus memberId:self.memberId booksId:self.booksId success:^(NSArray<SSJDatePeriod *> *periods) {
        _periodControl.periods = periods;
        if (!_periodControl.selectedPeriod && periods.count >= 3) {
            _periodControl.selectedPeriod = periods[periods.count - 3];
        }
        
        [self updateSubveiwsHidden];
        
        if (periods.count == 0) {
//            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            [self.view ssj_hideWatermark:YES];
        }
        
        [self reloadDatasInPeriod:_periodControl.currentPeriod];
        [self.view ssj_hideLoadingIndicator];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    }];
}

// 查询某个周期内的流水统计
- (void)reloadDatasInPeriod:(SSJDatePeriod *)period {
    if (!period) {
        return;
    }
    [self.tableView ssj_showLoadingIndicator];
    [SSJShareBooksMemberStore queryForIncomeOrPayType:[self currentType] booksId:self.booksId memberId:self.memberId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
        [self.tableView ssj_hideLoadingIndicator];
        [self reorganiseChartTableVieDatasWithOriginalData:result];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
        [self.tableView ssj_hideLoadingIndicator];
    }];
}

- (void)reorganiseChartTableVieDatasWithOriginalData:(NSArray<SSJReportFormsItem *> *)result {
    
    [self.cellItems removeAllObjects];
    
    //  将datas按照收支类型所占比例从大到小进行排序
    NSArray *oragnizeResult = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SSJReportFormsItem *item1 = obj1;
        SSJReportFormsItem *item2 = obj2;
        if (item1.scale > item2.scale) {
            return NSOrderedAscending;
        } else if (item1.scale < item2.scale) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    [self.cellItems addObjectsFromArray:oragnizeResult];
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
