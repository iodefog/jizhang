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
#import "UMFeedback.h"
#import "SSJSettingViewController.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJRegistCompleteViewController.h"
#import "SSJForgetPasswordSecondStepViewController.h"

#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"

static NSString *const kTitle1 = @"手势密码";
static NSString *const kTitle2 = @"记账提醒";
static NSString *const kTitle3 = @"周期记账";
static NSString *const kTitle4 = @"把APP推荐给好友";
static NSString *const kTitle5 = @"意见反馈";
static NSString *const kTitle6 = @"给个好评";
static NSString *const kTitle7 = @"设置";

static NSString *const kUMAppKey = @"566e6f12e0f55ac052003f62";


@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property (nonatomic,strong) UIView *loggedFooterView;
@property (nonatomic,strong) SSJUserInfoNetworkService *userInfoService;
@property (nonatomic,strong) SSJUserInfoItem *item;
@property (nonatomic, strong) NSArray *titles;

//  手势密码开关
@property (nonatomic, strong) UISwitch *motionSwitch;

@end

@implementation SSJMineHomeViewController{
    NSArray *_titleForSectionTwoArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"个人中心";
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
    
    //  根据审核状态显示响应的内容，“给个好评”在审核期间不能被看到，否则可能会被拒绝
    if ([SSJStartChecker sharedInstance].isInReview) {
        self.titles = @[@[kTitle1], @[kTitle2, kTitle3],@[kTitle4],@[kTitle5],@[kTitle7]];
    } else {
        self.titles = @[@[kTitle1], @[kTitle2, kTitle3], @[kTitle4],@[kTitle5, kTitle6],@[kTitle7]];
    }
    
    __weak typeof(self) weakSelf = self;
    [self getUserInfo:^(SSJUserInfoItem *item){
        if (SSJIsUserLogined()) {
            if (item.cmobileno == nil || [item.cmobileno isEqualToString:@""]) {
                weakSelf.header.nicknameLabel.text = item.realName;
                [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:item.cicon] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }else{
                NSString *phoneNum = [item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                weakSelf.header.nicknameLabel.text = phoneNum;
                [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(item.cicon)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }
        } else {
            weakSelf.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
            weakSelf.header.nicknameLabel.text = @"待君登录";
        }
        [weakSelf.tableView reloadData];
    }];
    
    //  查询手势密码是否开启
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWDState"] forUserId:SSJUSERID()];
    [self.motionSwitch setOn:[userItem.motionPWDState boolValue]];
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
            if (SSJIsUserLogined()) {
                UIActionSheet *sheet;
                sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
                [sheet showInView:weakSelf.view];
            }else{
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
                loginVC.backController = weakSelf;
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
            }
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
    return 65;
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
    
    //  手势密码
    if ([title isEqualToString:kTitle1]) {
        SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
        motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
        [self.navigationController pushViewController:motionVC animated:YES];
        return;
    }
    
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
        SSJBookkeepingReminderViewController *BookkeepingReminderVC = [[SSJBookkeepingReminderViewController alloc]init];
        [self.navigationController pushViewController:BookkeepingReminderVC animated:YES];
        return;
    }
    
    //  周期记账
    if ([title isEqualToString:kTitle3]) {
        SSJCircleChargeSettingViewController *circleChargeSettingVC = [[SSJCircleChargeSettingViewController alloc]init];
        [self.navigationController pushViewController:circleChargeSettingVC animated:YES];
        return;
    }

    //  把APP推荐给好友
    if ([title isEqualToString:kTitle4]) {
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:kUMAppKey
                                          shareText:@"财务管理第一步，从记录消费生活开始!"
                                         shareImage:[UIImage imageNamed:@"icon"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                           delegate:self];
    }
    
    //意见反馈
    if ([title isEqualToString:kTitle5]) {
        [self.navigationController pushViewController:[UMFeedback feedbackViewController]
                                             animated:YES];
    }
    
    if ([title isEqualToString:kTitle7]) {
        SSJSettingViewController *settingVC = [[SSJSettingViewController alloc]init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
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
        socialData.shareText = @"9188记账——财务管理第一步，从记录消费生活开始! http://1.9188.com/h5/jizhangApp/";
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
            item.realName = [rs stringForColumn:@"CREALNAME"];
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
            if (item.cmobileno == nil || [item.cmobileno isEqualToString:@""]) {
                weakSelf.header.nicknameLabel.text = item.realName;
                [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:item.cicon] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }else{
                NSString *phoneNum = [item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                weakSelf.header.nicknameLabel.text = phoneNum;
                [weakSelf.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(item.cicon)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
            }
        } else {
            weakSelf.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
            weakSelf.header.nicknameLabel.text = @"待君登录";
        }
    }];
}

- (void)motionSwitchAction {
    if (self.motionSwitch.isOn) {
        if (!SSJIsUserLogined()) {
            [self.motionSwitch setOn:NO animated:YES];
            
            __weak typeof(self) weakSelf = self;
            SSJAlertViewAction *registAction = [SSJAlertViewAction actionWithTitle:@"注册" handler:^(SSJAlertViewAction *action) {
                SSJRegistGetVerViewController *registerVc = [[SSJRegistGetVerViewController alloc] init];
                registerVc.finishHandle = ^(UIViewController *controller){
                    if ([controller isKindOfClass:[SSJRegistCompleteViewController class]]) {
                        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
                    } else if ([controller isKindOfClass:[SSJForgetPasswordSecondStepViewController class]]) {
                        SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
                        [weakSelf.navigationController setViewControllers:@[weakSelf, loginVC] animated:YES];
                    }
                };
                [self.navigationController pushViewController:registerVc animated:YES];
            }];
            SSJAlertViewAction *loginAction = [SSJAlertViewAction actionWithTitle:@"登录" handler:^(SSJAlertViewAction *action) {
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
                [weakSelf.navigationController pushViewController:loginVC animated:YES];
            }];
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"开启手势密码，需要您登录后方可使用哦！" action:registAction, loginAction, nil];
        } else {
            SSJUserItem *item = [[SSJUserItem alloc] init];
            item.userId = SSJUSERID();
            item.motionPWDState = @"1";
            [SSJUserTableManager saveUserItem:item];
        }
    } else {
        
        SSJUserItem *item = [[SSJUserItem alloc] init];
        item.userId = SSJUSERID();
        item.motionPWDState = @"0";
        [SSJUserTableManager saveUserItem:item];
    }
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

@end
