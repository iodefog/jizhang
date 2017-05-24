//
//  SSJArrayAddition.m
//  MoneyMore
//
//  Created by old lang on 15-3-25.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJArrayAddition.h"

@implementation NSArray (SSJCategory)

- (id)ssj_objectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.count > indexPath.section) {
        NSArray *subArray = self[indexPath.section];
        if ([subArray isKindOfClass:[NSArray class]]) {
            if (subArray.count > indexPath.row) {
                return subArray[indexPath.row];
            }
        }
    }
    return nil;
}

- (id)ssj_safeObjectAtIndex:(NSUInteger)index {
    if (self.count <= index) {
        SSJPRINT(@"<<< 警告：数组越界 >>>");
        return nil;
    }
    return [self objectAtIndex:index];
}

@end

@implementation NSMutableArray (SSJCategory)

- (void)ssj_removeFirstObject {
    if (self.count > 0) {
        [self removeObjectAtIndex:0];
    }
}

@end

@implementation NSArray (SSJAutoLayout)

- (void)ssj_distributeViewsAlongAxis:(SSJAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength {
    MAS_VIEW *superView = [self ssj_commonSuperviewOfViews];
    switch (axisType) {
        case SSJAxisTypeHorizontal:
            for (int i = 0; i < self.count; i ++) {
                MAS_VIEW *v = self[i];
                [v mas_remakeConstraints:^(MASConstraintMaker *make) {
                    CGFloat multiplier = (i + 1) / (CGFloat)(self.count + 1);
                    CGFloat offset = fixedItemLength * (i - (CGFloat)self.count) / ((CGFloat)self.count + 1);
                    make.left.mas_equalTo(superView.mas_right).multipliedBy(multiplier).offset(offset);
                    make.width.mas_equalTo(fixedItemLength);
                }];
            }
            break;
            
        case SSJAxisTypeVertical:
            
            break;
    }
}

- (MAS_VIEW *)ssj_commonSuperviewOfViews
{
    MAS_VIEW *commonSuperview = nil;
    MAS_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[MAS_VIEW class]]) {
            MAS_VIEW *view = (MAS_VIEW *)object;
            if (previousView) {
                commonSuperview = [view mas_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end

