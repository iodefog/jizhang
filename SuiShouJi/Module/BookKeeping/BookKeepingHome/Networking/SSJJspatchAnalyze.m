//
//  SSJJspatchAnalyze.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/5/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJJspatchAnalyze.h"
#import "AFNetworking.h"
#import "JPEngine.h"

@implementation SSJJspatchAnalyze

+ (dispatch_queue_t)sharedQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue = NULL;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ShuiShouJi.JspatchQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+(void)SSJJsPatchAnalyzeWithUrl:(NSString *)urlStr MD5:(NSString *)md5 patchVersion:(NSString *)version{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    if (![urlStr hasPrefix:@"http"]) {
        urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"JsPatch"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"JsPatch"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/%@",response.suggestedFilename]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/%@",response.suggestedFilename]];
            dispatch_async([self sharedQueue], ^{
                [JPEngine startEngine];
                NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                [JPEngine evaluateScript:script];
                SSJSavePatchVersion([version integerValue]);
            });
        }
    }];
    [downloadTask resume];
}

@end
