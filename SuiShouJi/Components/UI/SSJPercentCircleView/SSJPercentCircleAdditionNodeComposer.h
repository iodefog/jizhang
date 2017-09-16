//
//  SSJPercentCircleAdditionNodeComposer.h
//  SSJPieChartDemo
//
//  Created by old lang on 2017/9/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJPercentCircleAdditionNodeItem;

@interface SSJPercentCircleAdditionNodeComposer : NSObject

@property (nonatomic) CGRect circleFrame;

@property (nonatomic) CGRect boundary;

+ (instancetype)composer;

- (void)clearItems;

- (void)addNodeItem:(SSJPercentCircleAdditionNodeItem *)item;

- (NSArray<SSJPercentCircleAdditionNodeItem *> *)composeNodeItems;

@end
