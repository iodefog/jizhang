//
//  SSJSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSynchronizeTask.h"
#import "AFNetworking.h"

@interface SSJSynchronizeTask ()

@end

@implementation SSJSynchronizeTask

+ (instancetype)task {
    return [[self alloc] init];
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

- (NSURLSessionUploadTask *)uploadBodyData:(NSData *)data headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path fileName:(NSString *)fileName mimeType:(NSString *)mimeType completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    return [self constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:mimeType];
    } headerParams:prarms toUrlPath:path completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadModelList:(NSArray<SSJSyncFileModel *> *)modelList headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    return [self constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < modelList.count; i ++) {
            SSJSyncFileModel *model = [modelList ssj_safeObjectAtIndex:i];
            if (model.fileData && model.fileName && model.mimeType) {
                [formData appendPartWithFileData:model.fileData name:model.fileName fileName:model.fileName mimeType:model.mimeType];
            }
        }
    } headerParams:prarms toUrlPath:path completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    //  创建请求
    NSString *urlString = [[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:block error:&tError];
    
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
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //    NSProgress *progress = nil;
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    [task resume];
    
    return task;
}

@end
