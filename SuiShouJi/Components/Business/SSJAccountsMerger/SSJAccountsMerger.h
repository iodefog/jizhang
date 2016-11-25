//
//  SSJAccountsMerger.h
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJAccountsMerger : NSObject

/**
 将userId1的数据合并到userId2上，但是保留userId1的数据，
 
 数据排重
 1.流水
    （1）周期记账流水根据configid、billdate排重
    （2）借贷流水根据loanid排重
 2.周期记账根据billid、booksid、金额、周期排重
 3.借贷根据借贷日期、借贷人排重
 4.资金账户（包含信用卡）根据名称排重
 5.收支类别根据booksid、名称排重
 6.提醒
    （1）信用卡根据fundid排重
    （2）借贷提醒根据loanid排重
    （3）自定义提醒根据提醒名称排重
 8.成员流水直接根据流水表的排重结果选取合并数据
 7.成员根据
 
 
 数据合并
 合并的顺序是从分支到主干，共5个层次，依照层次顺序合并，同一层次的表不用按照顺序合并，以下是合并的顺序
 1.提醒、账本、成员
 2.资金账户（包含信用卡）、用户收支类别
 3.周期记账、借贷
 4.用户流水
 5.成员流水
 
 
 (5)                    member_charge
                        /          \
                       v            \
 (4)                user_charge      \
                    /         \       \
                   /           \       \
                  v             \       \
 (3)       period_charge       loan      \
             /       \          | \       \
            /         \         |  \       \
           v           v        v   \       \
 (2)  fund(credit)  user_bill  fund  \       \
           |            |             \       \
           |            |              \       \
           v            v               v       v
 (1)    remind        books           remind  member

 @param userId1
 @param userId2
 @param success
 @param failure
 */
+ (void)mergeDataFromUserID:(NSString *)userId1
                   toUserID:(NSString *)userId2
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;

@end
