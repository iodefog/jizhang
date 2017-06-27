//
//  SSJListAdItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJListAdItem : SSJBaseCellItem

// 广告标题
@property(nonatomic, copy) NSString *adTitle;

// 广告是否需要隐藏
@property(nonatomic) BOOL hidden;

//广告跳转页面
@property(nonatomic, copy) NSString *url;

//图片url
@property (nonatomic, copy) NSString *imageUrl;

@end
