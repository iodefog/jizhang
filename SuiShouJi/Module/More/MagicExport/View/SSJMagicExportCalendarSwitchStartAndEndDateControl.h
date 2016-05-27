//
//  SSJMagicExportCalendarSwitchStartAndEndDateControl.h
//  SuiShouJi
//
//  Created by old lang on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportCalendarSwitchStartAndEndDateControl : UIView

@property (nonatomic, copy) NSString *beginDate;

@property (nonatomic, copy) NSString *endDate;

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, copy) BOOL(^shouldSelectAction)(NSInteger index);

@property (nonatomic, copy) void(^didSelectAction)(NSInteger index);

@end
