//
//  SSJShareBookItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJBooksItem.h"

@interface SSJShareBookItem : SSJBaseCellItem <SSJBooksItemProtocol>

// 创建者id(userid)
@property(nonatomic, copy) NSString *creatorId;

// 管理员id(userid)
@property(nonatomic, copy) NSString *adminId;

// 管理员名称
@property(nonatomic, copy) NSString *adminName;

/**是否编辑中*/
@property (nonatomic, assign, getter = isEditing) BOOL editing;

/**成员人数*/
@property (nonatomic, assign) NSInteger memberCount;


+ (NSDictionary *)propertyMapping;
@end
