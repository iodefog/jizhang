//
//  SSJSyncSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingViewController.h"
#import "SSJSyncSettingTableViewCell.h"
#import "SSJSyncSettingMultiLineCell.h"
#import "SSJSyncSettingWarningFooterView.h"

#import "SSJEncourageService.h"
#import "SSJUserTableManager.h"
#import "SSJDataClearHelper.h"
#import "SSJNetworkReachabilityManager.h"

#import "SSJGlobalServiceManager.h"
#import "ZipArchive.h"

static NSString *const kSSJSyncSettingTableViewCellId = @"SSJSyncSettingTableViewCell";
static NSString *const kSSJSyncSettingMultiLineCellId = @"SSJSyncSettingMultiLineCell";

static NSString *const kQQGroupKey = @"kQQGroupKey";
static NSString *const kQQGroupIdKey = @"kQQGroupIdKey";

@interface SSJSyncSettingViewController ()

@property (nonatomic, strong) NSArray *cellItems;

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic) SSJSyncSettingType syncType;

@property (nonatomic, strong) SSJEncourageService *service;

@property (nonatomic, strong) SSJSyncSettingWarningFooterView *footer;

@end

@implementation SSJSyncSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"数据同步";
        self.hidesBottomBarWhenPushed = YES;
        self.syncType = SSJSyncSetting();
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self handleTableView];
    [self organiseCellItems];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.footer updateAppearanceAccordingToTheme];
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
    if ([item isKindOfClass:[SSJSyncSettingTableViewCellItem class]]) {
        SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJSyncSettingTableViewCellId forIndexPath:indexPath];
        cell.cellItem = item;
        return cell;
    } else if ([item isKindOfClass:[SSJSyncSettingMultiLineCellItem class]]) {
        SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJSyncSettingMultiLineCellId forIndexPath:indexPath];
        cell.cellItem = item;
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 10;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.syncType = SSJSyncSettingTypeWIFI;
        [self updateSyncTypeSelection];
        SSJSaveSyncSetting(self.syncType);
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        self.syncType = SSJSyncSettingTypeWWAN;
        [self updateSyncTypeSelection];
        SSJSaveSyncSetting(self.syncType);
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self uploadAllUserData];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self uploadDBLog];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self repullDataFromServer];
    }
}

#pragma mark - Private
- (void)handleTableView {
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[SSJSyncSettingTableViewCell class] forCellReuseIdentifier:kSSJSyncSettingTableViewCellId];
    [self.tableView registerClass:[SSJSyncSettingMultiLineCell class] forCellReuseIdentifier:kSSJSyncSettingMultiLineCellId];
    self.tableView.tableFooterView = self.footer;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
}

