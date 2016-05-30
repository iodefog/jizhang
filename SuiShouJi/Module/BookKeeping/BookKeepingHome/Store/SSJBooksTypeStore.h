//
//  SSJBooksTypeStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBooksTypeItem.h"

@interface SSJBooksTypeStore : NSObject

/**
 *  查询账本列表
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForBooksListWithSuccess:(void(^)(NSMutableArray<SSJBooksTypeItem *> *result))success
                                 failure:(void (^)(NSError *error))failure;

/**
 *  保存账本类型
 *
 *  @return (BOOL) 是否保存成功
 */
+ (BOOL)saveBooksTypeItem:(SSJBooksTypeItem *)item;
@end
