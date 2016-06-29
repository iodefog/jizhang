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

@property (nonatomic, strong) NSMutableArray *blocks;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) float progress;

@end

@implementation SSJThemeDownLoaderProgressBlocker

- (instancetype)init {
    if (self = [super init]) {
        _blocks = [NSMutableArray array];
    }
    return self;
}

@end

@interface SSJThemeDownLoaderManger()
@property(nonatomic, strong) AFURLSessionManager *manager;

@end

@interface SSJThemeDownLoaderManger ()

@property (nonatomic, strong) NSMutableDictionary *blockerMapping;

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
                    success:(void(^)())success
                    failure:(void (^)(NSError *error))failure {
    
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
        [_blockerMapping removeObjectForKey:ID];
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
            if ([self unzipUrl:filePath path:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:ID] error:&error]) {
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:&error];
            };
            
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
    [_blockerMapping setObject:progressBlocker forKey:ID];
    [downloadTask resume];
}

- (void)addProgressHandler:(SSJThemeDownLoaderProgressBlock)handler forID:(NSString *)ID {
    SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
    if (progressBlocker) {
        [progressBlocker.blocks addObject:handler];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSString *ID = progress.userInfo[@"ID"];
        SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
        progressBlocker.progress = progress.fractionCompleted;
        for (SSJThemeDownLoaderProgressBlock block in progressBlocker.blocks) {
            if (block) {
                block(progress.fractionCompleted);
            }
        }
        
//        NSLog(@"Progress is %f", progress.fractionCompleted);
//        [self.delegate downLoadThemeWithProgress:progress];
    }
}

//  将data进行解压
- (BOOL)unzipUrl:(NSURL *)Url path:(NSString *)path error:(NSError **)error {
    ZZArchive *archive = [ZZArchive archiveWithURL:Url error:error];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    for (ZZArchiveEntry* entry in archive.entries) {
        // Some archives don‘t have a separate entry for each directory
        // and just include the directory‘s name in the filename.
        // Make sure that directory exists before writing a file into it.
        NSArray * arr = [entry.fileName componentsSeparatedByString:@"/"];
        NSInteger index = [entry.fileName length] - 1 - [[arr lastObject] length];
        NSString * aimPath = [entry.fileName substringToIndex:index];
        NSError * err;
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", path, aimPath] withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            return NO;
        }
        
        NSData * data = [entry newDataWithError:nil];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@", path, entry.fileName] atomically:YES];
    }
    
    return YES;
}

@end
