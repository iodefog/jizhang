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
#import "FMDB.h"


@interface SSJBookKeepingHomeViewController ()

@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation SSJBookKeepingHomeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = [self BarTitle];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:@"47cfbe"] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self getDateFromDatebase];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.height = self.view.height - 69;
    NSString *path = SSJSQLitePath();
    NSLog(@"%@",path);
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJBookKeepingHeader *bookKeepingHeader = [SSJBookKeepingHeader BookKeepingHeader];
    bookKeepingHeader.income = @"4000.04";
    bookKeepingHeader.expenditure = @"5000.08";
    bookKeepingHeader.frame = CGRectMake(0, 0, self.view.width, 187);
    __weak typeof(self) weakSelf = self;
    bookKeepingHeader.BtnClickBlock = ^{
        SSJRecordMakingViewController *recordmaking = [[SSJRecordMakingViewController alloc]init];
        [weakSelf.navigationController pushViewController:recordmaking animated:YES];
        recordmaking.recordMakingType = 1;
    };
    return bookKeepingHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 187;
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
    bookKeepingCell.item = [self.items objectAtIndex:indexPath.row];
    return bookKeepingCell;
}

#pragma mark - Getter
-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"日历" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked)];
        _rightBarButton.tintColor = [UIColor whiteColor];
    }
    return _rightBarButton;
}

#pragma mark - Private
-(void)rightBarButtonClicked{
    SSJCalendarViewController *calendarVC = [[SSJCalendarViewController alloc]init];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

-(NSString*)BarTitle{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

-(void)getDateFromDatebase{
    self.items = [[NSMutableArray alloc]init];
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    NSString *sql =@"SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE FROM (SELECT CBILLDATE , IMONEY , ICHARGEID , IBILLID , CWRITEDATE FROM BK_USER_CHARGE WHERE CBILLDATE IN (SELECT CBILLDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE ASC LIMIT 7) AND  IBILLID != '1' AND IBILLID != '2') UNION SELECT * FROM ( SELECT CBILLDATE , SUMAMOUNT AS IMONEY , ICHARGEID , IBILLID , CWRITEDATE FROM BK_DAILYSUM_CHARGE ORDER BY CBILLDATE DESC LIMIT 7) ORDER BY CBILLDATE DESC , CWRITEDATE ASC";
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        SSJBookKeepHomeItem *item = [[SSJBookKeepHomeItem alloc]init];
        item.editeDate = [rs stringForColumn:@"CWRITEDATE"];
        item.billDate = [rs stringForColumn:@"CBILLDATE"];
        item.chargeMoney = [rs doubleForColumn:@"IMONEY"];
        item.chargeID = [rs stringForColumn:@"ICHARGEID"];
        item.billID = [rs stringForColumn:@"IBILLID"];
        [self.items addObject:item];
    }
    [db close];
    [self.tableView reloadData];
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
