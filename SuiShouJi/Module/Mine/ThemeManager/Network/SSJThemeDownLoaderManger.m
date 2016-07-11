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
#import "SSJThemeModel.h"
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
        _downLoadingArr = [NSMutableArray array];
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
    
    [self.downLoadingArr addObject:ID];
    
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
            [self.downLoadingArr removeObject:ID];
            SSJPRINT(@"%@",[error localizedDescription]);
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(error);
                });
            }
            return;
        }else{
            [self.downLoadingArr removeObject:ID];
            [tProgress removeObserver:self forKeyPath:@"fractionCompleted"];
            if ([self unzipUrl:filePath path:[NSString ssj_themeDirectory] error:&error]) {
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:&error];
                
                // 解析主题配置文件，
                NSString *themeSettingPath = [[[NSString ssj_themeDirectory] stringByAppendingPathComponent:ID] stringByAppendingPathComponent:@"themeSettings.json"];
                NSData *jsonData = [NSData dataWithContentsOfFile:themeSettingPath];
                
                if (!jsonData) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure(error);
                        });
                    }
                    SSJPRINT(@"<<< themeSettings.json 文件不存在 目录：%@>>>", themeSettingPath);
                    return;
                }
                
                NSError *error = nil;
                NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                if (error) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure(error);
                        });
                    }
                    SSJPRINT(@"<<< 解析主题json文件错误 error：%@ >>>", error);
                    return;
                }
                
                SSJThemeModel *model = [SSJThemeModel mj_objectWithKeyValues:resultInfo];
                [SSJThemeSetting addThemeModel:model];
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
    if (!ID) {
        return;
    }
    SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
    if (progressBlocker && handler && ![progressBlocker.blocks containsObject:handler]) {
        [progressBlocker.blocks addObject:handler];
    }
}

- (void)removeProgressHandler:(SSJThemeDownLoaderProgressBlock)handler forID:(NSString *)ID {
    if (!ID) {
        return;
    }
    SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
    if (progressBlocker && handler && [progressBlocker.blocks containsObject:handler]) {
        [progressBlocker.blocks removeObject:handler];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
//        NSLog(@"%f",progress.fractionCompleted);
        NSString *ID = progress.userInfo[@"ID"];
        SSJThemeDownLoaderProgressBlocker *progressBlocker = _blockerMapping[ID];
        progressBlocker.progress = progress.fractionCompleted;
        for (SSJThemeDownLoaderProgressBlock block in progressBlocker.blocks) {
            if (block) {
                SSJDispatchMainAsync(^{
                    block(progress.fractionCompleted);
                });
            }
        }
        
//        NSLog(@"Progress is %f", progress.fractionCompleted);
//        [self.delegate downLoadThemeWithProgress:progress];
    }
}

//  将data进行解压
- (BOOL)unzipUrl:(NSURL *)Url path:(NSString *)path error:(NSError **)error {
    ZZArchive *archive = [ZZArchive archiveWithURL:Url error:error];
    if (*error) {
        return NO;
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    for (ZZArchiveEntry* entry in archive.entries) {
        // Some archives don‘t have a separate entry for each directory
        // and just include the directory‘s name in the filename.
        // Make sure that directory exists before writing a file into it.
        NSArray * arr = [entry.fileName componentsSeparatedByString:@"/"];
        NSInteger index = [entry.fileName length] - 1 - [[arr lastObject] length];
        NSString * aimPath = [entry.fileName substringToIndex:index];
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", path, aimPath] withIntermediateDirectories:YES attributes:nil error:error];
        if (*error) {
            return NO;
        }
        
        NSData * data = [entry newDataWithError:nil];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@", path, entry.fileName] atomically:YES];
    }
    
    return YES;
}
@end
