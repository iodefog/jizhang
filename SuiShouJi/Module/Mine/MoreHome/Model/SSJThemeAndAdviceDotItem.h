//
//  SSJThemeAndAdviceDotItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/1/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJThemeAndAdviceDotItem : SSJBaseCellItem
/**
 最新回复时间String格式
 */
@property (nonatomic, copy) NSString *creplydate;

/**
 主题版本号
 */
@property (nonatomic, copy) NSString *themeVersion;

/**
 回复时间NSDate格式
 */
@property (nonatomic, strong) NSDate *creplyDate;

/**
 是否有主题更新
 */
@property (nonatomic, assign) BOOL hasThemeUpdate;

/**
 是否有建议回复
 */
@property (nonatomic, assign) BOOL hasAdviceUpdate;
@end
