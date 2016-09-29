//
//  SSJChargeSearchingStore.h
//  SuiShouJi
//
//  Created by ricky on 16/9/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJSearchResultItem.h"
#import "SSJSearchHistoryItem.h"

@interface SSJChargeSearchingStore : NSObject

typedef NS_ENUM(NSInteger, SSJChargeListOrder) {
    SSJChargeListOrderMoneyAscending,   //按金额升序
    SSJChargeListOrderMoneyDescending,  //按金额降序
    SSJChargeListOrderDateAscending,    //按日期升序
    SSJChargeListOrderDateDescending    //按日期降序
};

+ (void)searchForChargeListWithSearchContent:(NSString *)content
                                   ListOrder:(SSJChargeListOrder)order
                                     Success:(void(^)(NSArray <SSJSearchResultItem *>*result))success
                                     failure:(void (^)(NSError *error))failure;

+ (void)querySearchHistoryWithSuccess:(void(^)(NSArray <SSJSearchHistoryItem *>*result))success
                              failure:(void (^)(NSError *error))failure;

+ (BOOL)deleteSearchHistoryItem:(SSJSearchHistoryItem *)item error:(NSError **)error;
@end
