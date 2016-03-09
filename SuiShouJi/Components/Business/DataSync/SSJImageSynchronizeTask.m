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

@implementation SSJImageSynchronizeTask

@synthesize syncQueue;

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    NSMutableArray *imageNames = [NSMutableArray array];
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        //  查询当前用户没有同步的图片
        FMResultSet *resultSet = [db executeQuery:@"select a.cimgname from bk_img_sync as a, bk_user_charge as b where a.rid = b.ichargeid and a.operatortype <> 2 and a.isynctype = 0 and a.isyncstate = 0 and b.cuserid = ?", SSJCurrentSyncImageUserId()];
        if (!resultSet) {
            if (failure) {
                failure([db lastError]);
            }
            return;
        }
        
        while ([resultSet next]) {
            NSString *imageName = [resultSet stringForColumn:@"cimgname"];
            if (imageName.length) {
                [imageNames addObject:imageName];
            }
        }
    }];
    
    //  遍历未同步的图片名称，并上传
    for (int i = 0; i < imageNames.count; i++) {
        NSString *imageName = imageNames[i];
        NSString *userId = SSJCurrentSyncImageUserId();
        NSString *thumbImgName = [NSString stringWithFormat:@"%@-thumb", [imageName stringByDeletingPathExtension]];
        NSString *sign = [[NSString stringWithFormat:@"%@%@%@%@", userId, imageName, thumbImgName, kSignKey] ssj_md5HexDigest];
        
        NSMutableData *imageData = [NSMutableData data];
        [imageData appendData:[NSData dataWithContentsOfFile:SSJImagePath(imageName)]];
        [imageData appendData:[NSData dataWithContentsOfFile:SSJImagePath(thumbImgName)]];
        
        NSDictionary *params = @{@"cuserId":userId,
                                 @"imageName":imageName,
                                 @"thumbName":thumbImgName,
                                 @"sign":sign,
                                 @"appVersion":SSJAppVersion()};
        
        [SSJDataSyncHelper uploadBodyData:imageData headerParams:params toUrlPath:@"/sync/syncimg.go" completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
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
                
                if (![resultInfo[@"code"] isEqualToString:@"1"]) {
                    NSString *desc = resultInfo[@"desc"];
                    tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:desc ?: @""}];
                    return;
                }
                
                //  更改图片同步状态
                [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
                    if (![db executeUpdate:@"update bk_img_sync set isyncstate = 1 where cimgname = ?", imageName]) {
                        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:[db lastError]}];
                    }
                }];
                
                //  上传完最后一组图片后根据过程中是否有错误，调用响应的回调
                if (i == imageNames.count - 1) {
                    if (tError) {
                        if (failure) {
                            failure(tError);
                        }
                    } else {
                        if (success) {
                            success();
                        }
                    }
                }
            });
        }];
    }
}

@end
