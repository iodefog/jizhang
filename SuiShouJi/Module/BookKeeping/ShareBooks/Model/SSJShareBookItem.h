//
//  SSJShareBookItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJShareBookItem : SSJBaseItem

// 账本id
@property(nonatomic, copy) NSString *booksId;

// 创建者id(userid)
@property(nonatomic, copy) NSString *creatorId;

// 管理员id(userid)
@property(nonatomic, copy) NSString *adminId;

// 账本名称
@property(nonatomic, copy) NSString *booksName;

// 账本颜色
@property(nonatomic, copy) NSString *booksColor;

// 账本夫类型
@property(nonatomic) NSInteger parentType;

@end
