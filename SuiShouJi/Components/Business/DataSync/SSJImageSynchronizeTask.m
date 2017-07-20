//
//  SSJImageSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImageSynchronizeTask.h"
#import "SSJDatabaseQueue.h"

static NSString *const kSyncImagePrivateKey = @"iwannapie?!";

static NSString *const kImageNameKey = @"kImageNameKey";
static NSString *const kSyncTypeKey = @"kSyncTypeKey";

@interface SSJImageSynchronizeTask ()

@property (nonatomic) NSInteger uploadCounter;

@end

@implementation SSJImageSynchronizeTask

- (NSString *)thumbImgNameWithImgName:(NSString *)imgName {
    NSString *thumbImgName = [NSString stringWithFormat:@"%@-thumb", [imgName stringByDeletingPathExtension]];
    return [thumbImgName stringByAppendingPathExtension:imgName.pathExtension];
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    NSArray *syncImages = [self getImagesNeedToSyncWithError:&tError];
    
    if (tError) {
        if (failure) {
            failure(tError);
        }
        return;
    }
    
    if (syncImages.count == 0) {
        if (success) {
            success();
        }
        return;
    }
    
    self.uploadCounter = syncImages.count;
    
    // 遍历未同步的图片名称，并上传
    for (int i = 0; i < syncImages.count; i++) {
        NSDictionary *imageInfo = syncImages[i];
        
        NSString *imageName = imageInfo[kImageNameKey];
        NSString *syncType = imageInfo[kSyncTypeKey];
        NSString *userId = self.userId;
        NSString *thumbImgName = [self thumbImgNameWithImgName:imageName];
        NSString *sign = [[NSString stringWithFormat:@"%@%@%@%@%@", userId, imageName, thumbImgName, syncType, kSyncImagePrivateKey] ssj_md5HexDigest];
        
        NSDictionary *params = @{@"cuserId":userId,
                                 @"imageName":imageName,
                                 @"thumbName":thumbImgName,
                                 @"syncType":syncType,
                                 @"sign":sign,
                                 @"appVersion":SSJAppVersion()};
        
        NSMutableArray *imageList = [NSMutableArray arrayWithCapacity:2];
        NSData *imgData = [NSData dataWithContentsOfFile:SSJImagePath(imageName)];
        NSData *thumbData = [NSData dataWithContentsOfFile:SSJImagePath(thumbImgName)];
        
        if (imgData) {
            [imageList addObject:[SSJSyncFileModel modelWithFileData:imgData fileName:imageName mimeType:@"image/jpeg"]];
        }
        
        if (thumbData) {
            [imageList addObject:[SSJSyncFileModel modelWithFileData:thumbData fileName:thumbImgName mimeType:@"image/jpeg"]];
        }
        
        if (imageList.count == 0) {
            if (failure) {
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeNoImageSyncNeedToSync userInfo:@{NSLocalizedDescriptionKey:@"没有需要同步的图片"}]);
            }
            return;
        }
        
        SSJPRINT(@"<<< ------- 图片同步开始! ------- >>>");
        [self uploadModelList:imageList headerParams:params toUrlPath:@"/sync/syncimg.go" completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            dispatch_async(self.syncQueue, ^{
                
                self.uploadCounter --;
                
                if (error) {
                    if (self.uploadCounter == 0) {
                        if (failure) {
                            failure(error);
                        }
                    }
                    return;
                }
                
                // 解析json数据
                NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&tError];
                if (tError) {
                    SSJPRINT(@">>> SSJ warning:an error occured when parse json data\n error:%@", tError);
                    if (self.uploadCounter == 0) {
                        if (failure) {
                            failure(tError);
                        }
                    }
                    return;
                }
                
                if ([resultInfo[@"code"] intValue] != 1) {
                    NSString *desc = resultInfo[@"desc"];
                    tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:desc ?: @""}];
                    if (self.uploadCounter == 0) {
                        if (failure) {
                            failure(tError);
                        }
                    }
                    return;
                }
                
                NSDictionary *result = resultInfo[@"results"];
                NSString *uploadImgName = [result[@"imgurl"] lastPathComponent];
                
                // 更改图片同步状态
                [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
                    if (![db executeUpdate:@"update bk_img_sync set isyncstate = 1 where cimgname = ?", uploadImgName]) {
                        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeImageSyncFailed userInfo:@{NSLocalizedDescriptionKey:[db lastError]}];
                    }
                }];
                
                // 删除已上传的图片
                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(uploadImgName) error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath([self thumbImgNameWithImgName:uploadImgName]) error:nil];
                
                // 上传完最后一组图片后根据过程中是否有错误，调用响应的回调
                if (i == syncImages.count - 1) {
                    if (tError) {
                        SSJPRINT(@"<<< ------- 图片同步失败! ------- >>>");
                        if (self.uploadCounter == 0) {
                            if (failure) {
                                failure(tError);
                            }
                        }
                    } else {
                        SSJPRINT(@"<<< ------- 图片同步成功！------- >>>");
                        if (self.uploadCounter == 0) {
                            if (success) {
                                success();
                            }
                        }
                    }
                }
            });
        }];
    }
}

