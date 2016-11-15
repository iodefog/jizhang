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
#import "SSJPatchUpdateService.h"
#import "SSJGlobalServiceManager.h"

@implementation SSJJspatchAnalyze

+ (dispatch_queue_t)sharedQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue = NULL;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ShuiShouJi.JspatchQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (void)SSJJsPatchAnalyzePatch{
    [self SSJJsPatchAnalyzeLocalPatch];
    SSJPatchUpdateService *service = [[SSJPatchUpdateService alloc]init];
    __weak typeof(self) weakSelf = self;
    [service requestPatchWithCurrentVersion:SSJAppVersion() Success:^(SSJJsPatchItem *item) {
        [weakSelf SSJJsPatchAnalyzePatchWithItem:item];
    }];
}

+ (void)SSJJsPatchAnalyzePatchWithItem:(SSJJsPatchItem *)item{
    if ([item.patchVersion integerValue] > [SSJLastPatchVersion() integerValue]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[SSJGlobalServiceManager alloc] initWithSessionConfiguration:configuration];
        if (![item.patchUrl hasPrefix:@"http"]) {
            item.patchUrl = [NSString stringWithFormat:@"http://%@",item.patchUrl];
        }
        NSURL *URL = [NSURL URLWithString:item.patchUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"JsPatch"]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"JsPatch"] withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/patch%@",item.patchVersion]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            return fileURL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                NSLog(@"%@",[error localizedDescription]);
            }else{
                NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/patch%@",item.patchVersion]];
                dispatch_async([self sharedQueue], ^{
                    [JPEngine startEngine];
                    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScript:script];
                    SSJSavePatchVersion([item.patchVersion integerValue]);
                });
            }
        }];
        [downloadTask resume];
    }else{
        [self SSJJsPatchAnalyzeLocalPatch];
    }
}

+ (void)SSJJsPatchAnalyzeLocalPatch{
    if ([SSJLastPatchVersion() integerValue]) {
        NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/patch%@",SSJLastPatchVersion()]];
        dispatch_async([self sharedQueue], ^{
            [JPEngine startEngine];
            NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            [JPEngine evaluateScript:script];
        });
    }
}

+ (void)removePatch {
    [[NSFileManager defaultManager] removeItemAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"JsPatch"] error:nil];
    SSJSavePatchVersion(0);
}

@end
