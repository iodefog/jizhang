//
//  SSJReportFormsMemberAndCategorySwitchControl.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  类别、成员切换控件

#import <UIKit/UIKit.h>
#import "SSJListMenu.h"

typedef NS_ENUM(NSUInteger, SSJReportFormsMemberAndCategorySwitchControlOption) {
    SSJReportFormsMemberAndCategorySwitchControlOptionCategory = 0,
    SSJReportFormsMemberAndCategorySwitchControlOptionMember
};

@interface SSJReportFormsMemberAndCategorySwitchControl : UIControl

@property (nonatomic) SSJReportFormsMemberAndCategorySwitchControlOption option;

@property (nonatomic, strong, readonly) SSJListMenu *listMenu;

- (void)updateAppearance;

@end
