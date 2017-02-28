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
#import "SSJUserTableManager.h"
#import "SSJUserInfoItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserInfoNetworkService.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserInfoItem.h"
//#import "SSJBookkeepingReminderViewController.h"
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
#import "SSJBookkeepingTreeHelper.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBannerNetworkService.h"
#import "SSJBannerHeaderView.h"
#import "SSJReminderViewController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJListAdItem.h"
#import "SSJMineHomeViewController.h"
#import "SSJAnaliyticsManager.h"

#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"
#import "UIViewController+SSJMotionPassword.h"
#import "UMSocial.h"
#import "SSJMineHomeCollectionImageCell.h"
#import "SSJHeaderBannerImageView.h"
#import "SSJProductAdviceViewController.h"
#import "SSJPersonalDetailItem.h"
#import "SSJBillNoteWebViewController.h"
#import "SSJNewDotNetworkService.h"
#import "SSJScrollalbleAnnounceView.h"

#import "SSJThemeAndAdviceDotItem.h"

static NSString *const kTitle1 = @"提醒";
static NSString *const kTitle2 = @"主题皮肤";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"数据导出";
static NSString *const kTitle5 = @"建议与咨询";
static NSString *const kTitle6 = @"给个好评";
static NSString *const kTitle7 = @"设置";
static NSString *const kTitle8 = @"分享APP";
static NSString *const kHeaderViewID = @"headerViewIdentifier";
static NSString *const kItemID = @"homeItemIdentifier";


//static BOOL KHasEnterMineHome;

static BOOL kNeedBannerDisplay = YES;

@interface SSJMineHomeViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UMSocialUIDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SSJHeaderBannerImageViewDelegate>
//UITableViewDelegate,UITableViewDataSource,

@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property (nonatomic,strong) UIView *loggedFooterView;
@property (nonatomic,strong) SSJUserInfoNetworkService *userInfoService;
@property (nonatomic,strong) SSJUserInfoItem *item;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *images;
//@property (nonatomic,strong) NSString *circleChargeState;
@property(nonatomic, strong) UIView *rightbuttonView;
//@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SSJHeaderBannerImageView *headerBannerImageView;//头部banner

@property(nonatomic, strong) SSJScrollalbleAnnounceView *announcementView;
/**
 默认主题底部背景
 */
@property (nonatomic, strong) UIImageView *bottomBgView;
@property(nonatomic, strong) SSJBannerNetworkService *bannerService;

@property (nonatomic, strong) SSJNewDotNetworkService *dotService;
@property(nonatomic, strong) SSJBannerHeaderView *bannerHeader;

@property(nonatomic, strong) SSJPersonalDetailItem *personalDetailItem;

@property (nonatomic, strong) UIView *lineView;
//@property (nonatomic, strong) NSMutableArray<SSJListAdItem *> *adItems;//服务器返回的广告
@property (nonatomic, strong) NSMutableArray<SSJListAdItem *> *localAdItems;//本地固定的广告
@property (nonatomic, strong) NSMutableArray<SSJListAdItem *> *adItemsArray;//合并之后的广告
@end

