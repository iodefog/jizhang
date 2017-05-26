//
//  SSJShareBooksMemberSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberSyncTable.h"

@implementation SSJShareBooksMemberSyncTable

+ (NSString *)tableName {
    return @"bk_share_books_member";
}

+ (NSArray *)columns {
    return @[@"cmemberid",
             @"cbooksid",
             @"cjoindate",
             @"istate",
             @"cicon"];
}

+ (NSArray *)primaryKeys {
    return @[@"cmemberid",@"cbooksid"];
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        BOOL exist = [db boolForQuery:@"select count(*) from bk_share_books_member where cmemberid = ? and cbooksid = ?", recordInfo[@"cmemberid"], recordInfo[@"cbooksid"]];

        
        if (exist) {
            if (![db executeUpdate:@"update bk_share_books_member set cjoindate = ? ,istate = ? ,cicon = ? where cbooksid = ? and cmemberid = ?", recordInfo[@"cjoindate"], recordInfo[@"istate"], recordInfo[@"cicon"], recordInfo[@"cbooksid"], recordInfo[@"cmemberid"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"inset into bk_share_books_member (cjoindate,istate,cicon,cbooksid,cmemberid) values (?,?,?,?,?)", recordInfo[@"cjoindate"], recordInfo[@"istate"], recordInfo[@"cicon"], recordInfo[@"cbooksid"], recordInfo[@"cmemberid"]]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }
    
    return YES;
}
@end
