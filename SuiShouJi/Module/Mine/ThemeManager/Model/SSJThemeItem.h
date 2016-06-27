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
@property(nonatomic, strong) NSString *themeImageName;

//主题大小
@property(nonatomic, strong) NSString *themeSize;

//主题状态
@property(nonatomic, strong) NSString *themeStatus;

//主题详情的图片
@property(nonatomic, strong) NSArray *images;

//主题的描述
@property(nonatomic, strong) NSString *themeDesc;

@end