- (NSArray *)getImagesNeedToSyncWithError:(NSError **)error {
    NSMutableArray *imageInfoArr = [NSMutableArray array];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        // 查询当前用户的流水表中没有同步的图片
        FMResultSet *resultSet = [db executeQuery:@"select a.cimgname, a.isynctype from bk_img_sync as a, bk_user_charge as b where a.rid = b.ichargeid and a.operatortype <> 2 and a.isyncstate = 0 and b.cuserid = ?", self.userId];
        if (!resultSet) {
            *error = [db lastError];
            return;
        }
        
        while ([resultSet next]) {
            NSString *imageName = [resultSet stringForColumn:@"cimgname"];
            if (![imageName hasSuffix:@".jpg"]) {
                imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
            }
            NSString *syncType = [resultSet stringForColumn:@"isynctype"];
            if (imageName.length) {
                [imageInfoArr addObject:@{kImageNameKey:imageName,
                                          kSyncTypeKey:syncType}];
            }
        }
        
        // 查询当前用户的顶起记账中没有同步的图片
        resultSet = [db executeQuery:@"select a.cimgname, a.isynctype from bk_img_sync as a, bk_charge_period_config as b where a.rid = b.iconfigid and a.operatortype <> 2 and a.isyncstate = 0 and b.cuserid = ?", self.userId];
        if (!resultSet) {
            *error = [db lastError];
            return;
        }
        
        while ([resultSet next]) {
            NSString *imageName = [resultSet stringForColumn:@"cimgname"];
            NSString *syncType = [resultSet stringForColumn:@"isynctype"];
            if (![imageName hasSuffix:@".jpg"]) {
                imageName = [NSString stringWithFormat:@"%@.jpg",imageName];
            }
            if (imageName.length) {
                [imageInfoArr addObject:@{kImageNameKey:imageName,
                                          kSyncTypeKey:syncType}];
            }
        }
    }];
    return imageInfoArr;
}

- (NSURLSessionUploadTask *)uploadModelList:(NSArray<SSJSyncFileModel *> *)modelList headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    //  创建请求
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SSJURLWithAPI(path) parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < modelList.count; i ++) {
            SSJSyncFileModel *model = [modelList ssj_safeObjectAtIndex:i];
            if (model.fileData && model.fileName && model.mimeType) {
                [formData appendPartWithFileData:model.fileData name:model.fileName fileName:model.fileName mimeType:model.mimeType];
            }
        }
    } error:&tError];
    
    if (tError) {
        if (completionHandler) {
            completionHandler(nil, nil, tError);
        }
        return nil;
    }
    
    [prarms enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    //  开始上传
    NSURLSessionUploadTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    [task resume];
    
    return task;
}

@end
