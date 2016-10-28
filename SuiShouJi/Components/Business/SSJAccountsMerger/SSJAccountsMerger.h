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
 
 合并的顺序是从分支到主干，共5个层次，依照层次顺序合并，同一层次的表不用按照顺序合并，以下是合并的顺序
 1.提醒、资金账户、账本、成员
 2.信用卡、用户收支类别、借贷
 3.周期记账
 4.用户流水
 5.成员流水
 
 
 (5)                  member_charge
                        /      \
                       v        \
 (4)              user_charge    \
                     /   \        \
                    /     \        \
                   v       \        \
 (3)       period_charge    \        \
               /   \         \        \
              /     \         \        \
             v       v         v        \
 (2)      credit  user_bill   loan       \
           / \        |        / \        \
          /   \       |       /   \        \
         v     v      v      v     v        v
 (1)   fund  remind books  fund   remind   member

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
