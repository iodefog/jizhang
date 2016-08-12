//
//  SSJReportFormsMemberAndCategorySwitchControl.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SSJReportFormsMemberAndCategorySwitchControlOption) {
    SSJReportFormsMemberAndCategorySwitchControlOptionCategory = 0,
    SSJReportFormsMemberAndCategorySwitchControlOptionMember
};

@interface SSJReportFormsMemberAndCategorySwitchControl : UIControl

@property (nonatomic) SSJReportFormsMemberAndCategorySwitchControlOption option;

- (void)updateAppearance;

@end
