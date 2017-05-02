//
//  SSJReportFormsNavigationBar.h
//  SuiShouJi
//
//  Created by old lang on 17/5/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSJReportFormsNavigationBarOption) {
    SSJReportFormsNavigationBarChart,
    SSJReportFormsNavigationBarCurve
};

@interface SSJReportFormsNavigationBar : UIView

@property (nonatomic) SSJReportFormsNavigationBarOption option;

@property (nonatomic, strong) UIImage *leftImage;

@property (nonatomic, copy) void (^clickBooksHandler)(SSJReportFormsNavigationBar *bar);

@property (nonatomic, copy) void (^switchChartAndCurveHandler)(SSJReportFormsNavigationBar *bar);

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
