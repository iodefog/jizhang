//
//  SSJLoanModel.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanModel.h"

@implementation SSJLoanModel

+ (NSDictionary *)propertyMapping {
    return @{@"ID":@"loanid",
             @"userID":@"cuserid",
             @"lender":@"lender",
             @"jMoney":@"jmoney",
             @"fundID":@"cthefundid",
             @"targetFundID":@"ctargetfundid",
             @"borrowDate":@"cborrowdate",
             @"repaymentDate":@"crepaymentdate",
             @"rate":@"rate",
             @"memo":@"memo",
             @"remindID":@"cremindid",
             @"interest":@"interest",
             @"closeOut":@"iend",
             @"type":@"itype",
             @"operatorType":@"operatortype",
             @"version":@"iversion",
             @"writeDate":@"cwriteDate"};
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", @{@"ID":(_ID ?: @""),
                                               @"userID":(_userID ?: @""),
                                               @"lender":(_lender ?: @""),
                                               @"jMoney":(_jMoney ?: @""),
                                               @"fundID":(_fundID ?: @""),
                                               @"targetFundID":(_targetFundID ?: @""),
                                               @"borrowDate":(_borrowDate ?: @""),
                                               @"repaymentDate":(_repaymentDate ?: @""),
                                               @"rate":(_rate ?: @""),
                                               @"memo":(_memo ?: @""),
                                               @"remindID":(_remindID ?: @""),
                                               @"interest":@(_interest),
                                               @"closeOut":@(_closeOut),
                                               @"type":@(_type),
                                               @"operatorType":@(_operatorType),
                                               @"version":@(_version),
                                               @"writeDate":(_writeDate ?: @"")}];
}

@end
