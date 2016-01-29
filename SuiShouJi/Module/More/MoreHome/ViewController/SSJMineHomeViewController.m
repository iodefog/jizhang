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

#import "UIImageView+WebCache.h"
#import "SSJDataSynchronizer.h"

@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@property (nonatomic,strong) UIView *loggedFooterView;
@property (nonatomic,strong) SSJUserInfoNetworkService *userInfoService;
@property (nonatomic,strong) SSJUserInfoItem *item;
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
    if (SSJIsUserLogined()) {
        [self.userInfoService requestUserInfo];
    }
    [self.tableView reloadData];
    _titleForSectionTwoArray = [[NSArray alloc]initWithObjects:@"同步设置",@"关于我们",@"用户协议与隐私说明", nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUserInfo) name:SSJLoginOrRegisterNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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

-(UIView *)loggedFooterView{
    if (_loggedFooterView == nil) {
        _loggedFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *quitLogButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 260, 40)];
        [quitLogButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [quitLogButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        [quitLogButton addTarget:self action:@selector(quitLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        quitLogButton.backgroundColor = [UIColor whiteColor];
        [_loggedFooterView addSubview:quitLogButton];
        quitLogButton.center = CGPointMake(_loggedFooterView.width / 2, _loggedFooterView.height / 2);
    }
    return _loggedFooterView;
}

-(SSJUserInfoNetworkService *)userInfoService{
    if (!_userInfoService) {
        _userInfoService = [[SSJUserInfoNetworkService alloc]initWithDelegate:self];
    }
    return _userInfoService;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == 2) {
        return self.loggedFooterView;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == 2) {
        return 80;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && indexPath.section == 1) {
        SSJSyncSettingViewController *syncSettingVc = [[SSJSyncSettingViewController alloc]init];
        [self.navigationController pushViewController:syncSettingVc animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        NSURL *url = [[NSURL alloc]initWithString:@"http://1.9188.com/h5/about_shq/about.html"];
        SSJNormalWebViewController *webVC = [SSJNormalWebViewController webViewVCWithURL:url];
        webVC.title = @"关于我们";
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 1){
        NSURL *url = [[NSURL alloc]initWithString:@"http://1.9188.com/h5/about_shq/protocol.html"];
        SSJNormalWebViewController *webVC = [SSJNormalWebViewController webViewVCWithURL:url];
        webVC.title = @"用户协议";
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 1;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 0) {
        mineHomeCell.cellTitle = @"给个好评";
    }else if(indexPath.section == 1){
        mineHomeCell.cellTitle = @"同步设置";
    }else if (indexPath.section == 2){
        NSArray *titleForcell = @[@"关于我们",@"用户协议与隐私说明"];
        mineHomeCell.cellTitle = [titleForcell objectAtIndex:indexPath.row];
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

#pragma mark - SCYBaseNetworkServiceDelegate
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
    [super serverDidFinished:service];
    if (service == self.userInfoService) {
        self.item = self.userInfoService.item;
        NSString *phoneNum = [self.item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        self.header.nicknameLabel.text = phoneNum;
        [self.header.nicknameLabel sizeToFit];
        [self.header.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(self.item.cicon)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
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
    
    self.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
    self.header.nicknameLabel.text = @"待君登录";
    
    [self.tableView reloadData];
}

-(void)updateUserInfo{
    self.tableView.tableHeaderView = self.header;
    if (SSJIsUserLogined()) {
        [self.userInfoService requestUserInfo];
    }
    [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.portraitUploadService=[[SSJPortraitUploadNetworkService alloc]init];
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^{
        self.header.headPotraitImage.image = image;
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter]postNotificationName:SSJLoginOrRegisterNotification object:nil];
    }];
}

@end
