//
//  SSJMoreHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeViewController.h"
#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineHomeImageCell.h"
#import "SSJSyncSettingViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSJLoginViewController.h"
#import "SSJUserTableManager.h"
#import "SSJUserInfoItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserInfoNetworkService.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserInfoItem.h"
#import "SSJBookkeepingReminderViewController.h"
#import "SSJCircleChargeSettingViewController.h"
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

#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"
#import <YWFeedbackFMWK/YWFeedbackKit.h>


static NSString *const kTitle1 = @"记账提醒";
static NSString *const kTitle2 = @"周期记账";
static NSString *const kTitle3 = @"数据文件导出";
static NSString *const kTitle4 = @"意见反馈";
static NSString *const kTitle5 = @"给个好评";
static NSString *const kTitle6 = @"设置";



@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property (nonatomic,strong) UIView *loggedFooterView;
@property (nonatomic,strong) SSJUserInfoNetworkService *userInfoService;
@property (nonatomic,strong) SSJUserInfoItem *item;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic,strong) NSString *circleChargeState;
@property(nonatomic, strong) UIView *rightbuttonView;

@property (nonatomic, strong) YWFeedbackKit *feedbackKit;



//  手势密码开关
@property (nonatomic, strong) UISwitch *motionSwitch;

@end

@implementation SSJMineHomeViewController{
    NSArray *_titleForSectionTwoArray;
    SSJUserInfoItem *_userItem;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"更多";
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.header;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //  根据审核状态显示响应的内容，“给个好评”在审核期间不能被看到，否则可能会被拒绝-
    if ([SSJStartChecker sharedInstance].isInReview) {
        self.images = @[@[[UIImage imageNamed:@"more_tixing"], [UIImage imageNamed:@"more_zhouqi"]],@[[UIImage imageNamed:@"more_daochu"]], @[[UIImage imageNamed:@"more_fankui"], [UIImage imageNamed:@"more_shezhi"]]];
        self.titles = @[@[kTitle1 , kTitle2], @[kTitle3],@[kTitle4 , kTitle6]];
    } else {
        self.images = @[@[[UIImage imageNamed:@"more_tixing"], [UIImage imageNamed:@"more_zhouqi"]],@[[UIImage imageNamed:@"more_daochu"]], @[[UIImage imageNamed:@"more_fankui"], [UIImage imageNamed:@"more_haoping"], [UIImage imageNamed:@"more_shezhi"]]];
        self.titles = @[@[kTitle1 , kTitle2], @[kTitle3], @[kTitle4 , kTitle5 , kTitle6]];
    }

    __weak typeof(self) weakSelf = self;
    [self getUserInfo:^(SSJUserInfoItem *item){
        weakSelf.header.item = item;
        _userItem = item;
    }];
    
    SSJBookkeepingTreeCheckInModel *checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
    self.header.checkInLevel = [SSJBookkeepingTreeHelper treeLevelForDays:checkInModel.checkInTimes];
    
    //  查询手势密码是否开启
    if (SSJIsUserLogined()) {
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWDState"] forUserId:SSJUSERID()];
        [self.motionSwitch setOn:[userItem.motionPWDState boolValue]];
    } else {
        [self.motionSwitch setOn:NO];
    }
    [self getCircleChargeState];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.userInfoService cancel];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
    //  给个好评
    if ([title isEqualToString:kTitle5]) {
        NSURL *url = [NSURL URLWithString:SSJAppStoreAddress];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }
    
    //  记账提醒
    if ([title isEqualToString:kTitle1]) {
        SSJBookkeepingReminderViewController *BookkeepingReminderVC = [[SSJBookkeepingReminderViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    //  周期记账
    if ([title isEqualToString:kTitle2]) {
        SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
        return;
    }
    
//    //  记账树
//    if ([title isEqualToString:kTitle4]) {
//        SSJBookkeepingTreeViewController *treeVC = [[SSJBookkeepingTreeViewController alloc] init];
//        [self.navigationController pushViewController:treeVC animated:YES];
//        return;
//    }

//    //  把APP推荐给好友
//    if ([title isEqualToString:kTitle5]) {
//        [UMSocialSnsService presentSnsIconSheetView:self
//                                             appKey:kUMAppKey
//                                          shareText:@"财务管理第一步，从记录消费生活开始!"
//                                         shareImage:[UIImage imageNamed:@"icon"]
//                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
//                                           delegate:self];
//    }
    
    //意见反馈
    if ([title isEqualToString:kTitle4]) {
        __weak typeof(self) weakSelf = self;
        [self.feedbackKit makeFeedbackViewControllerWithCompletionBlock:^(YWFeedbackViewController *viewController, NSError *error) {
            if ( viewController != nil ) {
#warning 这里可以设置你需要显示的标题
                viewController.title = @"反馈界面";
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
                [weakSelf presentViewController:nav animated:YES completion:nil];
                
                viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(actionQuitFeedback)];
                
                __weak typeof(nav) weakNav = nav;
                
                [viewController setOpenURLBlock:^(NSString *aURLString, UIViewController *aParentController) {
                    UIViewController *webVC = [[UIViewController alloc] initWithNibName:nil bundle:nil];
                    UIWebView *webView = [[UIWebView alloc] initWithFrame:webVC.view.bounds];
                    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                    
                    [webVC.view addSubview:webView];
                    [weakNav pushViewController:webVC animated:YES];
                    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aURLString]]];
                }];
            } else {
                NSString *title = [error.userInfo objectForKey:@"msg"]?:@"接口调用失败，请保持网络通畅！";
            }
        }];

    }
    
    //数据导出
    if ([title isEqualToString:kTitle3]) {
        SSJMagicExportViewController *magicExportVC = [[SSJMagicExportViewController alloc] init];
        [self.navigationController pushViewController:magicExportVC animated:YES];
    }
    
    //设置
    if ([title isEqualToString:kTitle6]) {
        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
//    if ([title isEqualToString:kTitle7]) {
//        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
//        [self.navigationController pushViewController:settingVC animated:YES];
//    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSMutableArray *titleArr = [NSMutableArray array];
//    [titleArr addObjectsFromArray:self.titles];
//    SSJMineHomeImageCell * currentCell = (SSJMineHomeImageCell *)cell;
//    currentCell.transform = CGAffineTransformMakeTranslation(self.view.width , 0);
//    [UIView animateWithDuration:0.7 delay:0.1 * [self.titles indexOfObject:currentCell.cellTitle] options:UIViewAnimationOptionTransitionCurlUp animations:^{
//        currentCell.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeImageCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    mineHomeCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    
    mineHomeCell.cellImage = [self.images ssj_objectAtIndexPath:indexPath];
    
    if ([mineHomeCell.cellTitle isEqualToString:kTitle1]) {
        mineHomeCell.cellDetail = self.circleChargeState;
    }else{
        mineHomeCell.cellDetail = @"";
    }
    
    if ([mineHomeCell.cellTitle isEqualToString:kTitle4]) {
        mineHomeCell.cellSubTitle = @"反馈交流QQ群:552563622";
    }
    return mineHomeCell;
}

