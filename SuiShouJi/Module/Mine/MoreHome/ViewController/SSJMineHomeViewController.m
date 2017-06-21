//
//  SSJMoreHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineHomeImageCell.h"
#import "SSJSyncSettingViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJLoginViewController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJUserTableManager.h"
#import "SSJUserInfoItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserInfoNetworkService.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserInfoItem.h"

#import "SSJCircleChargeSettingViewController.h"
#import "SSJThemeHomeViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJSettingViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJRegistCompleteViewController.h"
#import "SSJForgetPasswordSecondStepViewController.h"
#import "SSJPersonalDetailViewController.h"
#import "SSJBookkeepingTreeViewController.h"
#import "SSJMagicExportViewController.h"
#import "SSJAnnouncementWebViewController.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBannerNetworkService.h"
#import "SSJBannerHeaderView.h"
#import "SSJReminderViewController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJListAdItem.h"
#import "SSJMineHomeViewController.h"
#import "SSJAnnouncementsListViewController.h"

#import "SSJAnaliyticsManager.h"

#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"
#import "UIViewController+SSJMotionPassword.h"
#import "SSJMineHomeCollectionImageCell.h"
#import "SSJHeaderBannerImageView.h"
#import "SSJProductAdviceViewController.h"
#import "SSJPersonalDetailItem.h"
#import "SSJNewDotNetworkService.h"
#import "SSJAnnoucementService.h"
#import "SSJScrollalbleAnnounceView.h"
#import "SSJMoreHomeAnnouncementButton.h"
#import "SSJNetworkReachabilityManager.h"
#import "SSJShareManager.h"
#import "SSJMoreBackImageViewCollectionReusableView.h"


#import "SSJThemeAndAdviceDotItem.h"

static NSString *const kTitle1 = @"提醒";
static NSString *const kTitle2 = @"主题皮肤";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"数据导出";
static NSString *const kTitle5 = @"建议与咨询";
static NSString *const kTitle6 = @"给个好评";
static NSString *const kTitle7 = @"设置";
static NSString *const kTitle8 = @"分享APP";
static NSString *const kTitle9 = @"帮助";
static NSString *const kHeaderViewID = @"headerViewIdentifier";
static NSString *const kFooterViewID = @"footerViewIdentifier";

static NSString *const kItemID = @"homeItemIdentifier";

static BOOL kNeedBannerDisplay = YES;

@interface SSJMineHomeViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SSJHeaderBannerImageViewDelegate>

@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;

@property(nonatomic, strong) SSJPersonalDetailItem *personalDetailItem;

@property (nonatomic, strong) NSMutableArray<SSJListAdItem *> *localAdItems;//本地固定的广告

@property (nonatomic, strong) NSMutableArray<SSJListAdItem *> *adItemsArray;//合并之后的广告

@property (nonatomic, strong) NSMutableArray *titles;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SSJHeaderBannerImageView *headerBannerImageView;//头部banner

@property(nonatomic, strong) SSJScrollalbleAnnounceView *announcementView;

@property(nonatomic, strong) SSJMoreHomeAnnouncementButton *rightButton;

@property(nonatomic, strong) NSArray *announcements;

/**
 默认主题底部背景
 */
@property (nonatomic, strong) SSJMoreBackImageViewCollectionReusableView *bottomBgView;

@property(nonatomic, strong) SSJBannerHeaderView *bannerHeader;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) SSJNewDotNetworkService *dotService;

@property(nonatomic, strong) SSJBannerNetworkService *bannerService;

@property(nonatomic, strong) SSJAnnoucementService *annoucementService;

@end

