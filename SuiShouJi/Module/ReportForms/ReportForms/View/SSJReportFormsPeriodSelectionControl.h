//
//  SSJReportFormsPeriodSelectionControl.h
//  SuiShouJi
//
//  Created by old lang on 17/3/23.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJDatePeriod;
@class SSJReportFormsPeriodSelectionControl;

typedef void(^SSJReportFormsPeriodSelectionControlHandler)(SSJReportFormsPeriodSelectionControl *);

@interface SSJReportFormsPeriodSelectionControl : UIView

@property (nonatomic, strong) NSArray<SSJDatePeriod *> *periods;

@property (nonatomic, strong) SSJDatePeriod *selectedPeriod;

@property (nonatomic, strong, nullable) SSJDatePeriod *customPeriod;

@property (nonatomic, strong, readonly) SSJDatePeriod *currentPeriod;

@property (nonatomic, copy) SSJReportFormsPeriodSelectionControlHandler periodChangeHandler;

@property (nonatomic, copy) SSJReportFormsPeriodSelectionControlHandler addCustomPeriodHandler;

@property (nonatomic, copy) SSJReportFormsPeriodSelectionControlHandler clearCustomPeriodHandler;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
