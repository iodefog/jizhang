//
//  SSJBooksTypeStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"
#import "SSJDatabaseQueue.h"

typedef enum : NSUInteger {
    ShareBookOperateCreate,
    ShareBookOperateEdite
} ShareBookOperate;

@interface SSJBooksTypeStore : NSObject

/**
 *  查询当前的账本
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryCurrentBooksItemWithSuccess:(void(^)(id<SSJBooksItemProtocol> booksItem))success
                             failure:(void (^)(NSError *error))failure;

#pragma mark - 个人账本
/**
 *  查询账本列表(个人账本)
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
+ (void)saveBooksTypeItem:(SSJBooksTypeItem *)item
                   sucess:(void(^)())success
                  failure:(void (^)(NSError *error))failure;

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
                              Success:(void(^)(BOOL bookstypeHasChange))success
                              failure:(void (^)(NSError *error))failure;

+ (void)getTotalIncomeAndExpenceWithSuccess:(void(^)(double income,double expenture))success
                                    failure:(void (^)(NSError *error))failure;

+ (BOOL)generateBooksTypeForBooksItem:(id<SSJBooksItemProtocol>)item
                           indatabase:(FMDatabase *)db
                            forUserId:(NSString *)userId ;


#pragma mark - 共享账本
/**
 *  查询账本列表(共享账本)
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForShareBooksListWithSuccess:(void(^)(NSMutableArray<SSJShareBookItem *> *result))success
                                  failure:(void(^)(NSError *error))failure;

/**
 *  保存账本(共享账本)
 *
 *  @return (BOOL) 是否保存成功
 */
+ (void)saveShareBooksTypeItem:(SSJShareBookItem *)item
               WithshareMember:(NSArray<NSDictionary *> *)shareMember
             shareFriendsMarks:(NSArray<NSDictionary *> *)shareFriendsMarks
              ShareBookOperate:(ShareBookOperate)shareBookOperate
                        sucess:(void(^)())success
                       failure:(void (^)(NSError *error))failure;



/**
 删除账本 （共享账本）
 @param item <#item description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)deleteShareBooksWithShareCharge:(NSArray<NSDictionary *> *)shareCharge
                            shareMember:(NSArray<NSDictionary *> *)shareMember
                                 bookId:(NSString *)bookId
                                 sucess:(void(^)(BOOL bookstypeHasChange))success
                                failure:(void (^)(NSError *error))failure;

/**
 保存账本顺序(共享账本)
 
 @param items   账本item的数组
 @param success 保存成功的回调
 @param failure 保存失败的回调
 */
+ (void)saveShareBooksOrderWithItems:(NSArray<SSJShareBookItem *> *)items
                         sucess:(void(^)())success
                        failure:(void (^)(NSError *error))failure;



/**
 保存账本成员表（共享账本）

 @param bookId <#bookId description#>
 @param shareMember <#shareMember description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)saveShareBooksMemberWithBookId:(NSString *)bookId
                           shareMember:(NSArray<NSDictionary *> *)shareMember
                               success:(void(^)())success
                               failure:(void(^)(NSError *error))failure;



/**
 保存用户昵称（共享账本）

 @param bookId <#bookId description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)saveShareBookMemberNickWithBookId:(NSString *)bookId
                        shareFriendsMarks:(NSArray <NSDictionary *>*)shareFriendsMarks
                                  success:(void(^)())success
                                  failure:(void(^)(NSError *error))failure;


@end
