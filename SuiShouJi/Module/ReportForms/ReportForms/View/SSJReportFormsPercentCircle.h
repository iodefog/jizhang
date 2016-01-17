//
//  SSJReportFormsPercentCircle.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormsPercentCircleItem.h"

@class SSJReportFormsPercentCircle;

@protocol SSJReportFormsPercentCircleDataSource <NSObject>

- (NSUInteger)numberOfComponentsInPercentCircle:(SSJReportFormsPercentCircle *)circle;

- (SSJReportFormsPercentCircleItem *)percentCircle:(SSJReportFormsPercentCircle *)circle itemForComponentAtIndex:(NSUInteger)index;

@end

@interface SSJReportFormsPercentCircle : UIView

- (instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets thickness:(CGFloat)thickness;

@property (nonatomic, readonly) UIEdgeInsets circleInsets;

@property (nonatomic, readonly) CGFloat circleThickness;

@property (nonatomic, weak) id <SSJReportFormsPercentCircleDataSource> dataSource;

- (void)reloadData;

@end
