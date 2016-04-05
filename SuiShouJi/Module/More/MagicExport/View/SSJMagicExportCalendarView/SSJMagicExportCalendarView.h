//
//  SSJMagicExportCalendarView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SSJMagicExportCalendarView : UIView

@property (nonatomic, strong) NSDate *selectedBeginDate;

@property (nonatomic, strong) NSDate *selectedEndDate;

- (instancetype)initWithFrame:(CGRect)frame startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