@implementation SSJMineHomeViewController{
    NSMutableArray *_titleArr;
    BOOL _hasUreadMassage;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"更多";
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.announcementView];
    [self.view addSubview:self.header];
    [self.view addSubview:self.bottomBgView];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bottomBgView.hidden = NO;
    } else {
        self.bottomBgView.hidden = YES;
    }
    [self.view addSubview:self.collectionView];
    [self loadOriDataArray];//固定数组
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bannerService requestBannersList];
    [self.dotService requestThemeAndAdviceUpdate];
        
    SSJUserItem *item = [SSJUserTableManager queryUserItemForID:SSJUSERID()];\
    self.header.item = item;
    [self.header setSignStr];//设置签名
    
    SSJBookkeepingTreeCheckInModel *checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
    self.header.checkInLevel = [SSJBookkeepingTreeHelper treeLevelForDays:checkInModel.checkInTimes];
    
    //    [self getCircleChargeState];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"eb4a64"];
    NSMutableArray *annoucements = [NSMutableArray arrayWithCapacity:0];
    SSJAnnouceMentItem *item1 = [[SSJAnnouceMentItem alloc] init];
    item1.announcementTitle = @"3131223j1ijdioaj";
    item1.announcementType = SSJAnnouceMentTypeHot;
    [annoucements addObject:item1];
    SSJAnnouceMentItem *item2 = [[SSJAnnouceMentItem alloc] init];
    item2.announcementTitle = @"danuidhauhduiahd283818938";
    item2.announcementType = SSJAnnouceMentTypeNew;
    [annoucements addObject:item2];
    SSJAnnouceMentItem *item3 = [[SSJAnnouceMentItem alloc] init];
    item3.announcementTitle = @"31e3131qeweqweqe";
    item3.announcementType = SSJAnnouceMentTypeHot;
    [annoucements addObject:item3];
    self.announcementView.items = annoucements;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self ssj_remindUserToSetMotionPasswordIfNeeded];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.header.size = CGSizeMake(self.view.width, 170);
    self.header.leftTop = CGPointMake(0, self.announcementView.bottom);
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - self.header.bottom);
    self.collectionView.top = self.header.bottom;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.bottomBgView.centerX = self.view.centerX;
    self.bottomBgView.bottom = self.view.bottom - SSJ_TABBAR_HEIGHT;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.userInfoService cancel];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.adItemsArray.count ;
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
    return CGSizeMake(SSJSCREENWITH / kColum, 100);
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
    //如果底部视图
    //    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
    //
    //    }
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
        SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
        return;
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
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:SSJDetailSettingForSource(@"UMAppKey")
                                              shareText:@"财务管理第一步，从记录消费生活开始!"
                                             shareImage:[UIImage imageNamed:SSJDetailSettingForSource(@"ShareIcon")]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                               delegate:self];
        }else{
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:SSJDetailSettingForSource(@"UMAppKey")
                                              shareText:@"在这里，记录消费生活是件有趣简单的事儿，管家更有窍门。"
                                             shareImage:[UIImage imageNamed:SSJDetailSettingForSource(@"ShareIcon")]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                               delegate:self];
        }
    }
    

}

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
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
    
    if ([service isKindOfClass:[SSJNewDotNetworkService class]]) {
        //更改模型数据
        for (SSJListAdItem *item in self.localAdItems) {
            if ([item.adTitle isEqualToString:kTitle2]) {//主题皮肤
                item.isShowDot = self.dotService.dotItem.hasThemeUpdate;
            }
            if ([item.adTitle isEqualToString:kTitle5]) {//建议与咨询
                item.isShowDot = self.dotService.dotItem.hasAdviceUpdate;
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error
{
//    [self loadDataArray];
    self.adItemsArray = self.localAdItems;
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


#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据responseCode得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"分享成功" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],nil];
    }else{
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"分享失败" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],nil];
    }
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if (platformName == UMShareToSina) {
        socialData.shareText = [NSString stringWithFormat:@"%@ %@",SSJDetailSettingForSource(@"ShareTitle"),SSJDetailSettingForSource(@"ShareUrl")];
        socialData.shareImage = [UIImage imageNamed:SSJDetailSettingForSource(@"WeiboBanner")];
    }else{
        socialData.shareText = SSJDetailSettingForSource(@"ShareContent");
    }
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


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake(SSJSCREENWITH/kColum, 100);
        layout.headerReferenceSize = CGSizeMake(SSJSCREENWITH, 0);//头的高度
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[SSJMineHomeCollectionImageCell class] forCellWithReuseIdentifier:kItemID];
        [_collectionView registerClass:[SSJHeaderBannerImageView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewID];//注册头
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

- (UIImageView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_bottom_bgimage"]];
    }
    return _bottomBgView;
}

- (SSJScrollalbleAnnounceView *)announcementView {
    if (!_announcementView) {
        _announcementView = [[SSJScrollalbleAnnounceView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 34)];
    }
    return _announcementView;
}

#pragma mark - Event
-(void)takePhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)localPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}

-(void)reloadDataAfterSync {
    SSJUserItem *item = [SSJUserTableManager queryUserItemForID:SSJUSERID()];
    self.header.item = item;
}

