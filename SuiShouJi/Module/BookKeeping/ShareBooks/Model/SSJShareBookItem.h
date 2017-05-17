//
//  SSJShareBookItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJShareBookItem : SSJBaseCellItem

// 账本id
@property(nonatomic, copy) NSString *booksId;

// 创建者id(userid)
@property(nonatomic, copy) NSString *creatorId;

// 管理员id(userid)
@property(nonatomic, copy) NSString *adminId;

// 账本名称
@property(nonatomic, copy) NSString *booksName;

// 账本顺序
@property(nonatomic, assign) NSInteger booksOrder;

// 账本颜色
@property(nonatomic, copy) NSString *booksColor;

// 账本父类型
@property(nonatomic) NSInteger parentType;


@end
