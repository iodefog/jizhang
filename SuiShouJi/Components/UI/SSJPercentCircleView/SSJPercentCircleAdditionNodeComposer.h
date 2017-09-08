//
//  SSJPercentCircleAdditionNodeComposer.h
//  SSJPieChartDemo
//
//  Created by old lang on 2017/9/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJPercentCircleAdditionNodeItem;

typedef struct {
    CGFloat top;
    CGFloat bottom;
} SSJAxisYRange;

SSJAxisYRange SSJAxisYRangeMake(CGFloat top, CGFloat bottom);

@interface SSJPercentCircleAdditionNodeComposer : NSObject

@property (nonatomic) CGRect circleFrame;

@property (nonatomic) SSJAxisYRange range;

+ (instancetype)composer;

- (void)clearItems;

- (void)addNodeItem:(SSJPercentCircleAdditionNodeItem *)item;

- (NSArray<SSJPercentCircleAdditionNodeItem *> *)composeNodeItems;

@end
