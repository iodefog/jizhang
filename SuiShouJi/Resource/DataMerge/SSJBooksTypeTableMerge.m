//
//  SSJAccountTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeTableMerge.h"
#import "FMDB.h"

@implementation SSJBooksTypeTableMerge

+ (NSString *)tableName {
    return @"bk_books_type";
}

+ (NSArray *)columns {
    return @[@"cbooksid",
             @"cuserid",
             @"cbooksname",
             @"cbookscolor",
             @"cwritedate",
             @"operatortype",
             @"iparenttype",
             @"iversion",
             @"iorder",
             @"cicoin"];
}

+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(FMDatabase *)db {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    
    return dict;
}
@end
