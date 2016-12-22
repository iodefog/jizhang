//
//  SSJReportFormsCurveCellItem.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveCellItem.h"

@implementation SSJReportFormsCurveCellItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"title":_title ?: [NSNull null],
                                                        @"titleFont":_titleFont ?: [NSNull null],
                                                        @"titleColor":_titleColor ?: [NSNull null],
                                                        @"scaleColor":_scaleColor ?: [NSNull null],
                                                        @"scaleTop":@(_scaleTop),
                                                        @"curveItems":[_curveItems debugDescription]}];
}

@end
