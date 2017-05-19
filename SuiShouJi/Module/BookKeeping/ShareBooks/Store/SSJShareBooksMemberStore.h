//
//  SSJShareBooksMemberStore.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJUserItem.h"

@interface SSJShareBooksMemberStore : NSObject

+ (void)queryMemberItemWithMemberId:(NSString *)memberId
                            booksId:(NSString *)booksId
                            Success:(void(^)(SSJUserItem * memberItem))success
                            failure:(void (^)(NSError *error))failure;

@end