#pragma mark - Getter
-(SSJMineHomeTableViewHeader *)header{
    if (!_header) {
        __weak typeof(self) weakSelf = self;
        _header = [[SSJMineHomeTableViewHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 135)];
        _header.HeaderClickedBlock = ^(){
            [weakSelf loginButtonClicked];
        };
        _header.syncButtonClickBlock = ^(){
            [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(SSJDataSynchronizeType type){
                if (type == SSJDataSynchronizeTypeData) {
                    
                }
            }failure:^(SSJDataSynchronizeType type, NSError *error) {
            
            }];
        };
        _header.checkInButtonClickBlock = ^(){
            SSJBookkeepingTreeViewController *treeVC = [[SSJBookkeepingTreeViewController alloc] init];
            [weakSelf.navigationController pushViewController:treeVC animated:YES];
        };
    }
    return _header;
}

-(YWFeedbackKit *)feedbackKit{
    if (!_feedbackKit) {
        NSString *avtarUrl;
        if ([_userItem.cicon hasPrefix:@"http"]) {
            avtarUrl = _userItem.cicon;
        }else{
            avtarUrl = SSJImageURLWithAPI(_userItem.cicon);
        }
        _feedbackKit = [[YWFeedbackKit alloc] initWithAppKey:@"60028148"];
        _feedbackKit.customUIPlist = @{@"bgColor":@"#eb4a64",
                                       @"color":@"#393939",
                                       @"avatar":avtarUrl};
        _feedbackKit.extInfo = @{@"userid":_userItem.cuserid ,
                                 @"loginType":@(SSJUserLoginType()),
                                 @"mobileNo":_userItem.cmobileno};
    }
    return _feedbackKit;
}

#pragma mark - Event
-(void)takePhoto{
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

-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}


