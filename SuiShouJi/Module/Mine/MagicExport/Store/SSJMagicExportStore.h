//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJMagicExportStore : NSObject

/**
 查询所有有效流水的记账时间(截止到当前系统时间)

 @param billId 查询指定收支类别的流水时间，如果有值就忽略billType
 @param billType 指定查询的是收入、支出还是结余（包含收入、支出）流水
 @param booksId 账本id，如果为nil就查询当前账本数据，如果为"SSJAllBooksIds"就查询所有账本数据
 @param containOtherMembers 当booksId为“SSJAllBooksIds”时有效，表示查询所有账本数据时是否包括共享账本的其他成员的流水
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)queryAllBillDateWithBillId:(nullable NSString *)billId
                          billName:(nullable NSString *)billName
                          billType:(SSJBillType)billType
                           booksId:(nullable NSString *)booksId
                            userId:(nullable NSString *)userId
            containsSpecialCharges:(BOOL)containsSpecialCharges
                           success:(void (^)(NSArray<NSDate *> *result))success
                           failure:(nullable void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

