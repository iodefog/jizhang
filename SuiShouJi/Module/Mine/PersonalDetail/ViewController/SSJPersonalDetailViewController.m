//
//  SSJPersonalDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailViewController.h"
#import "SSJPersonalDetailItem.h"
#import "SSJPersonalDetailHelper.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"

@interface SSJPersonalDetailViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SSJPersonalDetailItem *item;

@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;

@end

@implementation SSJPersonalDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"个人资料";
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
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self localPhoto];
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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
        [SSJUserTableManager saveUserItem:userItem success:NULL failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }];
}


#pragma mark - Event
- (void)uploadUserIcon {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
    [sheet showInView:self.view];
}

//- (void)modifyNickname {
//    self.item.nickName = textInputed;
//    SSJUserItem *userItem = [[SSJUserItem alloc] init];
//    userItem.userId = SSJUSERID();
//    userItem.nickName = textInputed;
//    userItem.writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    [SSJUserTableManager saveUserItem:userItem success:^{
//        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//    } failure:^(NSError * _Nonnull error) {
//        [SSJAlertViewAdapter showError:error];
//    }];
//}
//
//- (void)modifySignature {
//    weakSelf.item.signature = textInputed;
//    SSJUserItem *userItem = [[SSJUserItem alloc] init];
//    userItem.userId = SSJUSERID();
//    userItem.signature = textInputed;
//    userItem.writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    [SSJUserTableManager saveUserItem:userItem success:^{
//        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//    } failure:^(NSError * _Nonnull error) {
//        [SSJAlertViewAdapter showError:error];
//    }];
//}

- (void)takePhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    } else {
        SSJPRINT(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

- (void)localPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}

@end
