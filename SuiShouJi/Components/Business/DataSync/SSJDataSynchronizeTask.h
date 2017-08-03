//
//  SSJDataSynchronizeTask.h
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJSynchronizeTask.h"

/**
 
 同步用户数据
 同步的顺序是从分支到主干，共5个层次，依照层次顺序合并，同一层次的表不用按照顺序合并，以下是合并的顺序
 1.提醒、账本、成员、收支类别（自定义）
 2.资金账户（包含信用卡）、用户收支类别、预算
 3.周期记账、借贷、周期转账
 4.用户流水
 5.成员流水
 
 
 (5)                        member_charge
                            /          \
                           v            \
 (4)                    user_charge      \
                        /         \       \
                       /           \       \
                      v             \       \
 (3)           period_charge        loan     \                             wish_charge
             (transfer_cycle)        |\       \                                 |
              /       \              | \       \                                |
             /         \             |  \       \                               |
            v           v            v   \       \                              V
 (2)  fund(credit) user_bill_type  fund   \       \            budget         wish
          |             |                  \       \            /  \            |
          |             |                   \       \          /    \           |
          v             v                    v       v        v      v          V
 (1)    remind        books                remind  member   books   remind    remind
 
 */
@interface SSJDataSynchronizeTask : SSJSynchronizeTask

@end

@interface SSJDataSynchronizeTask (Simulation)

/**
 模拟用户登录

 @param userId 模拟用户的id
 */
+ (void)simulateUserSync:(NSString *)userId;

@end
