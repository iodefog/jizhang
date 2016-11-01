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

+ (NSArray *)mj_allowedPropertyNames {
    return @[@"ID",
             @"userID",
             @"lender",
             @"jMoney",
             @"fundID",
             @"targetFundID",
             @"endTargetFundID",
             @"borrowDate",
             @"repaymentDate",
             @"endDate",
             @"rate",
             @"memo",
             @"remindID",
             @"interest",
             @"closeOut",
             @"type",
             @"operatorType",
             @"version",
             @"writeDate"];
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"loanid",
             @"userID":@"cuserid",
             @"lender":@"lender",
             @"jMoney":@"jmoney",
             @"fundID":@"cthefundid",
             @"targetFundID":@"ctargetfundid",
             @"endTargetFundID":@"cetarget",
             @"borrowDate":@"cborrowdate",
             @"repaymentDate":@"crepaymentdate",
             @"endDate":@"cenddate",
             @"rate":@"rate",
             @"memo":@"memo",
             @"remindID":@"cremindid",
             @"interest":@"interest",
             @"closeOut":@"iend",
             @"type":@"itype",
             @"operatorType":@"operatortype",
             @"version":@"iversion",
             @"writeDate":@"cwritedate"};
}

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet {
    SSJLoanModel *model = [[SSJLoanModel alloc] init];
    model.ID = [resultSet stringForColumn:@"loanid"];
    model.userID = [resultSet stringForColumn:@"cuserid"];
    model.lender = [resultSet stringForColumn:@"lender"];
    model.image = [resultSet stringForColumn:@"cicoin"];
    model.jMoney = [resultSet doubleForColumn:@"jmoney"];
    model.fundID = [resultSet stringForColumn:@"cthefundid"];
    model.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
    model.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
    model.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
    model.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
    model.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
    model.rate = [resultSet doubleForColumn:@"rate"];
    model.memo = [resultSet stringForColumn:@"memo"];
    model.remindID = [resultSet stringForColumn:@"cremindid"];
    model.interest = [resultSet boolForColumn:@"interest"];
    model.closeOut = [resultSet boolForColumn:@"iend"];
    model.type = [resultSet intForColumn:@"itype"];
    model.operatorType = [resultSet intForColumn:@"operatorType"];
    model.version = [resultSet longLongIntForColumn:@"iversion"];
    model.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    return model;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJLoanModel *model = [[SSJLoanModel alloc] init];
    model.ID = _ID;
    model.userID = _userID;
    model.lender = _lender;
    model.jMoney = _jMoney;
    model.fundID = _fundID;
    model.targetFundID = _targetFundID;
    model.chargeID = _chargeID;
    model.targetChargeID = _targetChargeID;
    model.endTargetFundID = _endTargetFundID;
    model.endChargeID = _endChargeID;
    model.endTargetChargeID = _endTargetChargeID;
    model.interestChargeID = _interestChargeID;
    model.borrowDate = _borrowDate;
    model.repaymentDate = _repaymentDate;
    model.endDate = _endDate;
    model.rate = _rate;
    model.memo = _memo;
    model.remindID = _remindID;
    model.interest = _interest;
    model.closeOut = _closeOut;
    model.type = _type;
    model.operatorType = _operatorType;
    model.version = _version;
    model.writeDate = _writeDate;
    
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"ID":(_ID ?: [NSNull null]),
                                                        @"userID":(_userID ?: [NSNull null]),
                                                        @"lender":(_lender ?: [NSNull null]),
                                                        @"jMoney":@(_jMoney),
                                                        @"fundID":(_fundID ?:[NSNull null]),
                                                        @"targetFundID":(_targetFundID ?: [NSNull null]),
                                                        @"endTargetFundID":(_endTargetFundID ?: [NSNull null]),
                                                        @"chargeID":(_chargeID ?: [NSNull null]),
                                                        @"targetChargeID":(_targetChargeID ?: [NSNull null]),
                                                        @"endChargeID":(_endChargeID ?: [NSNull null]),
                                                        @"endTargetChargeID":(_endTargetChargeID ?: [NSNull null]),
                                                        @"interestChargeID":(_interestChargeID ?: [NSNull null]),
                                                        @"borrowDate":(_borrowDate ?: [NSNull null]),
                                                        @"repaymentDate":(_repaymentDate ?: [NSNull null]),
                                                        @"enddate":(_endDate ?: [NSNull null]),
                                                        @"rate":@(_rate),
                                                        @"memo":(_memo ?: [NSNull null]),
                                                        @"remindID":(_remindID ?: [NSNull null]),
                                                        @"interest":@(_interest),
                                                        @"closeOut":@(_closeOut),
                                                        @"type":@(_type),
                                                        @"operatorType":@(_operatorType),
                                                        @"version":@(_version),
                                                        @"writeDate":(_writeDate ?: [NSNull null])}];
}

@end
