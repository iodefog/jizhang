//
//  SSJPercentCircleNode.h
//  SuiShouJi
//
//  Created by old lang on 16/2/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJPercentCircleNodeItem.h"

@interface SSJPercentCircleNode : UIView

+ (instancetype)nodeWithCenter:(CGPoint)center radius:(CGFloat)radius lineWith:(CGFloat)lineWith;

- (void)setItems:(NSArray *)items completion:(void (^)(void))completion;

@end
