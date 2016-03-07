//
//  SSJDataSyncHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSyncHelper.h"
#import "AFNetworking.h"

NSString *const kSignKey = @"accountbook";

static NSString *const SSJCurrentSyncDataUserIdKey = @"SSJCurrentSyncDataUserIdKey";

BOOL SSJSetCurrentSyncDataUserId(NSString *userid) {
    [[NSUserDefaults standardUserDefaults] setObject:userid forKey:SSJCurrentSyncDataUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJCurrentSyncDataUserId() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:SSJCurrentSyncDataUserIdKey];
}

static NSString *const SSJCurrentSyncImageUserIdKey = @"SSJCurrentSyncImageUserIdKey";

BOOL SSJSetCurrentSyncImageUserId(NSString *userid) {
    [[NSUserDefaults standardUserDefaults] setObject:userid forKey:SSJCurrentSyncImageUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJCurrentSyncImageUserId() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:SSJCurrentSyncImageUserIdKey];
}


@implementation SSJDataSyncHelper

+ (void)uploadBodyData:(NSData *)data headerParams:(NSDictionary *)prarms toUrlPath:(NSString *)path completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    //  创建请求
    NSString *urlString = [[NSURL URLWithString:path relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"ios_sync_data_%ld.zip", (long)[NSDate date].timeIntervalSince1970];
        [formData appendPartWithFileData:data name:@"zip" fileName:fileName mimeType:@"application/zip"];
    } error:&tError];
    
    if (tError) {
        if (completionHandler) {
            completionHandler(nil, nil, tError);
        }
        return;
    }
    
    [prarms enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    //  开始上传
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //    NSProgress *progress = nil;
//    self.task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
//    
//    [self.task resume];
}

@end