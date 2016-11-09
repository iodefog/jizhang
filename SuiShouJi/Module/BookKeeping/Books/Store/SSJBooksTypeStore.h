//
//  SSJBooksTypeStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBooksTypeItem.h"
#import "SSJReportFormsItem.h"
#import "SSJDatePeriod.h"


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

/**
 *  查询当前的账本
 *
 *  @param booksid 账本id
 *
 *  @return @return (SSJBooksTypeItem *) 账本信息模型
 */
+(SSJBooksTypeItem *)queryCurrentBooksTypeForBooksId:(NSString *)booksid;


/**
 保存账本顺序

 @param items   账本item的数组
 @param success 保存成功的回调
 @param failure 保存失败的回调
 */
+ (void)saveBooksOrderWithItems:(NSArray *)items
                         sucess:(void(^)())success
                        failure:(void (^)(NSError *error))failure;



/**
 删除账本

 @param items   要删除的账本
 @param type    删除的类型(0为不删除流水,1为删除流水)
 @param success 删除成功的回调
 @param failure 删除失败的回调
 */
+ (void)deleteBooksTypeWithbooksItems:(NSArray *)items
                           deleteType:(BOOL)type
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure;

@end
