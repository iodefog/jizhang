//
//  SSJReportFormsPeriodSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/1/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSJReportFormsPeriodType) {
    SSJReportFormsPeriodTypeMonth,
    SSJReportFormsPeriodTypeYear
};

@class SSJReportFormsPeriodSelectionView;

typedef void(^SSJReportFormsPeriodSelectionViewBlock)(SSJReportFormsPeriodSelectionView *view, SSJReportFormsPeriodType periodType);

@interface SSJReportFormsPeriodSelectionView : UIView

@property (nonatomic, copy) SSJReportFormsPeriodSelectionViewBlock selectionHandler;

@property (nonatomic, readonly) SSJReportFormsPeriodType periodType;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (BOOL)isShowed;

@end

NS_ASSUME_NONNULL_END