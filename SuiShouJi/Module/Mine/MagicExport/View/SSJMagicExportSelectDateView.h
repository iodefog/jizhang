//
//  SSJMagicExportSelectDateView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportSelectDateView : UIView

@property (nonatomic, strong) NSDate *beginDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, copy) void (^beginDateAction)(void);

@property (nonatomic, copy) void (^endDateAction)(void);

@end
