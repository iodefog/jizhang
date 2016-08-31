//
//  SSJBillModel.h
//  SuiShouJi
//
//  Created by old lang on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  收支类别模型

#import <Foundation/Foundation.h>

@interface SSJBillModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *userID;

//@property (nonatomic, copy) NSString *parentID;

//@property (nonatomic, copy) NSString *booksID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *color;

// 0:关闭 1:开启
@property (nonatomic) int state;

// 顺序
@property (nonatomic) int order;

// 0:收入 1:支出
@property (nonatomic) int type;

// 0:系统类别 1:自定义类别
@property (nonatomic) int custom;

// 操作类型 0:新建 1:修改 2:删除
@property (nonatomic) int operatorType;

@end