@implementation SSJMineHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"更多";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoComplishedNotice) name:kUserItemReturnKey object:nil];
    [self.view addSubview:self.announcementView];
    [self.view addSubview:self.header];
    [self.view addSubview:self.collectionView];
    [self loadOriDataArray];//固定数组
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bannerService requestBannersList];
    [self.dotService requestThemeAndAdviceUpdate];
    
    if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
        [self getLocalAnnoucement];
    } else {
        [self.annoucementService requestAnnoucementsWithPage:1];
    }
    
    [self updateSign];
    
    [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull checkInModel) {
        self.header.checkInLevel = [SSJBookkeepingTreeHelper treeLevelForDays:checkInModel.checkInTimes];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    //    [self getCircleChargeState];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
}

// 更新用户签名
- (void)updateSign {
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        self.header.item = userItem;
        [self.header setSignStr];//设置签名
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self ssj_remindUserToSetMotionPasswordIfNeeded];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.header.size = CGSizeMake(self.view.width, 170);
    self.header.leftTop = CGPointMake(0, self.announcementView.bottom);
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - self.header.bottom - SSJ_TABBAR_HEIGHT);
    self.collectionView.top = self.header.bottom;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
//    self.bottomBgView.centerX = self.view.centerX;
//    self.bottomBgView.bottom = self.view.bottom - SSJ_TABBAR_HEIGHT;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.adItemsArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJMineHomeCollectionImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kItemID forIndexPath:indexPath];
    
    [cell setAdItem:[self.adItemsArray ssj_safeObjectAtIndex:indexPath.item] indexPath:indexPath];
    return cell;
}



#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //最后一列
    int itemWidth = floor(SSJSCREENWITH / kColum);
    if ((indexPath.item+1) % kColum == 0) {
        return CGSizeMake(SSJSCREENWITH - itemWidth * 2, 100);
    } else {
        return CGSizeMake(itemWidth, 100);
    }
}

