//
//  SSJReportFormCurveCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@class SSJReportFormsCurveModel;

@interface SSJReportFormCurveCellItem : SSJBaseItem

@property (nonatomic, strong) NSArray<SSJReportFormsCurveModel *> *curveModels;

@property (nonatomic) SSJTimeDimension timeDimension;

@end
