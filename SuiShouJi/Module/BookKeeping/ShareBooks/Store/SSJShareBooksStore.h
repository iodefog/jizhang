//
//  SSJShareBooksStore.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJShareBookItem.h"
#import "SSJShareBookMemberItem.h"

@interface SSJShareBooksStore : NSObject


+ (void)queryTheMemberListForTheShareBooks:(SSJShareBookItem *)booksItem
                                   Success:(void(^)(NSArray <SSJShareBookMemberItem *>* result))success
                                   failure:(void (^)(NSError *error))failure;

+ (void)kickOutMembersWithWithShareCharge:(NSArray *)shareChargeArray
                              shareMember:(NSArray *)shareMemberArray
                                  Success:(void(^)())success
                                  failure:(void (^)(NSError *error))failure;

@end
