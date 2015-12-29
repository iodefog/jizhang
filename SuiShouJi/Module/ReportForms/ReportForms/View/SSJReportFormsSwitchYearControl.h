//
//  SSJReportFormsSwitchYearControl.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsSwitchYearControl;

typedef void(^SSJReportFormsSwitchYearControlAction)(SSJReportFormsSwitchYearControl *switchYearControl);

@interface SSJReportFormsSwitchYearControl : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) SSJReportFormsSwitchYearControlAction preAction;

@property (nonatomic, copy) SSJReportFormsSwitchYearControlAction nextAction;

@end
