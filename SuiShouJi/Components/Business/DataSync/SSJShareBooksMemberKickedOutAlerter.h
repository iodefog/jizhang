//
//  SSJShareBooksMemberAlerter.h
//  SuiShouJi
//
//  Created by old lang on 17/6/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJDatabase;

NS_ASSUME_NONNULL_BEGIN

/**
 共享账本成员被踢出的弹窗模型
 */
@interface SSJShareBooksMemberKickedOutAlerter : NSObject

/**
 返回唯一单列对象

 @return <#return value description#>
 */
+ (instancetype)alerter;

/**
 记录哪个账本移出哪个成员

 @param memberId 成员id
 @param booksId 账本id
 @param date 被踢出时间
 */
- (void)recordWithMemberId:(NSString *)memberId booksId:(NSString *)booksId date:(NSDate *)date inDatabase:(SSJDatabase *)db error:(NSError **)error;

/**
 弹出某个成员被移出哪个共享账本的弹窗

 @param memberId 被移出账本的成员id
 */
- (void)showAlertIfNeededWithMemberId:(NSString *)memberId;

@end

NS_ASSUME_NONNULL_END
