//
//  SSJShareBookItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJFinancingGradientColorItem.h"
@interface SSJShareBookItem : SSJBaseCellItem

// 账本id
@property(nonatomic, copy) NSString *booksId;

// 创建者id(userid)
@property(nonatomic, copy) NSString *creatorId;

// 管理员id(userid)
@property(nonatomic, copy) NSString *adminId;

// 管理员名称
@property(nonatomic, copy) NSString *adminName;

// 账本名称
@property(nonatomic, copy) NSString *booksName;

// 账本顺序
@property(nonatomic, assign) NSInteger booksOrder;

// 账本颜色
@property(nonatomic, copy) SSJFinancingGradientColorItem *booksColor;

// 账本父类型
@property(nonatomic) NSInteger parentType;

/**是否编辑中*/
@property (nonatomic, assign, getter = isEditing) BOOL editing;

/**成员人数*/
@property (nonatomic, assign) NSInteger memberCount;

/**是否是共享账本*/
//@property (nonatomic, assign, getter = isShareBook) BOOL shareBook;
+ (NSDictionary *)propertyMapping;
@end
