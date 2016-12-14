//
//  SSJReportFormsPercentCircle.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJPercentCircleViewItem.h"

@class SSJPercentCircleView;

@protocol SSJReportFormsPercentCircleDataSource <NSObject>

- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle;

- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index;

@end

@interface SSJPercentCircleView : UIView

- (instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets thickness:(CGFloat)thickness;

@property (nonatomic, readonly) UIEdgeInsets circleInsets;

@property (nonatomic, readonly) CGFloat circleThickness;

@property (nonatomic) CGFloat gapBetweenTitles;

@property (nonatomic, copy) NSString *topTitle;

@property (nonatomic, copy) NSString *bottomTitle;

@property (nonatomic, strong) NSDictionary *topTitleAttribute;

@property (nonatomic, strong) NSDictionary *bottomTitleAttribute;

@property (nonatomic, weak) id <SSJReportFormsPercentCircleDataSource> dataSource;

- (void)reloadData;

@end
