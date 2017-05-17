//
//  SSJBooksTypeItem.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJBooksTypeItem : SSJBaseItem

//账本id
@property(nonatomic, strong) NSString *booksId;

//账本名称
@property(nonatomic, strong) NSString *booksName;

//账本颜色
@property(nonatomic, strong) NSString *booksColor;

//账本图标
@property(nonatomic, strong) NSString *booksIcoin;

//账本顺序
@property(nonatomic) int booksOrder;

//账本父类
@property(nonatomic) NSInteger booksParent;

@property(nonatomic, strong) NSString *userId;

@property(nonatomic, strong) NSString *cwriteDate;

@property(nonatomic) NSInteger operatorType;

@property(nonatomic) BOOL editeModel;

+ (NSDictionary *)propertyMapping;

@end
