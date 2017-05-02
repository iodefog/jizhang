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

@property (nonatomic, readonly) NSUInteger asixCount;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic) BOOL scaleMarkShowed;

@property (nonatomic, strong) UIColor *scaleColor;

@property (nonatomic, strong) UIColor *selectedScaleColor;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) UIColor *bottomLineColor;

/**
 底部角标的位置，取值范围[0~1]，默认0.5
 */
@property (nonatomic) CGFloat subscriptPosition;

- (void)reloadData;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end
