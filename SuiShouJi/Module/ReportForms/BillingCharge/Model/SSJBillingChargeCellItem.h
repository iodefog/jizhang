//
//  SSJBillingChargeCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJBillingChargeCellItem : SSJBaseItem

// 图片名称
@property (nonatomic, copy) NSString *imageName;

// 收支类型名称
@property (nonatomic, copy) NSString *typeName;

// 收支金额
@property (nonatomic, copy) NSString *money;

// 颜色值
@property (nonatomic, copy) NSString *colorValue;

// 流水id
@property (nonatomic, copy) NSString *ID;

// 流水类型(1是支出,0是收入)
@property (nonatomic) BOOL incomeOrExpence;

// 流水时间
@property (nonatomic,strong) NSString *billDate;

// 资金帐户编号
@property (nonatomic,strong) NSString *fundId;

// 资金帐户名称
@property (nonatomic,strong) NSString *fundName;

// 资金帐户图片名称
@property (nonatomic,strong) NSString *fundImage;

// 资金帐户操作类型
@property (nonatomic) NSInteger fundOperatorType;

// 资金账户的父类
@property (nonatomic,strong) NSString *fundParent;

//记账编辑时间
@property (nonatomic,strong) NSString *editeDate;

//记账类型
@property (nonatomic,strong) NSString *billId;

//流水备注
@property (nonatomic,strong) NSString *chargeMemo;

//记账图片(大图)
@property (nonatomic,strong) NSString *chargeImage;

//记账图片(缩略图)
@property (nonatomic,strong) NSString *chargeThumbImage;

//循环记账配置ID
@property (nonatomic,strong) NSString *configId;

//账本id
@property(nonatomic, strong) NSString *booksId;

//账本名称
@property(nonatomic, strong) NSString *booksName;

//循环记账类型
@property (nonatomic) NSInteger chargeCircleType;

//循环记账结束时间
@property (nonatomic, strong) NSString *chargeCircleEndDate;

//循环记账类型开关(循环配置用,0是关闭,1是开启)
@property (nonatomic) BOOL isOnOrNot;

//记账的下标
@property(nonatomic) NSInteger chargeIndex;

//操作类型
@property(nonatomic) NSInteger operatorType;

@property(nonatomic, strong) NSString *transferSource;

// 成员id
@property(nonatomic, strong) NSMutableArray *membersItem;

// 新增的成员
@property(nonatomic, strong) NSArray *newlyAddMembers;

//删除的成员
@property(nonatomic, strong) NSArray *deletedMembers;

//流水对应的借贷id
@property(nonatomic, strong) NSString *loanId;

//客户端添加时间
@property(nonatomic, strong) NSString *clientAddDate;


@end
