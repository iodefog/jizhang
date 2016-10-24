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
#import "SSJSearchResultSummaryItem.h"

@interface SSJChargeSearchingStore : NSObject

+ (void)searchForChargeListWithSearchContent:(NSString *)content
                                   ListOrder:(SSJChargeListOrder)order
                                     Success:(void(^)(NSArray <SSJSearchResultItem *>*result , SSJSearchResultSummaryItem *sumItem))success
                                     failure:(void (^)(NSError *error))failure;

+ (void)querySearchHistoryWithSuccess:(void(^)(NSArray <SSJSearchHistoryItem *>*result))success
                              failure:(void (^)(NSError *error))failure;

+ (BOOL)deleteSearchHistoryItem:(SSJSearchHistoryItem *)item error:(NSError **)error;

+ (BOOL)clearAllSearchHistoryWitherror:(NSError **)error;
@end
