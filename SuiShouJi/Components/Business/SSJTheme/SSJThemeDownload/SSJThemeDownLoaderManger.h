//
//  SSJThemeDownLoaderManger.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJThemeItem.h"

typedef void(^SSJThemeDownLoaderProgressBlock)(float);

@interface SSJThemeDownLoaderManger : NSObject

//获取唯一示例(保证主题下载在同一个线程进行)
+ (SSJThemeDownLoaderManger *)sharedInstance;

/**
 *  下载主题
 *
 *  @param item      主题item
 *  @param success 下载成功的回调
 *  @param failure 下载失败的回调
 */
- (void)downloadThemeWithItem:(SSJThemeItem *)item
                       success:(void(^)(SSJThemeItem *item))success
                       failure:(void (^)(NSError *error))failure;

/**
 *  添加一个下载进度的回调
 *
 *  @param handler 回调的方法
 *  @param ID      主题id
 */
- (void)addProgressHandler:(SSJThemeDownLoaderProgressBlock)handler forID:(NSString *)ID;

/**
 *  移除一个下载进度的回调
 *
 *  @param handler 回调的方法
 *  @param ID      主题id
 */
- (void)removeProgressHandler:(SSJThemeDownLoaderProgressBlock)handler forID:(NSString *)ID;

//正在下载的主题的id
@property (nonatomic, strong) NSMutableArray *downLoadingArr;

@property (nonatomic) NSInteger downloadingThemesCount;

@end

