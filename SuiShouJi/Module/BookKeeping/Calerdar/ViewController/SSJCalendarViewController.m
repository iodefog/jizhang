//
//  SSJCalendarViewController.m
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarViewController.h"
#import "SSJCalendarView.h"
#import "SSJRecordMakingViewController.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJBillingChargeCell.h"
#import "SSJCalenderTableViewNoDataHeader.h"
#import "SSJFundingDetailDateHeader.h"
#import "SSJCalenderDetailViewController.h"
#import "SSJCalenderTableViewCell.h"

#import "SSJDatabaseQueue.h"
#import "SSJCalenderHelper.h"
#import "FMDB.h"


@interface SSJCalendarViewController ()
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property (nonatomic,strong) SSJCalendarView *calendarView;
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UIButton *plusButton;
@property (nonatomic,strong) UIButton *minusButton;
@property (nonatomic,strong) UIView *dateChangeView;
@property (nonatomic,strong) UIView *noDateView;
@property (nonatomic,strong) UILabel *firstLineLabel;
@property (nonatomic,strong) UILabel *secondLineLabel;
@property (nonatomic,strong) UIButton *recordMakingButton;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSString *selectDate;
@property (nonatomic,strong) NSMutableDictionary *data;
@property(nonatomic, strong) SSJCalenderTableViewNoDataHeader *nodataHeader;
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;
@property (nonatomic) BOOL needAnimation;

@end

