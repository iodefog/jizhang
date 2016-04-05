//
//  SSJMoreHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeViewController.h"
#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineHomeTabelviewCell.h"
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


#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"

static NSString *const kTitle1 = @"手势密码";
static NSString *const kTitle2 = @"记账提醒";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"记账树";
static NSString *const kTitle5 = @"把APP推荐给好友";
static NSString *const kTitle6 = @"给个好评";

static NSString *const kUMAppKey = @"566e6f12e0f55ac052003f62";


@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property (nonatomic,strong) UIView *loggedFooterView;
@property (nonatomic,strong) SSJUserInfoNetworkService *userInfoService;
@property (nonatomic,strong) SSJUserInfoItem *item;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) NSString *circleChargeState;
@property(nonatomic, strong) UIView *rightbuttonView;

//  手势密码开关
@property (nonatomic, strong) UISwitch *motionSwitch;

@end

@implementation SSJMineHomeViewController{
    NSArray *_titleForSectionTwoArray;
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
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  根据审核状态显示响应的内容，“给个好评”在审核期间不能被看到，否则可能会被拒绝
    if ([SSJStartChecker sharedInstance].isInReview) {
        self.titles = @[@[kTitle1], @[kTitle2, kTitle3],@[kTitle4],@[kTitle5],@[kTitle6]];
    } else {
        self.titles = @[@[kTitle1], @[kTitle2, kTitle3], @[kTitle4],@[kTitle5],@[kTitle6]];
    }
    
    __weak typeof(self) weakSelf = self;
    [self getUserInfo:^(SSJUserInfoItem *item){
        if (SSJIsUserLogined()) {
            NSString *iconStr;
            if ([item.cicon hasPrefix:@"http"]) {
                iconStr = item.cicon;
            }else{
                iconStr = SSJImageURLWithAPI(item.cicon);
            }
            if (item.cmobileno == nil || [item.cmobileno isEqualToString:@""]) {
                //三方登录
                weakSelf.header.nicknameLabel.text = item.realName;
            }else{
                //手机号登陆
                NSString *phoneNum = [item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                weakSelf.header.nicknameLabel.text = phoneNum;
            }
            [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        } else {
            weakSelf.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
            weakSelf.header.nicknameLabel.text = @"待君登录";
        }
        [weakSelf.tableView reloadData];
    }];
    
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

#pragma mark - Getter
-(SSJMineHomeTableViewHeader *)header{
    if (!_header) {
        _header = [SSJMineHomeTableViewHeader MineHomeHeader];
        _header.frame = CGRectMake(0, 0, self.view.width, 125);
        __weak typeof(self) weakSelf = self;
        _header.HeaderButtonClickedBlock = ^(){
//            if (SSJIsUserLogined()) {
//                UIActionSheet *sheet;
//                sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
//                [sheet showInView:weakSelf.view];
//            }else{
//                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
//                loginVC.backController = weakSelf;
//                [weakSelf.navigationController pushViewController:loginVC animated:YES];
//            }
            SSJPersonalDetailViewController *personalDetailVc = [[SSJPersonalDetailViewController alloc]init];
            [weakSelf.navigationController pushViewController:personalDetailVc animated:YES];
        };
        _header.HeaderClickedBlock = ^(){
            if (!SSJIsUserLogined()) {
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
                loginVC.backController = weakSelf;
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
            }
        };
    }
    return _header;
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
    if ([title isEqualToString:kTitle6]) {
        NSURL *url = [NSURL URLWithString:SSJAppStoreAddress];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }
    
    //  记账提醒
    if ([title isEqualToString:kTitle2]) {
        SSJBookkeepingReminderViewController *BookkeepingReminderVC = [[SSJBookkeepingReminderViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    //  周期记账
    if ([title isEqualToString:kTitle3]) {
        SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
        return;
    }

    //  把APP推荐给好友
    if ([title isEqualToString:kTitle5]) {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMAppKey
                                          shareText:@"财务管理第一步，从记录消费生活开始!"
                                         shareImage:[UIImage imageNamed:@"icon"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                           delegate:self];
    }
    
//    //意见反馈
//    if ([title isEqualToString:kTitle6]) {
//        [self.navigationController pushViewController:[UMFeedback feedbackViewController]
//                                             animated:YES];
//    }
    
//    if ([title isEqualToString:kTitle7]) {
//        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
//        [self.navigationController pushViewController:settingVC animated:YES];
//    }
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
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    mineHomeCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    
    if ([mineHomeCell.cellTitle isEqualToString:kTitle1]) {
        mineHomeCell.accessoryView = self.motionSwitch;
    } else {
        mineHomeCell.accessoryView = nil;
    }
    if ([mineHomeCell.cellTitle isEqualToString:kTitle2]) {
        mineHomeCell.detailLabel.text = self.circleChargeState;
        [mineHomeCell.detailLabel sizeToFit];
    }else{
        mineHomeCell.detailLabel.text = @"";
    }

    return mineHomeCell;
}

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"分享成功"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"分享失败"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if (platformName == UMShareToSina) {
        socialData.shareText = @"9188记账——财务管理第一步，从记录消费生活开始! http://5.9188.com/note/d/";
        socialData.shareImage = [UIImage imageNamed:@"weibo_banner"];
    }
    else{
        socialData.shareText = @"财务管理第一步，从记录消费生活开始!";
    }
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self localPhoto];
            break;
    }
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

-(void)quitLogButtonClicked:(id)sender {
    //  退出登陆后强制同步一次
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
    
    SSJClearLoginInfo();
    
    [SSJUserTableManager reloadUserIdWithError:nil];
    [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithSuccess:NULL failure:NULL];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:SSJLastSelectFundItemKey];
    self.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
    self.header.nicknameLabel.text = @"待君登录";
    
    [self.tableView reloadData];
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
        if (SSJIsUserLogined()) {
            NSString *iconStr;
            if ([item.cicon hasPrefix:@"http"]) {
                iconStr = item.cicon;
            }else{
                iconStr = SSJImageURLWithAPI(item.cicon);
            }
            if (item.cmobileno == nil || [item.cmobileno isEqualToString:@""]) {
                //三方登录
                weakSelf.header.nicknameLabel.text = item.realName;
            }else{
                //手机号登陆
                NSString *phoneNum = [item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                weakSelf.header.nicknameLabel.text = phoneNum;
            }
            [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        } else {
            weakSelf.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
            weakSelf.header.nicknameLabel.text = @"待君登录";
        }
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

- (void)setttingButtonClick:(id)sender{
        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:settingVC animated:YES];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.portraitUploadService=[[SSJPortraitUploadNetworkService alloc]init];
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^(NSString *icon){
        self.header.headPotraitImage.image = image;
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter]postNotificationName:SSJLoginOrRegisterNotification object:nil];
        
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

-(UIView *)rightbuttonView{
    if (!_rightbuttonView) {
        _rightbuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.frame = CGRectMake(0, 0, 44, 44);
        [comfirmButton setTitle:@"设置" forState:UIControlStateNormal];
//        [comfirmButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(setttingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightbuttonView addSubview:comfirmButton];
    }
    return _rightbuttonView;
}

@end
