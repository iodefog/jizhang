//
//  SSJCalendarTabelViewHeaderView.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalendarTabelViewHeaderView : UITableViewHeaderFooterView

@property(nonatomic) double income;

@property(nonatomic) double expence;

@property(nonatomic) double balance;

@property(nonatomic, strong) NSString *currentDateStr;

@end
