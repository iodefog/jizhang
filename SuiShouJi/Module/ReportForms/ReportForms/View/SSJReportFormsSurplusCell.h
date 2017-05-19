//
//  SSJReportFormsSurplusCell.h
//  SuiShouJi
//
//  Created by old lang on 17/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJReportFormsSurplusCell : SSJBaseTableViewCell

@end

@interface SSJReportFormsSurplusCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *title;

@property (nonatomic) double income;

@property (nonatomic) double payment;

@end