@implementation SSJCalendarViewController{
    long _currentYear;
    long _currentMonth;
    long _currentDay;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"日历";
        self.hidesBottomBarWhenPushed = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCurrentDate];
    self.selectedYear = _currentYear;
    self.selectedMonth = _currentMonth;
    self.selectedDay = _currentDay;
    self.selectDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    self.navigationItem.titleView = self.dateChangeView;
    [self.view addSubview:self.calendarView];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[SSJFundingDetailDateHeader class] forHeaderFooterViewReuseIdentifier:@"FundingDetailDateHeader"];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:@"BillingChargeCellIdentifier"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"canleder_jia"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self getCurrentDate];
    [self getDataFromDateBase];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.dateLabel.center = CGPointMake(self.dateChangeView.width / 2, self.dateChangeView.height / 2);
    self.plusButton.left = self.dateLabel.right + 10;
    self.minusButton.right = self.dateLabel.left - 10;
    self.plusButton.centerY = self.dateChangeView.height / 2;
    self.minusButton.centerY = self.dateChangeView.height / 2;
    self.calendarView.frame = CGRectMake(0, 64, self.view.width, self.calendarView.viewHeight);
    self.tableView.top = self.calendarView.bottom;
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - self.calendarView.viewHeight - 64);
    _firstLineLabel.top = 20;
    _firstLineLabel.centerX = _noDateView.width / 2;
    _secondLineLabel.top = _firstLineLabel.bottom + 10;
    _secondLineLabel.centerX = _noDateView.width / 2;
    _recordMakingButton.centerX = _noDateView.width / 2;
    _recordMakingButton.top = _secondLineLabel.bottom + 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}   

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.items.count == 0) {
        return 0.1f;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJCalenderTableViewCell *cell = (SSJCalenderTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    SSJBillingChargeCellItem *item = (SSJBillingChargeCellItem*)cell.cellItem;
    SSJCalenderDetailViewController *CalenderDetailVC = [[SSJCalenderDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    CalenderDetailVC.item = item;
    [self.navigationController pushViewController:CalenderDetailVC animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.needAnimation) {
        __weak typeof(self) weakSelf = self;
        SSJCalenderTableViewCell * currentCell = (SSJCalenderTableViewCell *)cell;
        currentCell.transform = CGAffineTransformMakeTranslation(0, self.view.height - 400);
        [UIView animateWithDuration:0.3 delay:0.1 * indexPath.row options:UIViewAnimationOptionTransitionCurlUp animations:^{
            currentCell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            weakSelf.needAnimation = NO;
        }];
    }

}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.items.count == 0) {
        return nil;
    }
    SSJFundingDetailDateHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"FundingDetailDateHeader"];
    headerView.dateLabel.text = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",self.selectedYear,self.selectedMonth,self.selectedDay];
    [headerView.dateLabel sizeToFit];
    [SSJCalenderHelper queryBalanceForDate:self.selectDate success:^(double data) {
        if (data > 0) {
            headerView.balanceLabel.text = [NSString stringWithFormat:@"+%.2f",data];
            [headerView.balanceLabel sizeToFit];
        }else{
            headerView.balanceLabel.text = [NSString stringWithFormat:@"%.2f",data];
            [headerView.balanceLabel sizeToFit];
        }
    } failure:^(NSError *error) {
        
    }];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillingChargeCellIdentifier" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellItem:[self.items ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - Getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [_tableView ssj_clearExtendSeparator];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

-(SSJCalendarView *)calendarView{
    if (_calendarView == nil) {
        _calendarView = [[SSJCalendarView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 270)];
        _calendarView.isSelectOnly = NO;
        _calendarView.year = _currentYear;
        _calendarView.month = _currentMonth;
        _calendarView.day = _currentDay;
        [self getDataFromDateBase];
        __weak typeof(self) weakSelf = self;
        _calendarView.DateSelectedBlock = ^(long year , long month ,long day ,  NSString *selectDate){
            weakSelf.selectedYear = year;
            weakSelf.selectedMonth = month ;
            weakSelf.selectedDay = day;
            weakSelf.selectDate = selectDate;
            [weakSelf getDataFromDateBase];
            [weakSelf.view setNeedsLayout];
        };
    }
    return _calendarView;
}

-(UIView *)dateChangeView{
    if (!_dateChangeView) {
        _dateChangeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
        _dateChangeView.backgroundColor = [UIColor whiteColor];
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
        _dateLabel.font = [UIFont systemFontOfSize:18];
        [_dateLabel sizeToFit];
        _plusButton = [[UIButton alloc]init];
        _plusButton.frame = CGRectMake(0, 0, 20, 28);
        [_plusButton setImage:[UIImage imageNamed:@"reportForms_right"] forState:UIControlStateNormal];
        [_plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _plusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton = [[UIButton alloc]init];
        _minusButton.frame = CGRectMake(0, 0, 20, 28);
        [_minusButton setImage:[UIImage imageNamed:@"reportForms_left"] forState:UIControlStateNormal];
        [_minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_minusButton addTarget:self action:@selector(minusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_dateChangeView addSubview:_dateLabel];
        [_dateChangeView addSubview:_plusButton];
        [_dateChangeView addSubview:_minusButton];
    }
    return _dateChangeView;
}

-(SSJCalenderTableViewNoDataHeader *)nodataHeader{
    if (!_nodataHeader) {
        __weak typeof(self) weakSelf = self;
        _nodataHeader = [SSJCalenderTableViewNoDataHeader CalenderTableViewNoDataHeader];
        _nodataHeader.RecordMakingButtonBlock = ^(){
            SSJRecordMakingViewController *recordMakingVC = [[SSJRecordMakingViewController alloc]init];
            recordMakingVC.selectedDay = weakSelf.selectedDay;
            recordMakingVC.selectedMonth = weakSelf.selectedMonth;
            recordMakingVC.selectedYear = weakSelf.selectedYear;
            [weakSelf.navigationController pushViewController:recordMakingVC animated:YES];
        };
    }
    return _nodataHeader;
}



#pragma mark - private
-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    _currentYear = now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
}

-(void)plusButtonClicked:(UIButton*)button{
    self.selectedMonth = self.selectedMonth + 1;
    if (self.selectedMonth == 13) {
        self.selectedMonth = 1;
        self.selectedYear = self.selectedYear + 1;
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
    [self.dateLabel sizeToFit];
    self.calendarView.year = self.selectedYear;
    self.calendarView.month = self.selectedMonth;
    self.calendarView.day = 0;
    [self getDataFromDateBase];
}

-(void)minusButtonClicked:(UIButton*)button{
    self.selectedMonth = self.selectedMonth - 1;
    if (self.selectedMonth == 0) {
        self.selectedMonth = 12;
        self.selectedYear = self.selectedYear - 1;
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
    [self.dateLabel  sizeToFit];
    self.calendarView.year = self.selectedYear;
    self.calendarView.month = self.selectedMonth;
    self.calendarView.day = 0;
    [self getDataFromDateBase];
}

-(void)getDataFromDateBase{
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [SSJCalenderHelper queryDataInYear:self.selectedYear month:self.selectedMonth success:^(NSMutableDictionary *data) {
        NSString *selectedYear = [weakSelf.selectDate substringWithRange:NSMakeRange(0, 4)];
        NSString *selectedMonth = [weakSelf.selectDate substringWithRange:NSMakeRange(5, 2)];
        if (weakSelf.selectedYear == [selectedYear integerValue] && weakSelf.selectedMonth == [selectedMonth integerValue]) {
            weakSelf.items = [[NSMutableArray alloc]initWithArray:[data objectForKey:weakSelf.selectDate]];
            if (((NSArray *)[data objectForKey:weakSelf.selectDate]).count == 0) {
                [weakSelf.tableView ssj_showWatermarkWithCustomView:weakSelf.nodataHeader animated:NO target:nil action:nil];
            }else{
                [weakSelf.tableView ssj_hideWatermark:YES];
            }
            [weakSelf reloadWithAnimation];
        }
        weakSelf.calendarView.data = data;
        [weakSelf.view ssj_hideLoadingIndicator];
        [weakSelf.view setNeedsLayout];
    } failure:^(NSError *error) {
        [weakSelf.view ssj_hideLoadingIndicator];
    }];
}


-(void)rightButtonClicked:(id)sender{
    SSJRecordMakingViewController *recordMakingVC = [[SSJRecordMakingViewController alloc]init];
    recordMakingVC.selectedDay = self.selectedDay;
    recordMakingVC.selectedMonth = self.selectedMonth;
    recordMakingVC.selectedYear = self.selectedYear;
    UINavigationController *recordNav = [[UINavigationController alloc]initWithRootViewController:recordMakingVC];
    [self presentViewController:recordNav animated:YES completion:NULL];}

//-(void)getHaveRecordOrNotForDate:(NSString *)date WithSuccess:(void(^)(bool result))success
//                         failure:(void (^)(NSError * _Nullable error))failure{
//    __weak typeof(self) weakSelf = self;
//    [[SSJDatabaseQueue sharedInstance]inDatabase:^(FMDatabase *db) {
//        BOOL haveRecordOrNot = [db intForQuery:@"select * from BK_USER_CHARGE where CBILLDATE = ? and CUSERID = ? and OPERATORTYPE <> 2",date,SSJUSERID()];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
//    }];
//}

-(void)reloadWithAnimation{
    self.needAnimation = YES;
    [self.tableView reloadData];
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
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
