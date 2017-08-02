//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString SSJMagicExportStoreDateKey;

extern SSJMagicExportStoreDateKey *const SSJMagicExportStoreBeginDateKey;
extern SSJMagicExportStoreDateKey *const SSJMagicExportStoreEndDateKey;

@interface SSJMagicExportStore : NSObject

/**
 *  查询第一次记账时间和最近一次记账时间(非借贷流水截止到当前系统时间，借贷流水不做时间限制)
 *
 *  @param bookId    账本类型id，如果为空，就查询当前账本，如果为SSJAllBooksIds则查询所有账本数据
 *  @param success   查询成功的回调；参数result结构：@｛SSJMagicExportStoreBeginDateKey：开始日期，
                                                   SSJMagicExportStoreEndDateKey：结束日期｝
 *  @param failure   查询失败的回调
 */
+ (void)queryBillPeriodWithBookId:(nullable NSString *)bookId
                          success:(void (^)(NSDictionary<SSJMagicExportStoreDateKey *, NSDate *> *result))success
                          failure:(nullable void (^)(NSError *error))failure;

/**
 查询所有有效流水的记账时间(截止到当前系统时间)

 @param billId 查询指定收支类别的流水时间，如果有值就忽略billType
 @param billType 指定查询的是收入、支出还是结余（包含收入、支出）流水
 @param booksId 账本id，如果为nil就查询当前账本数据，如果为"SSJAllBooksIds"就查询所有账本数据
 @param containOtherMembers 当booksId为“SSJAllBooksIds”时有效，表示查询所有账本数据时是否包括共享账本的其他成员的流水
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)queryAllBillDateWithBillId:(NSString *)billId
                          billName:(NSString *)billName
                          billType:(SSJBillType)billType
                           booksId:(NSString *)booksId
                            userId:(NSString *)userId
            containsSpecialCharges:(BOOL)containsSpecialCharges
                           success:(void (^)(NSArray<NSDate *> *result))success
                           failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

