//
//  SSJListAdItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJListAdItem : SSJBaseItem

// 广告标题
@property(nonatomic, strong) NSString *adTitle;

// 广告是否需要隐藏
@property(nonatomic) BOOL hidden;

//广告跳转页面
@property(nonatomic, strong) NSString *url;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *imageName;
@end
