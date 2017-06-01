//
//  SSJCreateOrDeleteBooksService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJShareBookItem;

@interface SSJCreateOrDeleteBooksService : SSJBaseNetworkService

/**bookId*/
@property (nonatomic, copy) NSDictionary *shareBookDic;

/**<#注释#>*/
@property (nonatomic, copy) NSArray *shareChargeArray;

/**<#注释#>*/
@property (nonatomic, copy) NSArray *shareMemberArray;

/**<#注释#>*/
@property (nonatomic, copy) NSArray *shareFriendsMarkArray;

- (void)createShareBookWithBookItem:(SSJShareBookItem *)bookItem;

- (void)deleteShareBookWithBookId:(NSString *)bookId memberId:(NSString *)memberId memberState:(SSJShareBooksMemberState)memberState;
@end
