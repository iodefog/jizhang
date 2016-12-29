//
//  SSJReportFormsScaleAxisView.h
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsScaleAxisView;

@protocol SSJReportFormsScaleAxisViewDelegate <NSObject>

@required
- (NSUInteger)numberOfAxisInScaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView;

- (NSString *)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView titleForAxisAtIndex:(NSUInteger)index;

- (CGFloat)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView heightForAxisAtIndex:(NSUInteger)index;

@optional
- (void)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView didSelectedScaleAxisAtIndex:(NSUInteger)index;

@end

@class SSJDatePeriod;

@interface SSJReportFormsScaleAxisView : UIView

@property (nonatomic, weak) id<SSJReportFormsScaleAxisViewDelegate> delegate;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, readonly) NSUInteger axisCount;

@property (nonatomic, strong) UIColor *scaleColor;

@property (nonatomic, strong) UIColor *selectedScaleColor;

- (void)reloadData;

@end
