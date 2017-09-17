//
//  SSJPercentCircleNode.h
//  SuiShouJi
//
//  Created by old lang on 16/2/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJPercentCircleNode : UIView

+ (instancetype)node;

@property (nonatomic) CGPoint centerPoint;

@property (nonatomic) CGFloat radius;

@property (nonatomic) CGFloat thickness;

@property (nonatomic) CGFloat startAngle;

- (void)setItems:(NSArray *)items completion:(void (^)(void))completion;

@end


@interface SSJPercentCircleNodeItem : NSObject

@property (nonatomic) CGFloat startAngle;

@property (nonatomic) CGFloat endAngle;

@property (nonatomic, strong) UIColor *color;

@end
