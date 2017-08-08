//
//  SSJBannerItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJBannerItem : SSJBaseCellItem

// 图片url
@property(nonatomic, strong) NSString *bannerImageUrl;

// 名称
@property(nonatomic, strong) NSString *bannerName;

// banner的id
@property(nonatomic, strong) NSString *bannerId;

// banner的id
@property(nonatomic, strong) NSString *bannerTarget;

// 是否需要登录
@property (nonatomic) BOOL needLogin;

// banner的类型 0跳转到外部页面 1打开app内部页面
@property (nonatomic) int bannerType;

@end
