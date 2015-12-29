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

@property (nonatomic) UIEdgeInsets circleInsets;

@property (nonatomic) CGFloat circleWidth;

@property (nonatomic, weak) id <SSJReportFormsPercentCircleDataSource> dataSource;

- (void)reloadData;

@end
