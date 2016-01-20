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
#import "SSJPortraitUploadNetworkService.h"

@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;
@end

@implementation SSJMineHomeViewController{
    NSArray *_titleForSectionTwoArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"个人中心";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.header;
    _titleForSectionTwoArray = [[NSArray alloc]initWithObjects:@"同步设置",@"关于我们",@"用户协议与隐私说明", nil];
    __weak typeof(self) weakSelf = self;
    if (SSJIsUserLogined()) {
        _header.HeaderButtonClickedBlock = ^(){
            UIActionSheet *sheet;
            sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
            [sheet showInView:weakSelf.view];
        };
    }else{
        _header.HeaderButtonClickedBlock = ^(){
            SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
            loginVC.backController = weakSelf;
            [weakSelf.navigationController pushViewController:loginVC animated:YES];
        };
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = self.header;
    __weak typeof(self) weakSelf = self;
    if (SSJIsUserLogined()) {
        _header.HeaderButtonClickedBlock = ^(){
            UIActionSheet *sheet;
            sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
            [sheet showInView:weakSelf.view];
        };
    }else{
        _header.HeaderButtonClickedBlock = ^(){
            SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
            loginVC.backController = weakSelf;
            [weakSelf.navigationController pushViewController:loginVC animated:YES];
        };
    }
}

#pragma mark - Getter
-(SSJMineHomeTableViewHeader *)header{
    if (!_header) {
        _header = [SSJMineHomeTableViewHeader MineHomeHeader];
        _header.frame = CGRectMake(0, 0, self.view.width, 125);

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



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.portraitUploadService=[[SSJPortraitUploadNetworkService alloc]init];
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^{
//        [self loadUserBaseServiceShowIndicator:YES];
//        [weakSelf.tableView reloadData];
    }];
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