//  返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && kNeedBannerDisplay == YES) {
        self.headerBannerImageView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewID forIndexPath:indexPath];
        self.headerBannerImageView.delegate = self;
        self.headerBannerImageView.bannerItemArray = self.bannerService.item.bannerItems;
        //添加头视图的内容
        return self.headerBannerImageView;
    }
    //    如果底部视图
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        self.bottomBgView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterViewID forIndexPath:indexPath];
        [self.bottomBgView setNeedsLayout];
        return self.bottomBgView;
    }
    
    return nil;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJListAdItem *item = [self.adItemsArray ssj_safeObjectAtIndex:indexPath.item];
    
    // 如果是广告
    if (item.url.length && item.imageUrl.length) {
        SSJAdWebViewController *webVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:item.url]];
        [self.navigationController pushViewController:webVc animated:YES];
    }
    
    //  给个好评
    if ([item.adTitle isEqualToString:kTitle6]) {
        NSString *urlStr = SSJAppStoreUrl();
        if (urlStr) {
            NSURL *url = [NSURL URLWithString:urlStr];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        return;
    }
    
    //  记账提醒
    if ([item.adTitle isEqualToString:kTitle1]) {
        SSJReminderViewController *BookkeepingReminderVC = [[SSJReminderViewController alloc]init];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    //  周期记账
    if ([item.adTitle isEqualToString:kTitle3]) {
        if (SSJGetBooksCategory() == SSJBooksCategoryPersional) {
            SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
            return;
        } else if (SSJGetBooksCategory() == SSJBooksCategoryPublic) {
            [CDAutoHideMessageHUD showMessage:@"共享账本不能周期记账哦~"];
        }
        
    }

    //建议与咨询
    if ([item.adTitle isEqualToString:kTitle5]) {
        SSJProductAdviceViewController *adviceVC = [[SSJProductAdviceViewController alloc] init];
        [adviceVC setHidesBottomBarWhenPushed:YES];
        //更改模型数据
        for (SSJListAdItem *item in self.localAdItems) {
            if ([item.adTitle isEqualToString:kTitle5]) {//建议与咨询
                item.isShowDot = NO;
            }
        }
        [self.navigationController pushViewController:adviceVC animated:YES];
    }
    
    //数据导出
    if ([item.adTitle isEqualToString:kTitle4]) {
        if (SSJIsUserLogined()) {
            SSJMagicExportViewController *magicExportVC = [[SSJMagicExportViewController alloc] init];
            [self.navigationController pushViewController:magicExportVC animated:YES];
        } else {
            __weak typeof(self) wself = self;
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，登录后才能导出数据哦" action:[SSJAlertViewAction actionWithTitle:@"暂不导出" handler:NULL], [SSJAlertViewAction actionWithTitle:@"去登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                [wself login];
            }], nil];
        }
    }
    
    //设置
    if ([item.adTitle isEqualToString:kTitle7]) {
        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    //主题
    if ([item.adTitle isEqualToString:kTitle2]) {
        SSJThemeHomeViewController *themeVC = [[SSJThemeHomeViewController alloc]init];
        //更改模型数据
        for (SSJListAdItem *item in self.localAdItems) {
            if ([item.adTitle isEqualToString:kTitle2]) {//主题皮肤
                item.isShowDot = NO;
                
                if (self.dotService.dotItem.themeVersion.length > 0 && ![self.dotService.dotItem.themeVersion isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kThemeVersionKey]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:self.dotService.dotItem.themeVersion forKey:kThemeVersionKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
        }
        [self.navigationController pushViewController:themeVC animated:YES];
    }
    
    //  把APP推荐给好友
    if ([item.adTitle isEqualToString:kTitle8]) {
        if ([SSJDefaultSource() isEqualToString:@"11501"]) {
            [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:SSJDetailSettingForSource(@"ShareUrl") title:SSJDetailSettingForSource(@"ShareTitle") content:@"财务管理第一步，从记录消费生活开始!" PlatformType:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:NULL];
        } else {
            [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:SSJDetailSettingForSource(@"ShareUrl") title:SSJDetailSettingForSource(@"ShareTitle") content:@"在这里，记录消费生活是件有趣简单的事儿，管家更有窍门。" PlatformType:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:NULL];
        }
        
    }
    
    if ([item.adTitle isEqualToString:kTitle9]) {
        SSJAdWebViewController *helpVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:@"http://jzcms.youyuwo.com/a/bangzhu/index.html"]];
        helpVc.title = @"记账帮助";
        [self.navigationController pushViewController:helpVc animated:YES];
    }
}

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
    if ([service isKindOfClass:[SSJNewDotNetworkService class]]) return;
    if ([service isKindOfClass:[SSJBannerNetworkService class]]) {
        //banner
        if (self.bannerService.item.bannerItems.count) {
            UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
            if (kNeedBannerDisplay == YES) {
                collectionViewLayout.headerReferenceSize = CGSizeMake(SSJSCREENWITH, kBannerHeight);
                self.lineView.top = kBannerHeight;
            }else{
                self.lineView.top = 0;
            }
        }
        [self loadDataArray];
    }
    
    if ([service isKindOfClass:[SSJAnnoucementService class]]) {
        NSArray *topAnnoucements = [NSArray array];
        if (self.annoucementService.annoucements.count > 3) {
            topAnnoucements = [self.annoucementService.annoucements subarrayWithRange:NSMakeRange(0, 3)];
        } else {
            topAnnoucements = self.annoucementService.annoucements;
        }
        if (topAnnoucements.count) {
            self.announcementView.items = topAnnoucements;
            self.rightButton.hasNewAnnoucements = self.annoucementService.hasNewAnnouceMent;
            self.announcements = [NSArray arrayWithArray:self.annoucementService.annoucements];
            self.announcementView.height = 34;
            self.announcementView.hidden = NO;
            [self.view setNeedsLayout];
        }
    }
    [self.collectionView reloadData];
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error
{
//    [self loadDataArray];
    self.adItemsArray = self.localAdItems;
    [self.collectionView reloadData];
    [self getLocalAnnoucement];
}

