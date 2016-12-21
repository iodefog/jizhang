//
//  SSJReportFormsCurveCellItem.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJReportFormsCurveViewItem;

@interface SSJReportFormsCurveCellItem : NSObject

@property (nonatomic, strong) NSArray<SSJReportFormsCurveViewItem *> *curveItems;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) UIFont *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *scaleColor;

@property (nonatomic, assign) CGFloat scaleTop;

@end
