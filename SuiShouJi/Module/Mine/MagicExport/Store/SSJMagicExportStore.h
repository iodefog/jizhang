//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSJMagicExportStoreBeginDateKey;
extern NSString *const SSJMagicExportStoreEndDateKey;

@interface SSJMagicExportStore : NSObject

/**
 *  查询第一次记账时间和最近一次记账时间(截止到当前系统时间)
 *
 *  @param bookId    账本类型id，如果为空，就查询所有账本类型
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryBillPeriodWithBookId:(NSString *)bookId
                          success:(void (^)(NSDictionary<NSString *, NSDate *> *result))success
                          failure:(void (^)(NSError *error))failure;

/**
 查询所有有效的记账时间(截止到当前系统时间)

 @param billType 指定查询的是收入、支出、所有流水的时间
 @param booksId 查询指定账本的流水时间，如果不传就查询所有账本
 @param billTypeId 查询指定收支类别的流水时间，如果有值就忽略billType
 @param success 查询成功的回调
 @param failure 查询失败的回调
 */
+ (void)queryAllBillDateWithBillType:(SSJBillType)billType
                             booksId:(NSString *)booksId
                          billTypeId:(NSString *)billTypeId
                             success:(void (^)(NSArray<NSDate *> *result))success
                             failure:(void (^)(NSError *error))failure;

@end
