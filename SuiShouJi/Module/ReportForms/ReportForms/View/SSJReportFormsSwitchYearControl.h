//
//  SSJReportFormsSwitchYearControl.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsSwitchYearControl;

@interface SSJReportFormsSwitchYearControl : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, readonly, strong) UIButton *preBtn;

@property (nonatomic, readonly, strong) UIButton *nextBtn;

@end
