//
//  SSJShareBookMemberItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJShareBookMemberItem : SSJBaseCellItem

// 成员id(userid)
@property(nonatomic, copy) NSString *memberId;

// 账本id
@property(nonatomic, copy) NSString *booksId;

// 账本管理员id
@property(nonatomic, copy) NSString *adminId;


// 用户头像
@property(nonatomic, copy) NSString *icon;

// 用户昵称
@property(nonatomic, copy) NSString *nickName;

// 加入时间
@property(nonatomic, copy) NSString *joinDate;

// 加入状态(1为加入,0为退出)
@property(nonatomic) BOOL state;

@end