#pragma mark -- NoticeCenter
- (void)userInfoComplishedNotice
{
    //更改模型数据
    for (SSJListAdItem *item in self.localAdItems) {
        if ([item.adTitle isEqualToString:kTitle2]) {//主题皮肤
            item.isShowDot = self.dotService.dotItem.hasThemeUpdate;
        }
        if ([item.adTitle isEqualToString:kTitle5]) {//建议与咨询
            item.isShowDot = self.dotService.dotItem.hasAdviceUpdate;
        }
    }
    [self.collectionView reloadData];
}

- (void)loadDataArray
{
//插入广告模型
    NSMutableArray *tempArray = [NSMutableArray array];
    for (SSJListAdItem *listAdItem in self.bannerService.item.listAdItems) {
        if (listAdItem.hidden) {
            [tempArray addObject:listAdItem];
        }
    }
    
    for (SSJListAdItem *item in self.localAdItems) {
        [tempArray addObject:item];
    }
    self.adItemsArray = tempArray;
    [self additionOrgDataToModel];
}

#pragma mark - Getter
-(SSJBannerHeaderView *)bannerHeader {
    if (!_bannerHeader) {
        __weak typeof(self) weakSelf = self;
        _bannerHeader = [[SSJBannerHeaderView alloc]init];
        _bannerHeader.closeButtonClickBlock = ^(){
            kNeedBannerDisplay = NO;
            [weakSelf.collectionView reloadData];
        };
        _bannerHeader.bannerClickedBlock = ^(NSString *url , NSString *title){
            SSJAdWebViewController *webVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:url]];
            [weakSelf.navigationController pushViewController:webVc animated:YES];
        };
    }
    return _bannerHeader;
}

-(SSJBannerNetworkService *)bannerService {
    if (!_bannerService) {
        _bannerService = [[SSJBannerNetworkService alloc]initWithDelegate:self];
        _bannerService.httpMethod = SSJBaseNetworkServiceHttpMethodGET;
    }
    return _bannerService;
}

- (SSJNewDotNetworkService *)dotService
{
    if (!_dotService) {
        _dotService = [[SSJNewDotNetworkService alloc] initWithDelegate:self];
        _dotService.httpMethod = SSJBaseNetworkServiceHttpMethodGET;
    }
    return _dotService;
}

- (SSJAnnoucementService *)annoucementService {
    if (!_annoucementService) {
        _annoucementService = [[SSJAnnoucementService alloc] initWithDelegate:self];
    }
    return _annoucementService;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        layout.itemSize = CGSizeMake(SSJSCREENWITH/kColum, 100);
        layout.headerReferenceSize = CGSizeMake(SSJSCREENWITH, 0);//头的高度
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            double footerHeight = 0;
            if (CGSizeEqualToSize(screenSize, CGSizeMake(768.0, 1024.0))) {
                footerHeight = 118;
            } else if (CGSizeEqualToSize(screenSize, CGSizeMake(1536.0, 2048.0))) {
                footerHeight = 236;
            } else {
                footerHeight = 150;
            }
            layout.footerReferenceSize = CGSizeMake(SSJSCREENWITH, 150);//头的高度
        } else {
            layout.footerReferenceSize = CGSizeMake(SSJSCREENWITH, 0);//头的高度
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SSJMineHomeCollectionImageCell class] forCellWithReuseIdentifier:kItemID];
        [_collectionView registerClass:[SSJHeaderBannerImageView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewID];//注册头
        [_collectionView registerClass:[SSJMoreBackImageViewCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterViewID];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView addSubview:self.lineView];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}


-(SSJMineHomeTableViewHeader *)header {
    if (!_header) {
        __weak typeof(self) weakSelf = self;
        _header = [[SSJMineHomeTableViewHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 170)];
        _header.HeaderClickedBlock = ^(){
            [weakSelf loginButtonClicked];
        };
        _header.checkInButtonClickBlock = ^(){
            SSJBookkeepingTreeViewController *treeVC = [[SSJBookkeepingTreeViewController alloc] init];
            [weakSelf.navigationController pushViewController:treeVC animated:YES];
        };
        _header.shouldSyncBlock = ^BOOL() {
            BOOL shouldSync = SSJIsUserLogined();
            if (!shouldSync) {
                [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，登录后才能同步数据哦" action:[SSJAlertViewAction actionWithTitle:@"暂不同步" handler:NULL], [SSJAlertViewAction actionWithTitle:@"去登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                    [weakSelf login];
                }], nil];
            }
            return shouldSync;
        };
    }
    return _header;
}

