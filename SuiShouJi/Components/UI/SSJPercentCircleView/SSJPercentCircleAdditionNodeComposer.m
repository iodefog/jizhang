//
//  SSJPercentCircleAdditionNodeComposer.m
//  SSJPieChartDemo
//
//  Created by old lang on 2017/9/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleAdditionNodeComposer.h"
#import "SSJPercentCircleAdditionNode.h"

@interface SSJPercentCircleAdditionNodeComposer ()

@property (nonatomic, strong) NSMutableArray *leftItems;

@property (nonatomic, strong) NSMutableArray *rightItems;

@property (nonatomic, strong) SSJPercentCircleAdditionNodeItem *topItem;

@property (nonatomic, strong) SSJPercentCircleAdditionNodeItem *bottomItem;

@end

const CGFloat kBreakPointSpaceX = 5;

@implementation SSJPercentCircleAdditionNodeComposer

+ (instancetype)composer {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.leftItems = [NSMutableArray array];
        self.rightItems = [NSMutableArray array];
    }
    return self;
}

- (void)clearItems {
    [self.leftItems removeAllObjects];
    [self.rightItems removeAllObjects];
    self.topItem = nil;
    self.bottomItem = nil;
}

- (void)addNodeItem:(SSJPercentCircleAdditionNodeItem *)item {
    switch (item.range) {
        case SSJRadianRangeTop:
            self.topItem = item;
            break;
            
        case SSJRadianRangeRight:
            [self.rightItems addObject:item];
            break;
            
        case SSJRadianRangeBottom:
            self.bottomItem = item;
            break;
            
        case SSJRadianRangeLeft:
            [self.leftItems addObject:item];
            break;
    }
}

- (NSArray *)composeNodeItems {
    [self composeLeftNodeItems];
    [self composeRightNodeItems];
    
    NSMutableArray *items = [NSMutableArray array];
    if (self.topItem) {
        [items addObject:_topItem];
    }
    
    [items addObjectsFromArray:self.rightItems];
    
    if (self.bottomItem) {
        [items addObject:self.bottomItem];
    }
    
    [items addObjectsFromArray:self.leftItems];
    
    return [items copy];
}

