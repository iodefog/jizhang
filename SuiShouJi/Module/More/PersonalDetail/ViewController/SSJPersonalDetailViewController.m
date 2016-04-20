//
//  SSJPersonalDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString *const kTitle1 = @"更换头像";
static NSString *const kTitle2 = @"昵称";
static NSString *const kTitle3 = @"个性签名";
static NSString *const kTitle4 = @"手机号";
static NSString *const kTitle5 = @"修改密码";

#import "SSJPersonalDetailViewController.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJPersonalDetailItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJPersonalDetailHelper.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserItem.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJPasswordModifyViewController.h"
#import "SSJNickNameModifyView.h"


@interface SSJPersonalDetailViewController ()
@property (nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) SSJPersonalDetailItem *item;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property(nonatomic, strong) UIView *loggedFooterView;
@property(nonatomic, strong) SSJNickNameModifyView *nickNameModifyView;
@property(nonatomic, strong) SSJNickNameModifyView *signatureModifyView;
@end

@implementation SSJPersonalDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"个人资料";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [SSJPersonalDetailHelper queryUserDetailWithsuccess:^(SSJPersonalDetailItem *data) {
        weakSelf.item = [[SSJPersonalDetailItem alloc]init];
        weakSelf.item = data;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (SSJUserLoginType() != SSJLoginTypeNormal) {
        self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3]];
    }else{
        self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3],@[kTitle4],@[kTitle5]];
    }
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
        return self.loggedFooterView;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
        return 80;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle1]) {
        UIActionSheet *sheet;
        sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
        [sheet showInView:self.view];
    }
    if ([title isEqualToString:kTitle5]) {
        SSJPasswordModifyViewController *passwordModifyVC = [[SSJPasswordModifyViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:passwordModifyVC animated:YES];
    }
    if ([title isEqualToString:kTitle2]) {
        [self.nickNameModifyView show];
    }
    if ([title isEqualToString:kTitle3]) {
        [self.signatureModifyView show];
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
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    mineHomeCell.cellTitle = title;
    if ([title isEqualToString:kTitle1]) {
        if ([self.item.iconUrl hasPrefix:@"http"]) {
            [mineHomeCell.portraitImage sd_setImageWithURL:[NSURL URLWithString:self.item.iconUrl] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        }else{
            [mineHomeCell.portraitImage sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(self.item.iconUrl)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        }
    }else if ([title isEqualToString:kTitle2]){
        if ([self.item.nickName isEqualToString:@""] || self.item.nickName == nil) {
            mineHomeCell.cellDetail = @"起个名字吧~";
        }else{
            mineHomeCell.cellDetail = self.item.nickName;
        }
    }else if ([title isEqualToString:kTitle3]){
        if ([self.item.signature isEqualToString:@""] || self.item.signature == nil) {
            mineHomeCell.cellDetail = @"啥也不留~";
        }else{
            mineHomeCell.cellDetail = self.item.signature;
        }
    }else if ([title isEqualToString:kTitle4]){
        mineHomeCell.cellDetail = self.item.mobileNo;
    }else if ([title isEqualToString:kTitle5]){
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return mineHomeCell;
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.portraitUploadService=[[SSJPortraitUploadNetworkService alloc]init];
    __weak typeof(self) weakSelf = self;
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^(NSString *icon){
        weakSelf.item.iconUrl = icon;
        [weakSelf.tableView reloadData];
        
        SSJUserItem *userItem = [[SSJUserItem alloc] init];
        userItem.userId = SSJUSERID();
        userItem.icon = icon;
        [SSJUserTableManager saveUserItem:userItem];
    }];
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
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
-(UIView *)loggedFooterView{
    if (_loggedFooterView == nil) {
        _loggedFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *quitLogButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _loggedFooterView.width - 20, 40)];
        [quitLogButton setTitle:@"退出登录" forState:UIControlStateNormal];
        quitLogButton.layer.cornerRadius = 3.f;
        quitLogButton.layer.masksToBounds = YES;
        [quitLogButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [quitLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitLogButton addTarget:self action:@selector(quitLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        quitLogButton.center = CGPointMake(_loggedFooterView.width / 2, _loggedFooterView.height / 2);
        [_loggedFooterView addSubview:quitLogButton];
    }
    return _loggedFooterView;
}

-(SSJNickNameModifyView *)nickNameModifyView{
    if (!_nickNameModifyView) {
        _nickNameModifyView = [[SSJNickNameModifyView alloc]initWithFrame:[UIScreen mainScreen].bounds maxTextLength:10 title:@"昵称"];
        if (self.item.nickName != nil || ![self.item.nickName isEqualToString:@""]) {
            _nickNameModifyView.originalText = self.item.nickName;
        }
        __weak typeof(self) weakSelf = self;
        _nickNameModifyView.comfirmButtonClickedBlock = ^(NSString *textInputed){
            weakSelf.item.nickName = textInputed;
            [weakSelf.tableView reloadData];
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.nickName = textInputed;
            userItem.writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [SSJUserTableManager saveUserItem:userItem];
            if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
                [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
            }
        };
        _nickNameModifyView.typeErrorBlock = ^(NSString *errorDesc){
            [CDAutoHideMessageHUD showMessage:errorDesc];
        };
    }
    return _nickNameModifyView;
}

-(SSJNickNameModifyView *)signatureModifyView{
    if (!_signatureModifyView) {
        _signatureModifyView = [[SSJNickNameModifyView alloc]initWithFrame:[UIScreen mainScreen].bounds maxTextLength:20 title:@"个性签名"];
        if (self.item.signature != nil || ![self.item.signature isEqualToString:@""]) {
            _signatureModifyView.originalText = self.item.signature;
        }
        __weak typeof(self) weakSelf = self;
        _signatureModifyView.comfirmButtonClickedBlock = ^(NSString *textInputed){
            weakSelf.item.signature = textInputed;
            [weakSelf.tableView reloadData];
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.signature = textInputed;
            userItem.writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [SSJUserTableManager saveUserItem:userItem];
            if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
                [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
            }
        };
        _signatureModifyView.typeErrorBlock = ^(NSString *errorDesc){
            [CDAutoHideMessageHUD showMessage:errorDesc];
        };
    }
    return _signatureModifyView;
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
