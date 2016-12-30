//
//  SSJReportFormsCurveCellItem.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveViewItem.h"

@implementation SSJReportFormsCurveViewItem

- (BOOL)isCurveInfoEqualToItem:(SSJReportFormsCurveViewItem *)item {
    return (CGColorEqualToColor(_curveColor.CGColor, item.curveColor.CGColor)
            && CGPointEqualToPoint(_startPoint, item.startPoint)
            && CGPointEqualToPoint(_endPoint, item.endPoint)
            && CGSizeEqualToSize(_shadowOffset, item.shadowOffset)
            && _showCurve == item.showCurve
            && _showShadow == item.showShadow
            && _shadowWidth == item.shadowWidth
            && _shadowAlpha == item.shadowAlpha
            && _curveWidth == item.curveWidth);
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"showCurve":@(_showCurve),
                                                        @"startPoint":NSStringFromCGPoint(_startPoint),
                                                        @"endPoint":NSStringFromCGPoint(_endPoint),
                                                        @"curveWidth":@(_curveWidth),
                                                        @"curveColor":_curveColor ?: [NSNull null],
                                                        @"showShadow":@(_showShadow),
                                                        @"shadowWidth":@(_shadowWidth),
                                                        @"shadowOffset":NSStringFromCGSize(_shadowOffset),
                                                        @"shadowAlpha":@(_shadowAlpha),
                                                        @"showValue":@(_showValue),
                                                        @"value":_value ?: [NSNull null],
                                                        @"valueColor":_valueColor ?: [NSNull null],
                                                        @"valueFont":_valueFont ?: [NSNull null],
                                                        @"showDot":@(_showDot),
                                                        @"dotColor":_dotColor ?: [NSNull null],
                                                        @"dotAlpha":@(_dotAlpha)}];
}

@end