- (void)composeLeftNodeItems {
    // 按照从Y轴大到小对元素进行降序排序
    [self.leftItems sortUsingComparator:^NSComparisonResult(SSJPercentCircleAdditionNodeItem *obj1, SSJPercentCircleAdditionNodeItem *obj2) {
        if (obj1.endPoint.y > obj2.endPoint.y) {
            return NSOrderedAscending;
        } else if (obj1.endPoint.y < obj2.endPoint.y) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    // 检测是否有重叠的节点，有的话依次排开
    SSJPercentCircleAdditionNodeItem *preItem = nil;
    for (SSJPercentCircleAdditionNodeItem *item in self.leftItems) {
        item.textSize = [item.text sizeWithAttributes:@{NSFontAttributeName:item.font}];
        if (preItem) {
            if ([item textBottom] > [preItem textTop]) {
                CGFloat y = [preItem textTop] - item.textSize.height * 0.5;
                item.breakPoint = CGPointMake(item.breakPoint.x, y);
                item.endPoint = CGPointMake(item.endPoint.x, y);
            }
        }
        preItem = item;
    }
    
    // 如果最后一个节点超过顶部界限，反向遍历所有节点，将节点下移
    if ([[self.leftItems lastObject] textTop] < CGRectGetMinY(self.boundary)) {
        __block SSJPercentCircleAdditionNodeItem *preItem = nil;
        [self.leftItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SSJPercentCircleAdditionNodeItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == self.leftItems.count - 1) {
                CGFloat y = CGRectGetMinY(self.boundary) + item.textSize.height * 0.5;
                item.breakPoint = CGPointMake(item.breakPoint.x, y);
                item.endPoint = CGPointMake(item.endPoint.x, y);
            } else {
                if ([item textTop] < [preItem textBottom]) {
                    CGFloat y = [preItem textBottom] + item.textSize.height * 0.5;
                    item.breakPoint = CGPointMake(item.breakPoint.x, y);
                    item.endPoint = CGPointMake(item.endPoint.x, y);
                } else {
                    *stop = YES;
                }
            }
            preItem = item;
        }];
    }
    
    // 如果第一个节点超过底部界限，将所有节点整体上移
    SSJPercentCircleAdditionNodeItem *firstItem = [self.leftItems firstObject];
    if ([firstItem textBottom] > CGRectGetMaxY(self.boundary)) {
        CGFloat offset = ([firstItem textBottom] - CGRectGetMaxY(self.boundary)) * 0.5;
        for (SSJPercentCircleAdditionNodeItem *item in self.leftItems) {
            CGFloat y = item.endPoint.y - offset;
            item.breakPoint = CGPointMake(item.breakPoint.x, y);
            item.endPoint = CGPointMake(item.endPoint.x, y);
        }
    }
    
    // 调整X轴位置
    for (SSJPercentCircleAdditionNodeItem *item in self.leftItems) {
        if (item.breakPoint.y + item.textSize.height * 0.5 < CGRectGetMinY(self.circleFrame)
            || item.breakPoint.y - item.textSize.height * 0.5 > CGRectGetMaxY(self.circleFrame)) {
            continue;
        }
        
        CGFloat point_2 = [self caculateIntersectionTopBottomPoint:item];
        
        if (item.endPoint.x > point_2 - kBreakPointSpaceX) {
            item.endPoint = CGPointMake(point_2 - kBreakPointSpaceX, item.endPoint.y);
        }
        
        if (item.endPoint.x - item.textSize.width < CGRectGetMinX(self.boundary)) {
            CGFloat endPointX = CGRectGetMinX(self.boundary) + item.textSize.width;
            item.endPoint = CGPointMake(endPointX, item.endPoint.y);
        }
        
        if (item.endPoint.x > point_2) {
            item.endPoint = CGPointMake(point_2, item.endPoint.y);
            item.textSize = CGSizeMake(point_2 - CGRectGetMinX(self.boundary), item.textSize.height);
        }
        
        CGFloat point_1 = [self caculateIntersectionCenterYPoint:item];
        if (item.breakPoint.x >= point_1 || item.breakPoint.x < item.endPoint.x) {
            CGFloat breakX = (point_1 - point_2) * 0.5 + point_2;
            item.breakPoint = CGPointMake(breakX, item.breakPoint.y);
        }
    }
}

