//
//  SSJPercentCircleAdditionGroupNode.h
//  SuiShouJi
//
//  Created by old lang on 16/2/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJPercentCircleAdditionNode.h"

@interface SSJPercentCircleAdditionGroupNode : UIView

+ (instancetype)node;

- (void)setItems:(NSArray<SSJPercentCircleAdditionNodeItem *> *)items completion:(void (^)(void))completion;

- (void)cleanUpAdditionNodes;

@end
