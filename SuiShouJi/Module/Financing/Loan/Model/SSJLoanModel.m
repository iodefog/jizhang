//
//  SSJLoanModel.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanModel.h"
#import "FMResultSet.h"

@implementation SSJLoanModel

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet {
    SSJLoanModel *model = [[SSJLoanModel alloc] init];
    model.ID = [resultSet stringForColumn:@"loanid"];
    model.userID = [resultSet stringForColumn:@"cuserid"];
    model.lender = [resultSet stringForColumn:@"lender"];
    model.jMoney = [resultSet stringForColumn:@"jmoney"];
    model.fundID = [resultSet stringForColumn:@"cthefundid"];
    model.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
    model.chargeID = [resultSet stringForColumn:@"cthecharge"];
    model.targetChargeID = [resultSet stringForColumn:@"ctargetcharge"];
    model.endChargeID = [resultSet stringForColumn:@"cethecharge"];
    model.endTargetChargeID = [resultSet stringForColumn:@"cetargetcharge"];
    model.borrowDate = [resultSet stringForColumn:@"cborrowdate"];
    model.repaymentDate = [resultSet stringForColumn:@"crepaymentdate"];
    model.endDate = [resultSet stringForColumn:@"cenddate"];
    model.rate = [resultSet stringForColumn:@"rate"];
    model.memo = [resultSet stringForColumn:@"memo"];
    model.remindID = [resultSet stringForColumn:@"cremindid"];
    model.interest = [resultSet boolForColumn:@"interest"];
    model.closeOut = [resultSet boolForColumn:@"iend"];
    model.type = [resultSet intForColumn:@"itype"];
    model.operatorType = [resultSet intForColumn:@"operatorType"];
    model.version = [resultSet longLongIntForColumn:@"iversion"];
    model.writeDate = [resultSet stringForColumn:@"cwritedate"];
    
    return model;
}

//+ (NSDictionary *)propertyMapping {
//    return @{@"ID":@"loanid",
//             @"userID":@"cuserid",
//             @"lender":@"lender",
//             @"jMoney":@"jmoney",
//             @"fundID":@"cthefundid",
//             @"targetFundID":@"ctargetfundid",
//             @"chargeID":@"cthecharge",
//             @"targetChargeID":@"ctargetcharge",
//             @"borrowDate":@"cborrowdate",
//             @"repaymentDate":@"crepaymentdate",
//             @"rate":@"rate",
//             @"memo":@"memo",
//             @"remindID":@"cremindid",
//             @"interest":@"interest",
//             @"closeOut":@"iend",
//             @"type":@"itype",
//             @"operatorType":@"operatortype",
//             @"version":@"iversion",
//             @"writeDate":@"cwriteDate"};
//}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", @{@"ID":(_ID ?: @""),
                                               @"userID":(_userID ?: @""),
                                               @"lender":(_lender ?: @""),
                                               @"jMoney":(_jMoney ?: @""),
                                               @"fundID":(_fundID ?: @""),
                                               @"targetFundID":(_targetFundID ?: @""),
                                               @"chargeID":(_chargeID ?: @""),
                                               @"targetChargeID":(_targetChargeID ?: @""),
                                               @"endChargeID":(_endChargeID ?: @""),
                                               @"endTargetChargeID":(_endTargetChargeID ?: @""),
                                               @"borrowDate":(_borrowDate ?: @""),
                                               @"repaymentDate":(_repaymentDate ?: @""),
                                               @"enddate":(_endDate ?: @""),
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