- (void)updateSyncTypeSelection {
    SSJSyncSettingTableViewCell *WIFIItem = [self.cellItems ssj_objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    SSJSyncSettingTableViewCell *WWANItem = [self.cellItems ssj_objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    WIFIItem.accessoryType = self.syncType == SSJSyncSettingTypeWIFI ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    WWANItem.accessoryType = self.syncType == SSJSyncSettingTypeWWAN ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)organiseCellItems {
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        self.userItem = userItem;
        
        NSString *lastSyncTime = [userItem.lastSyncTime ssj_dateStringFromFormat:@"yyyy-MM-dd HH:mm" toFormat:@"yyyy年MM月dd日 HH:mm"];
        if (lastSyncTime) {
            lastSyncTime = [NSString stringWithFormat:@"最后同步日期  %@", lastSyncTime];
        }
        
        
        NSArray *section1 = @[[SSJSyncSettingTableViewCellItem itemWithTitle:@"仅在Wi-Fi自动同步"
                                                               accessoryType:(self.syncType == SSJSyncSettingTypeWIFI ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)],
                              [SSJSyncSettingTableViewCellItem itemWithTitle:@"有网络连接时自动同步"
                                                               accessoryType:(self.syncType == SSJSyncSettingTypeWWAN ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)]];
        NSArray *section2 = @[[SSJSyncSettingMultiLineCellItem itemWithTopTitle:@"将本机数据同步到云端"
                                                                    bottomTitle:lastSyncTime]];
        NSArray *section3 = @[[SSJSyncSettingMultiLineCellItem itemWithTopTitle:@"上传日志"
                                                                    bottomTitle:@"仅在工作人员引导下操作"],
                              [SSJSyncSettingTableViewCellItem itemWithTitle:@"将云端数据拉取到本机"
                                                               accessoryType:UITableViewCellAccessoryDisclosureIndicator]];
        self.cellItems = @[section1, section2, section3];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

/**
 上传用户所有数据
 */
- (void)uploadAllUserData {
    [SSJDataClearHelper uploadAllUserDataWithSuccess:^(NSString *syncTime){
        [CDAutoHideMessageHUD showMessage:@"上传成功"];
        SSJSyncSettingMultiLineCellItem *item = [self.cellItems ssj_objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        item.bottomTitle = [NSString stringWithFormat:@"最后同步日期  %@", syncTime];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

/**
 上传日志
 */
- (void)uploadDBLog {
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.service requestWithSuccess:^(SSJEncourageService * _Nonnull service) {
            [subscriber sendNext:@{kQQGroupKey:service.qqgroup,
                                   kQQGroupIdKey:service.qqgroupId}];
            [subscriber sendCompleted];
        } failure:^(SSJEncourageService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }] subscribeNext:^(NSDictionary *qqInfo) {
        SSJAlertViewAction *uploadAction = [SSJAlertViewAction actionWithTitle:@"仍然上传" handler:^(SSJAlertViewAction * _Nonnull action) {
            NSError *error = nil;
            NSData *zipData = [self zipDatabaseWithError:&error];
            if (error) {
                [SSJAlertViewAdapter showError:error];
                return;
            }
            [self uploadData:zipData BaseWithcompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    [CDAutoHideMessageHUD showMessage:@"上传成功"];
                }
            }];
        }];
        SSJAlertViewAction *contactAction = [SSJAlertViewAction actionWithTitle:@"找工作人员" handler:^(SSJAlertViewAction * _Nonnull action) {
            SSJJoinQQGroup(qqInfo[kQQGroupKey], qqInfo[kQQGroupIdKey]);
        }];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"请在工作人员引导下操作，也可加QQ群552563622反馈" action:uploadAction, contactAction, nil];
    } error:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

/**
 从服务端重新拉取数据
 */
- (void)repullDataFromServer {
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"手机上的记账数据将重新从云端获取，若您多个手机使用APP且数据不一致时可重新拉取，请在WIFi下操作。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即拉取" handler:^(SSJAlertViewAction * _Nonnull action) {
        if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
            [CDAutoHideMessageHUD showMessage:@"请连接网络后重试"];
            return;
        }
        
        [SSJDataClearHelper clearLocalDataWithSuccess:^{
            [CDAutoHideMessageHUD showMessage:@"重新拉取数据成功"];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
    }], nil];
}

- (void)uploadData:(NSData *)data BaseWithcompletionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
#ifdef DEBUG
    [data writeToFile:@"/Users/ricky/Desktop/db_error.zip" atomically:YES];
#endif
    
    SSJGlobalServiceManager *sessionManager = [SSJGlobalServiceManager standardManager];
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SSJURLWithAPI(@"/admin/applog.go") parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"ios_error_db_%lld.zip", SSJMilliTimestamp()];
        [formData appendPartWithFileData:data name:@"zip" fileName:fileName mimeType:@"application/zip"];
    } error:&tError];
    
    //  封装参数，传入请求头
    NSString *userId = SSJUSERID();
    NSString *version = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *phoneOs = [NSString stringWithFormat:@"%f",SSJSystemVersion()];
    NSString *model = SSJPhoneModel();
    NSString *date = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDictionary *parameters = @{@"cuserId":userId,
                                 @"releaseversion":version,
                                 @"cmodel":model,
                                 @"cphoneos":phoneOs,
                                 @"cdate":date,
                                 @"itype":@"2"};
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.timeoutInterval = 60;
    
    //  开始上传
    
    NSURLSessionUploadTask *task = [sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    
    [task resume];
}

//  将data进行zip压缩
- (NSData *)zipDatabaseWithError:(NSError **)error {
    NSString *zipPath = [SSJDocumentPath() stringByAppendingPathComponent:@"db_error.zip"];
    if (![SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[SSJSQLitePath()]]) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"压缩文件发生错误"}];
        }
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:zipPath];
}

- (SSJSyncSettingWarningFooterView *)footer {
    if (!_footer) {
        _footer = [[SSJSyncSettingWarningFooterView alloc] init];
        _footer.warningText = @"若您多个手机使用本App，但数据不一致，请先将你希望同步的数据同步到云端，再将云端数据拉取到本机。";
    }
    return _footer;
}

- (SSJEncourageService *)service {
    if (!_service) {
        _service = [[SSJEncourageService alloc] init];
        _service.showLodingIndicator = YES;
    }
    return _service;
}

@end
