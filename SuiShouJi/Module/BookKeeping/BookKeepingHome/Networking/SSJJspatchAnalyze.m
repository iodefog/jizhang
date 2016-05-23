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

+(void)SSJJsPatchAnalyzeWithUrl:(NSString *)urlStr MD5:(NSString *)md5{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString*path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/%@",response.suggestedFilename]];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }else{
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@",filePath]];
            if ([data md5Hash]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [JPEngine startEngine];
                    NSString *script = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@",filePath] encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScript:script];
                });
            }
        }
    }];
    [downloadTask resume];
}

@end
