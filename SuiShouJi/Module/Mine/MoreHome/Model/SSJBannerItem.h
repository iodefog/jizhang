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

// 跳转地址
@property(nonatomic, strong) NSString *bannerUrl;

// 名称
@property(nonatomic, strong) NSString *bannerName;

// banner的id
@property(nonatomic, strong) NSString *bannerId;

// 是否需要登录
@property (nonatomic) BOOL needLogin;

@end
