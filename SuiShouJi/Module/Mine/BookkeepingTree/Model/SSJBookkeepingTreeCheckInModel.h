//
//  SSJBookkeepingTreeCheckInModel.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBookkeepingTreeCheckInModel : NSObject

// 签到次数
@property (nonatomic) NSInteger checkInTimes;

// 上次签到成功日期
@property (nonatomic, copy) NSString *lastCheckInDate;

// 签到的用户id
@property (nonatomic, copy) NSString *userId;

// 记账树图片url
@property (nonatomic, copy) NSString *treeImgUrl;

// 记账树下雨gif图片url
@property (nonatomic, copy) NSString *treeGifUrl;

// 是否摇一摇签过到
@property (nonatomic) BOOL hasShaked;

@end
