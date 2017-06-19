//
//  SSJSharebooksCodeNetworkService.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJSharebooksCodeNetworkService : SSJBaseNetworkService


/**
 获取最新的暗号接口

 @param userid 用户id
 @param booksId 账本id
 */
- (void)requestCodeWithbooksId:(NSString *)booksId;

/**
 保存暗号接口

 @param userid 用户id
 @param booksId 账本id
 @param code 暗号
 */
- (void)saveCodeWithbooksId:(NSString *)booksId code:(NSString *)code;


@property(nonatomic, strong) NSString *overTime;

@property(nonatomic, strong) NSString *secretKey;

@end
