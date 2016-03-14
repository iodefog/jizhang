//
//  SSJImageSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImageSynchronizeTask.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSyncHelper.h"

static NSString *const kImageNameKey = @"kImageNameKey";
static NSString *const kSyncTypeKey = @"kSyncTypeKey";

@interface SSJImageSynchronizeTask ()

@property (nonatomic, strong) NSMutableArray *uploadTasks;

@property (nonatomic, strong) NSMutableArray *failureTasks;

@end

@implementation SSJImageSynchronizeTask

@synthesize syncQueue;

- (instancetype)init {
    if (self = [super init]) {
        self.uploadTasks = [[NSMutableArray alloc] init];
        self.failureTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    NSMutableArray *imageInfoArr = [NSMutableArray array];
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        //  查询当前用户没有同步的图片
        FMResultSet *resultSet = [db executeQuery:@"select a.cimgname, a.isynctype from bk_img_sync as a, bk_user_charge as b where a.rid = b.ichargeid and a.operatortype <> 2 and a.isyncstate = 0 and b.cuserid = ?", SSJCurrentSyncImageUserId()];
        if (!resultSet) {
            if (failure) {
                failure([db lastError]);
            }
            return;
        }
        
        while ([resultSet next]) {
            NSString *imageName = [resultSet stringForColumn:@"cimgname"];
            NSString *syncType = [resultSet stringForColumn:@"isynctype"];
            if (imageName.length) {
                [imageInfoArr addObject:@{kImageNameKey:imageName,
                                          kSyncTypeKey:syncType}];
            }
        }
    }];
    
    if (imageInfoArr.count == 0) {
        SSJPRINT(@"<<< ------- 没有要同步的图片 ------- >>>");
        if (success) {
            success();
        }
        return;
    }
    
    //  遍历未同步的图片名称，并上传
    for (int i = 0; i < imageInfoArr.count; i++) {
        NSDictionary *imageInfo = imageInfoArr[i];
        
        NSString *imageName = imageInfo[kImageNameKey];
        NSString *syncType = imageInfo[kSyncTypeKey];
        NSString *userId = SSJCurrentSyncImageUserId();
        NSString *thumbImgName = [NSString stringWithFormat:@"%@-thumb", [imageName stringByDeletingPathExtension]];
        NSString *sign = [[NSString stringWithFormat:@"%@%@%@%@%@", userId, imageName, thumbImgName, syncType, kSignKey] ssj_md5HexDigest];
        
        NSMutableData *imageData = [NSMutableData data];
        [imageData appendData:[NSData dataWithContentsOfFile:SSJImagePath(imageName)]];
        [imageData appendData:[NSData dataWithContentsOfFile:SSJImagePath(thumbImgName)]];
        
        NSDictionary *params = @{@"cuserId":userId,
                                 @"imageName":imageName,
                                 @"thumbName":thumbImgName,
                                 @"syncType":syncType,
                                 @"sign":sign,
                                 @"appVersion":SSJAppVersion()};
        
        SSJPRINT(@"<<< ------- 图片同步开始! ------- >>>");
        NSURLSessionUploadTask *task = [SSJDataSyncHelper uploadBodyData:imageData headerParams:params toUrlPath:@"/sync/syncimg.go" fileName:imageName mimeType:@"image/jpeg" completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            dispatch_async(self.syncQueue, ^{
                if (tError) {
                    tError = error;
                    return;
                }
                
                //  解析json数据
                NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&tError];
                if (tError) {
                    SSJPRINT(@">>> SSJ warning:an error occured when parse json data\n error:%@", tError);
                    return;
                }
                
                if ([resultInfo[@"code"] intValue] != 1) {
                    NSString *desc = resultInfo[@"desc"];
                    tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:desc ?: @""}];
                    return;
                }
                
                NSDictionary *result = resultInfo[@"results"];
                NSString *uploadImgeName = [result[@"imgurl"] lastPathComponent];
                
                //  更改图片同步状态
                [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
                    if (![db executeUpdate:@"update bk_img_sync set isyncstate = 1 where cimgname = ?", uploadImgeName]) {
                        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:[db lastError]}];
                    }
                }];
                
                //  上传完最后一组图片后根据过程中是否有错误，调用响应的回调
                if (i == imageInfoArr.count - 1) {
                    if (tError) {
                        SSJPRINT(@"<<< ------- 图片同步失败! ------- >>>");
                        if (failure) {
                            failure(tError);
                        }
                    } else {
                        SSJPRINT(@"<<< ------- 图片同步成功！------- >>>");
                        if (success) {
                            success();
                        }
                    }
                }
            });
        }];
        
        [self.uploadTasks addObject:task];
    }
}

- (void)finishWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

@end
