//
//  SSJBooksTypeStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBooksTypeItem.h"

@interface SSJBooksTypeStore : NSObject
+ (void)queryForBooksListWithSuccess:(void(^)(NSMutableArray<SSJBooksTypeItem *> *result))success
                                 failure:(void (^)(NSError *error))failure;
@end
