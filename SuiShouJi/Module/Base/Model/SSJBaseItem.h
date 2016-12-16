//
//  SSJBaseItem.h
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBaseItem : NSObject <NSCopying>

//  工厂初始化方法，初始化同时会调用parseElement:解析数据
+ (instancetype)itemWithElement:(id)element;

//  标准初始化方法，初始化同时会调用parseElement:解析数据
- (instancetype)initWithElement:(id)element;

//  解析数据，element可以为空
- (void)parseElement:(id)element;

/**
 返回对应cell的行高
 */
@property (nonatomic) CGFloat rowHeight;

@end
