//
//  SSJReportFormsCurveView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveView : UIView

@property (nonatomic, strong) NSArray *paymentValues;

@property (nonatomic, strong) NSArray *incomeValues;

@property (nonatomic) CGFloat maxValue;

@property (nonatomic) CGFloat bezierSmoothingTension;

@property (nonatomic) UIEdgeInsets contentInsets;

@end
