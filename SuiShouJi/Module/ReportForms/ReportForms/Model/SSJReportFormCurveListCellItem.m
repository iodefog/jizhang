//
//  SSJReportFormCurveListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveListCellItem.h"

@implementation SSJReportFormCurveListCellItem

- (instancetype)init {
    if (self = [super init]) {
        self.rowHeight = 90;
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"leftTitle1":_leftTitle1 ?: [NSNull null],
                                                        @"leftTitle2":_leftTitle2 ?: [NSNull null],
                                                        @"rightTitle":_rightTitle ?: [NSNull null],
                                                        @"progressColorValue":_progressColorValue ?: [NSNull null],
                                                        @"scale":@(_scale),
                                                        @"billTypeId":_billTypeId ?: [NSNull null]}];
}

@end
