//
//  SSJShareBookMemberItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJShareBookMemberItem : SSJBaseItem

// 成员id(userid)
@property(nonatomic, copy) NSString *memberId;

// 账本id
@property(nonatomic, copy) NSString *booksId;

// 加入时间
@property(nonatomic, copy) NSString *joinDate;

// 加入状态(1为加入,0为退出)
@property(nonatomic) BOOL state;

@end
