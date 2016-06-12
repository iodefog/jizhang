//
//  SSJReportFormsCurveGraphView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsCurveGraphView;

@protocol SSJReportFormsCurveGraphViewDelegate <NSObject>

- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView;

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index;

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index;

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index;

- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index;

@end

@interface SSJReportFormsCurveGraphView : UIView

@property (nonatomic, weak) id<SSJReportFormsCurveGraphViewDelegate> delegate;

// default 7
@property (nonatomic) CGFloat displayAxisXCount;

// default 0.3
@property (nonatomic) CGFloat bezierSmoothingTension;

- (void)reloadData;

- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted;

@end
