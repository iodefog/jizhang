//
//  SSJPercentCircleAdditionNodeComposer.m
//  SSJPieChartDemo
//
//  Created by old lang on 2017/9/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleAdditionNodeComposer.h"
#import "SSJPercentCircleAdditionNode.h"
#import <objc/runtime.h>

SSJAxisYRange SSJAxisYRangeMake(CGFloat top, CGFloat bottom) {
    SSJAxisYRange range;
    range.top = top;
    range.bottom = bottom;
    return range;
}

@interface SSJPercentCircleAdditionNodeItem (SSJPrivate)

@property (nonatomic) CGSize textSize;

- (CGFloat)textTop;

- (CGFloat)textBottom;

@end

static const void *kNodeTextSizeKey = &kNodeTextSizeKey;

@implementation SSJPercentCircleAdditionNodeItem (SSJPrivate)

- (void)setTextSize:(CGSize)textSize {
    objc_setAssociatedObject(self, kNodeTextSizeKey, [NSValue valueWithCGSize:textSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)textSize {
    return [objc_getAssociatedObject(self, kNodeTextSizeKey) CGSizeValue];
}

- (CGFloat)textTop {
    return self.endPoint.y - self.textSize.height * 0.5;
}

- (CGFloat)textBottom {
    return self.endPoint.y + self.textSize.height * 0.5;
}

@end

@interface SSJPercentCircleAdditionNodeComposer ()

@property (nonatomic, strong) NSMutableArray *leftItems;

@property (nonatomic, strong) NSMutableArray *rightItems;

@property (nonatomic, strong) SSJPercentCircleAdditionNodeItem *topItem;

@property (nonatomic, strong) SSJPercentCircleAdditionNodeItem *bottomItem;

@end

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

- (void)setRange:(SSJAxisYRange)range {
    _range = range;
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
    if ([[self.leftItems lastObject] textTop] < self.range.top) {
        __block SSJPercentCircleAdditionNodeItem *preItem = nil;
        [self.leftItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SSJPercentCircleAdditionNodeItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == self.leftItems.count - 1) {
                CGFloat y = self.range.top + item.textSize.height * 0.5;
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
    if ([firstItem textBottom] > self.range.bottom) {
        CGFloat offset = ([firstItem textBottom] - self.range.bottom) * 0.5;
        for (SSJPercentCircleAdditionNodeItem *item in self.leftItems) {
            CGFloat y = item.endPoint.y - offset;
            item.breakPoint = CGPointMake(item.breakPoint.x, y);
            item.endPoint = CGPointMake(item.endPoint.x, y);
        }
    }
    
    // 调整X轴位置
    for (SSJPercentCircleAdditionNodeItem *item in self.leftItems) {
        if (item.breakPoint.y < CGRectGetMinY(self.circleFrame)
            || item.breakPoint.y > CGRectGetMaxY(self.circleFrame)) {
            continue;
        }
        
        CGFloat side = pow(CGRectGetWidth(self.circleFrame) * 0.5, 2) - pow((item.breakPoint.y - CGRectGetMidY(self.circleFrame)), 2);
        CGFloat breakPointX = CGRectGetMidX(self.circleFrame) - sqrt(side) - 5;
        if (item.breakPoint.x > breakPointX) {
            CGFloat offset = item.breakPoint.x - breakPointX;
            item.breakPoint = CGPointMake(item.breakPoint.x - offset, item.breakPoint.y);
            item.endPoint = CGPointMake(item.endPoint.x - offset, item.endPoint.y);
        }
    }
}

- (void)composeRightNodeItems {
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
    if ([[self.rightItems lastObject] textBottom] > self.range.bottom) {
        __block SSJPercentCircleAdditionNodeItem *lastItem = nil;
        [self.rightItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SSJPercentCircleAdditionNodeItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == self.rightItems.count - 1) {
                CGFloat y = self.range.bottom - item.textSize.height * 0.5;
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
    if ([firstItem textTop] < self.range.top) {
        CGFloat offset = (self.range.top - [firstItem textTop]) * 0.5;
        for (SSJPercentCircleAdditionNodeItem *item in self.rightItems) {
            CGFloat y = item.endPoint.y + offset;
            item.breakPoint = CGPointMake(item.breakPoint.x, y);
            item.endPoint = CGPointMake(item.endPoint.x, y);
        }
    }
    
    // 调整X轴位置
    for (SSJPercentCircleAdditionNodeItem *item in self.rightItems) {
        if (item.breakPoint.y < CGRectGetMinY(self.circleFrame)
            || item.breakPoint.y > CGRectGetMaxY(self.circleFrame)) {
            continue;
        }
        
        CGFloat side = pow(CGRectGetWidth(self.circleFrame) * 0.5, 2) - pow((item.breakPoint.y - CGRectGetMidY(self.circleFrame)), 2);
        CGFloat breakPointX = sqrt(side) + CGRectGetMidX(self.circleFrame) + 5;
        if (item.breakPoint.x < breakPointX) {
            CGFloat offset = breakPointX - item.breakPoint.x;
            item.breakPoint = CGPointMake(item.breakPoint.x + offset, item.breakPoint.y);
            item.endPoint = CGPointMake(item.endPoint.x + offset, item.endPoint.y);
        }
    }
}


@end
