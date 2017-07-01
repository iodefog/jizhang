//
//  SSjEncourageViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageViewController.h"

#import "SSJEncourageHeaderView.h"
#import "SSJEncourageCell.h"

#import "SSJEncourageService.h"

static NSString *const ktitle1 = @"关于我们";
static NSString *const ktitle2 = @"五星好评";
static NSString *const ktitle3 = @"分享给好友";

static NSString *SSJEncourageCellIndetifer = @"SSJEncourageCellIndetifer";



@interface SSJEncourageViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) SSJEncourageHeaderView *header;

@property (nonatomic,strong) NSArray *titles;

@property (nonatomic,strong) SSJEncourageService *service;

@end

@implementation SSJEncourageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"爱的鼓励";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SSJ_MAIN_PACKAGE) {
        self.titles = @[@[ktitle1],@[ktitle2,ktitle3]];
    } else {
        self.titles = @[@[ktitle1],@[ktitle2]];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.service request];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];

    SSJEncourageCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJEncourageCellIndetifer];
    
    
    
    return cell;
}

#pragma mark - SSJBaseNetworkService
- (void)serverDidStart:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        self.header.currentVersion = self.service.updateModel.appVersion;
    }
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableHeaderView = self.header;
        [_tableView registerClass:[SSJEncourageCell class] forCellReuseIdentifier:SSJEncourageCellIndetifer];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (SSJEncourageHeaderView *)header {
    if (!_header) {
        _header = [[SSJEncourageHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return _header;
}

- (SSJEncourageService *)service {
    if (!_service) {
        _service = [[SSJEncourageService alloc] initWithDelegate:self];
    }
    return _service;
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
