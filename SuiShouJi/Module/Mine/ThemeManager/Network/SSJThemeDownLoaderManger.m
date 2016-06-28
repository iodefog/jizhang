//
//  SSJThemeDownLoaderManger.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeDownLoaderManger.h"
#import "NSString+SSJTheme.h"
#import "AFNetworking.h"

@interface SSJThemeDownLoaderManger()
@property(nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation SSJThemeDownLoaderManger

static id _instance;
+ (SSJThemeDownLoaderManger *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        [self.manager.operationQueue setMaxConcurrentOperationCount:5];
    }
    return self;
}

- (void)downloadThemeWithUrl:(NSString *)urlStr
                     Success:(void(^)())success
                     failure:(void (^)(NSError *error))failure{
    if (![urlStr hasPrefix:@"http"]) {
        urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (![[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename]withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(error);
                });
            }
            return;
        }else{
            [progress removeObserver:self forKeyPath:@"fractionCompleted"];
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success();
                });
            }
        }
    }];
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    [downloadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress is %f", progress.fractionCompleted);
        [self.delegate downLoadThemeWithProgress:progress];
    }
}

@end
