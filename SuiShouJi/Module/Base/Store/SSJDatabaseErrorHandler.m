//
//  SSJDatabaseErrorHandler.m
//  SuiShouJi
//
//  Created by old lang on 23/5/17.
//  Copyright © 2023年 ___9188___. All rights reserved.
//

#import "SSJDatabaseErrorHandler.h"
#import <ZipZap/ZipZap.h>
#import "SSJGlobalServiceManager.h"
#import "AFNetworking.h"

#define documentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define writePath [documentPath stringByAppendingPathComponent:@"db_error"]
#define jsonPath [writePath stringByAppendingPathComponent:@"db_error_list.json"]
@interface SSJDatabaseErrorHandler()
@end

@implementation SSJDatabaseErrorHandler

+ (void)handleError:(NSError *)error {
    return;
    if (!error) return;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:writePath]) {
        [fileManager createDirectoryAtPath:writePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //读取db_error_list.json
    NSMutableArray *errorArray = nil;
    if ([fileManager fileExistsAtPath:@"db_error_list.json"]) {
       NSData *jdata = [[NSData alloc] initWithContentsOfFile:jsonPath];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:nil];
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            errorArray = [NSMutableArray arrayWithArray:jsonObject];
        }
    }
    
    //格式化成json数据
    NSDate *currentDate = [NSDate date];
    NSString *sqlName = [NSString stringWithFormat:@"db_error_%ld",(long)[currentDate timeIntervalSince1970]];
    NSDictionary *dic = [NSDictionary dictionary];
    [dic setValue:SSJUSERID() forKey:@"cuserId"];
    [dic setValue:SSJAppVersion() forKey:@"releaseVersion"];
    [dic setValue:SSJDefaultSource() forKey:@"isource"];
    [dic setValue:SSJPhoneModel() forKey:@"cmodel"];
    [dic setValue:@(SSJSystemVersion()) forKey:@"cphoneOs"];
    [dic setValue:[error localizedDescription] forKey:@"cmemo"];
    [dic setValue:currentDate forKey:@"cdate"];
//    [dic setValue:sqlName forKey:@"cfileName"];
    [dic setValue:@(0) forKey:@"uploaded"];
    [errorArray addObject:dic];
    
    //压缩文件目录
    NSError *tError = nil;
//    NSString *sqlPath = [documentPath stringByAppendingPathComponent:@"%@",sqlName];
    NSString *sqlPath = writePath;
    NSData *data = [NSData dataWithContentsOfFile:SSJSQLitePath()];
    //压缩
    NSData *zipData = [self zipData:data error:&tError sqlPath:(NSString *)sqlPath sqlName:sqlPath];
    //上传判断网络状态
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {//wifi
        //读取db_error_list文件，查询没有上传过的记录
        for (NSDictionary *dic in errorArray) {
            if ([[dic objectForKey:@"uploaded"] intValue] == 0) {
                //上传
                    [self uploadData:zipData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        //修改此记录的上传状态（uploaded），并删除数据库文件
                        [dic setValue:@(1) forKey:@"uploaded"];
                        [fileManager removeItemAtPath:sqlPath error:nil];
                    } parametersDic:dic];
            }
        }
    }
    [errorArray writeToFile:jsonPath atomically:YES];//写入
}


//  上传文件
+ (void)uploadData:(NSData *)data completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler parametersDic:(NSDictionary *)paraDic{
    
    //  创建请求
//    NSString *urlString = [[NSURL URLWithString:@"/sync/syncdata.go" relativeToURL:[NSURL URLWithString:[SSJDomainManager domain]]] absoluteString];
    NSString *urlString = @"";
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"db_error_%ld.zip", (long)[NSDate date].timeIntervalSince1970];
        [formData appendPartWithFileData:data name:@"zip" fileName:fileName mimeType:@"application/zip"];
    } error:&tError];
    
    if (tError) {
        if (completionHandler) {
            completionHandler(nil, nil, tError);
        }
        return;
    }
    
    //  封装参数，传入请求头
    [paraDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.timeoutInterval = 30;
    
    //  开始上传
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager standardManager];
    manager.operationQueue.maxConcurrentOperationCount = 1;//一次只执行一个任务
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];

    [task resume];
}


//  将data进行zip压缩
+ (NSData *)zipData:(NSData *)data error:(NSError **)error sqlPath:(NSString *)sqlPath sqlName:(NSString *)sqlName {
    NSString *zipPath = [sqlPath stringByAppendingPathComponent:sqlName];
    ZZArchive *newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:zipPath]
                                                   options:@{ZZOpenOptionsCreateIfMissingKey:@YES}
                                                     error:error];
    ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:@"db_error_list.json"
                                                            compress:YES
                                                           dataBlock:^(NSError **error) {
                                                               return data;
                                                           }];
    
    if (![newArchive updateEntries:@[entry] error:error]) {
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:zipPath options:NSDataReadingUncached error:error];
}



/*
 cuserId：用户id
 releaseVersion：app版本号
 isource：渠道值
 cmodel：手机型号
 cphoneOs：手机系统版本
 cmemo：数据库错误描述
 cdate：错误发生时间
 cfileName：数据库文件名称
 uploaded：是否上传过

 */
@end
