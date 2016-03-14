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
//        SSJPRINT(@"<<< 警告：数组越界 >>>");
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