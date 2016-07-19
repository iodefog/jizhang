//
//  SSJBannerItem.h
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJBannerItem : SSJBaseItem

// 图片url
@property(nonatomic, strong) NSString *bannerImageUrl;

// 跳转地址
@property(nonatomic, strong) NSString *bannerUrl;

// 名称
@property(nonatomic, strong) NSString *bannerName;

@end
