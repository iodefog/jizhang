//
//  SSJShareBooksMemberStore.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJUserItem.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsItem.h"

@interface SSJShareBooksMemberStore : NSObject

+ (void)queryMemberItemWithMemberId:(NSString *)memberId
                            booksId:(NSString *)booksId
                            Success:(void(^)(SSJUserItem * memberItem))success
                            failure:(void(^)(NSError *error))failure;


+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                     memberId:(NSString *)memberId
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *periods))success
                                      failure:(void (^)(NSError *))failure;


+ (void)queryForIncomeOrPayType:(SSJBillType)type
                        booksId:(NSString *)booksId
                       memberId:(NSString *)memberId
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure;


+ (void)saveNickNameWithNickName:(NSString *)name
                        memberId:(NSString *)memberId
                         booksid:(NSString *)booksid
                         success:(void (^)(NSString * name))success
                         failure:(void (^)(NSError *error))failure ;

@end
