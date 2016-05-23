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

+(void)SSJJsPatchAnalyzeWithUrl:(NSString *)urlStr MD5:(NSString *)md5 patchVersion:(NSString *)version{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
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
            NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/%@",response.suggestedFilename]];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
            if ([[data md5Hash] isEqualToString:md5]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [JPEngine startEngine];
                    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScript:script];
                    SSJSavePatchVersion([version integerValue]);
                });
            }
        }
    }];
    [downloadTask resume];
}

@end
