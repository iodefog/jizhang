//
//  SSJBookkeepingTreeHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeHelper.h"
#import "SSJGlobalServiceManager.h"

@implementation SSJBookkeepingTreeHelper

+ (NSString *)treeLevelNameForLevel:(SSJBookkeepingTreeLevel)level {
    switch (level) {
        case SSJBookkeepingTreeLevelSeed:           return @"种子";
        case SSJBookkeepingTreeLevelSapling:        return @"树苗";
        case SSJBookkeepingTreeLevelSmallTree:      return @"小树";
        case SSJBookkeepingTreeLevelStrongTree:     return @"壮树";
        case SSJBookkeepingTreeLevelBigTree:        return @"大树";
        case SSJBookkeepingTreeLevelSilveryTree:    return @"银树";
        case SSJBookkeepingTreeLevelGoldTree:       return @"金树";
        case SSJBookkeepingTreeLevelDiamondTree:    return @"钻石树";
        case SSJBookkeepingTreeLevelCrownTree:      return @"皇冠树";
    }
}

+ (NSInteger)maxDaysForLevel:(SSJBookkeepingTreeLevel)level {
    switch (level) {
        case SSJBookkeepingTreeLevelSeed:           return 7;
        case SSJBookkeepingTreeLevelSapling:        return 30;
        case SSJBookkeepingTreeLevelSmallTree:      return 50;
        case SSJBookkeepingTreeLevelStrongTree:     return 100;
        case SSJBookkeepingTreeLevelBigTree:        return 180;
        case SSJBookkeepingTreeLevelSilveryTree:    return 300;
        case SSJBookkeepingTreeLevelGoldTree:       return 450;
        case SSJBookkeepingTreeLevelDiamondTree:    return 599;
        case SSJBookkeepingTreeLevelCrownTree:      return NSIntegerMax;
    }
}

+ (SSJBookkeepingTreeLevel)treeLevelForDays:(NSInteger)days {
    if (days >= 0 && days <= 7) {
        return SSJBookkeepingTreeLevelSeed;
    } else if (days >= 8 && days <= 30) {
        return SSJBookkeepingTreeLevelSapling;
    } else if (days >= 31 && days <= 50) {
        return SSJBookkeepingTreeLevelSmallTree;
    } else if (days >= 51 && days <= 100) {
        return SSJBookkeepingTreeLevelStrongTree;
    } else if (days >= 101 && days <= 180) {
        return SSJBookkeepingTreeLevelBigTree;
    } else if (days >= 181 && days <= 300) {
        return SSJBookkeepingTreeLevelSilveryTree;
    } else if (days >= 301 && days <= 450) {
        return SSJBookkeepingTreeLevelGoldTree;
    } else if (days >= 451 && days <= 599) {
        return SSJBookkeepingTreeLevelDiamondTree;
    } else if (days >= 600) {
        return SSJBookkeepingTreeLevelCrownTree;
    } else {
        return SSJBookkeepingTreeLevelSeed;
    }
}

+ (void)loadTreeImageWithUrlPath:(NSString *)url finish:(void (^)(UIImage *image, BOOL success))finish {
    [self loadTreeImageWithUrlPath:url timeout:60 finish:finish];
}

+ (void)loadTreeImageWithUrlPath:(NSString *)url timeout:(NSTimeInterval)timeout finish:(void (^)(UIImage *image, BOOL success))finish {
    if (!url.length) {
        if (finish) {
            finish(nil, NO);
        }
        return;
    }
    
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"开始下载记账树图片"];
#endif
    
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    manager.imageDownloader.downloadTimeout = timeout;
    [manager downloadImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(url)] options:(SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates) progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
#ifdef DEBUG
        if (error) {
            [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"下载记账树图片失败，error:%@", [error localizedDescription]]];
        } else {
            [CDAutoHideMessageHUD showMessage:@"下载记账树图片成功"];
        }
#endif
        dispatch_main_sync_safe(^{
            if (finish) {
                finish(image, !error);
            }
        });
    }];
}

+ (void)loadTreeGifImageDataWithUrlPath:(NSString *)url finish:(void (^)(NSData *data, BOOL success))finish {
    if (!url.length) {
        if (finish) {
            finish(nil, NO);
        }
        return;
    }
    
    NSData *imgData = [self loadFromCacheWithUrl:url];
    if (imgData) {
        if (finish) {
            finish(imgData, YES);
        }
        return;
    }
    
    NSString *gifUrl = SSJImageURLWithAPI(url);
    [[SSJGlobalServiceManager standardManager] GET:gifUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            [[self memoryCache] setObject:responseObject forKey:url];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [responseObject writeToFile:[self gifDiskPathWithUrl:url] atomically:YES];
            });
            if (finish) {
                finish(responseObject, YES);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (finish) {
            finish(nil, NO);
        }
    }];
}

+ (NSData *)loadFromCacheWithUrl:(NSString *)url {
    NSData *gifData = [[self memoryCache] objectForKey:url];
    if (gifData) {
        return gifData;
    }
    
    gifData = [NSData dataWithContentsOfFile:[self gifDiskPathWithUrl:url]];
    if (gifData) {
        return gifData;
    }
    
    return nil;
}

+ (NSString *)gifDiskPathWithUrl:(NSString *)url {
    NSString *documentPath = SSJDocumentPath();
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"gif_tree"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return @"";
        }
    }
    
    NSString *fileName = [url lastPathComponent];
    if (![[fileName pathExtension] isEqualToString:@"gif"]) {
        return @"";
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSCache *)memoryCache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cache) {
            cache = [[NSCache alloc] init];
        }
    });
    return cache;
}

@end