- (void)composeRightNodeItems {
    // 按照Y轴从小到大对元素进行升序排序
    [self.rightItems sortUsingComparator:^NSComparisonResult(SSJPercentCircleAdditionNodeItem *obj1, SSJPercentCircleAdditionNodeItem *obj2) {
        if (obj1.endPoint.y > obj2.endPoint.y) {
            return NSOrderedDescending;
        } else if (obj1.endPoint.y < obj2.endPoint.y) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    // 检测是否有重叠的节点，有的话依次排开
    SSJPercentCircleAdditionNodeItem *lastItem = nil;
    for (SSJPercentCircleAdditionNodeItem *item in self.rightItems) {
        item.textSize = [item.text sizeWithAttributes:@{NSFontAttributeName:item.font}];
        if (lastItem) {
            if ([item textTop] < [lastItem textBottom]) {
                CGFloat y = [lastItem textBottom] + item.textSize.height * 0.5;
                item.breakPoint = CGPointMake(item.breakPoint.x, y);
                item.endPoint = CGPointMake(item.endPoint.x, y);
            }
        }
        lastItem = item;
    }
    
    // 如果最后一个节点超过底部界限，反向遍历所有节点，将节点上移
    if ([[self.rightItems lastObject] textBottom] > CGRectGetMaxY(self.boundary)) {
        __block SSJPercentCircleAdditionNodeItem *lastItem = nil;
        [self.rightItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SSJPercentCircleAdditionNodeItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == self.rightItems.count - 1) {
                CGFloat y = CGRectGetMaxY(self.boundary) - item.textSize.height * 0.5;
                item.breakPoint = CGPointMake(item.breakPoint.x, y);
                item.endPoint = CGPointMake(item.endPoint.x, y);
            } else {
                if ([item textBottom] > [lastItem textTop]) {
                    CGFloat y = [lastItem textTop] - item.textSize.height * 0.5;
                    item.breakPoint = CGPointMake(item.breakPoint.x, y);
                    item.endPoint = CGPointMake(item.endPoint.x, y);
                } else {
                    *stop = YES;
                }
            }
            lastItem = item;
        }];
    }
    
    // 如果第一个节点超过顶部界限，将所有节点整体下移
    SSJPercentCircleAdditionNodeItem *firstItem = [self.rightItems firstObject];
    if ([firstItem textTop] < CGRectGetMinY(self.boundary)) {
        CGFloat offset = (CGRectGetMinY(self.boundary) - [firstItem textTop]) * 0.5;
        for (SSJPercentCircleAdditionNodeItem *item in self.rightItems) {
            CGFloat y = item.endPoint.y + offset;
            item.breakPoint = CGPointMake(item.breakPoint.x, y);
            item.endPoint = CGPointMake(item.endPoint.x, y);
        }
    }
    
    // 调整X轴位置
    for (SSJPercentCircleAdditionNodeItem *item in self.rightItems) {
        if (item.breakPoint.y + item.textSize.height * 0.5 < CGRectGetMinY(self.circleFrame)
            || item.breakPoint.y - item.textSize.height * 0.5 > CGRectGetMaxY(self.circleFrame)) {
            continue;
        }
        
        CGFloat point_2 = [self caculateIntersectionTopBottomPoint:item];
        
        if (item.endPoint.x < point_2 + kBreakPointSpaceX) {
            item.endPoint = CGPointMake(point_2 + kBreakPointSpaceX, item.endPoint.y);
        }
        
        if (item.endPoint.x + item.textSize.width > CGRectGetMaxX(self.boundary)) {
            CGFloat left = CGRectGetMaxX(self.boundary) - item.textSize.width;
            item.endPoint = CGPointMake(left, item.endPoint.y);
        }
        
        if (item.endPoint.x < point_2) {
            item.endPoint = CGPointMake(point_2, item.endPoint.y);
            item.textSize = CGSizeMake(CGRectGetMaxX(self.boundary) - point_2, item.textSize.height);
        }
        
        CGFloat point_1 = [self caculateIntersectionCenterYPoint:item];
        if (item.breakPoint.x <= point_1 || item.breakPoint.x > item.endPoint.x) {
            CGFloat breakX = (item.endPoint.x - point_1) * 0.5 + point_1;
            item.breakPoint = CGPointMake(breakX, item.breakPoint.y);
        }
    }
}

// 计算文本Y轴中间点与圆环交接的X轴位置
- (CGFloat)caculateIntersectionCenterYPoint:(SSJPercentCircleAdditionNodeItem *)item {
    CGFloat centerY = CGRectGetMidY(self.circleFrame);
    CGFloat verticalSide = item.breakPoint.y - centerY;
    CGFloat sideLength = sqrt(pow(CGRectGetWidth(self.circleFrame) * 0.5, 2) - pow(verticalSide, 2));
    
    CGFloat centerX = CGRectGetMidX(self.circleFrame);
    if (item.breakPoint.x <= centerX) {
        // 左半圆
        return centerX - sideLength;
    } else {
        // 右半圆
        return centerX + sideLength;
    }
}

// 计算文本上／下边与圆环交接的X轴位置
- (CGFloat)caculateIntersectionTopBottomPoint:(SSJPercentCircleAdditionNodeItem *)item {
    CGFloat centerY = CGRectGetMidY(self.circleFrame);
    CGFloat verticalSide = 0;
    if (item.breakPoint.y < centerY) {
        // 上半圆
        verticalSide = centerY - item.breakPoint.y - item.textSize.height * 0.5;
    } else if (item.breakPoint.y > centerY) {
        // 下半圆
        verticalSide = item.breakPoint.y - centerY - item.textSize.height * 0.5;
    } else {
        verticalSide = 0;
    }
    
    CGFloat radius = CGRectGetWidth(self.circleFrame) * 0.5;
    CGFloat sideLength = sqrt(pow(radius, 2) - pow(verticalSide, 2));
    
    CGFloat centerX = CGRectGetMidX(self.circleFrame);
    if (item.breakPoint.x <= centerX) {
        // 左半圆
        return centerX - sideLength;
    } else {
        // 右半圆
        return centerX + sideLength;
    }
}


@end
