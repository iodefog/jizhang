//
//  SSJUserDefaultDataCreater.m
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultDataCreater.h"
#import "SSJFundInfoModel.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultDataCreater

+ (void)createFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    //  判断当前userid有没有创建过默认资金帐户
    NSString *key = @"SSJIsFundAccountsCreateKey";
    NSDictionary *userFundAccountInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    if (userFundAccountInfo[SSJUSERID()]) {
        success();
        return;
    }
    
    //  创建默认的资金帐户
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME, CICOIN , CPARENT , CCOLOR , CADDDATE , CWRITEDATE , OPERATORTYPE , IVERSION , CMEMO , CUSERID) VALUES (?,?,?,?,?,?,?,?,?,?,?)", SSJUUID() , @"现金账户" , @"" , @"1" , @"#fe8a65" , [NSString stringWithFormat:@"%@",[NSDate date]] , @"", [NSNumber numberWithInt:0] , @"" , @"",SSJUSERID()];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CICOIN=(SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '1') WHERE CACCTNAME = '现金账户'"];
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME, CICOIN , CPARENT , CCOLOR , CADDDATE , CWRITEDATE , OPERATORTYPE , IVERSION , CMEMO , CUSERID) VALUES (?,?,?,?,?,?,?,?,?,?,?)", SSJUUID() , @"储蓄卡余额" , @"" , @"2" , @"#ffb944" , [NSString stringWithFormat:@"%@",[NSDate date]] , @"", [NSNumber numberWithInt:0] , @"" , @"" , SSJUSERID()];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CICOIN=(SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '2') WHERE CACCTNAME = '储蓄卡余额'"];
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME, CICOIN , CPARENT , CCOLOR , CADDDATE , CWRITEDATE , OPERATORTYPE , IVERSION , CMEMO , CUSERID) VALUES (?,?,?,?,?,?,?,?,?,?,?)", SSJUUID() , @"信用卡透支" , @"" , @"3" , @"#8dc4fa" , [NSString stringWithFormat:@"%@",[NSDate date]] , @"", [NSNumber numberWithInt:0] , @"" , @""];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CICOIN=(SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '3') WHERE CACCTNAME = '信用卡透支'"];
        [db executeUpdate:@"INSERT INTO BK_FUND_INFO (CFUNDID , CACCTNAME, CICOIN , CPARENT , CCOLOR , CADDDATE , CWRITEDATE , OPERATORTYPE , IVERSION , CMEMO , CUSERID) VALUES (?,?,?,?,?,?,?,?,?,?,?)", SSJUUID() , @"支付宝余额" , @"" , @"7" , @"#ffb944" , [NSString stringWithFormat:@"%@",[NSDate date]] , @"", [NSNumber numberWithInt:0] , @"" , @"" ,SSJUSERID()];
        [db executeUpdate:@"UPDATE BK_FUND_INFO SET CICOIN=(SELECT CICOIN FROM BK_FUND_INFO WHERE CFUNDID= '7') WHERE CACCTNAME = '支付宝余额'"];
        [db executeUpdate:@"INSERT INTO BK_FUNS_ACCT (CFUNDID , CUSERID , IBALANCE) SELECT CFUNDID , ? , ? FROM BK_FUND_INFO WHERE CPARENT <> 'root'",SSJUSERID(),[NSNumber numberWithDouble:0.00]];
        
        //  标记当前userid创建过默认资金帐户
        NSMutableDictionary *newUserFundAcctInfo = [userFundAccountInfo mutableCopy];
        [newUserFundAcctInfo setObject:@(YES) forKey:SSJUSERID()];
        [[NSUserDefaults standardUserDefaults] setObject:newUserFundAcctInfo forKey:key];
        
        success();
    }];
}

+ (void)createBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result1 = [db executeQuery:@"select count(*) from BK_BILL_TYPE"];
        FMResultSet *result2 = [db executeQuery:@"select count(*) from BK_USER_BILL where CUSERID = ?", SSJUSERID()];
        
        if (result1 && result2) {
            [result1 next];
            [result2 next];
            
            if ([result1 intForColumnIndex:0] <= [result2 intForColumnIndex:0]) {
                success();
                return;
            }
        }
        
        FMResultSet *billTypeResult = [db executeQuery:@"select id, istate from BK_BILL_TYPE"];
        if (billTypeResult) {
            while ([billTypeResult next]) {
//                [db]
            }
        }
//        [db executeUpdate:@"insert into BK_USER_BILL (CUSERID, CBILLID, ISTATE, CWRITEDATE, IVERSION, OPERATORTYPE) select ?, ID, ISTATE, ?, ?, 0 from BK_BILL_TYPE", SSJUSERID(), [[NSDate date] ssj_systemCurrentDateWithFormat:@""], ];
    }];
}

+ (void)createSyncRecordIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
}

//+ (NSInteger)lastSyncVersion {
//    
//}

@end
