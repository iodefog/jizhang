//
//  SSJReportFormsCurveGridView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJReportFormsCurveGridView;

@protocol SSJReportFormsCurveGridViewDataSource <NSObject>

- (NSUInteger)numberOfHorizontalLineInGridView:(SSJReportFormsCurveGridView *)gridView;

- (CGFloat)gridView:(SSJReportFormsCurveGridView *)gridView headerSpaceOnHorizontalLineAtIndex:(NSUInteger)index;

- (nullable NSString *)gridView:(SSJReportFormsCurveGridView *)gridView titleAtIndex:(NSUInteger)index;

@optional
//- (UIColor *)gridView:(SSJReportFormsCurveGridView *)gridView titleColorAtIndex:(NSUInteger)index;
//
//- (UIColor *)gridView:(SSJReportFormsCurveGridView *)gridView horizontalLineColorAtIndex:(NSUInteger)index;

@end

@interface SSJReportFormsCurveGridView : UIView

@property (nonatomic, weak) id <SSJReportFormsCurveGridViewDataSource> dataSource;

/**
 默认systemFontOfSize:12
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 默认grayColor
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 默认grayColor
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 默认1
 */
@property (nonatomic) CGFloat lineWith;

/**
 重载数据
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
