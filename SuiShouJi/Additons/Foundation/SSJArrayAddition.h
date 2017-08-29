//
//  SSJArrayAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-25.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SSJCategory)

- (id)ssj_objectAtIndexPath:(NSIndexPath *)indexPath;

//  安全返回数组元素
- (id)ssj_safeObjectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (SSJCategory)

- (void)ssj_safeRemoveObjectAtIndex:(NSUInteger)index;

- (void)ssj_removeFirstObject;

@end

typedef NS_ENUM(NSInteger, SSJAxisType) {
    SSJAxisTypeHorizontal,
    SSJAxisTypeVertical
};

@interface NSArray (SSJAutoLayout)

- (void)ssj_distributeViewsAlongAxis:(SSJAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength;

@end
