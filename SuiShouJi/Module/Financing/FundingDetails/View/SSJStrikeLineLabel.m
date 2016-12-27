//
//  SSJStrikeLineLabel.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStrikeLineLabel.h"

@implementation SSJStrikeLineLabel

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1);  //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 204.0 / 255.0, 204.0 / 255.0, 204.0 / 255.0, 1.0);  //线的颜色
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 0, 0);  //起点坐标
    CGContextAddLineToPoint(context, self.width, self.height);   //终点坐标
    
    CGContextStrokePath(context);
}

@end
