//
//  SSJWishModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJWishModel : SSJBaseCellItem

@property (nonatomic, copy) NSString *wishId;

@property (nonatomic, copy) NSString *cuserId;

@property (nonatomic, copy) NSString *wishName;

@property (nonatomic, copy) NSString *wishMoney;

@property (nonatomic, copy) NSString *wishImage;

@property (nonatomic, copy) NSString *cwriteDate;

@property (nonatomic, assign) SSJOperatorType operatorType;

@property (nonatomic, assign) SSJWishState status;

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

/**已存入金额*/
@property (nonatomic, copy) NSString *wishSaveMoney;

+ (NSDictionary *)propertyMapping;
@end
