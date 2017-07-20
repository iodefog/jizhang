//
//  SSJPersonalDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailViewController.h"
#import "SSJPersonalDetailUserIconCell.h"
#import "SSJPersonalDetailUserNicknameCell.h"
#import "SSJPersonalDetailUserSignatureCell.h"
#import "SSJPortraitUploadNetworkService.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "TPKeyboardAvoidingTableView.h"

static const NSUInteger kUserNicknameLimit = 10;
static const NSUInteger kUserSignatureLimit = 20;

static NSString *const kSSJPersonalDetailUserIconCellId = @"SSJPersonalDetailUserIconCell";
static NSString *const kSSJPersonalDetailUserNicknameCellId = @"SSJPersonalDetailUserNicknameCell";
static NSString *const kSSJPersonalDetailUserSignatureCellId = @"SSJPersonalDetailUserSignatureCell";

@interface SSJPersonalDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray *cellItems;

@property (nonatomic, strong) SSJPersonalDetailUserIconCellItem *iconItem;

@property (nonatomic, strong) SSJPersonalDetailUserNicknameCellItem *nicknameItem;

@property (nonatomic, strong) SSJPersonalDetailUserSignatureCellItem *signatureItem;

@property (nonatomic, strong) SSJPortraitUploadNetworkService *portraitUploadService;

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

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
    [self updateAppearance];
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        [self organiseCellItemsWithUserItem:userItem];
        [self.view addSubview:self.tableView];
        [self.view setNeedsUpdateConstraints];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveUserItem)];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)updateViewConstraints {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [super updateViewConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.cellItems ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJPersonalDetailUserIconCellItem class]]) {
        SSJPersonalDetailUserIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:kSSJPersonalDetailUserIconCellId forIndexPath:indexPath];
        iconCell.cellItem = item;
        return iconCell;
    } else if ([item isKindOfClass:[SSJPersonalDetailUserNicknameCellItem class]]) {
        SSJPersonalDetailUserNicknameCell *nicknameCell = [tableView dequeueReusableCellWithIdentifier:kSSJPersonalDetailUserNicknameCellId forIndexPath:indexPath];
        nicknameCell.cellItem = item;
        return nicknameCell;
    } else if ([item isKindOfClass:[SSJPersonalDetailUserSignatureCellItem class]]) {
        SSJPersonalDetailUserSignatureCell *signatureCell = [tableView dequeueReusableCellWithIdentifier:kSSJPersonalDetailUserSignatureCellId forIndexPath:indexPath];
        signatureCell.cellItem = item;
        return signatureCell;
    } else {
        return [UITableViewCell new];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.cellItems ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJPersonalDetailUserIconCellItem class]]) {
        return 85;
    } else if ([item isKindOfClass:[SSJPersonalDetailUserNicknameCellItem class]]) {
        return 55;
    } else if ([item isKindOfClass:[SSJPersonalDetailUserSignatureCellItem class]]) {
        return 100;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJBaseCellItem *item = [self.cellItems ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJPersonalDetailUserIconCellItem class]]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
        [sheet showInView:self.view];
    }
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
    self.portraitUploadService = [[SSJPortraitUploadNetworkService alloc] init];
    [self.portraitUploadService uploadimgWithIMG:image finishBlock:^(NSString *icon){
        self.iconItem.userIconUrl = [NSURL URLWithString:SSJImageURLWithAPI(icon)];
        
        SSJUserItem *userItem = [[SSJUserItem alloc] init];
        userItem.userId = SSJUSERID();
        userItem.icon = icon;
        [SSJUserTableManager saveUserItem:userItem success:NULL failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }];
}

#pragma mark - Private
- (void)organiseCellItemsWithUserItem:(SSJUserItem *)userItem {
    NSString *iconUrlStr = [userItem.icon hasPrefix:@"http"] ? userItem.icon : SSJImageURLWithAPI(userItem.icon);
    self.iconItem = [SSJPersonalDetailUserIconCellItem itemWithIconUrl:[NSURL URLWithString:iconUrlStr]];
    self.nicknameItem = [SSJPersonalDetailUserNicknameCellItem itemWithNickname:userItem.nickName];
    self.signatureItem = [SSJPersonalDetailUserSignatureCellItem itemWithSignatureLimit:kUserSignatureLimit signature:userItem.signature title:@"" placeholder:@""];
    self.cellItems = @[@[self.iconItem, self.nicknameItem], @[self.signatureItem]];
}

- (void)saveUserItem {
    if (self.nicknameItem.nickname.length > kUserNicknameLimit) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"昵称最多只能输入%d个字", (int)kUserNicknameLimit]];
        return;
    }
    
    if (self.signatureItem.signature.length > kUserSignatureLimit) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"记账小目标最多只能输入%d个字", (int)kUserSignatureLimit]];
        return;
    }
    
    SSJUserItem *userItem = [[SSJUserItem alloc] init];
    userItem.userId = SSJUSERID();
    userItem.nickName = self.nicknameItem.nickname;
    userItem.signature = self.signatureItem.signature;
    userItem.writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [SSJUserTableManager saveUserItem:userItem success:^{
        [self goBackAction];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

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

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJPersonalDetailUserIconCell class] forCellReuseIdentifier:kSSJPersonalDetailUserIconCellId];
        [_tableView registerClass:[SSJPersonalDetailUserNicknameCell class] forCellReuseIdentifier:kSSJPersonalDetailUserNicknameCellId];
        [_tableView registerClass:[SSJPersonalDetailUserSignatureCell class] forCellReuseIdentifier:kSSJPersonalDetailUserSignatureCellId];
    }
    return _tableView;
}



@end
