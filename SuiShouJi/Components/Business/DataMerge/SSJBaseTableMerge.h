//
//  SSJBaseTableMerge.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

// 提示,如果有新表要合并,请在base中统一添加头文件

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>
#import "SSJUserChargeTable.h"
#import "SSJMembereChargeTable.h"
#import "SSJBooksTypeTable.h"
#import "SSJChargePeriodConfigTable.h"
#import "SSJUserRemindTable.h"
#import "SSJUserCreditTable.h"
#import "SSJLoanTable.h"
#import "SSJFundInfoTable.h"


@interface SSJBaseTableMerge : NSObject


typedef NS_ENUM(NSInteger, SSJMergeDataType) {
    SSJMergeDataTypeByWriteDate,           //  按照修改日期合并
    SSJMergeDataTypeByWriteBillDate        //  按照记账日期合并
};


/**
 表名

 @return 表的名称
 */
+ (NSString *)tableName;



/**
 在要合并的表中查出所有需要合并的数据

 @param sourceUserid 合并数据的来源的userid
 @param targetUserId 合并数据的目标的userid
 @param mergeType 合并数据的方式(已billid或者以writedate)
 @param fromDate 合并开始的时间
 @param toDate 合并结束的时间
 @param db 数据库
 @return 字典中有两个值(@"error":为错误,@"results"是查询出来的结果)
 */
+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                   mergeType:(SSJMergeDataType)mergeType
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(WCTDatabase *)db;


/**
 查询出所有同名的对应的id

 @param sourceUserid 合并数据的来源的userid
 @param targetUserId 合并数据的目标的userid
 @param datas 查出要合并的数据,见上一个方法
 @param db 数据库
 @return 字典中以老的id为key,合并的目标用户中的id为value
 */
+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db;


/**
 更新每个表所关联的表

 @param sourceUserid 合并数据的来源的userid
 @param targetUserId 合并数据的目标的userid
 @param datas 上一个方法所产生的字典
 @param db 数据库
 @return (BOOL)是否合并成功
 */
+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db;

@end
