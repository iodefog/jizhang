//
//  SSJReportFormCurveHeaderViewItem.h
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJReportFormsCurveModel;

@interface SSJReportFormCurveHeaderViewItem : NSObject

@property (nonatomic, strong) NSArray<SSJReportFormsCurveModel *> *curveModels;

@property (nonatomic) SSJTimeDimension timeDimension;

@property (nonatomic, copy) NSString *generalIncome;

@property (nonatomic, copy) NSString *generalPayment;

@property (nonatomic, copy) NSString *dailyCost;

- (BOOL)isEqualToItem:(SSJReportFormCurveHeaderViewItem *)item;

@end
