//
//  SSJDatabaseErrorHandler.m
//  SuiShouJi
//
//  Created by old lang on 23/5/17.
//  Copyright © 2023年 ___9188___. All rights reserved.
//

#import "SSJDatabaseErrorHandler.h"
#import "SSJGlobalServiceManager.h"
#import "AFNetworking.h"
#import "SSJNetworkReachabilityManager.h"
#import "ZipArchive.h"

#define documentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define writePath [documentPath stringByAppendingPathComponent:@"db_error"]
#define jsonPath [writePath stringByAppendingPathComponent:@"db_error_list.plist"]
@interface SSJDatabaseErrorHandler()
@end

@implementation SSJDatabaseErrorHandler

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileData) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (void)handleError:(NSError *)error {
    if (!error) return;
    dispatch_async([self sharedQueue], ^{
        [self writeToFileWithError:error];//将错误写入文件
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), [self sharedQueue], ^{
            [self upLoadData];//压缩数据库上传错误信息
        });
    });
}

+ (void)uploadFileData
{
    dispatch_async([self sharedQueue], ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), [self sharedQueue], ^{
            [self upLoadData];//压缩数据库上传错误信息
        });
    });
}

+ (dispatch_queue_t)sharedQueue
{
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("SSJDatabaseErrorHandlerQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

//将错误写入文件
+ (void)writeToFileWithError:(NSError *)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:writePath]) {
        [fileManager createDirectoryAtPath:writePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //读取db_error_list.json
    NSMutableArray *errorArray = [self readErrerInJson];
    
    //格式化成json数据
    NSString *currentDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:SSJUSERID() forKey:@"cuserid"];
    [dic setValue:SSJAppVersion() forKey:@"releaseversion"];
    [dic setValue:SSJDefaultSource() forKey:@"isource"];
    [dic setValue:SSJPhoneModel() forKey:@"cmodel"];
    [dic setValue:[[UIDevice currentDevice] systemVersion] forKey:@"cphoneos"];
    [dic setValue:[error localizedDescription] forKey:@"cmemo"];
    [dic setValue:currentDate forKey:@"cdate"];
    [dic setValue:@(0) forKey:@"uploaded"];
    [errorArray addObject:dic];
//    [errorArray writeToFile:jsonPath atomically:YES];//写入
    
    if ([[dic objectForKey:@"uploaded"] intValue] == 0) {
        //数据库名称
        NSString *cFileName = [dic objectForKey:@"cfilename"];
        NSString *sqlName = cFileName.length ? cFileName : [NSString stringWithFormat:@"db_error_%lld",SSJMilliTimestamp()];
        
        //存储数据库名称
        [dic setValue:sqlName forKey:@"cfilename"];
        [self zipSqlWithName:sqlName];//压缩
        //再次写入
        [errorArray writeToFile:jsonPath atomically:YES];
    }
}

//压缩数据库上传错误信息
+ (void)upLoadData
{
//    for (int i=0; i<2; i++) {
//        NSError *error;
//        [self writeToFileWithError:error];//将错误写入文件
//    }
//    SSJPRINT(@"%@===%@",writePath,jsonPath);
    //上传判断网络状态
    if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi) {//wifi
        //读取db_error_list文件，查询没有上传过的记录
        //读取db_error_list.json
        NSMutableArray *errorArray = [self readErrerInJson];
        if (errorArray.count > 0) {
            [self uploadData:errorArray.count -1 array:errorArray];
        }
    }
}

+ (void)uploadData:(NSInteger)index array:(NSArray *)arr
{
    if (!([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi)) return;
    if (index < 0)return;
        NSDictionary *dic = [arr ssj_safeObjectAtIndex:index];
        if ([[dic objectForKey:@"uploaded"] intValue] == 0) {
//            //数据库名称
            NSString *cFileName = [dic objectForKey:@"cfilename"];
            NSString *sqlName = cFileName.length ? cFileName : [NSString stringWithFormat:@"db_error_%lld",SSJMilliTimestamp()];
            NSData *zipData = [self zipSqlWithName:sqlName];
            if (!zipData) return;
            [self uploadData:zipData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error)return;
                dispatch_async([self sharedQueue], ^{
                    NSHTTPURLResponse *tResponse = (NSHTTPURLResponse *)response;
                    NSString *contentType = tResponse.allHeaderFields[@"Content-Type"];
                    //  返回的是json数据格式
                    NSError *err;
                    if ([contentType isEqualToString:@"text/json;charset=UTF-8"]) {
                        NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&err];
                        NSInteger code = [responseInfo[@"code"] integerValue];
                        if (code == 1) {
                            //修改此记录的上传状态（uploaded），并删除数据库文件
                            [dic setValue:@(1) forKey:@"uploaded"];
                            [self removeSqlFileWithName:sqlName];
                            //再次写入
                            [arr writeToFile:jsonPath atomically:YES];
                        }
                    }
                    [self uploadData:index-1 array:arr];//上传下一个
                });
            } parametersDic:dic fileName:sqlName];
            
        }else{
            [self uploadData:index-1 array:arr];//上传下一个
        }
}

+ (void)removeSqlFileWithName:(NSString *)name
{
    NSString *dataPath = [writePath stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dataPath]) {//如果存在
        // 读取data
        [fileManager removeItemAtPath:dataPath error:nil];
    }
}

//读取db_error_list.json
+ (NSMutableArray *)readErrerInJson
{
    NSMutableArray *errorArray = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:jsonPath]) {
        NSArray *arr = [NSArray arrayWithContentsOfFile:jsonPath];
        errorArray = [NSMutableArray arrayWithArray:arr];
    }else{
        errorArray = [NSMutableArray array];
    }
    return errorArray;
}

//压缩数据库
+ (NSData *)zipSqlWithName:(NSString *)name
{
    //如果有文件就直接取出
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[writePath stringByAppendingPathComponent:name]]) {//如果存在
        NSString *dataPath = [writePath stringByAppendingPathComponent:name];
        // 读取data
        return [NSData dataWithContentsOfFile:dataPath];
    }
    //压缩文件目录
    NSString *zipPath = [writePath stringByAppendingPathComponent:name];
    [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[SSJSQLitePath()]];
    NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
    
    return zipData;
}

//  上传文件
+ (void)uploadData:(NSData *)data completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler parametersDic:(NSDictionary *)paraDic fileName:(NSString *)fileName{
    //  创建请求
    NSString *urlString = SSJURLWithAPI(@"/admin/applog.go");
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"zip" fileName:[fileName stringByAppendingPathExtension:@"zip"] mimeType:@"application/zip"];
    } error:&tError];
    
    if (tError) {
        if (completionHandler) {
            completionHandler(nil, nil, tError);
        }
        return;
    }
    
    //  封装参数，传入请求头
    [paraDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:[NSString stringWithFormat:@"%@",obj] forHTTPHeaderField:key];
    }];
    
    request.timeoutInterval = 30;
    
    //  开始上传
    SSJGlobalServiceManager *manager = [SSJGlobalServiceManager standardManager];
    //申明返回的结果是json类型
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    manager.operationQueue.maxConcurrentOperationCount = 1;//一次只执行一个任务
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];

    [task resume];
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
