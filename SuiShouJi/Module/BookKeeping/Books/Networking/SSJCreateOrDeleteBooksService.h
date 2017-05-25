//
//  SSJCreateOrDeleteBooksService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJShareBookItem;
//0正常   1退出　２移除
typedef enum : NSUInteger {
    SSJMemberStateNormal,
    SSJMemberStateQuit,
    SSJMemberStateRemove,
} SSJMemberState;

@interface SSJCreateOrDeleteBooksService : SSJBaseNetworkService
- (void)createShareBookWithBookItem:(SSJShareBookItem *)bookItem;

- (void)deleteShareBookWithBookId:(NSString *)bookId memberId:(NSString *)memberId memberState:(SSJMemberState)memberState;
@end
