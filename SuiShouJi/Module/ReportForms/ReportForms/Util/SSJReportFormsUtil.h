//
//  SSJReportFormsUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJReportFormsItem.h"

typedef NS_ENUM(NSUInteger, SSJReportFormsIncomeOrPayType) {
    SSJReportFormsIncomeOrPayTypeUnknown,
    SSJReportFormsIncomeOrPayTypeIncome,
    SSJReportFormsIncomeOrPayTypePay,
    SSJReportFormsIncomeOrPayTypeSurplus
};

@interface SSJReportFormsUtil : NSObject

+ (NSArray *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inYear:(NSString *)year;

+ (NSArray *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inMonth:(NSString *)month;

@end