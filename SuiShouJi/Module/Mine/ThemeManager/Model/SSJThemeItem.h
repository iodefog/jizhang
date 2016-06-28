//
//  SSJThemeItem.h
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJThemeItem : SSJBaseItem

//主题ID
@property(nonatomic, strong) NSString *themeId;

//主题名称
@property(nonatomic, strong) NSString *themeTitle;

//主题图片名
@property(nonatomic, strong) NSString *themeImageUrl;

//主题缩略图
@property(nonatomic, strong) NSString *themeThumbImageUrl;

//主题大小
@property(nonatomic, strong) NSString *themeSize;

//主题状态(0为未下载,1为已下载,2为已启用)
@property(nonatomic) NSInteger themeStatus;

//主题详情的图片
@property(nonatomic, strong) NSArray *images;

//主题的描述
@property(nonatomic, strong) NSString *themeDesc;

//主题的描述
@property(nonatomic, strong) NSString *themePrice;

//下载地址
@property(nonatomic, strong) NSString *downLoadUrl;

@end
