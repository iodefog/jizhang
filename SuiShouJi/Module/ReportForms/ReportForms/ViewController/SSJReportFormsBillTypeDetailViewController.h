//
//  SSJReportFormsBillTypeDetailViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@class SSJDatePeriod;

@interface SSJReportFormsBillTypeDetailViewController : SSJBaseViewController

@property (nonatomic, strong) NSString *billTypeID;

@property (nonatomic, copy) SSJDatePeriod *customPeriod;

@property (nonatomic, copy) SSJDatePeriod *selectedPeriod;

@end
