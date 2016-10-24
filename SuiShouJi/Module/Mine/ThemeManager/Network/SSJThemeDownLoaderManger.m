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

- (void)downloadThemeWithItem:(SSJThemeItem *)item
                    success:(void(^)(SSJThemeItem *item))success
                    failure:(void (^)(NSError *error))failure {
    
    if (![item.downLoadUrl hasPrefix:@"http"]) {
        item.downLoadUrl = [NSString stringWithFormat:@"http://%@",item.downLoadUrl];
    }
    NSURL *URL = [NSURL URLWithString:item.downLoadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    SSJThemeModel *model = [SSJThemeSetting ThemeModelForModelId:item.themeId];
    
    if (model.etag.length > 0) {
        [request setValue:model.etag forKey:@"forHTTPHeaderField"];
    }
    
    NSProgress *tProgress = nil;
    
    [self.downLoadingArr addObject:item.themeId];
    
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:&tProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (![[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:item.themeId] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *path = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:response.suggestedFilename];
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [_blockerMapping removeObjectForKey:item.themeId];
        
        if (error) {
            [self.downLoadingArr removeObject:item.themeId];
            SSJPRINT(@"%@",[error localizedDescription]);
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(error);
                });
            }
            return;
        }
        
        [self.downLoadingArr removeObject:item.themeId];
        [tProgress removeObserver:self forKeyPath:@"fractionCompleted"];
        
        NSError *tError = nil;
        [self unzipUrl:filePath path:[NSString ssj_themeDirectory] error:&tError];
        
        // 不管解压是否成功，把压缩包删除，否则可能会导致以后下载相同压缩包不能覆盖的奇葩问题
        [[NSFileManager defaultManager] removeItemAtURL:filePath error:&error];
        
        if (tError) {
            SSJPRINT(@"%@",[error localizedDescription]);
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(error);
                });
            }
            return;
        }
        
        // 解析主题配置文件，
        NSString *themeSettingPath = [[[NSString ssj_themeDirectory] stringByAppendingPathComponent:item.themeId] stringByAppendingPathComponent:@"themeSettings.json"];
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
        
        NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&tError];
        if (tError) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(tError);
                });
            }
            SSJPRINT(@"<<< 解析主题json文件错误 error：%@ >>>", error);
            return;
        }
        
        SSJThemeModel *model = [SSJThemeModel mj_objectWithKeyValues:resultInfo];
        [SSJThemeSetting addThemeModel:model];
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(item);
            });
        }
    }];
    
//    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        
//    }];
    
    [tProgress setUserInfoObject:item.themeId forKey:@"ID"];
    [tProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    SSJThemeDownLoaderProgressBlocker *progressBlocker = [[SSJThemeDownLoaderProgressBlocker alloc] init];
    progressBlocker.ID = item.themeId;
    [_blockerMapping setObject:progressBlocker forKey:item.themeId];
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
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, entry.fileName]]) {
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, entry.fileName] error:NULL];
        }
        [data writeToFile:[NSString stringWithFormat:@"%@/%@", path, entry.fileName] atomically:YES];
    }
    
    return YES;
}
@end