- (NSMutableArray<SSJListAdItem *> *)adItemsArray
{
    if (!_adItemsArray) {
        _adItemsArray = [NSMutableArray array];
    }
    return _adItemsArray;
}

- (NSMutableArray<SSJListAdItem *> *)localAdItems
{
    if (!_localAdItems) {
        _localAdItems = [NSMutableArray array];
    }
    return _localAdItems;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, 0.5)];
        _lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _lineView;
}

- (SSJScrollalbleAnnounceView *)announcementView {
    if (!_announcementView) {
        _announcementView = [[SSJScrollalbleAnnounceView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 0)];
        _announcementView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _announcementView.announceClickedBlock = ^(SSJAnnoucementItem *item) {
            if (item) {
                SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:item.announcementUrl]];
                webVc.item = item;
                [weakSelf.navigationController pushViewController:webVc animated:YES];
            }
        };
//        _announcementView.hidden = YES;
    }
    return _announcementView;
}

- (SSJMoreHomeAnnouncementButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[SSJMoreHomeAnnouncementButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        __weak typeof(self) weakSelf = self;
        _rightButton.buttonClickBlock = ^(){
            SSJAnnouncementsListViewController *annoucementListVc = [[SSJAnnouncementsListViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
            annoucementListVc.items = [weakSelf.announcements mutableCopy];
            annoucementListVc.totalPage = weakSelf.annoucementService.totalPage;
            [weakSelf.navigationController pushViewController:annoucementListVc animated:YES];
        };
    }
    return _rightButton;
}

#pragma mark - Event
-(void)reloadDataAfterSync {
    [self updateSign];
}

#pragma mark - Private
-(void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.header updateAfterThemeChange];
//    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
//  self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        collectionViewLayout.footerReferenceSize = CGSizeMake(SSJSCREENWITH, 150);
    } else {
        collectionViewLayout.footerReferenceSize = CGSizeMake(SSJSCREENWITH, 0);
    }
    
    [self.rightButton updateAfterThemeChange];
    [self.announcementView updateAppearanceAfterThemeChanged];
}

//-(void)getCircleChargeState {
//    __weak typeof(self) weakSelf = self;
//    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
//        BOOL isOnOrNot = [db intForQuery:@"select isonornot from BK_CHARGE_REMINDER"];
//        if (isOnOrNot) {
//            weakSelf.circleChargeState = @"开启";
//        }else{
//            weakSelf.circleChargeState = @"关闭";
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.collectionView reloadData];
//        });
//    }];
//}

- (void)loginButtonClicked {
    if (!SSJIsUserLogined()) {
        [self login];
    }else{
        SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:personalDetailVc animated:YES];
    }
}

- (void)login {
    SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc] init];
