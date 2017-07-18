//
//  SSJWishModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJWishType) {
    SSJWishTypeCustom,          // 自定义
    SSJWishTypeDefaultFirst,    // 存下人生第一个1万
    SSJWishTypeTravel,          // 一场说走就走的旅行
    SSJWishTypeBuyGift          // 为‘ta’买礼物
};

@interface SSJWishModel : SSJBaseCellItem

@property (nonatomic, copy) NSString *wishId;

@property (nonatomic, copy) NSString *cuserId;

@property (nonatomic, copy) NSString *wishName;

@property (nonatomic, copy) NSString *wishMoney;

@property (nonatomic, copy) NSString *wishImage;

@property (nonatomic, copy) NSString *cwriteDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) BOOL isFinished;

@property (nonatomic, copy) NSString *remindId;

@property (nonatomic, copy) NSString *startDate;

@property (nonatomic, copy) NSString *endDate;

/**
 0:自定义
 1:存下人生第一个1万
 2:一场说走就走的旅行
 3:为‘ta’买礼物
 */
@property (nonatomic, assign) SSJWishType wishType;

+ (NSDictionary *)propertyMapping;
@end
