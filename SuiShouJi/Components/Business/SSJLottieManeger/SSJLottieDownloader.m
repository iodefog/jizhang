//
//  SSJLottieDownloader.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLottieDownloader.h"
#import "SSJGlobalServiceManager.h"
#import "SSZipArchive.h"


@implementation SSJLottieDownloader

+ (void)downloadLotteWithUrl:(NSString *)url
                     Success:(void(^)(NSString *))success
                     failure:(void (^)(NSError *error))failure {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[SSJGlobalServiceManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"Lottie"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[SSJDocumentPath() stringByAppendingPathComponent:@"Lottie"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/%@",response.suggestedFilename]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            SSJDispatchMainSync(^{
                if (failure) {
                    failure(error);
                }
            });
        }else{
            [SSZipArchive unzipFileAtPath:[NSString stringWithFormat:@"%@",filePath] toDestination:[SSJDocumentPath() stringByAppendingPathComponent:@"Lottie"] progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total){
                
            }completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                if (error) {
                    SSJDispatchMainSync(^{
                        if (failure) {
                            failure(error);
                        }
                    });
                } else {
                    SSJDispatchMainSync(^{
                        if (success) {
                            success(path);
                        }
                    });
                }
            }];
            
        }
    }];
    
    
    [downloadTask resume];

}


@end
