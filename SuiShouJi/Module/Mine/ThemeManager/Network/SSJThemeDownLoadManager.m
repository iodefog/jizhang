//
//  SSJThemeDownLoadManager.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeDownLoadManager.h"
#import "AFNetworking.h"

@implementation SSJThemeDownLoadManager

+(void)downloadThemeWithUrl:(NSString *)urlStr{
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
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            
        }
    }];
    
    
    [downloadTask resume];
}

@end