//    SSJLoginViewController *loginVc = [[SSJLoginViewController alloc] init];
//    loginVc.finishHandle = ^(UIViewController *controller) {
//        UITabBarController *tabbarVc = self.navigationController.tabBarController;
//        UIViewController *homeController = [((UINavigationController *)[tabbarVc.viewControllers firstObject]).viewControllers firstObject];
//        controller.backController = homeController;
//        [controller ssj_backOffAction];
//    };
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (void)loadOriDataArray
{
    //  根据审核状态显示响应的内容，“给个好评”在审核期间不能被看到，否则可能会被拒绝-
    if ([SSJStartChecker sharedInstance].isInReview) {
        if ([SSJDefaultSource() isEqualToString:@"11501"] || [SSJDefaultSource() isEqualToString:@"11502"]) {
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_share", @"more_fankui", @"more_shezhi",@"more_help"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle8,kTitle5 , kTitle7, kTitle9 ] mutableCopy];
        } else{
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_fankui", @"more_shezhi",@"more_help"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle5 , kTitle7, kTitle9] mutableCopy];
        }
        
    } else {
        if ([SSJDefaultSource() isEqualToString:@"11501"] || [SSJDefaultSource() isEqualToString:@"11502"]) {
            self.images = [@[@"more_tixing", @"more_pifu",@"more_zhouqi",@"more_daochu", @"more_share", @"more_fankui", @"more_haoping", @"more_shezhi",@"more_help"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle8, kTitle5 , kTitle6 , kTitle7, kTitle9]mutableCopy];
        } else{
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_fankui", @"more_haoping", @"more_shezhi",@"more_help"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4, kTitle5 , kTitle6 , kTitle7, kTitle9] mutableCopy];
        }
    }
    [self orgDataToModel];
    self.adItemsArray = self.localAdItems;
    [self additionOrgDataToModel];
    [self.collectionView reloadData];
}

- (void)orgDataToModel
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i=0; i < self.titles.count; i++) {
        SSJListAdItem *item = [[SSJListAdItem alloc] init];
        item.adTitle = [self.titles ssj_safeObjectAtIndex:i];
        item.imageName = [self.images ssj_safeObjectAtIndex:i];
        item.imageUrl = nil;
        item.hidden = NO;
        item.url = nil;//不需要跳转网页
        [tempArray addObject:item];
    }
    self.localAdItems = tempArray;
}


/**
 处理如果不是3的倍数的时候空出的位置部分底部线，和背景的问题
 */
- (void)additionOrgDataToModel
{
    while (self.adItemsArray.count % 3 != 0) {
        SSJListAdItem *item = [[SSJListAdItem alloc] init];
        item.adTitle = @"";
        item.imageName = @"";
        item.imageUrl = nil;
        item.hidden = NO;
        item.url = nil;//不需要跳转网页
        [self.adItemsArray addObject:item];
    }
}

- (void)getLocalAnnoucement {
    
    NSString *directory = [SSJDocumentPath() stringByAppendingPathComponent:@"annoucements"];
    
    NSString *filePath = [directory stringByAppendingPathComponent:@"lastAnnoucements.json"];

    NSData *data= [NSData dataWithContentsOfFile:filePath];
    
    NSArray *jsonArr;
    
    if (data) {
         jsonArr = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:NULL];
    }
    
    NSArray *annoucements = [SSJAnnoucementItem mj_objectArrayWithKeyValuesArray:jsonArr];

    if (annoucements.count > 0) {
        self.announcementView.hidden = NO;
        self.announcementView.items = annoucements;
        self.announcementView.height = 34;
        [self.view setNeedsLayout];
    }
}


-(void)backButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - headerBannerImageView
- (void)pushToViewControllerWithUrl:(NSString *)urlStr title:(NSString *)title
{
//    if ([urlStr containsString:@"http://jz.youyuwo.com/5/zd/"]) {
//        SSJBillNoteWebViewController *bilVc = [[SSJBillNoteWebViewController alloc] init];
//        bilVc.urlStr = urlStr;
//        [self presentViewController:bilVc animated:YES completion:nil];
//        return;
//    }
    SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:urlStr]];
    if (title.length) {
        webVc.title = title;
    } else {
        webVc.showPageTitleInNavigationBar = YES;
    }
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)pushToViewControllerWithVC:(UIViewController *)vc
{
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)closeBanner
{
    kNeedBannerDisplay = NO;
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (kNeedBannerDisplay == YES) {
        collectionViewLayout.headerReferenceSize = CGSizeMake(SSJSCREENWITH, kBannerHeight);
        self.lineView.top = kBannerHeight;
    }else{
        collectionViewLayout.headerReferenceSize = CGSizeMake(SSJSCREENWITH, 0);
        self.lineView.top = 0;
    }
    [self.collectionView reloadData];
}

@end
