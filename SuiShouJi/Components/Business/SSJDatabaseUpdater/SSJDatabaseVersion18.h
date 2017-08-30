//
//  SSJDatabaseVersion18.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJDatabaseVersionProtocol.h"

@class SSJLoanChargeModel;

@interface SSJDatabaseVersion18 : NSObject <SSJDatabaseVersionProtocol>

/**
 修改借贷流水的cid，cid拼接格式：借贷项目id_idx；idx从1开始

 @param models 存储借贷流水模型的数组
 @param db 数据库对象
 @param error 错误描述对象
 @return 是否修改成功
 */
+ (BOOL)updateLoanChargesWithModels:(NSArray<SSJLoanChargeModel *> *)models
                           database:(FMDatabase *)db
                              error:(NSError **)error;

@end
