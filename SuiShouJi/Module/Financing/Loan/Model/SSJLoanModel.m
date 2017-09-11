//
//  SSJLoanModel.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanModel.h"
#import "FMDB.h"
#import "SSJLoanHelper.h"

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
             @"interestType",
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
             @"interestType":@"interesttype",
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
    model.interestType = [resultSet intForColumn:@"interesttype"];
    model.closeOut = [resultSet boolForColumn:@"iend"];
    model.type = [resultSet intForColumn:@"itype"];
    model.operatorType = [resultSet intForColumn:@"operatorType"];
    model.version = [resultSet longLongIntForColumn:@"iversion"];
    model.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    return model;
}

- (BOOL)caculateMoneyInDatabase:(FMDatabase *)db error:(NSError **)error {
    if (!self.ID.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"借贷ID不能为空"}];
        }
        return NO;
    }
    
    SSJLoanType loanType = SSJLoanTypeLend;
    NSArray *chargeModels = [SSJLoanHelper queryLoanChargeModeListWithLoanID:self.ID database:db error:error];
    
    for (SSJLoanCompoundChargeModel *model in chargeModels) {
        loanType = model.chargeModel.type;
        
        switch (model.chargeModel.chargeType) {
            case SSJLoanCompoundChargeTypeCreate:
                self.jMoney += model.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeBalanceIncrease:
                self.jMoney += model.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeBalanceDecrease:
                self.jMoney -= model.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeRepayment:
                if (!model.closeOut) {
                    self.jMoney -= model.chargeModel.money;
                }
                break;
                
            case SSJLoanCompoundChargeTypeAdd:
                self.jMoney += model.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeCloseOut:
            case SSJLoanCompoundChargeTypeInterest:
                break;
        }
    }
    
//    // 借入的话转出金额>转入金额即为正数；反之为负数
//    if (loanType == SSJLoanTypeBorrow) {
//        if (self.jMoney != 0) {
//            self.jMoney = -self.jMoney;
//        }
//    }
    
    return YES;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJLoanModel *model = [[SSJLoanModel alloc] init];
    model.ID = _ID;
    model.userID = _userID;
    model.lender = _lender;
    model.jMoney = _jMoney;
    model.fundID = _fundID;
    model.targetFundID = _targetFundID;
    model.endTargetFundID = _endTargetFundID;
    model.borrowDate = _borrowDate;
    model.repaymentDate = _repaymentDate;
    model.endDate = _endDate;
    model.rate = _rate;
    model.memo = _memo;
    model.remindID = _remindID;
    model.interest = _interest;
    model.closeOut = _closeOut;
    model.type = _type;
    model.interestType = _interestType;
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
                                                        @"borrowDate":(_borrowDate ?: [NSNull null]),
                                                        @"repaymentDate":(_repaymentDate ?: [NSNull null]),
                                                        @"enddate":(_endDate ?: [NSNull null]),
                                                        @"rate":@(_rate),
                                                        @"memo":(_memo ?: [NSNull null]),
                                                        @"remindID":(_remindID ?: [NSNull null]),
                                                        @"interest":@(_interest),
                                                        @"closeOut":@(_closeOut),
                                                        @"type":@(_type),
                                                        @"interestType":@(_interestType),
                                                        @"operatorType":@(_operatorType),
                                                        @"version":@(_version),
                                                        @"writeDate":(_writeDate ?: [NSNull null])}];
}

@end
