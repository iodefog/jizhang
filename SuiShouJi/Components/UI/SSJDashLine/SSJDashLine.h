//
//  SSJDashLine.h
//  SuiShouJi
//
//  Created by old lang on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJDashLine : UIView

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@property (nonatomic) CGPoint startPoint;

@property (nonatomic) CGPoint endPoint;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic) CGFloat lineWidth;

@end
