//
//  SJJBookKeepingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeViewController.h"
#import "SSJBookKeepingHeader.h"
#import "SSJBookKeepingHomeTableViewCell.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalendarViewController.h"
#import "SSJBookKeepHomeItem.h"
#import "SSJBookKeepingHomeNodateFooter.h"
#import "SSJHomeBarButton.h"
#import "FMDB.h"


@interface SSJBookKeepingHomeViewController ()

@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) SSJBookKeepingHeader *bookKeepingHeader;
@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;

@end

@implementation SSJBookKeepingHomeViewController{
    NSIndexPath *_selectIndex;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.title = @"个人账本";
        self.automaticallyAdjustsScrollViewInsets = NO;
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:@"47cfbe"] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self getCurrentDate];
    [self getDateFromDatebase];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bookKeepingHeader];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSString *path = SSJSQLitePath();
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@",path);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _selectIndex = nil;
    [self getCurrentDate];
    [self getDateFromDatebase];
    [self.tableView reloadData];
}

-(void)viewDidLayoutSubviews{
    self.bookKeepingHeader.size = CGSizeMake(self.view.width, 187);
    self.bookKeepingHeader.top = 64;
    self.tableView.top = self.bookKeepingHeader.bottom;
    self.tableView.height = self.view.height - self.bookKeepingHeader.bottom - 49;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.items.count == 0) {
        return 300;
    }
    return 0.1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.items.count == 0) {
        SSJBookKeepingHomeNodateFooter *nodateFooter = [[SSJBookKeepingHomeNodateFooter alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 300)];
        return nodateFooter;
    }
    return nil;
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJBookKeepingCell";
    SSJBookKeepingHomeTableViewCell *bookKeepingCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!bookKeepingCell) {
        bookKeepingCell = [[SSJBookKeepingHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    bookKeepingCell.isEdite = ([indexPath compare:_selectIndex] == NSOrderedSame);
    bookKeepingCell.item = [self.items objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    bookKeepingCell.beginEditeBtnClickBlock = ^(SSJBookKeepingHomeTableViewCell *cell){
        if (_selectIndex == nil) {
            _selectIndex = [tableView indexPathForCell:cell];
            [weakSelf.tableView reloadData];
        }else{
            _selectIndex = nil;
            [weakSelf.tableView reloadData];
        }
//        cell.isEdite = YES;
    };
    bookKeepingCell.editeBtnClickBlock = ^(SSJBookKeepingHomeTableViewCell *cell)
    {
        SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
        recordMakingVc.item = cell.item;
        [weakSelf.navigationController pushViewController:recordMakingVc animated:YES];
    };
    bookKeepingCell.deleteButtonClickBlock = ^{
        _selectIndex = nil;
        [weakSelf getDateFromDatebase];
        [weakSelf.tableView reloadData];
    };
    return bookKeepingCell;
}

#pragma mark - Getter
-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        SSJHomeBarButton *buttonView = [[SSJHomeBarButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        buttonView.currentDay = [NSString stringWithFormat:@"%ld",_currentDay];
        [buttonView.btn addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    }
    return _rightBarButton;
}

-(SSJBookKeepingHeader *)bookKeepingHeader{
    if (!_bookKeepingHeader) {
        _bookKeepingHeader = [SSJBookKeepingHeader BookKeepingHeader];
        _bookKeepingHeader.income = @"4000.04";
        _bookKeepingHeader.expenditure = @"5000.08";
        _bookKeepingHeader.frame = CGRectMake(0, 0, self.view.width, 187);
        __weak typeof(self) weakSelf = self;
        _bookKeepingHeader.BtnClickBlock = ^{
            SSJRecordMakingViewController *recordmaking = [[SSJRecordMakingViewController alloc]init];
            [weakSelf.navigationController pushViewController:recordmaking animated:YES];
        };
    }
    return _bookKeepingHeader;
}

#pragma mark - Private
-(void)rightBarButtonClicked{
    SSJCalendarViewController *calendarVC = [[SSJCalendarViewController alloc]init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

-(void)getDateFromDatebase{
    self.items = [[NSMutableArray alloc]init];
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }

    FMResultSet *rs = [db executeQuery:@"SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE  ,IFUNSID FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC LIMIT 7)  AND OPERATORTYPE != 2 AND CUSERID = ?) WHERE IBILLID != '1' AND IBILLID != '2' AND IBILLID != '3' AND IBILLID != '4' UNION SELECT * FROM ( SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , CWRITEDATE , IFUNSID FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC LIMIT 7) ORDER BY CBILLDATE DESC ,CWRITEDATE DESC",SSJUSERID()];

    while ([rs next]) {
        SSJBookKeepHomeItem *item = [[SSJBookKeepHomeItem alloc]init];
        item.editeDate = [rs stringForColumn:@"CWRITEDATE"];
        item.billDate = [rs stringForColumn:@"CBILLDATE"];
        item.chargeMoney = [rs doubleForColumn:@"IMONEY"];
        item.chargeID = [rs stringForColumn:@"ICHARGEID"];
        item.billID = [rs stringForColumn:@"IBILLID"];
        item.fundID = [rs stringForColumn:@"IFUNSID"];
        [self.items addObject:item];
    }
    double income = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(INCOMEAMOUNT) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE LIKE '%04ld-%02ld-__'", _currentYear,_currentMonth]];
    double expence = [db doubleForQuery:[NSString stringWithFormat:@"SELECT SUM(EXPENCEAMOUNT) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE LIKE '%04ld-%02ld-__'", _currentYear,_currentMonth]];
    self.bookKeepingHeader.income = [NSString stringWithFormat:@"%.2f",income];
    self.bookKeepingHeader.expenditure = [NSString stringWithFormat:@"%.2f",expence];
    [db close];
    [self.tableView reloadData];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear= [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
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
