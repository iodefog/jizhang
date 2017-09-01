//
//  SSJShareBooksMemberSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberSyncTable.h"
#import "SSJShareBooksMemberKickedOutAlerter.h"
#import "SSJSyncTable.h"

@implementation SSJShareBooksMemberSyncTable

+ (NSString *)tableName {
    return @"bk_share_books_member";
}

- (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(SSJDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        FMResultSet *rs = [db executeQuery:@"select istate from bk_share_books_member where cmemberid = ? and cbooksid = ?", recordInfo[@"cmemberid"], recordInfo[@"cbooksid"]];
        if (!rs) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        BOOL existed = NO;
        SSJShareBooksMemberState localState = SSJShareBooksMemberStateNormal;
        while ([rs next]) {
            existed = YES;
            localState = [rs intForColumn:@"istate"];
        }
        [rs close];
        
        NSString *joinDateStr = recordInfo[@"cjoindate"];
        NSString *state = recordInfo[@"istate"];
        NSString *icon = recordInfo[@"cicon"];
        NSString *color = recordInfo[@"ccolor"];
        NSString *memberId = recordInfo[@"cmemberid"];
        NSString *booksId = recordInfo[@"cbooksid"];
        NSString *leaveDateStr = recordInfo[@"cleavedate"];

        if (existed) {
            // 如果本地记录的状态是为退出，后段返回的状态是被踢出，就记录下相应记录的信息，数据同步成功后根据记录的信息弹出提示框
            SSJShareBooksMemberState mergedState = [recordInfo[@"istate"] integerValue];
            if (localState == SSJShareBooksMemberStateNormal
                && mergedState == SSJShareBooksMemberStateKickedOut
                && [memberId isEqualToString:userId]) {
                NSDate *leaveDate = [NSDate dateWithString:leaveDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
                [[SSJShareBooksMemberKickedOutAlerter alerter] recordWithMemberId:memberId booksId:booksId date:leaveDate inDatabase:db error:error];
                if (*error) {
                    return NO;
                }
            }
            
            if (![db executeUpdate:@"update bk_share_books_member set cjoindate = ? ,istate = ? ,cicon = ?, ccolor = ?, cleavedate = ? where cbooksid = ? and cmemberid = ?", joinDateStr, state, icon, color, leaveDateStr, booksId, memberId]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"insert into bk_share_books_member (cjoindate, istate, cicon, ccolor, cleavedate, cbooksid, cmemberid) values (?, ?, ?, ?, ?, ?, ?)", joinDateStr, state, icon, color, leaveDateStr, booksId, memberId]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSMutableArray *syncRecords = [NSMutableArray array];
    return syncRecords;
}

- (BOOL)updateVersionOfRecordModifiedDuringSync:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        if (error) {
            *error = [db lastError];
        }
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    return [db executeUpdate:@"update bk_member_charge set iversion = ? where iversion = ? and cmemberid = ?", @(newVersion), @(version + 2), userId];
}

@end