#pragma mark - Private
-(void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.header updateAfterThemeChange];
//    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
//  self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.lineView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bottomBgView.hidden = NO;
    } else {
        self.bottomBgView.hidden = YES;
    }

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
    SSJLoginViewController *loginVc = [[SSJLoginViewController alloc] init];
    loginVc.finishHandle = ^(UIViewController *controller) {
        UITabBarController *tabbarVc = self.navigationController.tabBarController;
        UIViewController *homeController = [((UINavigationController *)[tabbarVc.viewControllers firstObject]).viewControllers firstObject];
        controller.backController = homeController;
        [controller ssj_backOffAction];
    };
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (void)loadOriDataArray
{
    //  根据审核状态显示响应的内容，“给个好评”在审核期间不能被看到，否则可能会被拒绝-
    if ([SSJStartChecker sharedInstance].isInReview) {
        if ([SSJDefaultSource() isEqualToString:@"11501"] || [SSJDefaultSource() isEqualToString:@"11502"]) {
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_share", @"more_fankui", @"more_shezhi"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle8,kTitle5 , kTitle7] mutableCopy];
            _titleArr = [@[kTitle1 , kTitle2 , kTitle3 , kTitle4 , kTitle8 , kTitle5 , kTitle7] mutableCopy];
        } else{
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_fankui", @"more_shezhi"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle5 , kTitle7] mutableCopy];
            _titleArr = [@[kTitle1 , kTitle2 , kTitle3 , kTitle4 , kTitle5 , kTitle7] mutableCopy];
        }
        
    } else {
        if ([SSJDefaultSource() isEqualToString:@"11501"] || [SSJDefaultSource() isEqualToString:@"11502"]) {
            self.images = [@[@"more_tixing", @"more_pifu",@"more_zhouqi",@"more_daochu", @"more_share", @"more_fankui", @"more_haoping", @"more_shezhi"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4,kTitle8, kTitle5 , kTitle6 , kTitle7]mutableCopy];
            _titleArr = [@[kTitle1 , kTitle2 , kTitle3 , kTitle4 , kTitle8 , kTitle5 , kTitle6 , kTitle7] mutableCopy];
        } else{
            self.images = [@[@"more_tixing", @"more_pifu", @"more_zhouqi",@"more_daochu", @"more_fankui", @"more_haoping", @"more_shezhi"] mutableCopy];
            self.titles = [@[kTitle1 , kTitle2 , kTitle3, kTitle4, kTitle5 , kTitle6 , kTitle7] mutableCopy];
            _titleArr = [@[kTitle1 , kTitle2 , kTitle3 , kTitle4 , kTitle5 , kTitle6 , kTitle7] mutableCopy];
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


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.portraitUploadService=[[SSJPortraitUploadNetworkService alloc]init];
    __weak typeof(self) weakSelf = self;
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^(NSString *icon){
//        weakSelf.header.headPotraitImage.headerImage.image = image;
        [weakSelf.collectionView reloadData];
        
        SSJUserItem *userItem = [[SSJUserItem alloc] init];
        userItem.userId = SSJUSERID();
        userItem.icon = icon;
        [SSJUserTableManager saveUserItem:userItem];
    }];
}

-(void)backButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - headerBannerImageView
- (void)pushToViewControllerWithUrl:(NSString *)urlStr title:(NSString *)title
{
    if ([urlStr containsString:@"http://jz.youyuwo.com/5/zd/"]) {
        SSJBillNoteWebViewController *bilVc = [[SSJBillNoteWebViewController alloc] init];
        bilVc.urlStr = urlStr;
        [self presentViewController:bilVc animated:YES completion:nil];
        return;
    }
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

//-(SSJMineHomeTableViewHeader *)header{
//    if (!_header) {
//        _header = [SSJMineHomeTableViewHeader MineHomeHeader];
//        _header.frame = CGRectMake(0, 0, self.view.width, 125);
//        __weak typeof(self) weakSelf = self;
//        _header.HeaderButtonClickedBlock = ^(){
//            if (SSJIsUserLogined()) {
//                SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
//                [weakSelf.navigationController pushViewController:personalDetailVc animated:YES];
//            }else{
//                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
//                loginVC.backController = weakSelf;
//                [weakSelf.navigationController pushViewController:loginVC animated:YES];
//            }
//        };
//        _header.HeaderClickedBlock = ^(){
//            if (!SSJIsUserLogined()) {
//                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
//                loginVC.backController = weakSelf;
//                [weakSelf.navigationController pushViewController:loginVC animated:YES];
//            }else{
//                SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
//                [weakSelf.navigationController pushViewController:personalDetailVc animated:YES];
//            }
//        };
//    }
//    return _header;
//}


@end
