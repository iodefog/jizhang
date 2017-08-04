//
//  SSJStartLunchItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSJStartTextItem.h"

@interface SSJStartLunchItem : NSObject
//  启动页图片(静态)
@property (readonly, nonatomic, copy) NSString *startImageUrl;

//  lottie的地址
@property (readonly, nonatomic, copy) NSString *lottieUrl;

//  动态的动画
@property (readonly, nonatomic, copy) NSString *animImageUrl;

//是否下发 0 调用本地图片 1 使用下发type判断
@property (nonatomic, copy) NSString *open;

//0:静态图片,1:动态图片,2:图文
@property (nonatomic, assign) NSInteger type;

/**startVer	当前配置版本号*/
@property (nonatomic, copy) NSString *startVer;

@property (nonatomic, strong) SSJStartTextImgItem *textImgItem;

@end
