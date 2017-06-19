//
//  SSJReportFormsCurveView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

@class SSJReportFormsCurveViewItem;

@interface SSJReportFormsCurveView : UIView

@property (nonatomic, strong) SSJReportFormsCurveViewItem *item;

@end

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

@interface SSJReportFormsCurveViewItem : NSObject

@property (nonatomic) BOOL showCurve;

@property (nonatomic) CGPoint startPoint;

@property (nonatomic) CGPoint endPoint;

@property (nonatomic) CGFloat curveWidth;

@property (nonatomic, strong) UIColor *curveColor;

@property (nonatomic) BOOL showShadow;

@property (nonatomic) CGFloat shadowWidth;

@property (nonatomic) CGSize shadowOffset;

@property (nonatomic) CGFloat shadowAlpha;



@property (nonatomic) BOOL showValue;

@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong) UIColor *valueColor;

@property (nonatomic, strong) UIFont *valueFont;



@property (nonatomic) BOOL showDot;

@property (nonatomic, strong) UIColor *dotColor;

@property (nonatomic) CGFloat dotAlpha;

- (BOOL)isCurveInfoEqualToItem:(SSJReportFormsCurveViewItem *)item;

- (void)testOverlapPreItem:(SSJReportFormsCurveViewItem *)preItem space:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