-(void)getUserInfo:(void (^)(SSJUserInfoItem *item))UserInfo{
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_USER WHERE CUSERID = ?",SSJUSERID()];
        SSJUserInfoItem *item = [[SSJUserInfoItem alloc]init];
        while ([rs next]) {
            item.cuserid = [rs stringForColumn:@"CUSERID"];
            item.cmobileno = [rs stringForColumn:@"CMOBILENO"];
            item.cicon = [rs stringForColumn:@"CICONS"];
            item.realName = [rs stringForColumn:@"CNICKID"];
        }
        SSJDispatch_main_async_safe(^(){
            UserInfo(item);
        });
    }];
}

-(void)reloadDataAfterSync{
    __weak typeof(self) weakSelf = self;
    [self getUserInfo:^(SSJUserInfoItem *item){
        weakSelf.header.item = item;
        _userItem = item;
    }];
}

//  手势密码开关
- (void)motionSwitchAction {
    if (self.motionSwitch.isOn) {
        if (!SSJIsUserLogined()) {
            //  如果用户没有登录，提示用户登录或注册
            [self alertUserToLoginOrRegister];
        } else {
            //  如果保存了手势密码，就保存开启状态，反之进入设置手势密码页面
            SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD"] forUserId:SSJUSERID()];
            if (userItem.motionPWD.length > 0) {
                [self saveMotionPasswordState:YES];
            } else {
                SSJMotionPasswordViewController *motinoVC = [[SSJMotionPasswordViewController alloc] init];
                motinoVC.type = SSJMotionPasswordViewControllerTypeSetting;
                [self.navigationController pushViewController:motinoVC animated:YES];
            }
        }
    } else {
        [self saveMotionPasswordState:NO];
    }
}

#pragma mark - Private
//  提示用户登录或注册
- (void)alertUserToLoginOrRegister {
    [self.motionSwitch setOn:NO animated:YES];
    __weak typeof(self) weakSelf = self;
    SSJAlertViewAction *registAction = [SSJAlertViewAction actionWithTitle:@"注册" handler:^(SSJAlertViewAction *action) {
        SSJRegistGetVerViewController *registerVc = [[SSJRegistGetVerViewController alloc] init];
        registerVc.finishHandle = ^(UIViewController *controller){
            if ([controller isKindOfClass:[SSJRegistCompleteViewController class]]) {
                //  注册完成后返回个人中心
                [weakSelf.navigationController popToViewController:weakSelf animated:YES];
            } else if ([controller isKindOfClass:[SSJForgetPasswordSecondStepViewController class]]) {
                //  忘记密码完成后返回登录页面
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
                loginVC.backController = weakSelf;
                [weakSelf.navigationController setViewControllers:@[weakSelf, loginVC] animated:YES];
            }
        };
        [weakSelf.navigationController pushViewController:registerVc animated:YES];
    }];
    SSJAlertViewAction *loginAction = [SSJAlertViewAction actionWithTitle:@"登录" handler:^(SSJAlertViewAction *action) {
        SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
        loginVC.backController = weakSelf;
        [weakSelf.navigationController pushViewController:loginVC animated:YES];
    }];
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"开启手势密码，需要您登录后方可使用哦！" action:registAction, loginAction, nil];
}

//  保存手势密码开启状态
- (void)saveMotionPasswordState:(BOOL)state {
    SSJUserItem *item = [[SSJUserItem alloc] init];
    item.userId = SSJUSERID();
    item.motionPWDState = state ? @"1" : @"0";
    [SSJUserTableManager saveUserItem:item];
}


-(void)getCircleChargeState{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        BOOL isOnOrNot = [db intForQuery:@"select isonornot from BK_CHARGE_REMINDER"];
        if (isOnOrNot) {
            weakSelf.circleChargeState = @"开启";
        }else{
            weakSelf.circleChargeState = @"关闭";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)loginButtonClicked{
    if (!SSJIsUserLogined()) {
        SSJLoginViewController *loginVc = [[SSJLoginViewController alloc]init];
        [self.navigationController pushViewController:loginVc animated:YES];
    }else{
        SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc]init];
        [self.navigationController pushViewController:personalDetailVc animated:YES];
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
        [weakSelf.tableView reloadData];
        
        SSJUserItem *userItem = [[SSJUserItem alloc] init];
        userItem.userId = SSJUSERID();
        userItem.icon = icon;
        [SSJUserTableManager saveUserItem:userItem];
    }];
}

#pragma mark - Getter
- (UISwitch *)motionSwitch {
    if (!_motionSwitch) {
        _motionSwitch = [[UISwitch alloc] init];
        [_motionSwitch addTarget:self action:@selector(motionSwitchAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _motionSwitch;
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
