//
//  SSJReportFormsPercentCircleAdditionView.h
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormsPercentCircleAdditionViewItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJReportFormsPercentCircleAdditionView : UIView

@property (nonatomic, readonly, strong) SSJReportFormsPercentCircleAdditionViewItem *item;

- (instancetype)initWithItem:(SSJReportFormsPercentCircleAdditionViewItem *)item;

- (BOOL)testOverlap:(SSJReportFormsPercentCircleAdditionView *)view;

- (void)beginDraw;
    
@end

NS_ASSUME_NONNULL_END