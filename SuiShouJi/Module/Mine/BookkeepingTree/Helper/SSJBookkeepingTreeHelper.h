//
//  SSJBookkeepingTreeHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJBookkeepingTreeLevel) {
    SSJBookkeepingTreeLevelSeed,            // 种子
    SSJBookkeepingTreeLevelSapling,         // 树苗
    SSJBookkeepingTreeLevelSmallTree,       // 小树
    SSJBookkeepingTreeLevelStrongTree,      // 壮树
    SSJBookkeepingTreeLevelBigTree,         // 大树
    SSJBookkeepingTreeLevelSilveryTree,     // 银树
    SSJBookkeepingTreeLevelGoldTree,        // 金树
    SSJBookkeepingTreeLevelDiamondTree,     // 钻石树
    SSJBookkeepingTreeLevelCrownTree        // 皇冠树
};

@interface SSJBookkeepingTreeHelper : NSObject

+ (NSString *)treeLevelNameForLevel:(SSJBookkeepingTreeLevel)level;

+ (SSJBookkeepingTreeLevel)treeLevelForDays:(NSInteger)days;

+ (NSInteger)maxDaysForLevel:(SSJBookkeepingTreeLevel)level;

+ (void)loadTreeImageWithUrlPath:(NSString *)url finish:(void (^)(UIImage *image, BOOL success))finish;

+ (void)loadTreeImageWithUrlPath:(NSString *)url timeout:(NSTimeInterval)timeout finish:(void (^)(UIImage *image, BOOL success))finish;

+ (void)loadTreeGifImageDataWithUrlPath:(NSString *)url finish:(void (^)(NSData *data, BOOL success))finish;

/**
 计算缓存图片大小（包括磁盘、内存）

 @param success 成功回调
 @param failure 失败回调
 */
+ (NSUInteger)caculateCacheSize;

/**
 清楚缓存（包括磁盘、内存）

 @param success 成功回调
 @param failure 失败回调
 */
+ (BOOL)clearCache;

@end
