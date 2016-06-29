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
#import <ZipZap/ZipZap.h>

@interface SSJThemeDownLoaderProgressBlocker : NSObject

@property (nonatomic, copy) void (^progressBlock)(float progress);

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) float progress;

@end

@implementation SSJThemeDownLoaderProgressBlocker

@end

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
        _blockerMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadThemeWithID:(NSString *)ID
                        url:(NSString *)urlStr
                     Success:(void(^)())success
                    failure:(void (^)(NSError *error))failure
                   progress:(void(^)(float progress))progress {
    
    if (![urlStr hasPrefix:@"http"]) {
        urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSProgress *tProgress = nil;
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:&tProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (![[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:ID] withIntermediateDirectories:YES attributes:nil error:nil];
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
            [tProgress removeObserver:self forKeyPath:@"fractionCompleted"];
            
            NSData *themeData = [self unzipUrl:filePath error:&error];
            
//            [themeData writeToFile:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:ID] atomically:YES];
            
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success();
                });
            }
        }
    }];
    
//    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        
//    }];
    
    [tProgress setUserInfoObject:ID forKey:@"ID"];
    [tProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    SSJThemeDownLoaderProgressBlocker *progressBlocker = [[SSJThemeDownLoaderProgressBlocker alloc] init];
    progressBlocker.ID = ID;
    progressBlocker.progressBlock = progress;
    [_blockerMapping setObject:progressBlocker forKey:ID];
    
    [downloadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSString *ID = progress.userInfo[@"ID"];
        SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
        progressBlocker.progress = progress.fractionCompleted;
        if (progressBlocker.progressBlock) {
            progressBlocker.progressBlock(progress.fractionCompleted);
        }
        
        NSLog(@"Progress is %f", progress.fractionCompleted);
//        [self.delegate downLoadThemeWithProgress:progress];
    }
}

//  将data进行解压
- (NSData *)unzipUrl:(NSURL *)Url error:(NSError **)error {
    ZZArchive *archive = [ZZArchive archiveWithURL:Url error:error];
    
    NSString *targetPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"sdfsfd"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    for (ZZArchiveEntry* entry in archive.entries) {
        // Some archives don‘t have a separate entry for each directory
        // and just include the directory‘s name in the filename.
        // Make sure that directory exists before writing a file into it.
        NSArray * arr = [entry.fileName componentsSeparatedByString:@"/"];
        NSInteger index = [entry.fileName length] - 1 - [[arr lastObject] length];
        NSString * aimPath = [entry.fileName substringToIndex:index];
        NSError * err;
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", targetPath, aimPath] withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return nil;
        }
        
        NSData * data = [entry newDataWithError:nil];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@", targetPath, entry.fileName] atomically:YES];
    }
    
    return nil;
}

@end
