//
//  SSJPercentCircleAdditionGroupNode.m
//  SuiShouJi
//
//  Created by old lang on 16/2/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleAdditionGroupNode.h"

@interface SSJPercentCircleAdditionGroupNode ()

@property (nonatomic, strong) NSMutableArray *additionNodes;

@end

@implementation SSJPercentCircleAdditionGroupNode

+ (instancetype)node {
    SSJPercentCircleAdditionGroupNode *node = [[SSJPercentCircleAdditionGroupNode alloc] init];
    return node;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.additionNodes = [NSMutableArray array];
    }
    return self;
}

- (void)setItems:(NSArray *)items completion:(void (^)(void))completion {
    [self.additionNodes makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.additionNodes removeAllObjects];
    
    if (items.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    for (int idx = 0; idx < items.count; idx ++) {
        SSJPercentCircleAdditionNodeItem *item = items[idx];
        SSJPercentCircleAdditionNode *additionNode = [[SSJPercentCircleAdditionNode alloc] initWithItem:item];
        SSJPercentCircleAdditionNode *lastAdditionNode = [self.additionNodes lastObject];
        if (lastAdditionNode) {
            if ([additionNode testOverlap:lastAdditionNode]) {
                [self addSubview:additionNode];
                [self.additionNodes addObject:additionNode];
            }
        } else {
            [self addSubview:additionNode];
            [self.additionNodes addObject:additionNode];
        }
        
        [additionNode beginDrawWithCompletion:^{
            if (idx == items.count - 1) {
                if (completion) {
                    completion();
                }
            }
        }];
    }
}

- (void)cleanUpAdditionNodes {
    [self.additionNodes makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.additionNodes removeAllObjects];
}

@end
