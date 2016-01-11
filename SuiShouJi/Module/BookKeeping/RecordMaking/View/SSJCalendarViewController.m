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

@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;

@end

@implementation SSJCalendarViewController{
    long _currentYear;
    long _currentMonth;
    long _currentDay;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCurrentDate];
    self.selectedYear = _currentYear;
    self.selectedMonth = _currentMonth ;
    self.navigationItem.titleView = self.dateChangeView;
    self.tableView.tableHeaderView = self.calendarView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"],NSFontAttributeName:[UIFont systemFontOfSize:21]};
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.dateLabel.center = CGPointMake(self.dateChangeView.width / 2, self.dateChangeView.height / 2);
    self.plusButton.left = self.dateLabel.right + 10;
    self.minusButton.right = self.dateLabel.left - 10;
    self.plusButton.centerY = self.dateChangeView.height / 2;
    self.minusButton.centerY = self.dateChangeView.height / 2;
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
    return 55;
}   

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.view.height - 270;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.noDateView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Getter
-(UIBarButtonItem*)rightBarButton{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClicked)];
        _rightBarButton.tintColor = [UIColor blackColor];
    }
    return _rightBarButton;
}

-(SSJCalendarView *)calendarView{
    if (_calendarView == nil) {
        _calendarView = [[SSJCalendarView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 270)];
        _calendarView.year = _currentYear;
        _calendarView.month = _currentMonth;
        __weak typeof(self) weakSelf = self;
        _calendarView.DateSelectedBlock = ^(long year , long month ,long day){
            weakSelf.selectedYear = year;
            weakSelf.selectedMonth = month ;
            weakSelf.selectedDay = day;
            [weakSelf.tableView reloadData];
        };
    }
    return _calendarView;
}

-(UIView *)dateChangeView{
    if (!_dateChangeView) {
        _dateChangeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
        [_dateChangeView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_dateChangeView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"e8e8e8"]];
        _dateChangeView.backgroundColor = [UIColor whiteColor];
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
        _dateLabel.font = [UIFont systemFontOfSize:18];
        [_dateLabel sizeToFit];
        _plusButton = [[UIButton alloc]init];
        _plusButton.frame = CGRectMake(0, 0, 30, 30);
        [_plusButton setTitle:@"+" forState:UIControlStateNormal];
        [_plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _plusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton = [[UIButton alloc]init];
        _minusButton.frame = CGRectMake(0, 0, 30, 30);
        [_minusButton setTitle:@"-" forState:UIControlStateNormal];
        [_minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_minusButton addTarget:self action:@selector(minusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_dateChangeView addSubview:_dateLabel];
        [_dateChangeView addSubview:_plusButton];
        [_dateChangeView addSubview:_minusButton];
    }
    return _dateChangeView;
}

-(UIView *)noDateView{
    if (!_noDateView) {
        _noDateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 270)];
        _firstLineLabel = [[UILabel alloc]init];

        _firstLineLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _firstLineLabel.text = @"还没有任何记账记录哦";
        [_firstLineLabel sizeToFit];
        [_noDateView addSubview:_firstLineLabel];
        _secondLineLabel = [[UILabel alloc]init];

        _secondLineLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _secondLineLabel.text = @"赶紧来记一笔吧";
        [_secondLineLabel sizeToFit];
        [_noDateView addSubview:_secondLineLabel];
        _recordMakingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_recordMakingButton setTitle:@"记一笔" forState:UIControlStateNormal];
        [_recordMakingButton addTarget:self action:@selector(recordMakingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _recordMakingButton.backgroundColor = [UIColor redColor];
        _recordMakingButton.layer.cornerRadius = 30;
        _recordMakingButton.layer.borderColor = [UIColor redColor].CGColor;
        [_noDateView addSubview:_recordMakingButton];
    }
    return _noDateView;
}
#pragma mark - private
-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear = [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
}

-(void)plusButtonClicked:(UIButton*)button{
    self.selectedMonth = self.selectedMonth + 1;
    if (self.selectedMonth == 13) {
        self.selectedMonth = 1;
        self.selectedYear = self.selectedYear + 1;
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
    [self.dateLabel  sizeToFit];
    self.calendarView.year = self.selectedYear;
    self.calendarView.month = self.selectedMonth;
    [self.calendarView.calendar reloadData];
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
    [self.calendarView.calendar reloadData];
}

-(void)recordMakingButtonClicked:(UIButton*)button{
    SSJRecordMakingViewController *recordMakingVC = [[SSJRecordMakingViewController alloc]init];
    recordMakingVC.selectedDay = self.selectedDay;
    recordMakingVC.selectedMonth = self.selectedMonth;
    recordMakingVC.selectedYear = self.selectedYear;
    [self.navigationController pushViewController:recordMakingVC animated:YES];
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
