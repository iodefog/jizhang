//
//  SSJReportFormsPercentCircleLayer.h
//  SuiShouJi
//
//  Created by old lang on 15/12/30.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SSJReportFormsPercentCircleLayer : CALayer

@property (nonatomic) CGFloat thickness;

@property (nonatomic) CGFloat angle;

@property (nonatomic, strong) UIColor *fillColor;

- (void)setAngle:(CGFloat)angle
        animated:(BOOL)animated
        duration:(NSTimeInterval)duration
    finishHandle:(void (^)(void))finishHandle;

@end
