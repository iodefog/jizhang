//
//  SSjEncourageViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageViewController.h"
#import "SSJNewAboutUsViewController.h"

#import "SSJEncourageHeaderView.h"
#import "SSJEncourageCell.h"

#import "SSJEncourageService.h"
#import "SSJShareManager.h"

static NSString *const ktitle1 = @"关于我们";
static NSString *const ktitle2 = @"五星好评";
static NSString *const ktitle3 = @"分享给好友";

static NSString *SSJEncourageCellIndetifer = @"SSJEncourageCellIndetifer";



@interface SSJEncourageViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) SSJEncourageHeaderView *header;

@property (nonatomic, strong) UIView *footer;

@property (nonatomic,strong) NSArray *titles;

@property (nonatomic, strong) UIButton *rewardBtn;

@property (nonatomic,strong) SSJEncourageService *service;

@property(nonatomic, strong) NSMutableArray <SSJEncourageCellModel *> *items;

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
    [self organizeCellItems];
    [self.view addSubview:self.tableView];
    [self updateAppearanceAfterThemeChanged];
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
    
    if ([title isEqualToString:ktitle1]) {
        SSJNewAboutUsViewController *aboutVc = [[SSJNewAboutUsViewController alloc] init];
        aboutVc.service = self.service;
        [self.navigationController pushViewController:aboutVc animated:YES];
    }
    
    if ([title isEqualToString:ktitle2]) {
        NSString *urlStr = SSJAppStoreUrl();
        [SSJAnaliyticsManager event:@"love_good"];
        if (urlStr) {
            NSURL *url = [NSURL URLWithString:urlStr];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        
#warning TODO
        //应用内跳转appstore
        return;
    }
    
    if ([title isEqualToString:ktitle3]) {
        [SSJAnaliyticsManager event:@"love_share_to_friends"];
        if ([SSJDefaultSource() isEqualToString:@"11501"]) {
            [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:SSJDetailSettingForSource(@"ShareUrl") title:SSJDetailSettingForSource(@"ShareTitle") content:@"财务管理第一步，从记录消费生活开始!" PlatformType:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:NULL];
        } else {
            [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:SSJDetailSettingForSource(@"ShareUrl") title:SSJDetailSettingForSource(@"ShareTitle") content:@"在这里，记录消费生活是件有趣简单的事儿，管家更有窍门。" PlatformType:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:NULL];
        }
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJEncourageCellModel *item = [self.items ssj_objectAtIndexPath:indexPath];

    SSJEncourageCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJEncourageCellIndetifer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.item = item;
    
    return cell;
}

#pragma mark - SSJBaseNetworkService
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        self.header.currentVersion = self.service.updateModel.appVersion;
    }
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height- SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = self.header;
        _tableView.tableFooterView = self.footer;
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
        _header = [[SSJEncourageHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
    }
    return _header;
}

- (SSJEncourageService *)service {
    if (!_service) {
        _service = [[SSJEncourageService alloc] initWithDelegate:self];
    }
    return _service;
}

- (UIView *)footer {
    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 104)];
        [_footer addSubview:self.rewardBtn];
        self.rewardBtn.frame = CGRectMake(15, 30, _footer.width - 30, 44);
    }
    return _footer;
}

- (UIButton *)rewardBtn {
    if (!_rewardBtn) {
        _rewardBtn = [[UIButton alloc] init];
        [_rewardBtn setTitle:@"打赏支持" forState:UIControlStateNormal];
        _rewardBtn.layer.cornerRadius = 6;
        _rewardBtn.layer.masksToBounds = YES;
        _rewardBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        @weakify(self);
        [[_rewardBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            
            
        }];
    }
    return _rewardBtn;
}

#pragma mark - Private
- (void)organizeCellItems {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (NSArray *titles in self.titles) {
        NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *title in titles) {
            SSJEncourageCellModel *item = [[SSJEncourageCellModel alloc] init];
            item.cellTitle = title;
            if ([title isEqualToString:ktitle2]) {
                item.cellImage = @"fivestars";
            }
            [sectionArr addObject:item];
        }
        
        [tempArr addObject:sectionArr];
    }
    
    self.items = [NSMutableArray arrayWithArray:tempArr];
    
    [self.tableView reloadData];
}


#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [self.rewardBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.rewardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
